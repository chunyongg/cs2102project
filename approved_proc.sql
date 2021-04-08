----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGERS AND THEIR FUNCTIONS (put as a pair!)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_manager_status()
RETURNS TRIGGER AS $$
DECLARE 
    j_date date;
    d_date date;
BEGIN 
    SELECT join_date, depart_date INTO j_date, d_date FROM Employees 
    WHERE emp_id = NEW.manager_id;
        IF d_date < CURRENT_DATE THEN 
        RAISE EXCEPTION 'Employee departed';
    END IF;
    IF j_date < CURRENT_DATE THEN 
        RAISE EXCEPTION 'Employee not yet joined';
    END IF;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS check_manager_is_available ON CourseAreas;
CREATE TRIGGER check_manager_is_available
BEFORE INSERT OR UPDATE ON COURSEAREAS 
FOR EACH ROW EXECUTE FUNCTION check_manager_status();

CREATE OR REPLACE FUNCTION check_admin_status()
RETURNS TRIGGER AS $$
DECLARE 
    j_date date;
    d_date date;
BEGIN 
    SELECT join_date, depart_date INTO j_date, d_date FROM Employees 
    WHERE emp_id = NEW.admin_id;
        IF d_date < CURRENT_DATE THEN 
        RAISE EXCEPTION 'Employee departed';
    END IF;
    IF j_date < CURRENT_DATE THEN 
        RAISE EXCEPTION 'Employee not yet joined';
    END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER check_admin_status 
BEFORE INSERT OR UPDATE ON COURSEOFFERINGS 
FOR EACH ROW EXECUTE FUNCTION check_admin_status();

CREATE OR REPLACE FUNCTION prevent_both_full_and_part_time_instructor()
RETURNS TRIGGER AS $$ 
DECLARE 
existing_emp_type text;
BEGIN 
    SELECT emp_type into existing_emp_type FROM InstructorWorkingTypes WHERE emp_id = NEW.emp_id;
    IF existing_emp_type IS NOT NULL THEN 
        RAISE EXCEPTION 'Employee % is already a % instructor', NEW.emp_id, existing_emp_type;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS prevent_full_time_instructor ON FullTimeInstructors;
CREATE TRIGGER prevent_full_time_instructor
BEFORE INSERT ON FullTimeInstructors
FOR EACH ROW EXECUTE FUNCTION prevent_both_full_and_part_time_instructor();

DROP TRIGGER IF EXISTS prevent_part_time_instructor ON PartTimeInstructors;
CREATE TRIGGER prevent_part_time_instructor
BEFORE INSERT ON PartTimeInstructors
FOR EACH ROW EXECUTE FUNCTION prevent_both_full_and_part_time_instructor();

CREATE OR REPLACE FUNCTION prevent_both_full_and_part_time()
RETURNS TRIGGER AS $$ 
DECLARE 
existing_emp_type text;
BEGIN 
    SELECT emp_type into existing_emp_type FROM EmployeeWorkingTypes WHERE emp_id = NEW.emp_id;
    IF existing_emp_type IS NOT NULL THEN 
        RAISE EXCEPTION 'Employee % Is already a % employee', NEW.emp_id, existing_emp_type;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS prevent_full_time_insert_is_part_time ON FullTimeEmployees;
CREATE TRIGGER prevent_full_time_insert_is_part_time
BEFORE INSERT ON FullTimeEmployees
FOR EACH ROW EXECUTE FUNCTION prevent_both_full_and_part_time();

DROP TRIGGER IF EXISTS prevent_part_time_insert_is_full_time ON PartTimeEmployees;
CREATE TRIGGER prevent_part_time_insert_is_full_time 
BEFORE INSERT ON PartTimeEmployees
FOR EACH ROW EXECUTE FUNCTION prevent_both_full_and_part_time();

CREATE OR REPLACE FUNCTION prevent_part_time()
RETURNS TRIGGER AS $$ 
BEGIN 
IF EXISTS (SELECT 1 FROM Managers WHERE emp_id = NEW.emp_id
           UNION SELECT 1 FROM Administrators WHERE emp_id = NEW.emp_id
           ) THEN 
    RAISE EXCEPTION 'Manager or administrator cannot be part time';
END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS check_part_time_is_not_admin_or_manager ON PartTimeEmployees;
CREATE TRIGGER check_part_time_is_not_admin_or_manager
BEFORE INSERT OR UPDATE ON PartTimeEmployees
FOR EACH ROW EXECUTE FUNCTION prevent_part_time();

CREATE OR REPLACE FUNCTION check_isNot_Existing()
RETURNS TRIGGER AS $$
DECLARE 
existing_emp_type text;
BEGIN 
    SELECT emp_type into existing_emp_type FROM EmployeeTypes WHERE emp_id = NEW.emp_id;
    IF existing_emp_type IS NOT NULL THEN 
        RAISE EXCEPTION 'Employee % of type % already exists', NEW.emp_id, existing_emp_type;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS check_isNot_existing_when_adding_admin ON Administrators;
CREATE TRIGGER check_isNot_existing_when_adding_admin
BEFORE INSERT ON Administrators
FOR EACH ROW EXECUTE FUNCTION check_isNot_Existing();

DROP TRIGGER IF EXISTS check_isNot_existing_when_adding_manager ON Managers;
CREATE TRIGGER check_isNot_existing_when_adding_manager
BEFORE INSERT ON MANAGERS
FOR EACH ROW EXECUTE FUNCTION check_isNot_Existing();

DROP TRIGGER IF EXISTS check_isNot_existing_when_adding_instructor ON Instructors;
CREATE TRIGGER check_isNot_existing_when_adding_instructor
BEFORE INSERT OR UPDATE ON Instructors
FOR EACH ROW EXECUTE FUNCTION check_isNot_Existing();


-- CREATE OR REPLACE FUNCTION reject_operation()
-- RETURNS TRIGGER AS $$ 
-- BEGIN 
--     RAISE EXCEPTION 'Operation denied';
-- END;
-- $$ LANGUAGE PLPGSQL;

-- DROP TRIGGER IF EXISTS reject_course_offering_changes ON CourseOfferings;
-- CREATE TRIGGER reject_course_offering_changes
-- BEFORE DELETE ON COURSEOFFERINGS 
-- FOR EACH ROW EXECUTE FUNCTION reject_operation();


CREATE OR REPLACE FUNCTION before_sess_update_check_room_capacity()
RETURNS TRIGGER AS $$
DECLARE 
number_registered INT; 
room_capacity INT;
BEGIN 
    SELECT seating_capacity INTO room_capacity FROM ROOMS WHERE room_id = NEW.room_id;
    SELECT count(*) INTO number_registered FROM SessionParticipants WHERE sess_id = NEW.sess_id;
    IF number_registered > room_capacity THEN 
        RAISE EXCEPTION 'Room capacity is insufficient for this session';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS before_sess_update_check_room_capacity ON Sessions;
CREATE TRIGGER before_sess_update_check_room_capacity
BEFORE UPDATE ON SESSIONS 
FOR EACH ROW EXECUTE FUNCTION before_sess_update_check_room_capacity();

-- Ensures registrant has not registered for this offering before
CREATE OR REPLACE FUNCTION before_register_check_has_not_registered()
RETURNS TRIGGER AS $$
BEGIN 
    IF EXISTS (SELECT 1 FROM SessionParticipants 
    WHERE cust_id = NEW.cust_id AND sess_id = NEW.sess_id) THEN 
        RAISE EXCEPTION 'Already registered for session';
    END IF;
    RETURN NEW;
END; 
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS before_register_check_has_not_registered ON REGISTERS;
CREATE TRIGGER before_register_check_has_not_registered
BEFORE INSERT ON REGISTERS 
FOR EACH ROW EXECUTE FUNCTION before_register_check_has_not_registered();

DROP TRIGGER IF EXISTS before_redeem_check_has_not_registered ON REDEEMS;
CREATE TRIGGER before_redeem_check_has_not_registered
BEFORE INSERT ON REDEEMS
FOR EACH ROW EXECUTE FUNCTION before_register_check_has_not_registered();

CREATE OR REPLACE FUNCTION prevent_session_register()
RETURNS TRIGGER AS $$ 
DECLARE 
l_date date;
r_deadline date;
BEGIN 
    SELECT launch_date, registration_deadline INTO l_date, r_deadline FROM CourseOfferings 
    WHERE offering_id = NEW.offering_id;
    IF l_date < CURRENT_DATE THEN 
        RAISE EXCEPTION 'Course offering not launched yet';
    END IF;
    IF r_deadline < CURRENT_DATE THEN 
        RAISE EXCEPTION 'Registration deadline is over';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS before_register_check_dates ON Registers;
CREATE TRIGGER before_register_check_dates 
BEFORE INSERT ON REGISTERS 
FOR EACH ROW EXECUTE FUNCTION prevent_session_register();

DROP TRIGGER IF EXISTS before_redeem_check_dates ON Redeems;
CREATE TRIGGER before_redeem_check_dates 
BEFORE INSERT ON REDEEMS
FOR EACH ROW EXECUTE FUNCTION prevent_session_register();



	CREATE OR REPLACE FUNCTION AFTER_SESS_ADD() RETURNS TRIGGER AS $$
	DECLARE
	old_capacity integer;
	new_capacity integer;
	BEGIN
	IF (TG_OP = 'INSERT') THEN
	SELECT seating_capacity INTO new_capacity FROM Rooms WHERE room_id = NEW.room_id;
	UPDATE CourseOfferings
	SET seating_capacity = seating_capacity + new_capacity
	WHERE offering_id = NEW.offering_id;
	ELSIF (TG_OP = 'UPDATE' AND NEW.room_id <> OLD.room_id) THEN
		SELECT seating_capacity INTO old_capacity FROM Rooms WHERE room_id = OLD.room_id;
		SELECT seating_capacity INTO new_capacity FROM Rooms WHERE room_id = NEW.room_id;
		UPDATE CourseOfferings
		SET seating_capacity = seating_capacity - old_capacity
		WHERE offering_id = OLD.offering_id;

		UPDATE CourseOfferings
		SET seating_capacity = seating_capacity + new_capacity
		WHERE offering_id = NEW.offering_id;
	END IF;
	RETURN NULL;

	END;
	$$ LANGUAGE PLPGSQL;

	-- Updates CourseOffering seating capacity after insertion/update
	DROP TRIGGER IF EXISTS AFTER_SESSION_ADD ON SESSIONS;
	CREATE TRIGGER AFTER_SESSION_ADD AFTER
	INSERT
	OR
	UPDATE ON SESSIONS
	FOR EACH ROW EXECUTE FUNCTION AFTER_SESS_ADD();

	CREATE OR REPLACE FUNCTION CHECK_SESSION_REMOVAL() RETURNS TRIGGER AS $$
	DECLARE
	session_participant_id integer;
	curr_time timestamp;
	BEGIN
	SELECT LOCALTIMESTAMP INTO curr_time;
	IF (OLD.start_time <= curr_time) THEN
		RAISE EXCEPTION 'Session has already started and cannot be removed';
	END IF;

	SELECT cust_id INTO session_participant_id FROM SessionParticipants
	Where sess_id = OLD.sess_id
	limit 1;

	IF (session_participant_id IS NOT NULL) THEN
		Raise Exception 'A session with customers cannot be removed';
	END IF;
	RETURN OLD;
	END;
	$$ LANGUAGE PLPGSQL;

	DROP TRIGGER IF EXISTS BEFORE_SESSION_REMOVAL ON SESSIONS;
	-- Rejects deletion if session already started or there are customers signed up for the session
	CREATE TRIGGER BEFORE_SESSION_REMOVAL
	BEFORE
	DELETE ON SESSIONS
	FOR EACH ROW EXECUTE FUNCTION CHECK_SESSION_REMOVAL();

	CREATE OR REPLACE FUNCTION AFTER_SESSION_DELETE()
	RETURNS TRIGGER AS $$ 
	DECLARE 
	capacity integer;
	BEGIN 
	SELECT seating_capacity INTO capacity FROM Rooms WHERE room_id = OLD.room_id;
	UPDATE CourseOfferings
	SET seating_capacity = seating_capacity - capacity
	WHERE offering_id = OLD.offering_id;
	RETURN NULL;
	END;
	$$ LANGUAGE PLPGSQL;


	DROP TRIGGER IF EXISTS AFTER_SESSION_DELETE ON SESSIONS;
	CREATE TRIGGER AFTER_SESSION_DELETE 
	AFTER DELETE ON SESSIONS 
	FOR EACH ROW EXECUTE FUNCTION AFTER_SESSION_DELETE();
	

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

	CREATE OR REPLACE FUNCTION CHECK_SESSION_ADD() RETURNS TRIGGER AS $$
	DECLARE
	carea text;
	cid integer;
	curr_time timestamp;
	other_session_id integer;
	same_room_session_id integer;
	_duration integer;
	hours_taught integer;
	d_date date;
	j_date date;
	unavailable_hour integer;
    unavailable_hours int[];
	registration_deadline date;
	BEGIN

	SELECT LOCALTIMESTAMP into curr_time;

	IF (NEW.start_time <= LOCALTIMESTAMP) THEN
		RAISE EXCEPTION 'Session must start in the future';
	END IF;

	SELECT CO.registration_deadline INTO registration_deadline FROM CourseOfferings CO WHERE CO.offering_id = NEW.offering_id;

	IF registration_deadline < CURRENT_DATE THEN 
		RAISE EXCEPTION 'Registration deadline for course offering % has passed.', NEW.offering_id;
	END IF;

	IF date_part('hour', NEW.start_time) < 9 THEN 
		RAISE EXCEPTION 'Invalid start time: %', NEW.start_time;
	END IF;

	IF date_part('dow', NEW.sess_date) IN (0, 6) THEN 
		RAISE EXCEPTION 'Cannot start on weekends';
	END IF;

	IF date_part('hour', NEW.end_time) > 18 THEN 
		RAISE EXCEPTION 'Invalid end time: %', NEW.end_time;
	END IF;

	IF date_part('hour', NEW.start_time) BETWEEN 12 AND 13 THEN 
		RAISE EXCEPTION 'Invalid start time: %', NEW.start_time;
	END IF;

	IF date_part('hour', NEW.end_time) BETWEEN 13 AND 14 THEN 
		RAISE EXCEPTION 'Invalid end time: %', NEW.end_time;
	END IF;

	SELECT sess_id into same_room_session_id FROM Sessions
	WHERE sess_id <> NEW.sess_id AND room_id = NEW.room_id
    -- There exists another session that starts between the start and end times of the session to be added 
    AND (
			(
			NEW.start_time >= start_time
			AND NEW.start_time < end_time
			) 
		OR 
		-- Start before another session, but end after that session starts
			(
			NEW.start_time < start_time 
			AND NEW.end_time > start_time 
			)
	) 
	limit 1;
	
	IF same_room_session_id IS NOT NULL THEN
		RAISE EXCEPTION 'Room is occupied at this time';
	END IF;

	SELECT depart_date, join_date INTO d_date, j_date FROM Employees WHERE emp_id = NEW.instructor_id;

	IF (d_date IS NOT NULL AND d_date < NEW.sess_date) THEN 
		RAISE EXCEPTION 'Instructor left already';
	END IF;

	IF (j_date IS NOT NULL AND j_date > NEW.sess_date) THEN 
		RAISE EXCEPTION 'Instructor has not joined yet';
	END IF;

	SELECT course_id into cid from CourseOfferings where offering_id = NEW.offering_id;
	SELECT duration, course_area into _duration, carea from Courses where course_id = cid;

	IF (NOT EXISTS (SELECT 1 FROM Specializations WHERE emp_id = NEW.instructor_id AND course_area = carea)) THEN
		RAISE EXCEPTION 'Instructor does not specialize in area taught';
	END IF;

	SELECT sess_id INTO other_session_id FROM Sessions WHERE
	sess_id <> NEW.sess_id AND instructor_id = NEW.instructor_id
	AND sess_date = NEW.sess_date AND 
	(( -- Start after another session, but start before that session ends
		NEW.start_time >= start_time
		AND NEW.start_time < end_time
		) OR 
		-- Start before another session, but end after that session starts
		(
			NEW.start_time < start_time 
			AND NEW.end_time > start_time 
		)
	)
	limit 1;
	IF (other_session_id IS NOT NULL) THEN
		RAISE EXCEPTION 'Instructor is already teaching at this time';
	END IF;

	unavailable_hours:= get_instructor_unavailable_hours(NEW.instructor_id, NEW.sess_date);

	IF unavailable_hours IS NOT NULL THEN 
		FOREACH unavailable_hour IN ARRAY unavailable_hours
		LOOP
			IF (unavailable_hour = extract(hour FROM NEW.start_time) -- Cannot start during resting period
				OR 
				-- Start before resting period but end after resting period
				(extract(hour FROM NEW.start_time) < unavailable_hour AND extract(hour FROM NEW.end_time) > unavailable_hour)  
			) THEN
				RAISE EXCEPTION 'Give the poor instructor a break!';
			END IF;
		END LOOP;
	END IF;

	SELECT get_monthly_hours(NEW.instructor_id, DATE_PART('month', NEW.sess_date), DATE_PART('year', NEW.sess_date)) INTO hours_taught;

	IF (hours_taught + _duration > 30 AND EXISTS (SELECT 1 FROM PartTimeEmployees WHERE emp_id = NEW.instructor_id)) THEN
		RAISE EXCEPTION 'Part time instructor must not teach more than 30 hours in a month';
	END IF;

	RETURN NEW;
	END;
	$$ LANGUAGE PLPGSQL;

	-- Rejects insertion if: 
	-- Registration deadline for course offering is over
	-- Instructor does not specialize in area, 
	-- is teaching consecutive sessions, 
	-- (for part time) is teaching more than 30 hours,
	-- is teaching two sessions simultaneously
	-- Instructor does not get a break
	-- Room is occupied
	-- Instructor departed
	-- Instructor haven't joined
	-- Is on weekends 
	-- Is after/before operating hours
	DROP TRIGGER IF EXISTS BEFORE_SESSION_ADD ON SESSIONS;
	CREATE TRIGGER BEFORE_SESSION_ADD
	BEFORE
	INSERT
	OR
	UPDATE ON SESSIONS
	FOR EACH ROW EXECUTE FUNCTION CHECK_SESSION_ADD();
CREATE OR REPLACE FUNCTION check_courseofferings_seating_capacity()
RETURNS TRIGGER AS $$
BEGIN 
IF (NEW.seating_capacity < NEW.target_number_registrations) THEN
    RAISE EXCEPTION 'Seating capacity must not be less than target registrations';
END IF;
RETURN NEW;
END 
$$ LANGUAGE PLPGSQL;

-- Ensure CourseOffering seating capacity is valid
-- Update is omitted from this trigger since removal of session can be permitted even if seating capacity drops below target number (F23 remove_session)
DROP TRIGGER IF EXISTS check_seating_capacity ON CourseOfferings;
CREATE TRIGGER check_seating_capacity
BEFORE INSERT ON CourseOfferings
FOR EACH ROW EXECUTE FUNCTION check_courseofferings_seating_capacity();

CREATE OR REPLACE FUNCTION before_add_offering()
RETURNS TRIGGER AS $$
BEGIN 
    IF NEW.launch_date < CURRENT_DATE THEN 
        RAISE EXCEPTION 'Registration deadline must not be in the past';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS before_add_offering_check_date ON CourseOfferings;
CREATE TRIGGER before_add_offering_check_date 
BEFORE INSERT OR UPDATE ON CourseOfferings
FOR EACH ROW EXECUTE FUNCTION before_add_offering();

CREATE OR REPLACE FUNCTION check_is_not_admin_or_manager()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Administrators WHERE emp_id = NEW.emp_id) OR EXISTS (SELECT 1 FROM Administrators WHERE emp_id = NEW.emp_id) THEN
        RAISE EXCEPTION 'Part time employee must not be an administrator or manager';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;


DROP TRIGGER IF EXISTS check_part_time_employee ON PartTimeEmployees;
CREATE TRIGGER check_part_time_employee
BEFORE INSERT ON PartTimeEmployees
FOR EACH ROW EXECUTE FUNCTION check_is_not_admin_or_manager();

CREATE OR REPLACE FUNCTION check_removal_condition()
RETURNS TRIGGER AS $$
DECLARE 
temp_date date;
BEGIN 
IF (OLD.depart_date IS NOT NULL AND NEW.depart_date <> OLD.depart_date) THEN
    RAISE EXCEPTION 'Employee already removed';
END IF;

IF EXISTS (SELECT 1 FROM CourseAreas WHERE manager_id = OLD.emp_id) THEN 
    RAISE EXCEPTION 'A manager managing course areas cannot be removed';
END IF;

IF EXISTS (SELECT 1 FROM CourseOfferings WHERE admin_id = OLD.emp_id AND registration_deadline > NEW.depart_date) THEN 
    RAISE EXCEPTION 'An administrator handling a course offering with registration deadline after depart date cannot be removed';
END IF;

SELECT
    sess_date into temp_date
from
    Sessions
where
    instructor_id = OLD.emp_id
ORDER BY
    sess_date desc
LIMIT 1;
IF temp_date > NEW.depart_date THEN 
    RAISE EXCEPTION 'Instructor is teaching a session that starts after the instructor depart date';
END IF;

RETURN NEW;

END;
$$ LANGUAGE PLPGSQL;

-- Ensure instructor or manager or administrator being removed are not teaching any sessions after depart date,
-- managing any course areas, or handling any course offerings
DROP TRIGGER IF EXISTS check_employee_removal ON EMPLOYEES;
CREATE TRIGGER check_employee_removal
BEFORE UPDATE ON Employees
FOR EACH ROW
WHEN 
((NEW.depart_date IS NOT NULL and OLD.depart_date IS NULL)
OR (OLD.depart_date IS NOT NULL AND NEW.depart_date <> OLD.depart_date)
)
EXECUTE FUNCTION check_removal_condition();

-- CHUN YONG'S FUNCTIONS

	-- F23: remove_session

	CREATE OR REPLACE PROCEDURE REMOVE_SESSION(_OFFERING_ID integer, SESSION_NUMBER integer) AS $$
	DELETE FROM Sessions
	WHERE offering_id = _offering_id
	AND sess_num = session_number;
	$$ LANGUAGE SQL;

		-- F24: add_session

	CREATE OR REPLACE FUNCTION GETSESSIONEND(SESSION_START TIMESTAMP, OID integer) RETURNS TIMESTAMP AS $$
	DECLARE
	cid integer;
	_duration integer;
	end_time timestamp;
	BEGIN
	select course_id into cid from CourseOfferings where offering_id = oid;
	select duration into _duration from Courses where course_id = cid;
	end_time := session_start + interval '1h' * _duration;
	RETURN end_time;
	END;
	$$ LANGUAGE PLPGSQL;


	CREATE OR REPLACE PROCEDURE ADD_SESSION(OFFERING_ID integer, SESSION_NUMBER integer, SESSION_DAY date, SESSION_START TIMESTAMP,
	INSTRUCTOR_ID integer, ROOM_ID integer) AS $$
	DECLARE
	session_end timestamp;
	latest_cancel date;
	BEGIN
	latest_cancel := session_day - 7;
	SELECT getSessionEnd(session_start, offering_id) into session_end;
	INSERT INTO Sessions values(DEFAULT, session_number,session_start, session_end, session_day, latest_cancel, instructor_id, offering_id, room_id);
	END;
	$$ LANGUAGE PLPGSQL;

DROP TYPE IF EXISTS emp_type cascade;

DROP TYPE IF EXISTS emp_category cascade;

DROP TYPE IF EXISTS SessionInfo cascade;

CREATE TYPE emp_type AS ENUM ('full_time', 'part_time');

CREATE TYPE emp_category AS ENUM ('administrator', 'manager', 'instructor');

CREATE TYPE SessionInfo AS (
    session_date date,
    session_start timestamp,
    room_id integer
);


create or replace procedure add_employee(
    type emp_type,
    name TEXT,
    address TEXT,
    contact_number integer,
    email TEXT,
    salary numeric,
    join_date date,
    category emp_category,
    areas text []
) 
AS $$ 

DECLARE eid integer;

temp_area text;

BEGIN 

IF (category = 'administrator' AND type = 'part_time') THEN 
    RAISE EXCEPTION  'Administrator must be full time';
END IF;

IF (category = 'manager' AND type = 'part_time') THEN 
    RAISE EXCEPTION 'Manager must be full time';
END IF;

IF (category = 'administrator' and array_length(areas, 1) <> 0) 
THEN 
    RAISE EXCEPTION 'Administrator must have no course areas';
ELSIF (category <> 'administrator' and array_length(areas, 1) IS NULL) THEN 
    RAISE EXCEPTION 'Course area must be specified';
END IF;

INSERT INTO
    Employees
values
    (
        DEFAULT,
        name,
        address,
        contact_number,
        email,
        join_date,
        null
    ) RETURNING emp_id into eid;

IF (type = 'full_time') THEN
    INSERT INTO FullTimeEmployees values(salary, eid);
ELSE
    INSERT INTO PartTimeEmployees values(salary, eid);
END IF;

IF (category = 'instructor') THEN 
    INSERT INTO Instructors values(eid);
END IF;

IF (type = 'full_time' AND category ='instructor') THEN 

    INSERT INTO FullTimeInstructors values(eid);
END IF;

IF (type = 'part_time' AND category ='instructor') THEN 
    INSERT INTO PartTimeInstructors values(eid);
END IF;

    FOREACH temp_area IN ARRAY areas 
    LOOP 
        IF (NOT EXISTS (SELECT 1 FROM COURSEAREAS WHERE course_area = temp_area)) THEN
            RAISE EXCEPTION 'Course area does not exist';
        END IF;
    END LOOP;

IF (category = 'administrator') THEN
    INSERT INTO Administrators values(eid);
ELSIF (category = 'manager') THEN
    INSERT INTO Managers values(eid);
    FOREACH temp_area IN ARRAY areas LOOP
    UPDATE
        CourseAreas
    SET
        manager_id = eid
    where
        course_area = temp_area;
    END LOOP;

ELSE
        FOREACH temp_area IN ARRAY areas LOOP
            INSERT INTO SPECIALIZATIONS VALUES(eid, temp_area);
        END LOOP;
END IF;

COMMIT;
END;

$$ LANGUAGE plpgsql;

-- F2

CREATE OR REPLACE PROCEDURE remove_employee(
    eid integer,
    d_date date
) 
AS $$
DECLARE 
temp_date date;
BEGIN 
IF (NOT EXISTS (SELECT 1 FROM Employees where emp_id = eid)) THEN 
    RAISE EXCEPTION 'Employee does not exist';
END IF;

UPDATE
    Employees
SET
    depart_date = d_date
WHERE
    emp_id = eid;
END;

$$ LANGUAGE PLPGSQL;


-- F5
CREATE OR REPLACE PROCEDURE add_course(
    title text,
    description text,
    area text,
    duration integer
) AS $$ 
INSERT INTO Courses values (DEFAULT, duration, title, description, area);
$$ LANGUAGE SQL;

-- F10

CREATE OR REPLACE FUNCTION getCourseDuration(cid integer) 
RETURNS INTEGER AS $$ 
DECLARE
course_duration integer;
BEGIN 
SELECT duration into course_duration FROM Courses where course_id = cid;
RETURN course_duration;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION getEndDate(session_items SessionInfo []) 
RETURNS DATE AS $$
DECLARE 
curr_date date;
temp_date date;
item SessionInfo;

BEGIN
FOREACH item IN ARRAY session_items LOOP
    curr_date = (item).session_date;
    IF (temp_date IS NULL or curr_date > temp_date) THEN 
        temp_date := curr_date;
    END IF; 
END LOOP;
RETURN temp_date;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE PROCEDURE add_offering(
    offering_id integer,
    start_date date,
    end_date date,
    seating_capacity integer,
    course_id integer,
    fees numeric,
    target_number integer,
    launch_date date,
    registration_deadline date,
    admin_id integer
) AS $$ BEGIN
INSERT INTO
    CourseOfferings
values
(
        offering_id,
        launch_date,
        start_date,
        end_date,
        registration_deadline,
        target_number,
        fees,
        seating_capacity,
        admin_id,
        course_id
    );

END;

$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE PROCEDURE create_sessions(course_id integer, offering_id integer, launch_date date, duration integer, session_items SessionInfo []) AS $$ 
DECLARE 
item SessionInfo;
instructor_id integer;
session_number integer;
latest_cancellation date;
end_time timestamp;
BEGIN -- For each session,
session_number := 1;
-- Use find_instructors (Q6) to get available Instructors
-- If no instructors, raise exception
FOREACH item IN ARRAY session_items LOOP
    SELECT eid into instructor_id FROM find_instructors(course_id, (item).session_date, date_part('hour', (item).session_start) :: INT) LIMIT 1;
    if (instructor_id is NULL) THEN 
        RAISE EXCEPTION 'No instructors available to conduct session';
    END IF;
    end_time := (item).session_start + interval '1h' * duration;
    latest_cancellation = (item).session_date - 7;
    INSERT INTO Sessions values(DEFAULT, 
                                session_number, 
                                (item).session_start,
                                 end_time, 
                                 (item).session_date, 
                                 latest_cancellation, 
                                 instructor_id, 
                                 offering_id, 
                                 (item).room_id);
    session_number := session_number + 1;
END LOOP;
END $$ LANGUAGE PLPGSQL;

-- F10

-- Adds a new Course Offering.
-- Aborts if there are no sessions, session dates are in the past, seating capacity is less than target number, or no instructors
-- are available for one or more sessions.
-- Session end time is determined by start time and duration of course 

CREATE OR REPLACE FUNCTION getSeatingCapacity(_session_items SessionInfo []) 
RETURNS INTEGER AS $$ 
DECLARE 
item SessionInfo;
room_capacity integer;
capacity integer;
BEGIN
capacity := 0;
FOREACH item IN ARRAY _session_items LOOP
SELECT
    seating_capacity into room_capacity
from
    ROOMS
where
    room_id = (item).room_id;

capacity := capacity + room_capacity;
END LOOP;
RETURN capacity;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION getStartDate(session_items SessionInfo []) 
RETURNS DATE AS $$ 
DECLARE 
curr_date date;
temp_date date;
item SessionInfo;

BEGIN
FOREACH item IN ARRAY session_items LOOP
    curr_date = (item).session_date;
    IF (temp_date IS NULL or curr_date < temp_date) THEN 
        temp_date := curr_date;
    END IF; 
END LOOP;
RETURN temp_date;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION getCourseDuration(cid integer) 
RETURNS INTEGER AS $$ 
DECLARE
course_duration integer;
BEGIN 
SELECT duration into course_duration FROM Courses where course_id = cid;
RETURN course_duration;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION getEndDate(session_items SessionInfo []) 
RETURNS DATE AS $$
DECLARE 
curr_date date;
temp_date date;
item SessionInfo;

BEGIN
FOREACH item IN ARRAY session_items LOOP
    curr_date = (item).session_date;
    IF (temp_date IS NULL or curr_date > temp_date) THEN 
        temp_date := curr_date;
    END IF; 
END LOOP;
RETURN temp_date;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE PROCEDURE add_course_offering(
    offering_id integer,
    course_id integer,
    fees numeric,
    target_number integer,
    launch_date date,
    registration_deadline date,
    admin_id integer,
    session_items SessionInfo []
) AS $$ 

DECLARE 

seating_capacity integer;

start_date date;

end_date date;

duration integer;

BEGIN 

IF (array_length(session_items, 1) is NULL) THEN 
    RAISE EXCEPTION 'There must be at least one session';
END IF;

seating_capacity := getSeatingCapacity(session_items);

SELECT getStartDate(session_items) into start_date;

SELECT getEndDate(session_items) into end_date;

SELECT getCourseDuration(course_id) into duration;

CALL add_offering(
    offering_id,
    start_date,
    end_date,
    seating_capacity,
    course_id,
    fees,
    target_number,
    launch_date,
    registration_deadline,
    admin_id
);

CALL create_sessions(course_id, offering_id, launch_date, duration, session_items);

COMMIT;

END;

$$ LANGUAGE plpgsql;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
