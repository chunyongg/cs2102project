-- F6 (Completed)
-- Testcases:
-- select * from find_instructors(1, '2021-02-01', 10);
-- select * from find_instructors(2, '2021-04-01', 16);
-- select * from find_instructors(3, '2021-06-01', 17);
-- select * from find_instructors(4, '2021-07-15', 10);
CREATE OR REPLACE FUNCTION find_instructors (
    IN cid INTEGER, IN session_date DATE, IN session_hour INTEGER, 
    OUT emp_id INTEGER, OUT emp_name TEXT)
RETURNS RECORD AS $$
    SELECT emp_id, emp_name
    FROM Employees
    NATURAL JOIN Instructors
    INNER JOIN Sessions
    ON Instructors.emp_id = Sessions.instructor_id 
	INNER JOIN CourseOfferings
	ON Sessions.offering_id = CourseOfferings.offering_id
    WHERE CourseOfferings.course_id = cid
    AND Sessions.sess_date = session_date
    AND session_hour IN (SELECT DATE_PART('hour', Sessions.start_time));
$$ LANGUAGE sql;

-- F7 (Completed)
-- Testcases:
-- select * from get_available_instructors (1, '2021-01-01', '2021-05-01')
-- select * from get_available_instructors (2, '2021-01-01', '2021-05-01')
-- select * from get_available_instructors (3, '2021-01-01', '2021-05-01')
CREATE OR REPLACE FUNCTION get_available_instructors (
    IN cid INTEGER, IN s_date DATE, IN e_date DATE,
    OUT emp_id INTEGER, OUT emp_name TEXT, OUT current_monthly_hours DOUBLE PRECISION, OUT day DATE, OUT avail_hours INTEGER[]
)
RETURNS SETOF RECORD AS $$
WITH RangedSessionDates AS (
    SELECT sess_id, sess_date AS day
    FROM Sessions
    WHERE sess_date BETWEEN s_date AND e_date
), Specialises AS ( -- emp_id, course_area
    SELECT * FROM Instructors NATURAL JOIN FullTimeInstructors
    UNION
    SELECT * FROM Instructors NATURAL JOIN PartTimeInstructors
) 
SELECT emp_id, emp_name, get_monthly_hours(emp_id, DATE_PART('month', CURRENT_DATE), DATE_PART('year', CURRENT_DATE)), day, get_avail_hours(emp_id, day)
FROM Employees
INNER JOIN Sessions
ON Employees.emp_id = Sessions.instructor_id
NATURAL JOIN Specialises
NATURAL JOIN RangedSessionDates
NATURAL JOIN Courses
WHERE course_id = cid;
$$ LANGUAGE sql;

-- F15 (Completed)
-- Testcases:
-- select * from get_available_course_offerings()
CREATE OR REPLACE FUNCTION get_available_course_offerings (
    OUT c_title TEXT, OUT c_area TEXT, OUT s_date DATE, OUT e_date DATE, 
    OUT r_deadline DATE, OUT c_fee NUMERIC(10,2), OUT num_remaining INTEGER)
RETURNS SETOF RECORD AS $$
    WITH RemainingSeats AS (
        SELECT CourseOfferings.offering_id, COUNT(Sessions.sess_id) 
		FROM Registers
		NATURAL JOIN Sessions
		RIGHT JOIN CourseOfferings
		ON Sessions.offering_id = CourseOfferings.offering_id
		GROUP BY CourseOfferings.offering_id
    )
    SELECT title, course_area, start_date, end_date, registration_deadline, fees, (seating_capacity - count)
    FROM CourseOfferings
    INNER JOIN Courses
    ON CourseOfferings.course_id = Courses.course_id
	NATURAL LEFT JOIN RemainingSeats
    WHERE CURRENT_DATE <= registration_deadline
    AND seating_capacity > 0
    ORDER BY (registration_deadline, title) ASC;
$$ LANGUAGE sql;

-- F16 (Completed)
-- Testcases:
-- select * from get_available_course_sessions
CREATE OR REPLACE FUNCTION get_available_course_sessions (
    OUT session_date DATE, OUT session_hour INTEGER, OUT inst_name TEXT, OUT seat_remaining INTEGER)
RETURNS SETOF RECORD AS $$
    WITH RemainingSeats AS (
        SELECT Sessions.sess_id, COUNT(Registers.sess_id) AS count
        FROM Registers
        NATURAL RIGHT JOIN Sessions
        GROUP BY Sessions.sess_id
    )
    SELECT sess_date, DATE_PART('hour', start_time), emp_name,(Rooms.seating_capacity - count)
    FROM Sessions
    INNER JOIN Rooms
    ON Sessions.room_id = Rooms.room_id
    INNER JOIN CourseOfferings
    ON Sessions.offering_id = CourseOfferings.offering_id
    INNER JOIN Employees
    ON Sessions.instructor_id = Employees.emp_id
    NATURAL LEFT JOIN RemainingSeats
    WHERE CURRENT_DATE <= registration_deadline
    AND Rooms.seating_capacity > 0
    ORDER BY (sess_date, DATE_PART('hour', start_time)) ASC;
$$ LANGUAGE sql;

-- F21 (Completed)
-- Testcases:
-- call update_instructor('2021-10-01', 10, 3, 27)
-- call update_instructor('2021-10-01', 10, 3, 31)
-- call update_instructor('2021-01-01', 1, 1, 32);
CREATE OR REPLACE PROCEDURE update_instructor (
    l_date DATE, coid INTEGER, s_num INTEGER, eid INTEGER
)
AS $$
    WITH Specialises AS (
        SELECT * FROM Instructors NATURAL JOIN FullTimeInstructors
        UNION
        SELECT * FROM Instructors NATURAL JOIN PartTimeInstructors
    ) 
	UPDATE Sessions
    SET instructor_id = eid
    FROM CourseOfferings
    WHERE launch_date = l_date
    AND sess_date > CURRENT_DATE
    AND Sessions.offering_id = coid
    AND EXISTS(
        SELECT course_area
        FROM Specialises
        WHERE emp_id = instructor_id
        AND course_area IN (
            SELECT course_area
            FROM Specialises
            WHERE emp_id = eid)
    );
$$ LANGUAGE SQL

-- F22 (Completed)
-- Set trigger to update seating capacity in course_offering when session's room is changed
-- Testcases:
-- call update_room(5, 1, 20);
-- call update_room(5, 1, 6);
-- call update_room(5, 1, 1);

CREATE OR REPLACE PROCEDURE update_room (
    cid INTEGER, s_num INTEGER, rid INTEGER
)
AS $$
    WITH SessionRegistrations AS (
        SELECT Sessions.sess_id, COUNT(*) AS count
        FROM Registers
        INNER JOIN Sessions
        ON Registers.sess_id = Sessions.sess_id
        GROUP BY Sessions.sess_id
        ORDER BY Sessions.sess_id
    ), RoomCapacities AS (
        SELECT room_id, seating_capacity
        FROM Rooms
    )
    UPDATE Sessions
    SET room_id = rid
    From CourseOfferings
    WHERE course_id = cid
    AND sess_num = s_num
    AND sess_date > CURRENT_DATE
    AND (
        (SELECT count FROM SessionRegistrations)
        <=
        (SELECT seating_capacity FROM Rooms WHERE room_id = rid)
    );
$$ LANGUAGE SQL

------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_monthly_hours (
    IN eid INTEGER, IN mth DOUBLE PRECISION, IN yr DOUBLE PRECISION, 
    OUT work_hours DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION AS $$
	WITH InstructorWorkRecords AS (
        SELECT DATE_PART('year', sess_date) AS year, DATE_PART('month', sess_date) AS month, instructor_id, SUM(extract (epoch from end_time - start_time)/3600) AS total_hours
        FROM Sessions
        GROUP BY instructor_id, DATE_PART('year', sess_date), DATE_PART('month', sess_date)
        ORDER BY month ASC
    )
    SELECT COALESCE(MAX(total_hours), 0)
    FROM InstructorWorkRecords
    WHERE instructor_id = eid
    AND month = mth
    AND year = yr;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION get_session_hours(
    IN eid INTEGER, IN day DATE, 
    OUT session_hours INTEGER[]
)
RETURNS INTEGER[] AS $$
SELECT ARRAY(
    SELECT * 
    FROM generate_series(DATE_PART('hour', start_time)::INTEGER, DATE_PART('hour', end_time)::INTEGER))
FROM Sessions
WHERE sess_date = day
AND instructor_id = eid
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION get_avail_hours(
    IN eid INTEGER, IN day DATE,
    OUT avail_hours INTEGER[]
)
RETURNS INTEGER[] AS $$
WITH avail_hours(array1, array2) AS (
    VALUES (array[9,10,11,14,15,16,17], 
        (SELECT array_agg(combined)
        FROM (
            SELECT unnest(session_hours) 
            FROM get_session_hours(eid, day)
            ) as dt(combined)
        )
    )
)
SELECT array_agg(hour) 
FROM avail_hours, unnest(array1) hour
WHERE hour <> all(array2)
$$ LANGUAGE sql;
------------------------------------------------------------------------------------------------------------

-- F25:
-- inserts the new salary payment records 
-- returns a table of records (sorted in ascending order of employee identifier) 
-- employee identifier, name, status (either pt or ft), number of work days, number of work hours, hourly rate, monthly salary, and salary amount paid.
-- for pt: number of work days and monthly salary should be null
-- for ft: number of work hours and hourly rate should be null
CREATE OR REPLACE FUNCTION get_emp_status (
    IN eid INTEGER, OUT status TEXT)
RETURNS TEXT AS $$
	WITH FT_EID AS (
		SELECT emp_id AS fteid
		FROM FullTimeEmployees
	), PT_EID AS (
        SELECT emp_id AS pteid
		FROM PartTimeEmployees
    )
    SELECT 
        CASE 
            WHEN (eid IN (SELECT fteid FROM FT_EID)) THEN 'Full Time'
            WHEN (eid IN (SELECT pteid FROM PT_EID)) THEN 'Part Time'
            ELSE NULL
        END AS status;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_pt_salary_amount (
    IN eid INTEGER, IN yr INTEGER, IN mth INTEGER,
    OUT pt_salary_amt NUMERIC(10,2)
)
RETURNS NUMERIC(10,2) AS $$
    SELECT get_monthly_hours(eid, mth) * hourly_rate
    FROM PartTimeEmployees
    WHERE emp_id = eid
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE pay_salary (
)
AS $$
$$ LANGUAGE SQL

-- F26