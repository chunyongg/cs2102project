----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's TESTS

-- F8
-- Note: Room 3 is the only room that is used on this date from 9am-11am
select * from find_rooms('2021-04-10 09:00:00', 1) -- invalid as it is a weekend
select * from find_rooms('2021-05-21 08:00:00', 1) -- invalid as it is a non-operational hour
select * from find_rooms('2021-05-21 09:00:00', 1) -- no, room 3 is not available
select * from find_rooms('2021-05-21 09:00:00', 2) -- no, room 3 is not available
select * from find_rooms('2021-05-21 09:00:00', 3) -- no, room 3 is not available
select * from find_rooms('2021-05-21 09:00:00', 4) -- invalid as it is a non-operational hour
select * from find_rooms('2021-05-21 10:00:00', 1) -- no, room 3 is not available
select * from find_rooms('2021-05-21 11:00:00', 1) -- yes, room 1 is available
-- Run this to check:
select * from Sessions

-- F9
-- Note: Room 3 is used from 9am-11am on 2021-05-21, 9am to 12pm on 2021-05-24, 9am-12pm on 2021-06-04
select * from get_available_rooms('2021-01-06', '2021-01-05') -- invalid as start date is before end date
select * from get_available_rooms('2021-05-21', '2021,05-21') -- room 3 is available from 11am
select * from get_available_rooms('2021-05-21', '2021-05-24') -- room 3 is available from 2pm on 2021-05-24 as well
select * from get_available_rooms('2021-05-21', '2021-06-04') -- other rooms have varying availability timings, and room 3 is available from 2pm on 2021-06-04 as well
-- Run this to check:
select * from Sessions

-- F11
call add_course_package ('Valentines Day Sale', 2, '2021-02-01', '2021-02-14', 160)
call add_course_package ('Jovial Sale', 3, '2021-04-10', '2021-05-31', 299.99)
-- Undo:
delete from CoursePackages where package_id >= 11;
ALTER SEQUENCE Coursepackages_package_id_seq RESTART WITH 11
-- Run this to check:
select * from CoursePackages

-- F12
select * from get_available_course_packages() -- excludes 3-3 Sale Package since its sales has ended
-- Run this to check:
select * from CoursePackages

-- F17
call register_session(16, 4, 1, 'payment') -- succeed
call register_session(16, 4, 1, 'payment') -- ERROR: Already registered for session
call register_session(16, 4, 1, 'randomword') -- ERROR: You may register for the session via payment or redemption only.
call register_session(16, 4, 1, 'redemption') -- ERROR:  You do not have a package to redeem sessions from.
call register_session(9, 10, 1, 'redemption') -- succeed, 4 redemptions_left becomes 3
call register_session(9, 11, 1, 'redemption') -- succeed, 3 redemptions_left becomes 2
call register_session(9, 12, 1, 'redemption') -- succeed, 2 redemptions_left becomes 1
call register_session(9, 13, 1, 'redemption') -- succeed, 1 redemptions_left becomes 0
call register_session(9, 14, 1, 'redemption') -- ERROR: There is no more redemptions left in the package, redemption of new session failed.
-- Run this to check:
select * from sessionparticipants where cust_id = 16
select * from buys where cust_id = 16 -- customer 16 did not buy any packages
select * from buys -- customer 9 bought package 9 which has 4 redemptions left
select * from sessionparticipants where cust_id = 9 -- check whether customer is registered correctly

-- F18
select * from get_my_registrations(6) -- these registrations have not ended
-- Run this to check:
select * from SessionParticipants order by cust_id

-- F26
select * from promote_courses() -- returns all course offerings that haven't ended registration, for all courses that each inactive customer is interested in
-- Run this to check:
select cust_id, sess_id, register_date, redeem_date from sessionparticipants natural full join Registers natural full join Redeems order by cust_id

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