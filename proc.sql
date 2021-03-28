-- F6:
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

-- Testcases:
-- select * from find_instructors(1, '2021-02-01', 10);
-- select * from find_instructors(2, '2021-04-01', 16);
-- select * from find_instructors(3, '2021-06-01', 17);
-- select * from find_instructors(4, '2021-07-15', 10);

-- F7:
-- incomplete (need to add teach hours and avail hour)
CREATE OR REPLACE FUNCTION get_available_instructors (
    IN cid INTEGER, IN s_date DATE, IN e_date DATE,
    OUT emp_id INTEGER, OUT emp_name TEXT) -- teach_hours INTEGER , avail_hours INTEGER ARRAY
RETURNS SETOF RECORD AS $$
    SELECT course_id, start_date, end_date, emp_id, emp_name
    FROM Sessions 
    INNER JOIN Employees
    ON Sessions.instructor_id = Employees.emp_id;
$$ LANGUAGE sql;

-- Testcases:

-- F15:
-- incomplete (need to fix remaining seats)
CREATE OR REPLACE FUNCTION get_available_course_offerings (
    OUT c_title TEXT, OUT c_area TEXT, OUT s_date DATE, OUT e_date DATE, 
    OUT r_deadline DATE, OUT c_fee NUMERIC(10,2), num_remaining INTEGER)
RETURNS SETOF RECORD AS $$
    SELECT title, course_area, start_date, end_date, registration_deadline, fees 
    FROM CourseOfferings
    INNER JOIN Sessions
    ON CourseOfferings.launch_date = Sessions.launch_date
    INNER JOIN Courses
    ON CourseOfferings.course_id = Courses.course_id
    ORDER BY (registration_deadline, title);
$$ LANGUAGE sql;

-- Testcases:
-- select * from get_available_course_offerings

-- F16:
-- incomplete (need to fix remaining seats)
CREATE OR REPLACE FUNCTION get_available_course_sessions (
    OUT session_date DATE, OUT session_hour INTEGER, OUT inst_name TEXT, OUT seat_remaining INTEGER)
RETURNS SETOF RECORD AS $$
    WITH RegistrationCount AS (
        SELECT COUNT(*) AS registered FROM Registers
        GROUP BY sess_id
    ), RemainingSeats AS (
        SELECT (Rooms.seating_capacity - registered) AS remaining
        FROM CourseOfferings
        INNER JOIN RegistrationCount
        ON CourseOfferings.sess_id = RegistrationCount.sess_id
        INNER JOIN Rooms
        ON S
        GROUP BY sess_id
    )
    SELECT sess_date, DATE_PART('hour', start_time), emp_name, remaining
    FROM Sessions
    INNER JOIN Employees
	ON Sessions.instructor_id = Employees.emp_id
    NATURAL JOIN RemainingSeats
    ORDER BY (sess_date, DATE_PART('hour', start_time));
$$ LANGUAGE sql;

-- Testcases:
-- select * from get_available_course_sessions

-- F21
-- Works but I think need to add sth like ensure instructor updated is of course area
CREATE OR REPLACE PROCEDURE update_instructor (
    l_date DATE, cid INTEGER, s_num INTEGER, emp_id INTEGER
)
AS $$
    UPDATE Sessions
    SET instructor_id = emp_id
    WHERE launch_date = l_date
    AND course_id = cid
    AND sess_num = s_num;
$$ LANGUAGE SQL

-- Testcases:
-- select * from update_instructor('2021-10-01', 10, 3, 30)

-- F22
-- Current tables have to be updated to support this
CREATE OR REPLACE PROCEDURE update_room (
    cid INTEGER, s_num INTEGER, rid INTEGER
)
AS $$
    --UPDATE ???
    --SET ???.room_id = rid
$$ LANGUAGE SQL