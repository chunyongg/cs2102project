-- OUTDATED, LATEST IN APPROVED_PROC

CREATE OR REPLACE FUNCTION end_of_month(month date)
RETURNS DATE as $$
BEGIN
RETURN (select (date_trunc('month', $1) + interval '1 month' - interval '1 day')::date);
END;
$$ language PLPGSQL;

CREATE OR REPLACE FUNCTION start_of_month(month date)
RETURNS DATE as $$
DECLARE 
BEGIN
RETURN (SELECT date_trunc('month', month));
END;
$$ language PLPGSQL;

-- Returns a date exactly one month ago
CREATE OR REPLACE FUNCTION subtract_month( month date)
RETURNS DATE AS $$ 
BEGIN
    RETURN month - interval '1 month';
END;
$$ LANGUAGE PLPGSQL;


	-- Get an array of hours where the instructor is unavailable to teach, including breaks.
	CREATE OR REPLACE FUNCTION get_instructor_unavailable_hours(eid integer, day date)
	RETURNS INT[] AS $$
	SELECT ARRAY(
		SELECT * 
		FROM generate_series(DATE_PART('hour', start_time)::INTEGER - 1,
         DATE_PART('hour', end_time)::INTEGER))
	FROM Sessions
	WHERE sess_date = day
	AND instructor_id = eid
	$$ LANGUAGE SQL;

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