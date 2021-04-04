-- Q23: remove_session

CREATE OR REPLACE PROCEDURE REMOVE_SESSION(_OFFERING_ID integer, SESSION_NUMBER integer) AS $$
    BEGIN
    DELETE FROM Sessions
    WHERE offering_id = _offering_id
    AND sess_num = session_number;
    END;
    $$ LANGUAGE PLPGSQL;

-- Removal fails if: Session has started or if there is at least one registration/redemption for the session

CREATE OR REPLACE FUNCTION CHECK_SESSION_REMOVAL() RETURNS TRIGGER AS $$
    DECLARE
    registered_cust integer;
    redeemed_cust integer;
    curr_time timestamp;
    capacity integer;
    BEGIN
    SELECT LOCALTIMESTAMP INTO curr_time;
    IF (OLD.start_time <= curr_time) THEN

        RAISE EXCEPTION 'Session has already started and cannot be removed';
    END IF;

    SELECT cust_id INTO registered_cust FROM Registers
    Where sess_id = OLD.sess_id
    limit 1;

    SELECT cust_id INTO redeemed_cust FROM Redeems
    Where sess_id = OLD.sess_id
    limit 1;

    IF (registered_cust IS NOT NULL OR redeemed_cust IS NOT NULL) THEN
        Raise Exception 'A session with customers cannot be removed';
    END IF;

    SELECT seating_capacity INTO capacity FROM Rooms WHERE room_id = OLD.room_id;
    UPDATE CourseOfferings
    SET seating_capacity = seating_capacity - capacity
    WHERE offering_id = OLD.offering_id;
    RETURN OLD;
    END;
    $$ LANGUAGE PLPGSQL;


DROP TRIGGER IF EXISTS BEFORE_SESSION_REMOVAL ON SESSIONS;


CREATE TRIGGER BEFORE_SESSION_REMOVAL
BEFORE
DELETE ON SESSIONS
FOR EACH ROW EXECUTE FUNCTION CHECK_SESSION_REMOVAL();

-- Q24: add_session

CREATE OR REPLACE FUNCTION GETSESSIONEND(SESSION_START TIMESTAMP,

																															OID integer) RETURNS TIMESTAMP AS $$
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


CREATE OR REPLACE VIEW INSTRUCTORSPECIALIZATIONS AS
SELECT * FROM SPECIALIZATIONS;

-- Fails if: Instructor does not specialize in area, is teaching consecutive sessions, (for part time) is teaching more than 30 hours,
 -- is teaching two sessions simultaneously, room is occupied
 -- Updates capacity of course offering

CREATE OR REPLACE FUNCTION CHECK_SESSION_ADD() RETURNS TRIGGER AS $$
    DECLARE
    carea text;
    cid integer;
    curr_time timestamp;
    registration_deadline date;
    other_session_id integer;
    same_room_session_id integer;
    _duration integer;
    hours_taught integer;
    d_date date;
    BEGIN

    SELECT LOCALTIMESTAMP into curr_time;
    IF (NEW.start_time <= LOCALTIMESTAMP) THEN
        RAISE EXCEPTION 'Session must start in the future';
    END IF;

    SELECT course_id into cid from CourseOfferings where offering_id = NEW.offering_id;
    SELECT duration, course_area into _duration, carea from Courses where course_id = cid;


    IF (NOT EXISTS (SELECT 1 FROM InstructorSpecializations WHERE emp_id = NEW.instructor_id AND course_area = carea)) THEN
        RAISE EXCEPTION 'Instructor does not specialize in area taught';
    END IF;


    SELECT sess_id INTO other_session_id FROM Sessions WHERE
    sess_id <> NEW.sess_id AND instructor_id = NEW.instructor_id
    AND sess_date = NEW.sess_date AND start_time >= NEW.start_time
    AND end_time <= NEW.end_time
    limit 1;
    IF (other_session_id IS NOT NULL) THEN
        RAISE EXCEPTION 'Instructor is already teaching at this time';
    END IF;

    SELECT get_monthly_hours(NEW.instructor_id, DATE_PART('month', NEW.sess_date), DATE_PART('year', NEW.sess_date)) INTO hours_taught;

    IF (hours_taught + _duration > 30 AND EXISTS (SELECT 1 FROM PartTimeEmployees WHERE emp_id = NEW.instructor_id)) THEN
        RAISE EXCEPTION 'Part time instructor must not teach more than 30 hours in a month';
    END IF;

    SELECT depart_date INTO d_date FROM Employees WHERE emp_id = NEW.instructor_id;

    IF (d_date IS NOT NULL AND d_date <= NEW.sess_date) THEN 
        RAISE EXCEPTION 'Instructor left already';
    END IF;

    SELECT sess_id into same_room_session_id FROM Sessions
    WHERE sess_id <> NEW.sess_id AND room_id = NEW.room_id
    AND sess_date = NEW.sess_date AND start_time >= NEW.start_time
    AND end_time <= NEW.end_time
    limit 1;
    if (same_room_session_id IS NOT NULL) THEN
        RAISE EXCEPTION 'Room is occupied at this time';
    END IF;

    RETURN NEW;
    END;
    $$ LANGUAGE PLPGSQL;


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
    ELSIF (TG_OP = 'UPDATE' AND NEW.room_id <> OLD.room_id AND NEW.offering_id = OLD.offering_id) THEN
        SELECT seating_capacity INTO old_capacity FROM Rooms WHERE room_id = OLD.room_id;
                SELECT seating_capacity INTO new_capacity FROM Rooms WHERE room_id = NEW.room_id;
    UPDATE CourseOfferings
    SET seating_capacity = seating_capacity - old_capacity + new_capacity
    WHERE offering_id = NEW.offering_id;
    END IF;
    RETURN NULL;

END;
$$ LANGUAGE PLPGSQL;


DROP TRIGGER IF EXISTS AFTER_SESSION_ADD ON SESSIONS;


CREATE TRIGGER AFTER_SESSION_ADD AFTER
INSERT
OR
UPDATE ON SESSIONS
FOR EACH ROW EXECUTE FUNCTION AFTER_SESS_ADD();


DROP TRIGGER IF EXISTS BEFORE_SESSION_ADD ON SESSIONS;


CREATE TRIGGER BEFORE_SESSION_ADD
BEFORE
INSERT
OR
UPDATE ON SESSIONS
FOR EACH ROW EXECUTE FUNCTION CHECK_SESSION_ADD();