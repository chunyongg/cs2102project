CREATE OR REPLACE PROCEDURE add_course_package (package_name TEXT, num_free_registrations INT, sale_start_date DATE, sale_end_date DATE, price NUMERIC(10, 2))

-- Create the packages 
CALL add_course_package('3-3 Sale Package', 1, '2021-03-03', '2021-03-03', 100);
CALL add_course_package('Flash Sale', 1, '2021-04-01', '2021-04-15', 150);
CALL add_course_package('Trial', 3, '2021-04-01', '2021-05-01', 200);
CALL add_course_package('Beginner Friendly', 3, '2021-04-01', '2021-06-01', 300);
CALL add_course_package('Best Value', 6, '2021-04-01', '2021-07-01', 500);
CALL add_course_package('Ultimate Edition', 10, '2021-04-01', '2021-08-01', 1000);
CALL add_course_package('Intermediate Package', 15, '2021-04-01', '2021-09-01', 1300);
CALL add_course_package('Comprehensive Package', 20, '2021-04-01', '2021-10-01', 2000);
CALL add_course_package('Expert Package', 30, '2021-04-01', '2021-11-01', 2500);
CALL add_course_package('Unlimited', 9999, '2021-04-01', '2021-12-01', 10000);

-- Buy the packages
CALL buy_course_package(1, 2);
CALL buy_course_package(2, 2);
CALL buy_course_package(3, 3);
CALL buy_course_package(4, 4);
CALL buy_course_package(5, 5);
CALL buy_course_package(6, 6);
CALL buy_course_package(7, 7);
CALL buy_course_package(8, 8);
CALL buy_course_package(9, 9);
CALL buy_course_package(10, 10);


CALL register_session(1, 1, 1, 'redemption');
CALL register_session(2, 2, 1, 'redemption');
CALL register_session(3, 3, 1, 'redemption');
CALL register_session(4, 4, 1, 'redemption');

CALL register_session(5, 1, 1, 'redemption');
CALL register_session(5, 2, 1, 'redemption');
CALL register_session(5, 3, 1, 'redemption');
CALL register_session(5, 4, 1, 'redemption');
CALL register_session(5, 5, 1, 'redemption');

CALL register_session(6, 1, 1, 'redemption');
CALL register_session(6, 2, 1, 'redemption');
CALL register_session(6, 3, 1, 'redemption');
CALL register_session(6, 4, 1, 'redemption');
CALL register_session(6, 5, 1, 'redemption');
CALL register_session(6, 6, 1, 'redemption');

CALL register_session(7, 1, 1, 'redemption');
CALL register_session(7, 2, 1, 'redemption');
CALL register_session(7, 3, 1, 'redemption');
CALL register_session(7, 4, 1, 'redemption');
CALL register_session(7, 5, 1, 'redemption');
CALL register_session(7, 6, 1, 'redemption');
CALL register_session(7, 7, 1, 'redemption');

CALL register_session(8, 1, 1, 'redemption');
CALL register_session(8, 2, 1, 'redemption');
CALL register_session(8, 3, 1, 'redemption');
CALL register_session(8, 4, 1, 'redemption');
CALL register_session(8, 5, 1, 'redemption');
CALL register_session(8, 6, 1, 'redemption');
CALL register_session(8, 7, 1, 'redemption');
CALL register_session(8, 8, 1, 'redemption');

CALL register_session(9, 1, 1, 'redemption');
CALL register_session(9, 2, 1, 'redemption');
CALL register_session(9, 3, 1, 'redemption');
CALL register_session(9, 4, 1, 'redemption');
CALL register_session(9, 5, 1, 'redemption');
CALL register_session(9, 6, 1, 'redemption');
CALL register_session(9, 7, 1, 'redemption');
CALL register_session(9, 8, 1, 'redemption');
CALL register_session(9, 9, 1, 'redemption');

CALL register_session(10, 1, 1, 'redemption');
CALL register_session(10, 2, 1, 'redemption');
CALL register_session(10, 3, 1, 'redemption');
CALL register_session(10, 4, 1, 'redemption');
CALL register_session(10, 5, 1, 'redemption');
CALL register_session(10, 6, 1, 'redemption');
CALL register_session(10, 7, 1, 'redemption');
CALL register_session(10, 8, 1, 'redemption');
CALL register_session(10, 9, 1, 'redemption');
CALL register_session(10, 10, 1, 'redemption');

CALL cancel_registration(5, 1);
CALL cancel_registration(6, 1);
CALL cancel_registration(7, 1);
CALL cancel_registration(8, 1);
CALL cancel_registration(9, 1);
CALL cancel_registration(10, 1);
