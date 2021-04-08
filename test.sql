----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F6
select * from find_instructors(1, '2021-05-03', 8);  -- invalid session start hour
select * from find_instructors(1, '2021-05-03', 12); -- invalid session start hour
select * from find_instructors(1, '2021-05-03', 17); 
select * from find_instructors(1, '2021-05-03', 10); -- instructor 21 teaching
select * from find_instructors(1, '2021-05-03', 14); -- instructor 26 free
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F7
select * from get_available_instructors (1, '2021-05-01', '2021-08-01') 
-- all days except weekend
-- contains only instructor from same course area
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F15
select * from get_available_course_offerings()
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F16
select * from get_available_course_sessions(1)
select * from get_available_course_sessions(8)
select * from get_available_course_sessions(11)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F21
call update_instructor(1, 1, 21)
call update_instructor(1, 1, 22) -- instructor does not specialise in the course
call update_instructor(3, 1, 39) -- instructor haven't join yet
call update_instructor(2, 1, 40) -- instructor departed alr
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F22
call update_room(1, 1, 3) -- room is taken by another session
-- Not tested: registered > capacity
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------