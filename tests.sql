CREATE
OR REPLACE PROCEDURE remove_session(offering_id integer, session_number integer) -- Should fail
CALL add_session(1, 2, '2021-05-03', '2021-05-03 17:00', 25, 7) -- Instructor already teaching
CALL add_session(1, 2, '2021-04-03', '2021-05-03 17:00', 25, 7) -- Session in past
CALL add_session(1, 2, '2021-04-05', '2021-05-03 17:00', 25, 7) -- Instructor does not specialize in area
CALL add_session(1, 2, '2021-07-01', '2021-07-01 10:00', 25, 6) -- Room occupied
CALL remove_session(7, 1); -- Session already started
-- Should succeed
CALL add_session(7, 4, '2021-07-01','2021-07-01 14:00' , 30, 6); --Note: Replace with latest session number
CALL remove_session(7, 4) -- Note: Update sess_num before running

INSERT INTO Sessions values(DEFAULT, 4, '2021-07-01 14:00', '2021-07-01 17:00', '2021-07-01', '2021-06-24', 30, 7, 6);