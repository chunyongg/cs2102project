----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's TESTS

-- F8
-- Note: These tests focus on room 1, which is used on this date from 9am-10am, 11am-12pm, 2pm-3pm
select * from find_rooms('2021-01-01 09:00:00', 1) -- no, room 1 isnt available
select * from find_rooms('2021-01-01 10:00:00', 1) -- yes, room 1 is available
select * from find_rooms('2021-01-01 10:30:00', 1) -- no
select * from find_rooms('2021-01-01 11:00:00', 1) -- no
select * from find_rooms('2021-01-01 11:30:00', 1) -- no
select * from find_rooms('2021-01-01 12:00:00', 1) -- invalid as it is a non-operational hours
select * from find_rooms('2021-04-10 09:00:00', 1) -- invalid as it is a weekend
select * from find_rooms('2021-04-06 12:00:00', 1) -- invalid as it is a non-operational hour

-- F9
select * from get_available_rooms('2021-01-04', '2021-01-05') -- returns (1, 20, 2021-01-04, {10,14,16}) as it is used from 9am-10am, 11am-12pm, 3pm-4pm, 5pm-6pm
select * from get_available_rooms('2021-01-08', '2021-01-08') -- returns {9}
select * from get_available_rooms('2021-01-06', '2021-01-05') -- invalid as start date is before end date

-- F11
call add_course_package ('Valentines Day Sale', 2, '2021-02-01', '2021-02-14', 2222)

-- F12
select * from get_available_course_packages() -- returns 2021 Sale and April Flash Sale since we're querying in April 2021

-- F17
-- Testing for errors:
call register_session(5, 4, 1, 'payment') -- Error: The registration deadline has passed.
call register_session(2, 6, 1, 'lala') -- Error: You may register for the session via payment or redemption only.
call register_session(9, 7, 1, 'redemption') -- Error: You do not have a package to redeem sessions from.
-- Testing for functionality:
call register_session(5, 5, 1, 'payment') -- insert into registers
call register_session(6, 6, 1, 'redemption') -- update buys, insert into redeems
call register_session(6, 6, 1, 'redemption') -- invalid as the customer has already registered for one of this courses sessions
call register_session(6, 6, 1, 'redemption') -- invalid as the customer has already registered for one of this courses sessions
call register_session(2, 7, 1, 'redemption') -- update buys, insert into redeems

-- F18
select * from get_my_registrations(1) -- returns 2 records

-- F26
select * from promote_courses() -- returns all course offerings that haven't ended registration, for all courses that each inactive customer is interested in

-- F27
select * from top_packages(500) -- returns all packages
select * from top_packages(3) -- returns top 3 packages
select * from top_packages(2) -- returns top 2 packages
select * from top_packages(1) -- returns top 1 package
select * from top_packages(0) -- exception raised
select * from top_packages(-1) -- exception raised

-- F28
select * from popular_courses()
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
-- MICH's TESTS (WIP, need to create new data first)
-- F6
select * from find_instructors(1, '2021-05-03', 8);  -- invalid session start hour
select * from find_instructors(1, '2021-05-03', 12); -- invalid session start hour
select * from find_instructors(1, '2021-05-03', 17); 
select * from find_instructors(1, '2021-05-03', 10); -- instructor 21 teaching
select * from find_instructors(1, '2021-05-03', 14); -- instructor 26 free
-- F7
select * from get_available_instructors (1, '2021-05-01', '2021-08-01') ;
-- all days except weekend
-- contains only instructor from same course area
-- F15
select * from get_available_course_offerings();
-- F16
select * from get_available_course_sessions(1);
select * from get_available_course_sessions(8);
select * from get_available_course_sessions(11);
-- F21
call update_instructor(1, 1, 21);
call update_instructor(1, 1, 22); -- instructor does not specialise in the course
call update_instructor(3, 1, 39); -- instructor haven't join yet
call update_instructor(2, 1, 40); -- instructor departed alr
-- F22
call update_room(1, 1, 3); -- room is taken by another session
-- Not tested: registered > capacity
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
