-- RUIEY's TESTS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F8

-- Note: data includes room 1 (used on 2021-01-01 from 9am to 10am) and all other rooms (not used on 2021-01-01)

-- select find_rooms('2021-01-01', '2021-01-01 05:00:00', 4) -- room 1 + all other rooms are available
-- select find_rooms('2021-01-01', '2021-01-01 06:00:00', 4) -- all other rooms are available
-- select find_rooms('2021-01-01', '2021-01-01 09:00:00', 4) -- all other rooms are available
-- select find_rooms('2021-01-01', '2021-01-01 09:00:01', 4) -- all other rooms are available
-- select find_rooms('2021-01-01', '2021-01-01 09:59:59', 4) -- all other rooms are available
-- select find_rooms('2021-01-01', '2021-01-01 10:00:00', 4) -- room 1 + all other rooms are available
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F9

-- select get_available_rooms('2021-01-04', '2021-01-04')
-- select get_available_rooms('2021-01-08', '2021-01-08')
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F11

-- call add_course_package ('Valentines Day Sale', 2, '2021-02-01', '2021-02-14', 2222)

-- Note: undo addition by doing these
-- 1. delete from CoursePackages where package_name='Valentines Day Sale'
-- 2. alter sequence CoursePackages_package_id_seq restart with 11
-- 3. select * from CoursePackages
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F12

-- select get_available_course_packages() - returns 2021 Sale and April Flash Sale since we're querying in April 2021
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F17

-- Testing for errors:
-- call register_session(5, 4, 1, 'payment'::text) -- Error: The registration deadline has passed.
-- call register_session(2, 6, 1, 'lala'::text) -- Error: You may register for the session via payment or redemption only.
-- call register_session(9, 7, 1, 'redemption'::text) -- Error: You do not have a package to redeem sessions from.

-- Testing for functionality:
-- call register_session(5, 5, 1, 'payment'::text) -- insert into registers
-- call register_session(6, 6, 1, 'redemption'::text) -- update buys, insert into redeems
-- call register_session(6, 6, 1, 'redemption'::text) -- Error: You have already registered for one of this courses sessions.
-- call register_session(2, 7, 1, 'redemption'::text) -- [trigger] there is no more redemptions left in the package, redemption of new session failed.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F18

-- select get_my_registrations(1) - returns 2 records
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F27

-- select top_packages(4) - returns packages 6,1,7,2
-- select top_packages(3) - returns packages 6,1,7,2
-- select top_packages(2) - returns packages 6,1
-- select top_packages(2) - returns packages 6
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F28

-- select popular_courses
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
