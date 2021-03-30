-- Should fail
-- No such course area
CALL add_course('EC1101', 'Learn all about Economics', 'Economics', 5);
--manager must be full time
CALL add_employee('part_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{"Game Design"}');
-- admin must be full time
CALL add_employee('part_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'administrator', '{}'); 
-- Admin must not handle any area at time of creation
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'administrator', '{"Game Design"}');
-- Manager must manage at least one area
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{}');
 -- Manager managing course areas cannot be removed
CALL remove_employee(43, '2021-02-21')
-- Employee already left
CALL remove_employee(40, '2021-05-21')
-- Should pass
CALL add_course('GD1101', 'Learn all about Games', 'Game Design', 5);
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'manager', '{"Game Design"}');
CALL add_employee('full_time', 'Maynard', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'instructor', '{"Game Design"}');
CALL add_employee('full_time', 'John', 'Potato Street', 93342258, 'johny@gmail.com', 3321.33, '2009-12-31', 'administrator', '{}');
CALL add_course_offering(11, 1, 300, 10, '2021-05-21', '2021-05-11', 42, '{"(2021-05-21,\"2021-05-21 00:00:00\",11)"}' :: SessionInfo[])
CALL add_course_offering(11, 1, 300, 10, '2021-05-21', '2021-05-11', 42, '{}' :: SessionInfo[])

CREATE OR REPLACE PROCEDURE add_course_offering(
    offering_id integer,
    course_id integer,
    fees numeric,
    target_number integer,
    launch_date date,
    registration_deadline date,
    admin_id integer,
    session_items SessionInfo []
) AS $$ 