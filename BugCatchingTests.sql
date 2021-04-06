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

--Q19 PASSED
-- update_course_session(IN cust_id integer,
-- IN offering_id integer, IN sess_id integer)
select cust_id, offering_id, sess_id, package_id
from SessionParticipants natural join CourseOfferings;
--
select offering_id, sess_num, sess_id
from CourseOfferings natural join Sessions order by offering_id;
--
select * from Customers;
-- testcase -> successful
call update_course_session(2, 8, 7);
call update_course_session(5, 6, 5); -- pass but table 1 doesnt show change in sess num
-- testcase -> not successful -> customer already in session
call update_course_session(5, 6, 1);
-- testcase -> not successful -> customer did not register for any session
call update_course_session(3, 2, 10);
-- testcase -> not successful -> user does not exist
call update_course_session(50, 2, 2);
-- testcase -> not successful -> session does not exist
call update_course_session(1, 11, 2);
call update_course_session(2, 8, 6);


--Q20 PASSED
-- cancel_registration(IN cust_id integer, IN offering_id integer)
-- CANCEL REDEEM SUCCESS
-- -- to see who to add to redemption
-- select * from Buys;
-- -- to see which session haven start so can cancel
-- select start_time, sess_id, offering_id, sess_num from Sessions;
-- -- CHOSEN sid 9 oid 5
-- -- give sid, pid, cid
-- insert into Redeems values(CURRENT_DATE, 9, 1, 1);
-- -- to see session, offering, package that customer bought and redeemed
-- select cust_id, offering_id, sess_num, sess_id, package_id
-- from SessionParticipants
--     natural join CourseOfferings
--     natural join Sessions
-- where package_id is not null
-- and cust_id = 1
-- order by cust_id;
-- -- to see redemptions
-- select * from Redeems where cust_id = 1;
-- -- see who bought packages and how many redemptions left
-- select * from Buys where cust_id = 1;
-- -- cancel registration -> give cid and oid
-- call cancel_registration(1, 5);
-- -- see cancel table
-- select * from Cancels;
--
-- CANCEL REGISTER SUCCESS
-- -- to see which session haven start so can cancel
-- select start_time, sess_id, offering_id, sess_num from Sessions;
-- -- CHOSEN sid 13 oid 4
-- -- to who has not sign up for any session
-- select * from SessionParticipants;
-- -- to see cc_num of customer
-- select * from CreditCards where cust_id = 3;
-- -- give reg_date, cid, sid, cc_num
-- insert into Registers values(CURRENT_DATE, 3, 13, '4347465053571468');
-- -- to see Register
-- select * from Registers where cust_id = 3;
-- -- cancel registration -> give cid and oid
-- call cancel_registration(3, 4);
-- -- see cancel table
-- select * from Cancels;
-- -- see removed from Registers
-- select * from Registers;
--
-- testcase -> not successful -> session started
call cancel_registration(1, 1);
-- testcase -> not successful -> user does not exist
call cancel_registration(50, 5);
-- testcase -> not successful -> offering does not exist
call cancel_registration(25, 10);

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
