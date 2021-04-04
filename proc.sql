----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S FUNCTIONS

-- F12
CREATE FUNCTION func_name (...)
CREATE FUNCTION helper_function_1 (...)
CREATE FUNCTION helper_function_2 (...)

-- F14
CREATE FUNCTION func_name (...)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS

-- F8
CREATE OR REPLACE FUNCTION find_rooms (_sess_date DATE, _start_time TIMESTAMP, _duration INT)
RETURNS TABLE(room_id INT) AS $$
    SELECT distinct room_id
    FROM Sessions
	EXCEPT
    SELECT distinct room_id
    FROM Sessions
    WHERE (start_time, end_time) overlaps (_start_time, _start_time + interval '1h' * _duration)
	ORDER BY room_id;
$$ LANGUAGE SQL

-- F9
CREATE OR REPLACE FUNCTION get_available_rooms (_start_date DATE, _end_date DATE)
RETURNS TABLE(_room_id INT, _room_capacity INT, _day DATE, _hours INT[]) AS $$
    SELECT *
    FROM get_available_rooms_helper(_start_date, _end_date) A
    ORDER BY A._room_id, A._day
$$ LANGUAGE SQL

CREATE OR REPLACE FUNCTION get_available_rooms_helper (_start_date DATE, _end_date DATE)
RETURNS TABLE(_room_id INT, _room_capacity INT, _day DATE, _hours INT[]) AS $$
    DECLARE
        target_room RECORD;
        current_day DATE := _start_date;
        unavail_row RECORD;
        all_hours INT[] := array[9,10,11,14,15,16,17];
        avail_hours INT[] := all_hours;
		unavail_hours INT[];
    BEGIN
        FOR target_room in (SELECT * FROM Rooms) LOOP
            LOOP
                EXIT WHEN current_day > _end_date;
                
                FOR unavail_row IN (SELECT * FROM Sessions WHERE sess_date = current_day AND room_id = target_room.room_id) LOOP
                    unavail_hours := array(
                        SELECT date_part('hour', unavail_ref)
                        FROM generate_series(
                            unavail_row.start_time::timestamp,
                            unavail_row.end_time::timestamp - '1 hour'::interval,
                            '1 hour'::interval) unavail_ref order by 1
                        )::int[];
                        
                    avail_hours := array(select unnest(avail_hours) except select unnest(unavail_hours) order by 1);
                    
                END LOOP;

                RETURN QUERY
                SELECT target_room.room_id, target_room.seating_capacity, current_day, avail_hours;
                
                current_day := current_day + 1;
                avail_hours := all_hours;
            END LOOP;
			current_day := _start_date;
        END LOOP;
    END;
$$ LANGUAGE PLPGSQL

-- F11
CREATE OR REPLACE PROCEDURE add_course_package (package_name TEXT, num_free_registrations INT, sale_start_date DATE, sale_end_date DATE, price NUMERIC(10, 2))
AS $$
    INSERT INTO CoursePackages(package_name, num_free_registrations, sale_start_date, sale_end_date, price)
        VALUES (package_name, num_free_registrations, sale_start_date, sale_end_date, price);
$$ LANGUAGE SQL

-- F12
CREATE OR REPLACE FUNCTION get_available_course_packages ()
RETURNS TABLE(package_name TEXT, num_free_registrations INT, sale_end_date DATE, price NUMERIC(10, 2)) AS $$
    SELECT package_name, num_free_registrations, sale_end_date, price
    FROM CoursePackages
    WHERE CURRENT_DATE BETWEEN sale_start_date AND sale_end_date
$$ LANGUAGE SQL

-- F17
CREATE OR REPLACE PROCEDURE register_session (_cust_id INT, _offering_id INT, _sess_num INT, _payment_method TEXT)
AS $$
    DECLARE
        target_sess_id INT;
        target_registration_deadline DATE;
        target_num_sess_registered INT;
        target_cc_number VARCHAR;
        target_redemptions_left INT;
        target_package_id INT;
    BEGIN
		SELECT sess_id
		INTO target_sess_id
		FROM Sessions
		WHERE offering_id = _offering_id
		AND sess_num = _sess_num;

		SELECT registration_deadline
		INTO target_registration_deadline
		FROM CourseOfferings
		WHERE offering_id = _offering_id;

		SELECT count(*)
		INTO target_num_sess_registered
		FROM SessionParticipants
		WHERE sess_id in (
			SELECT Sessions.sess_id
			FROM Sessions
			WHERE Sessions.offering_id = _offering_id
		)
		AND cust_id = _cust_id;
			
        IF CURRENT_DATE > target_registration_deadline THEN
            raise exception 'Error: The registration deadline has passed.';
        ELSIF target_num_sess_registered > 0 THEN -- trigger!
            raise exception 'Error: You have already registered for one of this courses sessions.';
        ELSIF _payment_method = 'payment' THEN
            SELECT cc_number INTO target_cc_number FROM CreditCards WHERE CreditCards.cust_id = _cust_id;
            INSERT INTO Registers VALUES (CURRENT_DATE, _cust_id, target_sess_id, target_cc_number);
        ELSIF _payment_method = 'redemption' THEN
            SELECT redemptions_left, package_id INTO target_redemptions_left, target_package_id FROM Buys WHERE cust_id = _cust_id ORDER BY redemptions_left desc LIMIT 1;
			IF target_package_id is null THEN
				raise exception 'Error: You do not have a package to redeem sessions from.';
            ELSIF target_redemptions_left = 0 THEN -- trigger!
                raise exception 'Error: You have already fully redeemed sessions from the package.';
            END IF;
            UPDATE Buys SET redemptions_left = redemptions_left - 1 WHERE cust_id = _cust_id;
            INSERT INTO Redeems VALUES (CURRENT_DATE, target_sess_id, target_package_id, _cust_id);
        ELSE
            raise exception 'Error: You may register for the session via payment or redemption only.';
        END IF;
    END;
$$ LANGUAGE PLPGSQL

-- F18
CREATE OR REPLACE FUNCTION get_my_registrations (input_cust_id INT)
RETURNS TABLE(title TEXT, fees INT, sess_date DATE, start_hour INT, duration INT, emp_name TEXT) AS $$
    SELECT title, fees, sess_date, date_part('hour', start_time) as start_hour, duration, emp_name
    FROM Courses natural join CourseOfferings natural join Sessions natural join Employees
    WHERE sess_id in (SELECT R.sess_id FROM SessionParticipants R WHERE R.cust_id = input_cust_id)
    AND emp_id = instructor_id
$$ LANGUAGE SQL

-- F26
-- This routine is used to identify potential course offerings that could be of interest to inactive customers.
-- A customer is classified as an active customer if the customer has registered for some course offering in the last six months (inclusive of the current month);
-- otherwise, the customer is considered to be inactive customer.
-- Course area A is of interest to a customer C if there is some course offering in area A among the three most recent course offerings registered by C.
-- If a customer has not yet registered for any course offering, we assume that every course area is of interest to that customer.
-- Returns: a table of records consisting of the following information for each inactive customer:
-- customer identifier, customer name, course area A that is of interest to the customer, course identifier of a course C in area A, course title of C,
-- launch date of course offering of course C that still accepts registrations, course offering’s registration deadline, and fees for the course offering.
-- The output is sorted in ascending order of customer identifier and course offering’s registration deadline.

CREATE OR REPLACE FUNCTION promote_courses ()
RETURNS TABLE(_cust_id INT, _cust_name TEXT, _course_area TEXT, _course_id INT, _title TEXT, _launch_date DATE, _registration_deadline DATE, _fees NUMERIC(10, 2)) AS $$
    BEGIN
		RETURN QUERY
        WITH ActiveCustomers AS (

        ),
        WITH InactiveCustomers AS (
            SELECT cust_id
            FROM customers
            EXCEPT
            SELECT cust_id
            FROM ActiveCustomers
        )
        SELECT cust_id, cust_name, course_area, course_id, title, launch_date, registration_deadline, fees
        FROM InactiveCustomers
        ORDER BY cust_id, registration_deadline
    END;
$$ LANGUAGE PLPGSQL

-- F27
CREATE OR REPLACE FUNCTION top_packages (n INT)
RETURNS TABLE(_package_id INT, _num_free_registrations INT, _price NUMERIC(10,2), _sale_start_date DATE, _sale_end_date DATE, _num_sold BIGINT) AS $$
    BEGIN
		RETURN QUERY
        WITH Ranks AS (
            SELECT B.package_id, count(B.package_id) as num_sold, RANK () OVER (ORDER BY count(B.package_id) DESC) num_rank
            FROM Buys B
            GROUP BY B.package_id
        )
        SELECT package_id, num_free_registrations, price, sale_start_date, sale_end_date, num_sold
        FROM CoursePackages natural join Ranks
        WHERE num_rank <= n
        ORDER BY num_sold desc, price desc;
    END;
$$ LANGUAGE PLPGSQL

-- F28
CREATE OR REPLACE FUNCTION popular_courses ()
RETURNS TABLE(_course_id INT, _title TEXT, _course_area TEXT, _num_offerings INT, _num_registrations INT) AS $$
    BEGIN
        RETURN QUERY
        WITH HighlyOfferedCourses AS ( -- courses with at least two offerings
            SELECT course_id, count(course_id) as num_offerings
            FROM CourseOfferings
            WHERE date_part('year', start_date) = date_part('year', CURRENT_DATE)
            GROUP BY course_id
            HAVING count(course_id) >= 2
        ), RelevantOfferings AS ( -- offerings of HighlyOfferedCourses, along with their dates and num_registrations
            SELECT course_id, offering_id, start_date, get_num_registrations_of_offering(offering_id) as num_registrations
            FROM CourseOfferings
            WHERE course_id in (SELECT course_id FROM HighlyOfferedCourses)
        ), ComparedOfferings AS ( -- earlier-later offerings placed side-by-side
            SELECT R.course_id as R_course_id, R.offering_id as R_offering_id, R.start_date as R_start_date, R.num_registrations as R_num_registrations,
            R2.course_id as R2_course_id, R2.offering_id as R2_offering_id, R2.start_date as R2_start_date, R2.num_registrations as R2_num_registrations
            FROM RelevantOfferings R, RelevantOfferings R2
            WHERE R.course_id = R2.course_id
            AND R.offering_id <> R2.offering_id
            AND R.start_date <= R2.start_date
        ), PopularCourses AS ( -- popular courses
            SELECT r_course_id as course_id
            FROM ComparedOfferings
            EXCEPT
            SELECT r_course_id
            FROM ComparedOfferings
            WHERE r_course_id = r2_course_id
            AND r_num_registrations > r2_num_registrations
        ), LatestOfferings AS ( -- the latest offering of a course
            SELECT course_id, max(start_date) as latest_date
            FROM CourseOfferings
            GROUP BY course_id
        ), LatestRegistrations AS ( -- the number of registrations of the latest offering of a course
            SELECT C.course_id, get_num_registrations_of_offering(C.offering_id) as num_registrations
            FROM CourseOfferings C natural join LatestOfferings L
            WHERE C.start_date = L.latest_date
        )
        SELECT course_id, title, course_area, num_offerings, num_registrations
        FROM PopularCourses natural join Courses natural join HighlyOfferedCourses natural join LatestRegistrations;
    END;
$$ LANGUAGE PLPGSQL

CREATE OR REPLACE FUNCTION get_num_registrations_of_offering (_offering_id INT)
RETURNS INT AS $$
    SELECT count(*) FILTER (WHERE sess_id in (SELECT sess_id FROM Sessions WHERE offering_id = _offering_id))
    FROM SessionParticipants 
$$ LANGUAGE SQL
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
