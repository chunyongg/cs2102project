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
-- F7:
-- incomplete (need to add teach hours and avail hour)
CREATE OR REPLACE FUNCTION get_available_instructors (
    IN cid INTEGER, IN s_date DATE, IN e_date DATE,
    OUT emp_id INTEGER, OUT emp_name TEXT, OUT teach_hours INTEGER) -- avail_hours INTEGER ARRAY
RETURNS SETOF RECORD AS $$
$$ LANGUAGE sql;

-- Testcases:
