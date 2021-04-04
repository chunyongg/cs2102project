

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S TESTS

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
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{"Game Design"}'); -- Pass
CALL add_employee('full_time', 'Maynard', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'instructor', '{"Game Design"}'); -- Pass
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'administrator', '{}'); -- Pass

--F2
 -- Manager managing course areas cannot be removed
CALL remove_employee(43, '2021-02-21')
-- Employee already left
CALL remove_employee(40, '2021-05-21')

--F5 
CALL add_course('EC1101', 'Learn all about Economics', 'Economics', 5); -- No such course area
CALL add_course('GD1101', 'Learn all about Games', 'Game Design', 5); -- Pass

--F10
-- Sessions cannot be empty
CALL add_course_offering(11, 1, 300, 10, '2021-05-21', '2021-05-11', 42, '{}' :: SessionInfo[])
-- Session capacity less than target number
CALL add_course_offering(11, 1, 300, 200, '2021-05-21', '2021-05-11', 42, '{"(2021-05-21,\"2021-05-21 00:00:00\",1)"}' :: SessionInfo[])
-- Should pass
CALL add_course_offering(11, 1, 300, 10, '2021-05-21', '2021-05-11', 42, '{"(2021-05-21,\"2021-05-21 00:00:00\",11)"}' :: SessionInfo[])
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
