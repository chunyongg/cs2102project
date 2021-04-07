-- select <function>
-- call <procedure>

--Q3 PASSED
-- add_customer(IN cust_name text, IN address text,
-- IN phone integer, IN email text,  IN cc_number varchar(16),
-- IN cvv integer, IN expiry_date date))
-- call add_customer(cust_name,address, phone, email, cc_number, cvv, expiry_date);
-- testcase -> successful!
call add_customer('Kroyel Koh', 'Blk 9 KentRidge', 99118877, 'kk@gmail.com',
    '9192032931234567', 923, '2022-03-21');
call add_customer('Kranken Koh', 'Blk 10 KentRidge', 99123877, 'kk1@gmail.com',
    '9192012342312347', 713, '2023-03-21');
-- testcase -> not successful -> missing info e.g. address
call add_customer('Kollin Koh', null, 99123877, 'kk1@gmail.com',
    '9192012342312347', 713, '2023-03-21');


--Q4 PASSED
-- update_credit_card(IN cust_id integer,
-- IN cc_number varchar, IN cvv integer,
-- IN expiry_date date)
select * from CreditCards;
-- testcase -> successful
call update_credit_card(25, '9123456789012345', 999, '2022-06-22');
-- testcase -> not successful -> id does not exist (raise notice)
call update_credit_card(50, '9123456789012345', 999, '2022-06-22');
-- testcase -> not successful -> expiry date past (raise notice)
call update_credit_card(25, '3411892055157028', 369, '2019-12-01');

--Q13 PASSED
-- buy_course_package(IN cust_id integer, IN package_id integer)
select * from Buys;
-- testcase -> successful
call buy_course_package(23, 8);
-- testcase -> not successful -> user bought before
call buy_course_package(25, 8);
-- testcase -> not successful -> user does not exist
call buy_course_package(50, 10);
-- testcase -> not successful -> package does not exist
call buy_course_package(25, 100);


--Q14 PASSED
-- get active/partially active package
-- get_my_course_package(IN cust_id integer)
select * from Buys;
-- testcase -> successful
select get_my_course_package(25);
-- testcase -> not successful -> no active/inactive package
select get_my_course_package(1);
-- testcase -> not successful -> user no course_package
select get_my_course_package(9);
-- testcase -> not successful -> user does not exist
select get_my_course_package(50);

--Q19 -> fuse with ruien code and test success case for redeems
-- update_course_session(IN cust_id integer,
-- IN offering_id integer, IN sess_num integer)
-- REGISTER
-- -- choose a sess start time after current time
-- select cust_id, offering_id, sess_num, sess_id, start_time from Registers natural right join Sessions order by (offering_id, cust_id);
-- -- old cid 10 oid 5 sessnum 1 sid 9
-- -- new cid 10 oid 5 sessnum 2 sid 14
-- -- input: cid,oid,sessnum
-- call update_course_session(10, 5, 2);
-- -- check register session change
-- select cust_id, offering_id, sess_num, sess_id, start_time from Registers natural right join Sessions order by (offering_id, cust_id);
--
-- REDEEMS
-- -- choose a sess start time after current time
-- select cust_id, offering_id, sess_num, sess_id, start_time from Redeems natural right join Sessions order by (offering_id, cust_id);
-- -- old cid 6 oid 6 sessnum 3 sid 86
-- -- new cid 6 oid 6 sessnum 1 sid 10
-- -- input: cid,oid,sessnum
-- call update_course_session(6, 6, 3);
-- -- check register session change
-- select cust_id, offering_id, sess_num, sess_id, start_time from Redeems natural right join Sessions order by (offering_id, cust_id);

-- testcase -> not successful -> customer already in session
call update_course_session(5, 6, 1);
-- testcase -> not successful -> customer did not register for any session
call update_course_session(3, 2, 10);
-- testcase -> not successful -> user does not exist
call update_course_session(50, 2, 2);
-- testcase -> not successful -> session does not exist
call update_course_session(1, 11, 2);
-- testcase -> not successful -> customer did not sign up for session in the offering
call update_course_session(10, 4, 1);


--Q20 PASSED -> move some code to triggers
-- cancel_registration(IN cust_id integer, IN offering_id integer)
-- CANCEL REDEEM SUCCESS
-- see who bought packages and how many redemptions left
-- choose start time later than current
-- select cust_id, sess_id, offering_id, package_id, redemptions_left, start_time from Sessions natural join Redeems natural join Buys ;
-- -- cid 23, sid 15, oid 7, pid 1, rleft 4
-- -- cancel registration -> give cid and oid
-- call cancel_registration(23, 7);
-- -- see cancel table
-- select * from Cancels;
-- -- confirm it is not in redeems table
-- select * from Redeems where cust_id = 25;
--
-- CANCEL REGISTER SUCCESS
-- -- find one start date not near to cancel
-- select cust_id, offering_id, sess_id, start_time from Registers natural join Sessions;
-- -- cid 15 oid 5 sid 9
-- -- cancel registration -> give cid and oid
-- call cancel_registration(15, 5);
-- -- see cancel table
-- select * from Cancels;
-- -- see removed from Registers
-- select * from Registers where cust_id = 15;
--
-- testcase -> not successful -> user does not exist
call cancel_registration(50, 5);
-- offering does not exist
call cancel_registration(1, 100);
-- customer did not register any session
call cancel_registration(3, 1);
-- customer did not register any session in the offering
call cancel_registration(1, 6);

--Q30 // NEED MORE DATA TO TEST
-- view_manager_report()
select * from view_manager_report();

-- TEST HELPER FUNCTIONS for manager report function
select * from Managers order by emp_id;
select * from ManagerDetails order by emp_id;
select * from view_manager_report();
-- mid 20
select * from get_all_areas_offerings_net_fee(20); -- obtain oid -> 7 only
-- Get relevant sid in offering -> 15, 16, 17
select sess_id, sess_date, latest_cancel_date, offering_id from Sessions where offering_id = 7;
-- Get participants in sessions
-- sid 15 [cis 23 (pid 1), cid 6 (register), cid 1 (register), cid 25 (pid 8)
select * from SessionParticipants where sess_id = 15 or sess_id = 16 or sess_id = 17;
-- Get fees of session -> fees of offering
-- fee: 100
select offering_id, fees from CourseOfferings where offering_id = 7;
-- For ppl who redeem, check price of ind sess
-- cid 23: 4000/5 = 800 | cid 25: 180/2 = 90
select package_id, num_free_registrations, price from CoursePackages;
-- 100 x 2 + 800 + 90 = 1090
select * from get_total_net_reg_fee_for_course_offering(7); -- 1090
