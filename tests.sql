
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S TESTS

-- F30
SELECT get_sales('2019-03-01') -- 0
SELECT get_sales('2030-03-01') -- 0
SELECT get_sales('2021-03-01') -- non-null positive value
SELECT get_salary('2019-03-01') -- 0
SELECT get_salary('2030-03-01') -- 0
SELECT get_salary('2021-03-01') -- non-null positive value
SELECT get_registration_fees('2021-07-30') -- non-null positive value
SELECT get_registration_fees('2019-07-30') -- 0
SELECT get_registration_fees('2021-07-30') -- 0
SELECT get_course_redemptions('2021-03-05') --1
SELECT get_course_redemptions('2019-04-05') -- 0
SELECT get_course_redemptions('2030-04-05') -- 0
SELECT get_refunded_fees('2021-03-01') -- non-null positive value
SELECT get_refunded_fees('2019-03-01') -- 0
SELECT get_refunded_fees('2030-04-05') -- 0
SELECT * FROM view_summary_report(0) -- Error
SELECT * FROM view_summary_report(-3) -- Error
SELECT * FROM view_summary_report(null) -- Error
SELECT * FROM view_summary_report(200) -- Lots of rows with zeros in them rows 
SELECT * FROM view_summary_report(3) --  5 columns, 3 rows, all non-null values

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S TESTS

--F23
CALL remove_session(7, 1); -- Session already started
CALL remove_session(7, 4) -- Note: Update sess_num before running, should succeed

--F24
CALL add_session(1, 2, '2021-05-03', '2021-05-03 17:00', 25, 7) -- Instructor already teaching
CALL add_session(1, 2, '2021-04-03', '2021-05-03 17:00', 25, 7) -- Session in past
CALL add_session(1, 2, '2021-04-05', '2021-05-03 17:00', 25, 7) -- Instructor does not specialize in area
CALL add_session(1, 2, '2021-07-01', '2021-07-01 10:00', 25, 6) -- Room occupied
CALL add_session(8, 4, '2021-08-01','2021-07-01 14:00' , 27, 6); -- Instructor left

CALL add_session(21, 2, '2021-05-03', '2021-05-03 14:00', 29, 7) 
CALL remove_session(21, 2)
-- Check course offering seating capacity afterwards

CALL add_session(7, 4, '2021-07-01','2021-07-01 14:00' , 30, 6); --Note: Replace with latest session number, should succeed
-- Should fail

-- F1
--manager must be full time
CALL add_employee('part_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{"Game Design"}');
-- admin must be full time
CALL add_employee('part_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'administrator', '{}'); 
-- Admin must not handle any area at time of creation
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'administrator', '{"Game Design"}');
-- Manager must manage at least one area
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{}');
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{"Game Designhnrrn"}'); --No such area
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{"Game Design"}'); -- Pass
CALL add_employee('full_time', 'Maynard', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'instructor', '{"Game Design"}'); -- Pass
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'administrator', '{}'); -- Pass

--F2
 -- Manager managing course areas cannot be removed
CALL remove_employee(11, '2021-02-21')
-- Employee already left
CALL remove_employee(40, '2021-05-21')
CALL REMOVE_EMPLOYEE(343333, '2021-04-21') -- Does not exist
--F5 
CALL add_course('EC1101', 'Learn all about Economics', 'Economics', 5); -- No such course area
CALL add_course('GD1101', 'Learn all about Games', 'Game Design', 5); -- Pass

--F10
-- Sessions cannot be empty
CALL add_course_offering(11, 1, 300, 10, '2021-05-21', '2021-05-11', 42, '{}' :: SessionInfo[])
-- Session capacity less than target number
CALL add_course_offering(11, 1, 300, 200, '2021-05-21', '2021-05-11', 42, '{"(2021-05-21,\"2021-05-21 00:00:00\",1)"}' :: SessionInfo[])
-- Should pass
-- Toggle room_id and/or offering_id if it fails
CALL add_course_offering(23, 35, 300, 5, '2021-05-21', '2021-05-11', 7, 
'{"(2021-05-21,\"2021-05-21 15:00:00\",6)", "(2021-05-21,\"2021-05-21 09:00:00\",6)"}' :: SessionInfo[]
)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE'S TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TRigger tests

INSERT INTO INSTRUCTORS VALUES(37) -- Manager exists
INSERT INTO PartTimeInstructors values('Database Systems', 25) -- Is full time
INSERT INTO FULLTIMEEMPLOYEES VALUES(300, 27) -- Is part time
INSERT INTO FULLTIMEEMPLOYEES VALUES(300, 27) -- Is full time