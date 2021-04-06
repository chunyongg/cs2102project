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
-- XINYEE's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
