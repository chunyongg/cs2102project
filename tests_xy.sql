--Q3 add_customer(cust_name,address, phone, email, cc_number, cvv, expiry_date)

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
-- try to add an added Customer
call add_customer('Karnasia Koh', 'Clementi Street 1 Blk 7', 98849394, 'kak@gmail.com',
    '9192032932234997', 820, '2023-03-21');
-- run to check:
select * from Customers where cust_name = 'Karnasia Koh'; -- cid
select * from CreditCards where cc_number = '9192032932234997';
---------------------------------------------------------------------------------

--Q4 update_credit_card(cust_id, cc_number, cvv, expiry_date date)

select * from CreditCards;
-- id does not exist
call update_credit_card(50, '8766876687668766', 991, '2022-06-22');
-- expiry date past
call update_credit_card(1, '8766876687668766', 991, '2019-12-01');
-- same credit card given
call update_credit_card(1, '4602659607038509', 725, '2022-01-01');
-- successful
call update_credit_card(1, '8766876687668766', 991, '2022-06-22');
run to check:
select * from CreditCards where cust_id = 1;
---------------------------------------------------------------------------------

--Q13 buy_course_package(cust_id, package_id)

-- customer does not exist
call buy_course_package(50, 10);
-- package does not exist
call buy_course_package(25, 100);
-- user bought active package
call buy_course_package(1, 8);
-- package sale over
select * from CoursePackages;
call buy_course_package(24, 1);
-- successful
call add_customer('Coraline Lae', 'Clementi Street 1 Blk 9', 99449494, 'CLa@gmail.com',
    '9192032931335999', 823, '2025-01-21');
select * from Customers where cust_name = 'Coraline Lae';
call buy_course_package(cid, 5);
select * from Buys where cust_id = cid;
---------------------------------------------------------------------------------

--Q14 get_my_course_package(cust_id)
select * from Buys;
-- user does not exist
select * from get_my_course_package(50);
-- user no course_package
select * from get_my_course_package(11);
-- successful
select * from get_my_course_package(1);
---------------------------------------------------------------------------------

--Q19 update_course_session(cust_id, offering_id, sess_num)
-- customer does not exist
call update_course_session(50, 2, 2);
-- session does not exist
call update_course_session(1, 11, 2);
-- customer did not register for any session
call update_course_session(11, 2, 1);
-- customer did not sign up for session in the offering
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

-- REDEEM SUCCESS
-- add customer
call add_customer('Pluto Kane', 'Clementi Street 2 Blk 7', 98999394, 'kak@gmail.com',
    '9192032932284997', 828, '2022-03-21'); -- cust_id = 26
select * from Customers where cust_name = 'Pluto Kane';
-- buy package
select * from CoursePackages;
call buy_course_package(26, 7);
select * from Buys where package_id = 7;
-- register_session
select offering_id, sess_num, sess_id, start_time from Sessions order by offering_id;
call register_session (26, 2, 1, 'redemption');
select cust_id, offering_id, sess_num, sess_id, start_time
from Redeems natural right join Sessions order by offering_id;
-- to update session
-- old: 26 2 1 sid 2
-- new: 26 2 2 sid 23
call update_course_session(26, 2, 2);
-- check register session change
select cust_id, offering_id, sess_num, sess_id, start_time
from Redeems natural right join Sessions where cust_id = 26;
---------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------

--Q30
select * from view_manager_report();
-------------------------------------------------------------------------------