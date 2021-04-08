----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGERS AND THEIR FUNCTIONS (put as a pair!)

CREATE OR REPLACE FUNCTION check_isNot

CREATE OR REPLACE FUNCTION reject_operation()
RETURNS TRIGGER AS $$ 
BEGIN 
    RETURN OLD;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION reject_course_offering_changes()
BEFORE UPDATE OR DELETE ON COURSEOFFERINGS 
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
BEFORE INSERT ON REGISTERS 
FOR EACH ROW EXECUTE FUNCTION before_register_check_has_not_registered();
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
