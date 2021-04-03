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
RETURNS TABLE (eid INTEGER, e_name TEXT)
AS $$
    SELECT emp_id, emp_name
    FROM Employees
    NATURAL JOIN InstructorSpecialisation
    INNER JOIN Courses
    ON InstructorSpecialisation.course_area = Courses.course_area
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
-- Q7
-- Testcases:
-- select * from get_available_instructors(1, '2021-01-01', '2021-01-31');
CREATE OR REPLACE FUNCTION get_available_instructors (
IN cid INTEGER, IN s_date DATE, IN e_date DATE)
RETURNS TABLE(emp_id INTEGER, emp_name TEXT, current_monthly_hours DOUBLE PRECISION, day DATE, avail_hours INTEGER[]) AS $$
SELECT DISTINCT emp_id, emp_name, get_monthly_hours(emp_id, DATE_PART('month', CURRENT_DATE), DATE_PART('year', CURRENT_DATE)), sess_date, get_avail_hours(emp_id, sess_date)
FROM Employees
NATURAL JOIN InstructorSpecialisation
INNER JOIN Courses
ON InstructorSpecialisation.course_area = Courses.course_area
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