----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS

-- F8
CREATE OR REPLACE FUNCTION find_rooms (_start_time TIMESTAMP, _duration INT)
RETURNS TABLE(_room_id INT) AS $$
    DECLARE
        _day INT := extract(dow from _start_time);
        _hour INT := date_part('hour', _start_time);
    BEGIN
        IF _day in (0,6) THEN
        raise exception 'No course sessions will be held during weekends.';
        ELSIF _hour not in (9,10,11,14,15,16,17) THEN
            raise exception 'No course sessions will be held during non-operational hours.';
        END IF;
        RETURN QUERY
        SELECT distinct room_id
        FROM Rooms
        EXCEPT
        SELECT distinct room_id
        FROM Sessions
        WHERE (start_time, end_time) overlaps (_start_time, _start_time + interval '1h' * _duration)
        ORDER BY room_id;
    END;
$$ LANGUAGE PLPGSQL
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
