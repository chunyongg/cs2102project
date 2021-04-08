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

DROP TRIGGER IF EXISTS check_admin_status ON CourseOfferings;
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
	
-- TRIGGERS AND THEIR FUNCTIONS (put as a pair!)
-- Trigger for sess end time (match duration of course)
CREATE OR REPLACE FUNCTION check_session_end()
RETURNS TRIGGER AS $$
DECLARE
    _course_id INTEGER;
    _duration INTEGER;
    _start_time TIMESTAMP;
    _end_time TIMESTAMP;
    _check_end_time TIMESTAMP;
BEGIN
    _start_time := NEW.start_time;
	_end_time := NEW.end_time;
    SELECT course_id INTO _course_id FROM CourseOfferings WHERE offering_id = NEW.offering_id;
    SELECT duration INTO _duration FROM Courses WHERE course_id = _course_id;
    SELECT (_start_time + (_duration||' hours')::INTERVAL) INTO _check_end_time;
    IF (_end_time <> _check_end_time) THEN
        RAISE EXCEPTION 'Duration of the session does not match the duration of the course';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS check_session_end_trigger ON SESSIONS;
CREATE TRIGGER check_session_end_trigger
BEFORE INSERT OR UPDATE ON Sessions
FOR EACH ROW EXECUTE FUNCTION check_session_end();

-- Trigger for PartTime/FullTime: Instructor only paid once a month, and paid at the end of the month
CREATE OR REPLACE FUNCTION check_ft_salary_payment()
RETURNS TRIGGER AS $$
DECLARE
    _ft_payment_date DATE;
    _last_day_of_month DATE;
    _number_of_payment_dates INTEGER;
BEGIN
    SELECT payment_date INTO _ft_payment_date FROM FullTimeSalary;
    SELECT end_of_month(_ft_payment_date) INTO _last_day_of_month;
    SELECT COUNT(DISTINCT payment_date) INTO _number_of_payment_dates FROM FullTimeSalary 
        WHERE DATE_PART('month', payment_date) = DATE_PART('month', _last_day_of_month) 
        AND DATE_PART('year', payment_date) = DATE_PART('year', _last_day_of_month);
    IF (_ft_payment_date <> _last_day_of_month) THEN
        RAISE EXCEPTION 'Payment date is not at end of the month';
    END IF;
	IF (_number_of_payment_dates > 1) THEN
        RAISE EXCEPTION 'Salaries are paid more than once for this month';
	END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_ft_payment_date_trigger ON FullTimeSalary;
CREATE TRIGGER check_ft_payment_date_trigger
BEFORE INSERT ON FullTimeSalary
FOR EACH ROW EXECUTE FUNCTION check_ft_salary_payment();

CREATE OR REPLACE FUNCTION check_pt_salary_payment()
RETURNS TRIGGER AS $$
DECLARE
    _pt_payment_date DATE;
    _last_day_of_month DATE;
    _number_of_payment_dates INTEGER;
BEGIN
    SELECT payment_date INTO _pt_payment_date FROM PartTimeSalary;
    SELECT end_of_month(_pt_payment_date) INTO _last_day_of_month;
    SELECT COUNT(DISTINCT payment_date) INTO _number_of_payment_dates FROM PartTimeSalary 
        WHERE DATE_PART('month', payment_date) = DATE_PART('month', _last_day_of_month) 
        AND DATE_PART('year', payment_date) = DATE_PART('year', _last_day_of_month);
    IF (_pt_payment_date <> _last_day_of_month) THEN
        RAISE EXCEPTION 'Payment date is not at end of the month';
    END IF;
	IF (_number_of_payment_dates > 1) THEN
        RAISE EXCEPTION 'Salaries are paid more than once for this month';
	END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_pt_payment_date_trigger ON PartTimeSalary;
CREATE TRIGGER check_pt_payment_date_trigger
BEFORE INSERT ON PartTimeSalary
FOR EACH ROW EXECUTE FUNCTION check_pt_salary_payment();

-- TRIGGERS AND THEIR FUNCTIONS (put as a pair!)

-- Trigger which updates Buys after each redemption by a customer
-- The value of the redemptions_left of the customer's course package will decrease after the redemption

CREATE OR REPLACE FUNCTION after_redeem_session_func()
RETURNS TRIGGER AS $$
    BEGIN
			UPDATE Buys SET redemptions_left = redemptions_left - 1 WHERE cust_id = NEW.cust_id;
            RETURN NULL;
	END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS after_redeem_session_trigger ON Redeems;
CREATE TRIGGER after_redeem_session_trigger
AFTER INSERT ON Redeems
FOR EACH ROW EXECUTE FUNCTION after_redeem_session_func();

-- A customer can only register for at most one sessions for each course offering
CREATE OR REPLACE FUNCTION course_session_limit() RETURNS TRIGGER AS $$
declare
    oid integer;
BEGIN
    oid := (select S.offering_id from Sessions S where S.sess_id = New.sess_id);
    if (exists (select SPS.sess_id
        from (SessionParticipants natural join Sessions) SPS
        where SPS.cust_id = New.cust_id
        and SPS.offering_id = oid)) then
        raise exception 'Customer is trying to register for more than one session
            from the same course offering. Process aborted.';
    else
        return new;
    end if;
end;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS register_session_limit_trigger ON REGISTERS;
CREATE TRIGGER register_session_limit_trigger
BEFORE INSERT ON Registers
FOR EACH ROW EXECUTE FUNCTION course_session_limit();

DROP TRIGGER IF EXISTS redeem_session_limit_trigger ON REDEEMS;
CREATE TRIGGER redeem_session_limit_trigger
BEFORE INSERT ON Redeems
FOR EACH ROW EXECUTE FUNCTION course_session_limit();

-- Check Seating Capacity Trigger
-- Only can join/change course offering if there is still seat available for new course offering
CREATE OR REPLACE FUNCTION seating_capacity_limit() RETURNS TRIGGER AS $$
declare
    seats_taken integer;
    seat_limit integer;
BEGIN
    if (TG_OP = 'INSERT' or (TG_OP = 'UPDATE' and old.sess_id <> new.sess_id)) then
        seat_limit := (select R.seating_capacity
            from Sessions S natural join Rooms R
            where S.sess_id = New.sess_id);
        seats_taken := (select count(*)
            from SessionParticipants SP
            where SP.sess_id = New.sess_id);
        if (seats_taken < seat_limit) then
            return new;
        else
            raise exception 'This Session is full, please try another Session.';
        end if;
    else
        return new;
    end if;
end;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS register_exceeded_session_trigger ON Registers;
CREATE TRIGGER register_exceeded_session_trigger
BEFORE INSERT OR UPDATE ON Registers
FOR EACH ROW EXECUTE FUNCTION seating_capacity_limit();

DROP TRIGGER IF EXISTS redeem_exceeded_session_trigger ON REDEEMS;
CREATE TRIGGER redeem_exceeded_session_trigger
BEFORE INSERT OR UPDATE ON Redeems
FOR EACH ROW EXECUTE FUNCTION seating_capacity_limit();

-- Enforce only 1 active/partially package per buyer TRIGGER
-- 'Each customer can have at most one active
-- or partially active package'
CREATE OR REPLACE FUNCTION active_package_limit() RETURNS TRIGGER AS $$
declare
BEGIN
    if (TG_OP = 'INSERT') then
        if (exists (select B.package_id
            from Buys B
            where B.cust_id = New.cust_id
            and B.redemptions_left > 0)) then -- active
            raise exception 'Customer can only have one active package.';
        elsif (exists (select B.package_id
                from Buys B natural join Redeems R natural join Sessions S
                where B.cust_id = New.cust_id
                and S.latest_cancel_date >= CURRENT_DATE)) then -- partially active
            raise exception 'Customer can only have one partially active package.';
        else
            return new;
        end if;
    end if;
end;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS buy_excessive_active_package_trigger ON BUYS;
CREATE TRIGGER buy_excessive_active_package_trigger
BEFORE INSERT ON Buys
FOR EACH ROW EXECUTE FUNCTION active_package_limit();

-- Trigger for when inserting Redemptions into Redeems -> need ensure it corr to redemptions left in Buys
-- Redeem(redeem_date, sess_id, package_id, cust_id)

CREATE OR REPLACE FUNCTION redeem_sess() RETURNS TRIGGER AS $$
declare
    r_left integer;
begin
    select redemptions_left into r_left
        from Buys
        where cust_id = New.cust_id
        and package_id = New.package_id;
    if (r_left = 0) then
        raise exception 'There is no more redemptions left in the package, redemption of new session failed.';
    else
        return new;
    end if;
end;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS redeem_session_trigger ON REDEEMS;
CREATE TRIGGER redeem_session_trigger
BEFORE INSERT ON Redeems
FOR EACH ROW EXECUTE FUNCTION redeem_sess();

-- Trigger on Updating CreditCard
-- Check expiry day is not before current date

CREATE OR REPLACE FUNCTION update_cc() RETURNS TRIGGER AS $$
BEGIN
    if (New.expiry_date <= current_date) then
        raise exception 'Credit Card has expired, please update with a valid card.';
    else
        return New;
    end if;
end;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_cc_trigger ON CreditCards;
CREATE TRIGGER update_cc_trigger
BEFORE INSERT or UPDATE ON CreditCards
FOR EACH ROW EXECUTE FUNCTION update_cc();

-- Check that current date within sale range before buying course package

CREATE OR REPLACE FUNCTION check_sale_period()
RETURNS TRIGGER AS $$
declare
    _sale_start date;
    _sale_end date;
begin
    select CP.sale_start_date, CP.sale_end_date
        into _sale_start, _sale_end
        from CoursePackages CP
        where CP.package_id = New.package_id;
        if (CURRENT_DATE not between _sale_start and _sale_end) then
            raise exception 'Course Package not available for Sale.';
        end if;
        return New;
end;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS buy_package_trigger ON Buys;
CREATE TRIGGER buy_package_trigger
BEFORE INSERT ON Buys
FOR EACH ROW EXECUTE FUNCTION check_sale_period();

-- Do not allow change in session if session started
CREATE OR REPLACE FUNCTION check_session_period()
RETURNS TRIGGER AS $$
declare
    _curr_sess_start date;
    _new_sess_start date;
begin
    select S.start_time
    into _curr_sess_start
    from Sessions S
    where S.sess_id = old.sess_id;
    select S.start_time
    into _new_sess_start
    from Sessions S
    where S.sess_id = new.sess_id;
    if (_curr_sess_start <= LOCALTIMESTAMP or _new_sess_start <= LOCALTIMESTAMP) THEN
	    RAISE EXCEPTION 'Session already started';
    end if;
    return New;
end;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS change_reg_session_trigger ON REGISTERS;
CREATE TRIGGER change_reg_session_trigger
BEFORE UPDATE ON Registers
FOR EACH ROW EXECUTE FUNCTION check_session_period();

DROP TRIGGER IF EXISTS change_redeem_session_trigger ON REDEEMS;
CREATE TRIGGER change_redeem_session_trigger
BEFORE UPDATE ON Redeems
FOR EACH ROW EXECUTE FUNCTION check_session_period();

CREATE OR REPLACE FUNCTION insertHoursWorked_partTimeInstructor()
RETURNS TRIGGER AS $$
DECLARE 
inst_id integer;
new_hours_worked integer;
BEGIN 
    inst_id := NEW.instructor_id;
        IF (NOT EXISTS (SELECT 1 FROM PartTimeInstructors WHERE emp_id = inst_id)) THEN 
        RETURN NULL;
    END IF;
        new_hours_worked := get_difference_in_hours(NEW.end_time, NEW.start_time);
        INSERT INTO PartTimeHoursWorked 
        VALUES (new_hours_worked, date_trunc('month', NEW.sess_date), inst_id)
        ON CONFLICT (month_year, emp_id) DO UPDATE SET hours_worked = EXCLUDED.hours_worked + new_hours_worked;
    RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS insert_part_time_hours ON SESSIONS;
CREATE TRIGGER insert_part_time_hours
AFTER INSERT ON SESSIONS 
FOR EACH ROW EXECUTE FUNCTION insertHoursWorked_partTimeInstructor();

CREATE OR REPLACE FUNCTION removeHoursWorked_partTimeInstructor()
RETURNS TRIGGER AS $$
DECLARE 
inst_id integer;
old_hours_worked integer;
BEGIN 
    inst_id := OLD.instructor_id;
        IF (NOT EXISTS (SELECT 1 FROM PartTimeInstructors WHERE emp_id = inst_id)) THEN 
        RETURN NULL;
    END IF;
    old_hours_worked := get_difference_in_hours(OLD.end_time, OLD.start_time);

    UPDATE PartTimeHoursWorked
    SET hours_worked = hours_worked - old_hours_worked
    WHERE emp_id = OLD.instructor_id AND month_year = date_trunc('month', OLD.sess_date);
    RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS after_sess_delete_update_pt_hours ON SESSIONS;
CREATE TRIGGER after_sess_delete_update_pt_hours
AFTER DELETE ON SESSIONS
FOR EACH ROW EXECUTE FUNCTION removeHoursWorked_partTimeInstructor();


CREATE OR REPLACE FUNCTION updateHoursWorked_partTimeInstructor()
RETURNS TRIGGER AS $$
DECLARE 
inst_id integer;
old_hours_worked integer;
new_hours_worked integer;
BEGIN 
    inst_id := NEW.instructor_id;

    old_hours_worked := get_difference_in_hours(OLD.end_time, OLD.start_time);
    new_hours_worked := get_difference_in_hours(NEW.end_time, NEW.start_time);

    INSERT INTO PartTimeHoursWorked 
    VALUES (new_hours_worked, date_trunc('month', NEW.sess_date), inst_id)
    ON CONFLICT (month_year, emp_id) DO UPDATE SET hours_worked = EXCLUDED.hours_worked + new_hours_worked;
    
    UPDATE PartTimeHoursWorked
    SET hours_worked = hours_worked - old_hours_worked
    WHERE emp_id = OLD.instructor_id AND month_year = date_trunc('month', OLD.sess_date);

RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS update_part_time_hours ON Sessions; 
CREATE TRIGGER update_part_time_hours
AFTER UPDATE ON SESSIONS 
FOR EACH ROW EXECUTE FUNCTION updateHoursWorked_partTimeInstructor();