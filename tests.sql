add_session(offering_id integer, 
                                        session_number integer, 
                                        session_day date, 
                                        session_start timestamp, 
                                        instructor_id integer,
                                        room_id integer)


-- Should fail
CALL add_session(1, 2, '2021-05-03', '2021-05-03 17:00', 25, 7) -- Instructor already teaching
CALL add_session(1, 2, '2021-04-03', '2021-05-03 17:00', 25, 7) -- Session in past
CALL add_session(1, 2, '2021-04-05', '2021-05-03 17:00', 25, 7) -- Instructor does not specialize in area
CALL add_session(1, 2, '2021-07-01', '2021-07-01 10:00', 25, 6) -- Room occupied
CALL add_session(7, 2, '2021-07-01', '2021-07-01 14:00', 30, 6) -- Hours taught exceeded