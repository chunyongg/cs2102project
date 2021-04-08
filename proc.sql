----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGERS AND THEIR FUNCTIONS (put as a pair!)

CREATE OR REPLACE FUNCTION prevent_both_full_and_part_time_instructor()
RETURNS TRIGGER AS $$ 
DECLARE 
existing_emp_type text;
BEGIN 
    SELECT emp_type into existing_emp_type FROM InstructorWorkingTypes WHERE emp_id = NEW.emp_id;
    IF existing_emp_type IS NOT NULL THEN 
        RAISE EXCEPTION '% is already a % instructor', NEW.emp_id, existing_emp_type;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS prevent_full_time_instructor ON FullTimeInstructors;
CREATE TRIGGER prevent_full_time_instructor
BEFORE INSERT OR UPDATE ON FullTimeInstructors
FOR EACH ROW EXECUTE FUNCTION prevent_both_full_and_part_time_instructor();

DROP TRIGGER IF EXISTS prevent_part_time_instructor ON PartTimeInstructors;
CREATE TRIGGER prevent_part_time_instructor
BEFORE INSERT OR UPDATE ON PartTimeInstructors
FOR EACH ROW EXECUTE FUNCTION prevent_both_full_and_part_time_instructor();

CREATE OR REPLACE FUNCTION prevent_both_full_and_part_time()
RETURNS TRIGGER AS $$ 
DECLARE 
existing_emp_type text;
BEGIN 
    SELECT emp_type into existing_emp_type FROM EmployeeWorkingTypes WHERE emp_id = NEW.emp_id;
    IF existing_emp_type IS NOT NULL THEN 
        RAISE EXCEPTION '% Is already a % employee', NEW.emp_id, existing_emp_type;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS prevent_full_time_insert_is_part_time ON FullTimeEmployees;
CREATE TRIGGER prevent_full_time_insert_is_part_time
BEFORE INSERT OR UPDATE ON FullTimeEmployees
FOR EACH ROW EXECUTE FUNCTION prevent_both_full_and_part_time();

DROP TRIGGER IF EXISTS prevent_part_time_insert_is_full_time ON PartTimeEmployees;
CREATE TRIGGER prevent_part_time_insert_is_full_time 
BEFORE INSERT OR UPDATE ON PartTimeEmployees
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
BEFORE INSERT OR UPDATE ON Administrators
FOR EACH ROW EXECUTE FUNCTION check_isNot_Existing();

DROP TRIGGER IF EXISTS check_isNot_existing_when_adding_manager ON Managers;
CREATE TRIGGER check_isNot_existing_when_adding_manager
BEFORE INSERT OR UPDATE ON MANAGERS
FOR EACH ROW EXECUTE FUNCTION check_isNot_Existing();

DROP TRIGGER IF EXISTS check_isNot_existing_when_adding_instructor ON Instructors;
CREATE TRIGGER check_isNot_existing_when_adding_instructor
BEFORE INSERT OR UPDATE ON Instructors
FOR EACH ROW EXECUTE FUNCTION check_isNot_Existing();


CREATE OR REPLACE FUNCTION reject_operation()
RETURNS TRIGGER AS $$ 
BEGIN 
    RAISE EXCEPTION 'Operation denied';
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS reject_course_offering_changes ON CourseOfferings;
CREATE TRIGGER reject_course_offering_changes
BEFORE DELETE ON COURSEOFFERINGS 
FOR EACH ROW EXECUTE FUNCTION reject_operation();


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
    IF EXISTS (SELECT 1 FROM SessionParticipants WHERE cust_id = NEW.cust_id AND sess_id = NEW.sess_id) THEN 
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


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
