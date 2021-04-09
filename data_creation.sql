delete from Employees;
alter sequence Employees_emp_id_seq restart with 1;
CALL add_employee('full_time', 'Sarah Tan', 'Blk 123 Ang Mo Kio', 90001010, 'sarah.tan@gmail.com', 3000, '2020-05-01', 'administrator', '{}');
CALL add_employee('full_time', 'Joshua Lau', '14 Marshall Road', 93487131, 'joshua.lau@gmail.com', 3000, '2020-06-01', 'administrator', '{}');
CALL add_employee('full_time', 'Michelle Tan', '11 Bedok Reservoir Road', 93883567, 'michelle.tan@gmail.com', 3000, '2020-07-01', 'administrator', '{}');
CALL add_employee('full_time', 'Angeline Hill', '240 Macpherson Road', 84026810, 'angeline.hill@gmail.com', 3000, '2018-06-01', 'administrator', '{}');
CALL add_employee('full_time', 'Thomas Hackett', '19 Hougang Street', 88726293, 'thomas.hackett@gmail.com', 3000, '2019-05-01', 'administrator', '{}');
CALL add_employee('full_time', 'Lowell Ward', '180B Bencoolen Street', 94517022, 'lowell.ward@gmail.com', 3000, '2019-05-01', 'administrator', '{}');
CALL add_employee('full_time', 'Aniya Covy', '24 Chapel Rd', 81613371, 'aniya.covy@gmail.com', 3000, '2019-05-11', 'administrator', '{}');
CALL add_employee('full_time', 'Howard Peter', '150F East Coast Road', 92903217, 'howard.peter@gmail.com', 3000, '2019-05-01', 'administrator', '{}');
CALL add_employee('full_time', 'Eugenia Haley', '15 Serangoon Road', 91839949, 'eugenia.haley@gmail.com', 3000, '2019-05-01', 'administrator', '{}');
CALL add_employee('full_time', 'Jennie Kozey', '438 Alexandra Road', 83428645, 'jennie.kozey@gmail.com', 3000, '2019-04-01', 'administrator', '{}');

CALL add_employee('full_time', 'Zander Chong', 'Blk 123 Toa Payoh', 93980294, 'zander.chong@gmail.com', 4000, '2018-01-01', 'manager', '{Algorithms and Theory}');
CALL add_employee('full_time', 'Katheryn Brenda', 'Blk 129 Bishan Ave 3', 80525852, 'katheryn.brenda@gmail.com', 4000, '2020-09-01', 'manager', '{Artificial Intelligence}');
CALL add_employee('full_time', 'Devan Boyle', 'Blk 44 Braddell Ave 1', 87336198, 'devan.boyle@gmail.com', 4000, '2020-10-01', 'manager', '{Game Design}');
CALL add_employee('full_time', 'David Sim', '25 Tuas Avenue 13', 98977879, 'david.sim@gmail.com', 4000, '2020-10-01', 'manager', '{Computer Security}');
CALL add_employee('full_time', 'Joanna Neo', '391A Orchard Road', 92352568, 'joanna.neo@gmail.com', 4000, '2020-09-01', 'manager', '{Database Systems}');
CALL add_employee('full_time', 'Joey Chua', '414 Yishun Ring Rd', 87531197, 'joey.chua@gmail.com', 4000, '2020-08-01', 'manager', '{Computer Networking}');
CALL add_employee('full_time', 'Joe Doe', '91 Defu Lane', 92803670, 'joe.doe@gmail.com', 4000, '2017-02-15', 'manager', '{Parallel Computing}');
CALL add_employee('full_time', 'Patrick Loh', '315 Outram Road', 83235333, 'patrick.loh@gmail.com', 4000, '2020-01-01', 'manager', '{Software Engineering}');
CALL add_employee('full_time', 'Joella Tan', '370H Alexandra Road', 94766173, 'joella.tan@gmail.com', 4000, '2020-01-01', 'manager', '{Data Analytics}');
CALL add_employee('full_time', 'Brenda Wong', '22 Kallang Ave', 91733252, 'brenda.wong@gmail.com', 4000, '2019-02-01', 'manager', '{Programming Languages}');

CALL add_employee('full_time', 'Chloe Lim', '20 Prince Edward Road', 91733252, 'chloe.lim@gmail.com', 5000, '2020-02-01', 'instructor', '{Algorithms and Theory, Artificial Intelligence}');
CALL add_employee('full_time', 'Benjamin Kok', '81 Marine Parade Central', 84470579, 'benjamin.kok@gmail.com', 5000, '2020-06-01', 'instructor', '{Game Design, Computer Security}');
CALL add_employee('full_time', 'Jovin Seah', '53 Ubi Avenue 1', 87488977, 'jovin.seah@gmail.com', 5000, '2021-05-01', 'instructor', '{Database Systems, Computer Networking}');
CALL add_employee('full_time', 'Joshua Chan', '1 North Bridge Road', 94563049, 'joshua.chan@gmail.com', 5000, '2018-08-01', 'instructor', '{Parallel Computing, Software Engineering}');
CALL add_employee('full_time', 'Justin Lim', '35 Kallang Pudding Road', 97416583, 'justin.lim@gmail.com', 5000, '2021-01-01', 'instructor', '{Data Analytics, Programming Languages}');
CALL add_employee('full_time', 'Sean Fang', 'Blk 27 Bedok Street 77', 90872861, 'sean.fang@gmail.com', 5000, '2020-09-01', 'instructor', '{Algorithms and Theory, Game Design}');
CALL add_employee('full_time', 'Farihah Riduan', '83 Bedok Reservoir Gate', 90648144, 'farihah.riduan@gmail.com', 5000, '2021-09-01', 'instructor', '{Database Systems, Parallel Computing}');
CALL add_employee('full_time', 'Sarah Oh', 'Blk 15 Ang Mo Kio Street 19', 93232348, 'sarah.oh@gmail.com', 5000, '2020-08-01', 'instructor', '{Artificial Intelligence, Computer Security}');
CALL add_employee('full_time', 'Beth Choi', 'Blk 342 Jurong West Street 10', 82653413, 'beth.choi@gmail.com', 5000, '2021-01-01', 'instructor', '{Computer Networking, Software Engineering}');
CALL add_employee('full_time', 'Lindsey Yeoh', 'Blk 199 Lorong 7 Lok Yang', 85431443, 'lindsey.yeoh@gmail.com', 5000, '2021-01-01', 'instructor', '{Data Analytics, Programming Languages}');

CALL add_employee('part_time', 'Stefanie Tan', '360 Orchard Road', 93381811, 'stefanie.tan@gmail.com', 3000, '2021-01-01', 'instructor', '{Algorithms and Theory, Programming Languages}');
CALL add_employee('part_time', 'Jared Wong', '7 Pasir Panjang Road', 91841170, 'jared.wong@gmail.com', 3000, '2021-02-01', 'instructor', '{Artificial Intelligence, Data Analytics}');
CALL add_employee('part_time', 'June Lim', '1 Brooke Rd', 97416583, 'june.lim@gmail.com', 3000, '2019-08-01', 'instructor', '{Game Design, Parallel Computing}');
CALL add_employee('part_time', 'Historia Reiss', 'Blk 407b Fernvale Road', 82956254, 'historia.reiss@gmail.com', 3000, '2021-01-01', 'instructor', '{Computer Security, Computer Networking}');
CALL add_employee('part_time', 'Eren Yeager', '244 Westwood Ave', 97390470, 'eren.yeager@gmail.com', 3000, '2020-03-01', 'instructor', '{Database Systems}');
CALL add_employee('part_time', 'Stephen Tan', '63 West Coast Rd', 92287290, 'stephen.tan@gmail.com', 3000, '2021-05-01', 'instructor', '{Algorithms and Theory, Artificial Intelligence, Game Design, Computer Security, Database Systems}');
CALL add_employee('part_time', 'Yxavion Lim', '709 Tampines Street 54', 86215290, 'yxavion.lim@gmail.com', 3000, '2020-01-01', 'instructor', '{Computer Networking, Parallel Computing, Software Engineering, Data Analytics, Programming Languages}');
CALL add_employee('part_time', 'Ma Chen', '7 Thomson View', 98255196, 'ma.chen@gmail.com', 3000, '2021-04-01', 'instructor', '{Algorithms and Theory, Game Design, Database Systems, Parallel Computing, Data Analytics}');
CALL add_employee('part_time', 'Stuart Yip', '87 Tiong Bahru Walk', 81885290, 'stuart.yip@gmail.com', 3000, '2021-07-01', 'instructor', '{Artificial Intelligence, Computer Security, Computer Networking, Software Engineering, Programming Languages}');
CALL add_employee('part_time', 'Hasna Mohammad', 'Blk 43 Marine Parade Street 27', 98983211, 'hasna.mohammad@gmail.com', 3000, '2020-01-01', 'instructor', '{Algorithms and Theory, Computer Networking, Software Engineering}');

CALL remove_employee(1, '2021-10-01');
CALL remove_employee(6, '2022-05-01');
CALL remove_employee(7, '2019-08-01');
CALL remove_employee(8, '2021-08-01');
CALL remove_employee(9, '2019-08-01');

CALL remove_employee(22, '2021-12-01');
CALL remove_employee(25, '2021-03-01');
CALL remove_employee(26, '2021-09-01');
CALL remove_employee(28, '2022-02-01');
CALL remove_employee(29, '2023-01-01');
CALL remove_employee(30, '2023-01-01');

CALL remove_employee(31, '2021-10-01');
CALL remove_employee(32, '2021-08-01');
CALL remove_employee(33, '2021-05-01');
CALL remove_employee(38, '2021-04-01');
CALL remove_employee(40, '2021-01-01');

-- alter sequence Table_attribute_seq restart with 1 -- (resets serial number) e.g. ALTER SEQUENCE employees_emp_id_seq RESTART WITH 1

insert into CourseAreas values
('Algorithms and Theory', 11),      -- course area 1  manager_id = 11
('Artificial Intelligence', 12),    -- course area 2  manager_id = 12
('Game Design', 13),                -- course area 3  manager_id = 13
('Computer Security', 14),          -- course area 4  manager_id = 14
('Database Systems', 15),           -- course area 5  manager_id = 15
('Computer Networking', 16),        -- course area 6  manager_id = 16
('Parallel Computing', 17),         -- course area 7  manager_id = 17
('Software Engineering', 18),       -- course area 8  manager_id = 18
('Data Analytics', 19),             -- course area 9  manager_id = 19
('Programming Languages', 20);      -- course area 10 manager_id = 20

alter sequence Courses_course_id_seq restart with 1;
CALL add_course('Algorithms', 'Learn all about algorithms!', 'Algorithms and Theory', 1);
CALL add_course('Artificial Intelligence', 'Learn about AI', 'Artificial Intelligence', 2);
CALL add_course('Game Design', 'Design the best games', 'Game Design', 3);
CALL add_course('Computer Security', 'Secure your computers', 'Computer Security', 1);
CALL add_course('Database Systems', 'Learn about databases', 'Database Systems', 2);
CALL add_course('Computer Networking', 'Learn about networks', 'Computer Networking', 3);
CALL add_course('Parallel Computing', 'Learn about parallelism', 'Parallel Computing', 1);
CALL add_course('Software Engineering', 'Learn about software engineering', 'Software Engineering', 2);
CALL add_course('Data Analytics', 'Learn about data analytics', 'Data Analytics', 3);
CALL add_course('Programming Languages', 'Learn about programming', 'Programming Languages', 1);

insert into Rooms values
(default, '01-01', 20),
(default, '01-02', 20),
(default, '01-03', 20),
(default, '01-04', 20),
(default, '01-05', 20),
(default, '02-01', 25),
(default, '02-02', 25),
(default, '02-03', 25),
(default, '02-04', 25),
(default, '02-05', 25),
(default, '03-01', 30),
(default, '03-02', 30),
(default, '03-03', 30),
(default, '03-04', 30),
(default, '03-05', 30),
(default, '04-01', 35),
(default, '04-02', 35),
(default, '04-03', 35),
(default, '04-04', 35),
(default, '04-05', 35),
(default, '05-01', 40),
(default, '05-02', 40),
(default, '05-03', 40),
(default, '05-04', 40),
(default, '05-05', 40);

delete from Customers;
alter sequence Customers_cust_id_seq restart with 1;
call add_customer('Xia Cheng','13 Lor 8 Toa Payoh', 98264332, 'xiacheng@gmail.com', '4602659607038509', 725, '2022-01-01');
call add_customer('Shi Hui Min','51 New Bridge Road', 82654397, 'huimin96@yahoo.com', '3487730179254246', 135, '2023-02-01');
call add_customer('Abdul Hazirah','437 Tanjong Katong Rd', 89776527, 'itzhazirah@email.com', '4347465053571468', 355, '2024-03-01');
call add_customer('Carole Tay','Blk 32 Hougang Street 19', 93522165, 'caroleee@me.com', '6011160715370157', 890, '2022-04-01');
call add_customer('Diana Yusoff','Blk 194 Tampines Street 16', 81234562, 'dddofff@icloud.com', '5204007499487609', 447, '2023-05-01');
call add_customer('Kristen Teoh','9 Jalan Selaseh', 99286426, 'kristen123@gmail.com', '4209949185032728', 123, '2024-06-01');
call add_customer('Alicia Tan','Blk 39 Bedok Street 75', 88261126, 'alistar73@outlook.com', '3710753283744374', 865, '2022-07-01');
call add_customer('Danish Yacob','82 Pandan Valley Circle', 89235761, 'dyacob@rocketmail.com', '3674217885515676', 981, '2023-08-01');
call add_customer('Carter Shum','Blk 49 Lorong 6 Buangkok', 99111836, 'carter@ymail.com', '5491129751647597', 236, '2024-09-01');
call add_customer('Yong See Kew Alvira','30 Punggol Hill', 98183329, 'alviraysk@gmail.com', '4246936242452879', 576, '2022-10-01');
call add_customer('Sedrick Skiles','Blk 616D Gleason Grove Place', 95026183, 'sedrick@gmail.com', '3770148713541449', 282, '2023-11-01');
call add_customer('Beryl Carroll','Blk 5 Jalan Boyer', 97763128, 'beryl.carroll@icloud.com', '4716439600987074', 913, '2024-12-01');
call add_customer('Lexus Ratke','50 Jalan Lateh', 96656111, 'lexus_ratke@fastmail.com', '4024007196118250', 642, '2022-12-01');
call add_customer('Peggy Tan','487 Crescent Link', 81836428, 'peggy78@mail.com', '5598648621344095', 241, '2023-11-01');
call add_customer('Sheryl Goh','3 Phillip Street', 82357968, 'sherylgoh@gmail.com', '4994864865055287', 173, '2024-10-01');
call add_customer('Sherman Heng','320 Lavender St', 97966656, 'shermanhengah@ymail.com', '4255179226593710', 287, '2023-09-01');
call add_customer('Lucy Cheng','1 Kaki Bukit View', 81265434, 'luckylucy@mail.com', '3462414407196593', 752, '2022-08-01');
call add_customer('Fatimah Bte Ahmed','279 Balestier Road', 98126456, 'fatimah@gmail.com', '6346055242179659', 198, '2024-07-01');
call add_customer('Lashimi Ramasamy','101B Up Cross St', 99864564, 'lashimi@yahoo.com.sg', '4876053574214217', 953, '2023-06-01');
call add_customer('Sarah Tan','Blk 120 Serangoon Gardens', 87271543, 'sarah_tan@hotmail.com.sg', '3283357111169600', 862, '2022-05-01');
call add_customer('Nabila Salleh','Blk 281 Lorong 4 Lok Yang', 94928027, 'nabilasalleh@outlook.com', '4402703555407878', 218, '2024-04-01');
call add_customer('Preeti Sun','23 Simei Center', 90816006, 'preeti@me.com', '4713286671658115', 754, '2023-03-01');
call add_customer('Adi Wahid','65 Chong Pang Green', 82936537, 'adi_wahid@email.com', '5344835097660156', 893, '2022-02-01');
call add_customer('Amanda Hong','7 Teck Ghee Road', 92298531, 'amandahong@gmail.com', '5392456596274919', 443, '2024-01-01');
call add_customer('Hassan Nasser','6 Choa Chu Kang Hill', 83553470, 'hassan@me.com', '3411892055157023', 369, '2023-12-01');

alter sequence Sessions_sess_id_seq restart with 1;
-- Algorithms
CALL add_course_offering(1, 1 , 100, 10, '2021-03-23', 
'2021-05-23', 1 , '{"(2021-06-02,\"2021-06-02 11:00:00\",1)"}' :: SessionInfo[]);
-- AI
CALL add_course_offering(2, 2 , 100, 11, '2021-03-23', 
'2021-05-23', 2 , '{"(2021-06-03,\"2021-06-03 10:00:00\",2)"}' :: SessionInfo[]);
-- Game Design
CALL add_course_offering(3, 3 , 100, 12, '2021-03-23', 
'2021-05-23', 3 , '{"(2021-06-04,\"2021-06-04 09:00:00\",3)"}' :: SessionInfo[]);
-- Computer Security
CALL add_course_offering(4, 4 , 100, 13, '2021-03-23', 
'2021-05-23', 4 , '{"(2021-06-02,\"2021-06-02 17:00:00\",4)"}' :: SessionInfo[]);
-- Database Systems
CALL add_course_offering(5, 5 , 100, 14, '2021-03-23', 
'2021-05-23', 5 , '{"(2021-06-03,\"2021-06-03 16:00:00\",5)"}' :: SessionInfo[]);
-- Networking
CALL add_course_offering(6, 6 , 100, 15, '2021-03-23', 
'2021-05-23', 6 , '{"(2021-06-04,\"2021-06-04 15:00:00\",6)"}' :: SessionInfo[]);
-- Parallel Computing
CALL add_course_offering(7, 7 , 100, 16, '2021-03-23', 
'2021-05-23', 6 , '{"(2021-06-07,\"2021-06-07 17:00:00\",7)"}' :: SessionInfo[]);
-- Software Engineering
CALL add_course_offering(8, 8 , 100, 17, '2021-03-23', 
'2021-05-23', 8 , '{"(2021-06-08,\"2021-06-08 16:00:00\",8)"}' :: SessionInfo[]);
-- Data Analytics
CALL add_course_offering(9, 9 , 100, 18, '2021-03-23', 
'2021-05-23', 6 , '{"(2021-06-09,\"2021-06-09 15:00:00\",9)"}' :: SessionInfo[]);
-- Programming Languages
CALL add_course_offering(10, 10 , 100, 19, '2021-03-23', 
'2021-05-23', 10 , '{"(2021-06-02,\"2021-06-02 17:00:00\",10)"}' :: SessionInfo[]);

CALL add_course_offering(11, 1 , 100, 10, '2021-03-08', 
'2021-05-08', 1 , '{"(2021-05-19,\"2021-05-19 11:00:00\",21)"}' :: SessionInfo[]);
CALL add_course_offering(12, 1 , 100, 10, '2021-03-09', 
'2021-05-09', 1 , '{"(2021-05-20,\"2021-05-20 11:00:00\",21)"}' :: SessionInfo[]);
CALL add_course_offering(13, 2 , 100, 10, '2021-03-10', 
'2021-05-10', 1 , '{"(2021-05-21,\"2021-05-21 09:00:00\",3)"}' :: SessionInfo[]);
CALL add_course_offering(14, 3 , 100, 10, '2021-03-13', 
'2021-05-13', 1 , '{"(2021-05-24,\"2021-05-24 09:00:00\",3)"}' :: SessionInfo[]);
CALL add_course_offering(15, 4 , 100, 10, '2021-03-14', 
'2021-05-14', 1 , '{"(2021-05-25,\"2021-05-25 09:00:00\",6)"}' :: SessionInfo[]);
CALL add_course_offering(16, 4 , 100, 10, '2021-03-15', 
'2021-05-15', 1 , '{"(2021-05-26,\"2021-05-26 14:00:00\",17)"}' :: SessionInfo[]);
CALL add_course_offering(17, 5 , 100, 10, '2021-03-16', 
'2021-05-16', 5 , '{"(2021-05-27,\"2021-05-27 16:00:00\",14)"}' :: SessionInfo[]);
CALL add_course_offering(18, 6 , 100, 10, '2021-03-20', 
'2021-05-20', 3 , '{"(2021-05-31,\"2021-05-31 09:00:00\",2)"}' :: SessionInfo[]);
CALL add_course_offering(19, 7 , 100, 10, '2021-03-20', 
'2021-05-20', 4 , '{"(2021-05-31,\"2021-05-31 14:00:00\",4)"}' :: SessionInfo[]);
CALL add_course_offering(20, 8 , 100, 10, '2021-03-21', 
'2021-05-21', 10 , '{"(2021-06-01,\"2021-06-01 10:00:00\",6)"}' :: SessionInfo[]);
CALL add_course_offering(21, 9 , 100, 10, '2021-03-22', 
'2021-05-22', 10 , '{"(2021-06-02,\"2021-06-02 15:00:00\",23)"}' :: SessionInfo[]);
CALL add_course_offering(22, 10 , 100, 10, '2021-03-23', 
'2021-05-23', 2 , '{"(2021-06-03,\"2021-06-03 15:00:00\",24)"}' :: SessionInfo[]);

-- Create the packages 
CALL add_course_package('3-3 Sale Package', 1, '2021-03-03', '2021-03-03', 100);
CALL add_course_package('Flash Sale', 2, '2021-04-01', '2021-04-15', 150);
CALL add_course_package('Trial', 3, '2021-04-01', '2021-05-01', 200);
CALL add_course_package('Beginner Friendly', 4, '2021-04-01', '2021-06-01', 300);
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

CALL register_session(2, 1, 1, 'redemption');
CALL register_session(2, 2, 1, 'redemption');

CALL register_session(3, 1, 1, 'redemption');
CALL register_session(3, 2, 1, 'redemption');
CALL register_session(3, 3, 1, 'redemption');

CALL register_session(4, 1, 1, 'redemption');
CALL register_session(4, 2, 1, 'redemption');
CALL register_session(4, 3, 1, 'redemption');
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


CALL cancel_registration(2, 2);
CALL cancel_registration(3, 3);
CALL cancel_registration(4, 1);
CALL cancel_registration(5, 1);
CALL cancel_registration(6, 1);
CALL cancel_registration(7, 1);
CALL cancel_registration(8, 1);
CALL cancel_registration(9, 1);
CALL cancel_registration(10, 1);

call register_session(1, 11, 1, 'payment');
call register_session(2, 12, 1, 'payment');
call register_session(3, 13, 1, 'payment');
call register_session(4, 14, 1, 'payment');
call register_session(5, 15, 1, 'payment');
call register_session(6, 16, 1, 'payment');
call register_session(7, 17, 1, 'payment');
call register_session(8, 18, 1, 'payment');
call register_session(9, 19, 1, 'payment');
call register_session(10, 20, 1, 'payment');

call cancel_registration(1, 11);
call cancel_registration(3, 13);
call cancel_registration(5, 15);
call cancel_registration(7, 17);
call cancel_registration(9, 19);