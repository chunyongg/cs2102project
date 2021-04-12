-------------------------- F6 find_instructors --------------------------------
-- Negative testcases:
-- 1) invalid start hour
select * from find_instructors(1, '2021-05-19', 8);
select * from find_instructors(1, '2021-05-19', 18);
-- 2) invalid course duration
select duration from courses where course_id = 2; -- duration = 2 hours
select * from find_instructors(2, '2021-05-19', 17);

-- Positive testcases:
-- 1) valid duration and start hour
select duration from courses where course_id = 1; -- duration = 1 hour
select * from find_instructors(1, '2021-05-19', 17); -- 21, 26, 31, 36
-- 2) Instructor specialised in course's course area and is available to teach
select * from specializations natural join courses where course_id = 1; -- all instructors that are specialised in teaching course 1
select depart_date from employees where emp_id = 36; -- instructor 36 joined in 2021-05-01
select depart_date from employees where emp_id = 38; -- instructor 38 departed on 2021-04-01
select depart_date from employees where emp_id = 40; -- instructor 40 departed on 2021-01-01
select * from find_instructors(1, '2021-05-19', 9);  -- 21, 26, 31, 36
select * from find_instructors(1, '2021-04-01', 9); -- 21, 26, 31, 38 (instructor 38's last day and instructor 36 had yet to join)
select * from sessions where start_time = '2021-05-19 11:00:00' and instructor_id = 21; 
select * from find_instructors(1, '2021-05-19', 11); -- 26, 31, 36 (21 teaching)

-------------------------- F7 get_available_instructors --------------------------------
-- Positive testcases:
-- 1) Correct available hours & weekends excluded
select * from sessions natural join courseofferings natural join courses where course_id = 1; 
-- 3 sessions from course 1:
-- 2 June (Out of range), 19 & 20 May (11am to 12pm) => Not available to teach at 10, 11
select * from get_available_instructors (1, '2021-05-01', '2021-06-01');
-- 2) Correct monthly hours
select course_id, start_time, instructor_id from sessions natural join courseofferings natural join courses where sess_date between '2021-04-01' and '2021-04-30'; -- cid = 2, instructor = 32
select * from get_available_instructors (2, '2021-04-01', '2022-04-30'); -- monthly hour for this month = 2

-------------------------- F15 get_available_course_offerings --------------------------------
-- Positive testcases:
select * from get_available_course_offerings();

-------------------------- F16 get_available_course_sessions --------------------------------
-- Negative testcases:
-- 1) Seating capacity full
select * from get_available_course_sessions(13);
-- 2) No such course offering
select * from get_available_course_sessions(50);

-- Positive testcases:
-- 1) More than one sessions from same course offerings
select * from get_available_course_sessions(2);
-- 2) One session only
select * from get_available_course_sessions(11);

-------------------------- F21 update_instructor --------------------------
-- Negative testcases:
call update_instructor(1, 1, 22); -- instructor does not specialise in the course
call update_instructor(3, 1, 39); -- instructor haven't join yet
call update_instructor(2, 1, 40); -- instructor departed alr

-- Positive testcases:
call update_instructor(1, 1, 21);
-------------------------- F22 update_room --------------------------
-- Negative testcases:
call update_room(4, 1, 10); -- room is taken by another session
call update_room(50, 1, 6); -- offering_id does not exist
call update_room(1, 50, 6); -- session does not exist

-- Positive testcases:
call update_room(1, 1, 6);