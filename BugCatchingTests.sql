-- select <function>
-- call <procedure>

--Q3 PASSED
-- add_customer(IN cust_name text, IN address text,
-- IN phone integer, IN email text,  IN cc_number varchar(16),
-- IN cvv integer, IN expiry_date date))
-- call add_customer(cust_name,address, phone, email, cc_number, cvv, expiry_date);
-- testcase1 -> successful!
call add_customer('Kryel Koh', 'Blk 9 KentRidge', 99118877, 'kk@gmail.com',
    '9192032931234567', 923, '2022-03-21');
-- testcase2 -> successful
call add_customer('Kranken Koh', 'Blk 10 KentRidge', 99123877, 'kk1@gmail.com',
    '9192012342312347', 713, '2023-03-21');
-- testcase3 -> not successful -> missing info e.g. address
call add_customer('Kollin Koh', 99123877, 'kk1@gmail.com',
    '9192012342312347', 713, '2023-03-21');


--Q4 PASSED
-- update_credit_card(IN cust_id integer,
-- IN cc_number varchar, IN cvv integer,
-- IN expiry_date date)
-- testcase1 -> successful
call update_credit_card(25, '9123456789012345', 999, '2022-06-22');
-- testcase2 -> not successful -> id does not exist (raise notice)
call update_credit_card(30, '9123456789012345', 999, '2022-06-22');
-- testcase -> not successful -> expiry date past (raise notice)
call update_credit_card(25, '3411892055157028', 369, '2020-12-01');

--Q13 PASSED
-- buy_course_package(IN cust_id integer, IN package_id integer)
-- testcase1 -> successful
call buy_course_package(25, 8);
-- testcase2 -> not successful -> user does not exist
call buy_course_package(50, 10);
-- testcase3 -> not successful -> package does not exist
call buy_course_package(25, 100);


--Q14
-- get_my_course_package(IN cust_id integer)
-- testcase1 -> successful
select get_my_course_package(5);
-- testcase2 -> not successful -> user no course_package
select get_my_course_package(9);
-- testcase2 -> not successful -> user does not exist
select get_my_course_package(50);

--Q19 // need double check and change values
-- update_course_session(IN cust_id integer,
-- IN offering_id integer, IN sess_id integer)
-- testcase1 -> successful
call update_course_session(3, 6, 2);
-- testcase2 -> not successful -> user does not exist
call update_course_session(50, 6, 2);
-- testcase2 -> not successful -> offering does not exist
call update_course_session(3, 10, 2);
-- testcase2 -> not successful -> session does not exist
call update_course_session(3, 6, 10);


--Q20 // need double check and change values
-- cancel_registration(IN cust_id integer, IN offering_id integer)
-- testcase1 -> successful
call cancel_registration(25, 5);
-- testcase2 -> not successful -> user does not exist
call cancel_registration(50, 5);
-- testcase2 -> not successful -> offering does not exist
call cancel_registration(25, 10);

--Q30
-- view_manager_report()
select * from view_manager_report();
