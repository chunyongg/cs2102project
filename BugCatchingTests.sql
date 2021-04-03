-- select <function>
-- call <procedure>

--Q3
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


--Q4
-- update_credit_card(IN cust_id integer,
-- IN cc_number varchar, IN cvv integer,
-- IN expiry_date date)
-- testcase1 -> successful
call update_credit_card(74, '9123456789012345', 999, '2022-06-22');
-- testcase2 -> not successful -> id does not exist (raise notice)
call update_credit_card(28, '9123456789012345', 999, '2022-06-22');
-- testcase -> not successful -> expiry date past (raise notice)
call update_credit_card(75, '9123456789012345', 999, '2020-06-22');

--Q13
-- buy_course_package(IN cust_id integer, IN package_id integer)


--Q14
-- get_my_course_package(IN cust_id integer)

--Q19
-- update_course_session(IN cust_id integer,
-- IN offering_id integer, IN sess_id integer)

--Q20
-- cancel_registration(IN cust_id integer, IN offering_id integer)

--Q30
-- view_manager_report()
select * from view_manager_report();