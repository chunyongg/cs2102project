CALL add_employee('part_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{"Game Design"}');
-- admin must be full time
CALL add_employee('part_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'administrator', '{}'); 
-- Admin must not handle any area at time of creation
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'administrator', '{"Game Design"}');
-- Manager must manage at least one area
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{}');
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{"Game Design"}'); -- Pass
-- Course area does not exist
CALL add_employee('full_time', 'Maynard', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'instructor', '{"Game Desigwsdsdn"}');
-- Pass
CALL add_employee('full_time', 'Maynard', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'instructor', '{"Game Design"}'); 
-- Pass
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'administrator', '{}'); -- Pass

--F2
 -- Manager managing course areas cannot be removed
CALL remove_employee(11, '2021-02-21');
-- Employee already left
CALL remove_employee(26, '2021-05-21');
CALL REMOVE_EMPLOYEE(343333, '2021-04-21'); -- Does not exist
CALL remove_employee(41, '2021-'); -- Succeed

--F5
CALL add_course('EC1101', 'Learn all about Economics', 'Economics', 5); -- No such course area
CALL add_course('GD1101', 'Learn all about Games', 'Game Design', 5); -- Pass

--F10
-- Sessions cannot be empty
CALL add_course_offering(23, 2, 300, 10, '2021-05-21', '2021-05-11', 1, '{}' :: SessionInfo[]);
-- Launch date after registration deadline
CALL add_course_offering(23, 2, 300, 200, '2021-05-21', '2021-05-11', 1, '{"(2021-05-21,\"2021-05-21 09:00:00\",1)"}' :: SessionInfo[]);
-- Registration deadline less than 10 days before start date
CALL add_course_offering(23, 2, 300, 200, '2021-05-11', '2021-05-20', 1, '{"(2021-05-29,\"2021-05-29 09:00:00\",1)"}' :: SessionInfo[]);
-- Session capacity less than target number
CALL add_course_offering(23, 2, 300, 200, '2021-05-11', '2021-05-11', 1, '{"(2021-05-21,\"2021-05-21 09:00:00\",1)"}' :: SessionInfo[]);
-- Should pass
-- Toggle room_id and/or offering_id if it fails
CALL add_course_offering(23, 2, 300, 20, '2021-05-11', '2021-05-11', 1, '{"(2021-05-21,\"2021-05-21 09:00:00\",1)"}' :: SessionInfo[]);


--F24

CALL add_session(2, 2, '2021-06-02', '2021-06-02 10:00', 21, 7); -- Instructor already teaching at 11am, session duration is 2hrs
CALL add_session(1, 2, '2021-04-03', '2021-04-03 17:00', 25, 7); -- Session in past
CALL add_session(1, 2, '2021-05-03', '2021-05-04 17:00', 21, 7);-- Start date and start time does not tally
CALL add_session(3, 2, '2021-05-03', '2021-05-03 09:00', 21, 7); -- Instructor does not specialize in area
CALL add_session(3, 2, '2021-06-02', '2021-06-02 09:00', 22, 1); -- Room occupied from 11am onwards, session duration is 3hrs
CALL add_session(3, 2, '2021-06-02', '2021-06-02 16:00', 22, 2); -- Cannot end at 7pm
CALL add_session(3, 2, '2021-06-02', '2021-06-02 08:00', 22, 2); -- Cannot start at 8am
CALL add_session(8, 4, '2021-04-17','2021-04-17 14:00' , 21, 6); -- Cannot start on weekends
CALL add_session(3, 2, '2021-05-03', '2021-05-03 09:00', 38, 7); -- Instructor departed
CALL add_session(3, 2, '2021-05-31', '2021-05-31 09:00', 36, 7); -- Adding session less than 10 days after registration deadline
CALL add_session(3, 2, '2021-06-07', '2021-06-07 09:00', 36, 7); -- Passes
CALL add_session(3, 3, '2021-06-08', '2021-06-08 09:00', 36, 7); -- Passes

-- F23
CALL remove_session(2, 2) -- Session started, cannot be removed
------------
-- FAILS
CALL register_session(25, 3, 2, 'payment');
CALL remove_session(3, 2); -- Customer registered, cannot remove
---------------
--PASSES
CALL add_session(3, 3, '2021-06-08', '2021-06-08 09:00', 36, 7); -- Passes
CALL remove_session(3, 3); -- Succeeds
-------------

--F25
---------------
-- PASSES
DELETE FROM FULLTIMESALARY;
DELETE FROM PARTTIMESALARY;
SELECT * FROM PAY_SALARY();
--------------

-- F29
-----------
SELECT * FROM VIEW_SUMMARY_REPORT(3);
----------
