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
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
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
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_session_hours(
    IN session_id INTEGER, 
    OUT session_hours INTEGER[]
)
RETURNS INTEGER[] AS $$
SELECT ARRAY(
    SELECT * FROM generate_series(DATE_PART('hour', start_time)::INTEGER - 1, DATE_PART('hour', end_time)::INTEGER))
FROM Sessions
WHERE sess_id = session_id
$$ LANGUAGE sql;
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_total_session_hours(IN eid INTEGER, IN session_date DATE)
RETURNS TABLE(session_hours INTEGER[]) AS $$
SELECT array_agg(all_sessions_combined)
FROM (
  SELECT unnest(get_session_hours(sess_id))
  FROM Sessions
	WHERE instructor_id = eid
	AND sess_date = session_date
) AS dt(all_sessions_combined);
$$ LANGUAGE sql
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
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
            FROM get_total_session_hours(eid, day)
            ) as dt(combined)
        )
    )
)
SELECT CASE
	WHEN (array_agg(hour) IS NULL AND (SELECT * FROM get_total_session_hours(eid, day)) IS NULL) THEN array[9,10,11,14,15,16,17]
	ELSE array_agg(hour)
END
FROM avail_hours, unnest(array1) hour
WHERE hour <> all(array2)
$$ LANGUAGE sql;
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-- F6
-- Testcases:
-- select * from find_instructors (1, '2021-01-01', 15); // 25 is free
-- select * from find_instructors (1, '2021-01-01', 10); // 25 is not free
-- select * from find_instructors (1, '2021-04-01', 10); // 25 alr departed
-- select * from find_instructors (1, '2021-03-01', 15); // 25's last day
CREATE OR REPLACE FUNCTION find_instructors (IN cid INTEGER, IN session_date DATE, IN session_hour INTEGER)
RETURNS TABLE (eid INTEGER, e_name TEXT) AS $$
    SELECT emp_id, emp_name
    FROM Employees
    NATURAL JOIN InstructorSpecializations
    INNER JOIN Courses
    ON InstructorSpecializations.course_area = Courses.course_area
    WHERE Courses.course_id = cid
    AND (depart_date IS NULL OR (depart_date IS NOT NULL AND depart_date >= session_date))
    AND session_hour = ANY(get_avail_hours_2(emp_id, session_date))
    AND (
        (get_emp_status(emp_id) = 'Part Time' AND get_monthly_hours(emp_id, DATE_PART('month', session_date), DATE_PART('year', session_date)) <= 29) 
        OR get_emp_status(emp_id) = 'Full Time'
    )
    ORDER BY emp_id;
$$ LANGUAGE sql;
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-- F7
-- Testcases:
-- select * from get_available_instructors(1, '2021-01-01', '2021-01-31');
CREATE OR REPLACE FUNCTION get_available_instructors (
IN cid INTEGER, IN s_date DATE, IN e_date DATE)
RETURNS TABLE(emp_id INTEGER, emp_name TEXT, current_monthly_hours DOUBLE PRECISION, day DATE, avail_hours INTEGER[]) AS $$
SELECT DISTINCT emp_id, emp_name, get_monthly_hours(emp_id, DATE_PART('month', CURRENT_DATE), DATE_PART('year', CURRENT_DATE)), sess_date, get_avail_hours(emp_id, sess_date)
FROM Employees
NATURAL JOIN InstructorSpecializations
INNER JOIN Courses
ON InstructorSpecializations.course_area = Courses.course_area
INNER JOIN CourseOfferings
ON Courses.course_id = CourseOfferings.course_id
INNER JOIN Sessions
ON CourseOfferings.offering_id = Sessions.offering_id
WHERE Courses.course_id = cid
AND (
        (get_emp_status(emp_id) = 'Part Time' AND get_monthly_hours(emp_id, DATE_PART('month', sess_date), DATE_PART('year', sess_date)) <= 29) 
        OR get_emp_status(emp_id) = 'Full Time'
);
$$ LANGUAGE sql;
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-- F15
-- Testcases:
-- select * from get_available_course_offerings();
CREATE OR REPLACE FUNCTION get_available_course_offerings ()
RETURNS TABLE(c_title TEXT, c_area TEXT, s_date DATE, e_date DATE, r_deadline DATE, c_fee NUMERIC(10,2), num_remaining INTEGER) AS $$
    WITH RegistrationCount AS (
        SELECT CourseOfferings.offering_id, COUNT(Sessions.sess_id)  AS count
		FROM SessionParticipants
		NATURAL JOIN Sessions
		NATURAL RIGHT JOIN CourseOfferings
		GROUP BY CourseOfferings.offering_id
    )
    SELECT title, course_area, start_date, end_date, registration_deadline, fees, (CourseOfferings.seating_capacity - count)
    FROM CourseOfferings
    INNER JOIN Courses
    ON CourseOfferings.course_id = Courses.course_id
	NATURAL LEFT JOIN RegistrationCount
    WHERE CURRENT_DATE <= registration_deadline
    AND CourseOfferings.seating_capacity > 0
    ORDER BY (registration_deadline, title) ASC;
$$ LANGUAGE sql;
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-- F16
-- Testcases:
-- select * from get_available_course_sessions(6);
CREATE OR REPLACE FUNCTION get_available_course_sessions (IN oid INTEGER)
RETURNS TABLE(session_date DATE, session_hour INTEGER, inst_name TEXT, seat_remaining INTEGER) AS $$
    WITH RegistrationCount AS (
        SELECT sess_id, (seating_capacity - COUNT(sess_id)) AS remaining
		FROM SessionParticipants
		NATURAL RIGHT JOIN Sessions
		NATURAL JOIN Rooms
		GROUP BY sess_id, seating_capacity
		ORDER BY sess_id
    )
    SELECT sess_date, DATE_PART('hour', start_time), emp_name, remaining
    FROM Sessions
    INNER JOIN CourseOfferings
    ON Sessions.offering_id = CourseOfferings.offering_id
    INNER JOIN Employees
    ON Sessions.instructor_id = Employees.emp_id
    NATURAL LEFT JOIN RegistrationCount
    WHERE CURRENT_DATE <= registration_deadline
    AND remaining > 0
    AND CourseOfferings.offering_id = oid
    ORDER BY (sess_date, DATE_PART('hour', start_time)) ASC;
$$ LANGUAGE sql;
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-- F21
-- Testcases:
-- call update_instructor(9, 1, 26);
-- call update_instructor(9, 1, 22);
CREATE OR REPLACE PROCEDURE update_instructor (
    oid INTEGER, s_num INTEGER, eid INTEGER
)
AS $$
	UPDATE Sessions
    SET instructor_id = eid
	FROM Courseofferings
	INNER JOIN Courses
	ON Courseofferings.course_id = Courses.course_id 
    WHERE (Sessions.offering_id = oid AND sess_num = s_num)
    AND sess_date > CURRENT_DATE
$$ LANGUAGE SQL;
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-- F22
CREATE OR REPLACE PROCEDURE update_room (
    oid INTEGER, s_num INTEGER, rid INTEGER
)
AS $$
    WITH RegistrationCount AS (
        SELECT sess_id AS session_id, COUNT(sess_id) AS count
		FROM SessionParticipants
		GROUP BY sess_id
		ORDER BY sess_id
    )
    UPDATE Sessions
    SET room_id = rid
    From CourseOfferings
    WHERE Sessions.offering_id = oid
    AND sess_num = s_num
    AND sess_date > CURRENT_DATE
    AND ((SELECT count FROM RegistrationCount WHERE session_id = sess_id) <= (SELECT seating_capacity FROM Rooms WHERE room_id = rid));
$$ LANGUAGE SQL;