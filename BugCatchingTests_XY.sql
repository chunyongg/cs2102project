-- select <function>
-- call <procedure>

--Q3 add_customer(cust_name,address, phone, email, cc_number, cvv, expiry_date);
-- null info e.g. address
call add_customer('Karnasia Koh', null, 98849394, 'kak@gmail.com',
    '9192032932234997', 820, '2023-03-21');
-- missing info
call add_customer('Karnasia Koh', 98849394, 'kak@gmail.com',
    '9192032932234997', 820, '2023-03-21');
-- credit card expired
call add_customer('Karnasia Koh', 'Clementi Street 1 Blk 7', 98849394, 'kak@gmail.com',
    '9192032932234997', 820, '2020-03-21');
-- successful
call add_customer('Karnasia Koh', 'Clementi Street 1 Blk 7', 98849394, 'kak@gmail.com',
    '9192032932234997', 820, '2023-03-21');
select * from Customers where cust_name = 'Karnasia Koh'; -- cid
select * from CreditCards where cc_number = '9192032932234997';

-- NEED UPDATE AFTER SCHEMA MERGED
--Q4 update_credit_card(cust_id, cc_number, cvv, expiry_date date)
-- to find a case for same credit card (testcase3)
select * from CreditCards;
-- id does not exist
call update_credit_card(50, '8766876687668766', 991, '2022-06-22');
-- expiry date past
call update_credit_card(1, '8766876687668766', 991, '2019-12-01');
-- same credit card given
call update_credit_card(1, '4602659607038509', 725, '2022-01-01');
-- call update_credit_card(1, '8766876687668766', 991, '2022-06-22');
-- successful
call update_credit_card(1, '8766876687668766', 991, '2022-06-22');
select * from CreditCards where cust_id = 1;

--Q13 buy_course_package(cust_id, package_id)
-- customer does not exist
call buy_course_package(50, 10);
-- package does not exist
call buy_course_package(25, 100);
-- user bought active package
call buy_course_package(25, 8);
-- package sale over
select * from CoursePackages;
call buy_course_package(24, 1);
-- successful
call add_customer('Coraline Lae', 'Clementi Street 1 Blk 9', 99449494, 'CLa@gmail.com',
    '9192032931335999', 823, '2025-01-21');
select * from Customers where cust_name = 'Coraline Lae';
call buy_course_package(cid, 3);
select * from Buys where cust_id = cid;

--Q14 get_my_course_package(cust_id)
select * from Buys;
-- user does not exist
select * from get_my_course_package(50);
-- user no course_package
select * from get_my_course_package(11);
-- no active/inactive package
select * from get_my_course_package(24);
-- successful
select * from get_my_course_package(1);

-- NEED UPDATE REDEEM SUCCESS
--Q19 update_course_session(cust_id, offering_id, sess_num)
select cust_id, offering_id, sess_num, sess_id from SessionParticipants natural join Sessions;
-- customer does not exist
call update_course_session(50, 2, 2);
-- session does not exist
call update_course_session(1, 11, 2);
-- customer did not register for any session
call update_course_session(3, 2, 1);
-- customer did not sign up for session in the offering
select cust_id, offering_id, sess_num, sess_id from SessionParticipants natural join Sessions order by offering_id;
call update_course_session(2, 2, 1);
-- customer already in session
call update_course_session(7, 2, 1);

-- REGISTER SUCCESS
-- choose a sess start time after current time
select cust_id, offering_id, sess_num, sess_id, start_time from Registers natural right join Sessions order by (offering_id, cust_id);
-- in:cid oid sessnum
-- old:25 3 3 sid 48
-- new:25 3 2 sid 58
call update_course_session(25, 3, 2);
-- check register session change
select cust_id, offering_id, sess_num, sess_id, start_time
from Registers natural right join Sessions where cust_id = 25;

-- REDEEMS SUCCESS
-- choose a sess start time after current time
select cust_id, offering_id, sess_num, sess_id, start_time from Redeems natural right join Sessions order by (offering_id, cust_id);
-- in: cid,oid,sessnum
-- old: 6 6 3 sid 86
-- new: 6 6 1 sid 10
call update_course_session(6, 6, 3);
-- check register session change
select cust_id, offering_id, sess_num, sess_id, start_time
from Redeems natural right join Sessions where cust_id = 6;


--Q20 cancel_registration(cust_id, offering_id)
-- customer does not exist
call cancel_registration(50, 5);
-- offering does not exist
call cancel_registration(1, 100);
-- customer did not register any session
select * from SessionParticipants order by cust_id;
call cancel_registration(12, 1);
-- customer did not register any session in the offering
select * from SessionParticipants natural join CourseOfferings order by offering_id;
call cancel_registration(2, 2);

-- CANCEL REDEEM SUCCESS
-- see who bought packages and how many redemptions left
-- choose start time later than current
select cust_id, offering_id, package_id, sess_id, redemptions_left, start_time from Sessions natural join Redeems natural join Buys ;
-- cid, oid, pid, sid, rleft
-- 2 1 2 1 4
-- in: cid and oid
call cancel_registration(2, 1);
-- see cancel table
select * from Cancels where cust_id = 2;
-- confirm it is not in redeems table
select * from Redeems where cust_id = 2;

-- CANCEL REGISTER SUCCESS
-- find one start date not near to cancel
select cust_id, offering_id, sess_id, start_time from Registers natural join Sessions;
-- cid oid sid
-- 4 14 14
-- in: cid and oid
call cancel_registration(4, 14);
-- see cancel table
select * from Cancels where cust_id = 4;
-- see removed from Registers
select * from Registers where cust_id = 4;

--Q30
-- RETURN manager name, total course areas managed,
-- total course offerings ended that yr & offerings total net reg fees,
-- course offering with highest net reg fee
select * from view_manager_report();
-- check all managers in record and sorted in asc order
select * from Managers order by emp_id;
select * from ManagerDetails order by emp_id;
select * from view_manager_report();
-- check total course area correct -> 1
select * from CourseAreas natural join Employees where emp_name = 'Brenda Wong' and emp_id = manager_id;
-- select Course Area
select course_id from Courses where course_area = 'Programming Languages';
--> cid 10
-- check total course offerings -> 2
select * from CourseOfferings natural join Courses where course_id = 10;
--> oid 10 22
-- check total net reg fee -> 769
-- Find net reg fee for oid 10
select sess_id, sess_date, latest_cancel_date, offering_id from Sessions where offering_id = 10;
--> sid 10
select * from SessionParticipants where sess_id = 10;
--> register: --
select offering_id, fees from CourseOfferings where offering_id = 10;
-- fee: fee * no.of customers
-- 100 * 0 = 0
--> redeem: cid 10 pid 10
select package_id, num_free_registrations, price from CoursePackages where package_id = 10;
-- For ppl who redeem, check price of ind sess (fee: price/numFreeReg)
--> cid 10: 10000/13 = 769.23
-- Find net reg fee for oid 22
select sess_id, sess_date, latest_cancel_date, offering_id from Sessions where offering_id = 22;
--> sid 22
select * from SessionParticipants where sess_id = 22;
--> --
select package_id, num_free_registrations, price from CoursePackages where package_id = 10;
-- price/numFreeReg
-->
-- total: 769.23 + 0 = 769 (round down)
-- confirm course_area with highest net reg fee
select get_total_net_reg_fee_for_course_offering(10);
select get_total_net_reg_fee_for_course_offering(22);


-- TEST HELPER FUNCTIONS for manager report function
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
