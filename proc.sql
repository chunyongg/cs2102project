-- Q23: remove_session
CREATE OR REPLACE PROCEDURE remove_session(offering_id integer, session_number integer)
AS $$ 
BEGIN 
DELETE FROM Sessions 
WHERE offering_id = offering_id 
AND sess_number = session_number;
END;
$$ LANGUAGE PLPGSQL;

-- Removal fails if: Session has started or if there is at least one registration/redemption for the session
CREATE OR REPLACE FUNCTION check_session_removal() 
RETURNS TRIGGER AS $$
DECLARE 
registered_cust integer;
redeemed_cust integer;
curr_time timestamp;
BEGIN 
SELECT LOCALTIMESTAMP INTO curr_time; 
IF (OLD.start_time <= LOCALTIMESTAMP) THEN 
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

END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS before_session_removal ON Sessions;
CREATE TRIGGER before_session_removal
BEFORE DELETE ON Sessions 
FOR EACH ROW EXECUTE FUNCTION check_session_removal();


-- Q24: add_session
CREATE OR REPLACE FUNCTION getSessionEnd(session_start timestamp, offering_id integer) 
RETURNS timestamp AS $$ 
DECLARE 
course_id integer;
duration integer; 
end_time timestamp;
BEGIN 
select course_id into course_id from CourseOfferings where offering_id = offering_id;
select duration into duration from Courses where course_id = course_id;
end_time := session_start + interval '1h' * duration;
RETURN end_time;
END; 
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE PROCEDURE add_session(offering_id integer, 
                                        session_number integer, 
                                        session_day date, 
                                        session_start timestamp, 
                                        instructor_id integer,
                                        room_id integer)
AS $$ 
DECLARE 
session_end timestamp;
latest_cancel date; 
BEGIN 
latest_cancel := session_day - 7;
SELECT getSessionEnd(session_start, offering_id) into session_end;
INSERT INTO Sessions values(DEFAULT, session_number,session_start, session_end, session_day, latest_cancel, instructor_id, offering_id, room_id);
END;
$$ LANGUAGE PLPGSQL;

-- Fails if: Instructor does not specialize in area, is teaching consecutive sessions, (for part time) is teaching more than 30 hours,
-- is teaching two sessions simultaneously, room is occupied
-- part time check not implemented yet
-- Updates capacity of course offering
CREATE OR REPLACE FUNCTION check_session_add()
RETURNS TRIGGER AS $$ 
DECLARE 
carea text;
instructor_spec text;
cid integer;
curr_time timestamp;
registration_deadline date;
other_session_id integer;
same_room_session_id integer;
capacity integer;
BEGIN 

SELECT LOCALTIMESTAMP into curr_time;
IF (NEW.start_time <= LOCALTIMESTAMP) THEN 
    RAISE EXCEPTION 'Session must start in the future';
END IF;

SELECT course_id into cid from CourseOfferings where offering_id = NEW.offering_id;
SELECT course_area into carea from Courses where course_id = cid;
SELECT course_area into instructor_spec from FullTimeInstructors, PartTimeInstructors where emp_id = NEW.instructor_id limit 1;
IF (instructor_spec <> carea) THEN 
    RAISE EXCEPTION 'Instructor does not specialize in area taught';
END IF;

SELECT session_id INTO other_session_id FROM Sessions WHERE 
sess_id <> NEW.sess_id AND instructor_id = NEW.instructor_id 
AND sess_date = NEW.sess_date AND start_time >= NEW.start_time 
AND end_time <= NEW.end_time
limit 1;
IF (other_session_id IS NOT NULL) THEN 
    RAISE EXCEPTION 'Instructor is already teaching at this time';
END IF;

SELECT session_id into same_room_session_id FROM Sessions 
WHERE sess_id <> NEW.sess_id AND room_id = NEW.room_id 
AND sess_date = NEW.sess_date AND start_time >= NEW.start_time
AND end_time <= NEW.end_time
limit 1;
if (same_room_session_id IS NOT NULL) THEN 
    RAISE EXCEPTION 'Room is occupied at this time';
END IF;

SELECT seating_capacity INTO capacity FROM Rooms WHERE room_id = NEW.room_id;
UPDATE CourseOfferings 
SET seating_capacity = seating_capacity + capacity
WHERE offering_id = NEW.offering_id;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS before_session_add ON Sessions;
CREATE TRIGGER before_session_add
BEFORE INSERT OR UPDATE on Sessions 
FOR EACH ROW EXECUTE FUNCTION check_session_add();

