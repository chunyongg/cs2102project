----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGERS AND THEIR FUNCTIONS (put as a pair!)
-- Get instructor's work hours for that month
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

-- Get employee's employment status
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

-- Get each session's hours (including breaks before and after the session)
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
-- Get each instructor's busy hours in a day
CREATE OR REPLACE FUNCTION get_total_session_hours(IN eid INTEGER, IN session_date DATE)
RETURNS TABLE(session_hours INTEGER[]) AS $$
SELECT array_agg(all_sessions_combined)
FROM (
  SELECT unnest(get_session_hours(sess_id))
  FROM Sessions
	WHERE instructor_id = eid
	AND sess_date = session_date
) AS dt(all_sessions_combined);
$$ LANGUAGE sql;

-- Get each session's hours
CREATE OR REPLACE FUNCTION get_session_hours_2(
    IN session_id INTEGER, 
    OUT session_hours INTEGER[]
)
RETURNS INTEGER[] AS $$
SELECT ARRAY(
    SELECT * FROM generate_series(DATE_PART('hour', start_time)::INTEGER, DATE_PART('hour', end_time)::INTEGER - 1))
FROM Sessions
WHERE sess_id = session_id
$$ LANGUAGE sql;

-- Get each instructor's avail hours in a day
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
	WHEN (array_agg(hour ORDER BY hour ASC) IS NULL AND (SELECT * FROM get_total_session_hours(eid, day)) IS NULL) THEN array[9,10,11,14,15,16,17]
	ELSE array_agg(hour ORDER BY hour ASC)
END
FROM avail_hours, unnest(array1) hour
WHERE hour <> all(array2)
$$ LANGUAGE sql;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F6, F7, F15, F16, F21, F22
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F6
-- CREATE OR REPLACE FUNCTION find_instructors (IN cid INTEGER, IN session_date DATE, IN session_hour INTEGER)
-- RETURNS TABLE (eid INTEGER, e_name TEXT) AS $$
--     SELECT emp_id, emp_name
--     FROM Employees
--     NATURAL JOIN Specializations
--     INNER JOIN Courses
--     ON Specializations.course_area = Courses.course_area
--     WHERE Courses.course_id = cid
--     AND (depart_date IS NULL OR (depart_date IS NOT NULL AND depart_date >= session_date))
--     AND session_hour = ANY(get_avail_hours(emp_id, session_date))
--     AND (
--         (get_emp_status(emp_id) = 'Part Time' AND get_monthly_hours(emp_id, DATE_PART('month', session_date), DATE_PART('year', session_date)) <= 29) 
--         OR get_emp_status(emp_id) = 'Full Time'
--     )
--     ORDER BY emp_id;
-- $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION find_instructors (IN cid INTEGER, IN session_date DATE, IN session_hour INTEGER)
RETURNS TABLE (eid INTEGER, e_name TEXT) AS $$
    SELECT emp_id, emp_name
    FROM Employees
    NATURAL JOIN Specializations
    INNER JOIN Courses
    ON Specializations.course_area = Courses.course_area
    WHERE Courses.course_id = cid
    AND (depart_date IS NULL OR (depart_date IS NOT NULL AND depart_date >= session_date))
    AND (ARRAY(SELECT generate_series(session_hour, session_hour + duration - 1))) <@ get_avail_hours(emp_id, session_date)
    AND (
        (get_emp_status(emp_id) = 'Part Time' AND get_monthly_hours(emp_id, DATE_PART('month', session_date), DATE_PART('year', session_date)) <= 29) 
        OR get_emp_status(emp_id) = 'Full Time'
    )
    AND extract(dow from session_date) in (1, 2, 3, 4, 5)
    ORDER BY emp_id;
$$ LANGUAGE sql;

-- F7
-- CREATE OR REPLACE FUNCTION get_available_instructors (
-- IN cid INTEGER, IN s_date DATE, IN e_date DATE)
-- RETURNS TABLE(emp_id INTEGER, emp_name TEXT, current_monthly_hours DOUBLE PRECISION, day DATE, avail_hours INTEGER[]) AS $$
-- SELECT DISTINCT emp_id, emp_name, get_monthly_hours(emp_id, DATE_PART('month', CURRENT_DATE), DATE_PART('year', CURRENT_DATE)), sess_date, get_avail_hours(emp_id, sess_date)
-- FROM Employees
-- NATURAL JOIN Specializations
-- INNER JOIN Courses
-- ON Specializations.course_area = Courses.course_area
-- INNER JOIN CourseOfferings
-- ON Courses.course_id = CourseOfferings.course_id
-- INNER JOIN Sessions
-- ON CourseOfferings.offering_id = Sessions.offering_id
-- WHERE Courses.course_id = cid
-- AND sess_date BETWEEN s_date AND e_date
-- AND (
--         (get_emp_status(emp_id) = 'Part Time' AND get_monthly_hours(emp_id, DATE_PART('month', sess_date), DATE_PART('year', sess_date)) <= 29) 
--         OR get_emp_status(emp_id) = 'Full Time'
-- );
-- $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_available_instructors (
IN cid INTEGER, IN s_date DATE, IN e_date DATE)
RETURNS TABLE(emp_id INTEGER, emp_name TEXT, current_monthly_hours DOUBLE PRECISION, day DATE, avail_hours INTEGER[]) AS $$
WITH AllSessionDates AS (
    SELECT date_trunc('day', dd):: DATE AS day
    FROM generate_series(s_date::TIMESTAMP , e_date::TIMESTAMP , '1 day'::interval) dd
    WHERE extract(dow from date_trunc('day', dd):: DATE) in (1, 2, 3, 4, 5)
)
SELECT DISTINCT Specializations.emp_id, emp_name, get_monthly_hours(Specializations.emp_id, DATE_PART('month', CURRENT_DATE), DATE_PART('year', CURRENT_DATE)), day, get_avail_hours(Specializations.emp_id, day)
FROM Employees
CROSS JOIN AllSessionDates
NATURAL JOIN Specializations
INNER JOIN Courses
ON Specializations.course_area = Courses.course_area
INNER JOIN CourseOfferings
ON Courses.course_id = CourseOfferings.course_id
WHERE Courses.course_id = cid
AND day BETWEEN s_date AND e_date
AND (
        (get_emp_status(Specializations.emp_id) = 'Part Time' AND get_monthly_hours(Specializations.emp_id, DATE_PART('month', day), DATE_PART('year', day)) + duration <= 30) 
        OR get_emp_status(Specializations.emp_id) = 'Full Time'
)
ORDER BY (emp_id, day) ASC;
$$ LANGUAGE sql;

-- F15
CREATE OR REPLACE FUNCTION get_available_course_offerings ()
RETURNS TABLE(c_title TEXT, c_area TEXT, s_date DATE, e_date DATE, r_deadline DATE, c_fee NUMERIC(10,2), num_remaining INTEGER) AS $$
    WITH RegistrationCount AS (
        SELECT CourseOfferings.offering_id, COUNT(Sessions.sess_id)  AS count
		FROM SessionParticipants
		NATURAL JOIN Sessions
		NATURAL RIGHT JOIN CourseOfferings
		GROUP BY CourseOfferings.offering_id
    )
    SELECT title, course_area, start_date, end_date, registration_deadline, fees, (CourseOfferings.seating_capacity - count) AS remaining
    FROM CourseOfferings
    INNER JOIN Courses
    ON CourseOfferings.course_id = Courses.course_id
	NATURAL JOIN RegistrationCount
    WHERE CURRENT_DATE <= registration_deadline
    AND remaining > 0
    ORDER BY (registration_deadline, title) ASC;
$$ LANGUAGE sql;

-- F16
CREATE OR REPLACE FUNCTION get_available_course_sessions (IN oid INTEGER)
RETURNS TABLE(session_date DATE, session_hour INTEGER, inst_name TEXT, seat_remaining INTEGER) AS $$
    WITH RegistrationCount AS (
        SELECT sess_id, (seating_capacity - COUNT(sess_id)) AS remaining
		FROM SessionParticipants
        NATURAL JOIN Sessions
        INNER JOIN Rooms
        ON Sessions.room_id = Rooms.room_id
		GROUP BY sess_id, seating_capacity
    ), SessionsWithZeroRegistration AS (
        SELECT sess_id, seating_capacity AS remaining 
        FROM Sessions INNER JOIN Rooms
        ON Sessions.room_id = Rooms.room_id
        EXCEPT
        SELECT sess_id, seating_capacity AS remaining 
        FROM SessionParticipants 
        NATURAL JOIN Sessions 
        INNER JOIN Rooms
        ON Sessions.room_id = Rooms.room_id
    ), TotalCount AS (
        SELECT * FROM RegistrationCount
        UNION
        SELECT * FROM SessionsWithZeroRegistration
    )
    SELECT sess_date, DATE_PART('hour', start_time), emp_name, remaining
    FROM Sessions
    INNER JOIN CourseOfferings
    ON Sessions.offering_id = CourseOfferings.offering_id
    INNER JOIN Employees
    ON Sessions.instructor_id = Employees.emp_id
    NATURAL LEFT JOIN TotalCount
    WHERE CURRENT_DATE <= registration_deadline
    AND remaining > 0
    AND CourseOfferings.offering_id = oid
    ORDER BY (sess_date, DATE_PART('hour', start_time)) ASC;
$$ LANGUAGE sql;

-- F21

CREATE OR REPLACE PROCEDURE update_instructor (oid INTEGER, s_num INTEGER, eid INTEGER) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sessions WHERE offering_id = oid) THEN
        RAISE EXCEPTION 'The offering does not exist';
    ELSIF NOT EXISTS (SELECT 1 FROM Sessions WHERE offering_id = oid AND sess_num = s_num) THEN
        RAISE EXCEPTION 'The session does not exist';
    ELSIF NOT EXISTS (SELECT 1 FROM Instructors WHERE emp_id = eid) THEN
        RAISE EXCEPTION 'The instructor does not exist';
    END IF;

    UPDATE Sessions
    SET instructor_id = eid
    WHERE offering_id = oid 
    AND sess_num = s_num;

END;
$$ LANGUAGE plpgsql;
-- F22
-- CREATE OR REPLACE PROCEDURE update_room (
--     oid INTEGER, s_num INTEGER, rid INTEGER
-- )
-- AS $$
--     WITH RegistrationCount AS (
--         SELECT sess_id AS session_id, COUNT(sess_id) AS count
-- 		FROM SessionParticipants
-- 		GROUP BY sess_id
-- 		ORDER BY sess_id
--     )
--     UPDATE Sessions
--     SET room_id = rid
--     From CourseOfferings
--     WHERE Sessions.offering_id = oid
--     AND sess_num = s_num
--     AND sess_date > CURRENT_DATE
--     AND ((SELECT count FROM RegistrationCount WHERE session_id = sess_id) <= (SELECT seating_capacity FROM Rooms WHERE room_id = rid));

CREATE OR REPLACE PROCEDURE update_room (oid INTEGER, s_num INTEGER, rid INTEGER) AS $$
DECLARE
    _sess_id INTEGER;
    _sess_date DATE;
    _sess_start_time TIMESTAMP;
    _sess_hours INTEGER[];

    _register_count INTEGER;
    _room_avail_hours INTEGER[];
BEGIN

    IF NOT EXISTS (SELECT 1 FROM Sessions WHERE offering_id = oid) THEN
        RAISE EXCEPTION 'The offering does not exist';
    ELSIF NOT EXISTS (SELECT 1 FROM Sessions WHERE offering_id = oid AND sess_num = s_num) THEN
        RAISE EXCEPTION 'The session does not exist';
    ELSIF NOT EXISTS (SELECT 1 FROM ROOMS WHERE ROOM_ID = rid) THEN
        RAISE EXCEPTION 'The room does not exist';
    END IF;

    SELECT sess_id INTO _sess_id FROM Sessions WHERE offering_id = oid and sess_num = s_num;
    SELECT sess_date INTO _sess_date FROM Sessions WHERE sess_id = _sess_id;
    SELECT start_time INTO _sess_start_time FROM Sessions WHERE sess_id = _sess_id;

    select _hours INTO _room_avail_hours FROM get_available_rooms(_sess_date, _sess_date) WHERE _room_id = rid;
    select session_hours INTO _sess_hours FROM get_session_hours_2(_sess_id);

    WITH RegistrationCount AS (
        SELECT sess_id, COUNT(sess_id) AS count
		FROM SessionParticipants
        NATURAL JOIN Sessions
        GROUP BY sess_id
    ), SessionsWithZeroRegistration AS (
        SELECT sess_id, 0 AS count
        FROM Sessions
        EXCEPT
        SELECT sess_id, 0 AS count 
        FROM SessionParticipants 
    ), TotalCount AS (
        SELECT * FROM RegistrationCount
        UNION
        SELECT * FROM SessionsWithZeroRegistration
    )
    SELECT count INTO _register_count FROM TotalCount WHERE sess_id = _sess_id;

    IF (_sess_hours <@ _room_avail_hours) THEN
        UPDATE Sessions
        SET room_id = rid
        WHERE Sessions.offering_id = oid
        AND sess_num = s_num;
    ELSE 
		RAISE EXCEPTION 'The room is unavailable';
    END IF;

END;
$$ LANGUAGE plpgsql;
