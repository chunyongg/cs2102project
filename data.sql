delete from Rooms;
alter sequence Rooms_room_id_seq restart with 1;
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

delete from Employees;
alter sequence Employees_emp_id_seq restart with 1;
insert into Employees values
-- admin
(default, 'Sarah Tan', 'Blk 123 Ang Mo Kio', 90001010, 'sarah.tan@gmail.com', '2020-05-01', '2021-10-01'),
(default, 'Joshua Lau', '14 Marshall Road', 93487131, 'joshua.lau@gmail.com', '2020-06-01', null),
(default, 'Michelle Tan', '11 Bedok Reservoir Road', 93883567, 'michelle.tan@gmail.com', '2020-07-01', null),
(default, 'Angeline Hill', '240 Macpherson Road', 84026810, 'angeline.hill@gmail.com', '2018-06-01', null),
(default, 'Thomas Hackett', '19 Hougang Street', 88726293, 'thomas.hackett@gmail.com', '2019-05-01', null),
(default, 'Lowell Ward', '180B Bencoolen Street', 94517022, 'lowell.ward@gmail.com', '2019-05-01', '2021-08-01'),
(default, 'Aniya Covy', '24 Chapel Rd', 81613371, 'aniya.covy@gmail.com', '2019-05-11', '2019-08-01'),
(default, 'Howard Peter', '150F East Coast Road', 92903217, 'howard.peter@gmail.com', '2019-05-01', '2021-08-01'),
(default, 'Eugenia Haley', '15 Serangoon Road', 91839949, 'eugenia.haley@gmail.com', '2019-05-01', '2019-08-01'),
(default, 'Jennie Kozey', '438 Alexandra Road', 83428645, 'jennie.kozey@gmail.com', '2019-04-01', null),
-- managers
(default, 'Zander Chong', 'Blk 123 Toa Payoh', 93980294, 'zander.chong@gmail.com', '2018-01-01', null),
(default, 'Katheryn Brenda', 'Blk 129 Bishan Ave 3', 80525852, 'katheryn.brenda@gmail.com', '2020-09-01', null),
(default, 'Devan Boyle', 'Blk 44 Braddell Ave 1', 87336198, 'devan.boyle@gmail.com', '2020-10-01', null),
(default, 'David Sim', '25 Tuas Avenue 13', 98977879, 'david.sim@gmail.com', '2020-10-01', null),
(default, 'Joanna Neo', '391A Orchard Road', 92352568, 'joanna.neo@gmail.com', '2020-09-01', '2021-12-01'),
(default, 'Joey Chua', '414 Yishun Ring Rd', 87531197, 'joey.chua@gmail.com', '2020-08-01', '2021-12-01'),
(default, 'Joe Doe', '91 Defu Lane', 92803670, 'joe.doe@gmail.com', '2017-02-15', '2021-03-01'),
(default, 'Patrick Loh', '315 Outram Road', 83235333, 'patrick.loh@gmail.com', '2020-01-01', '2020-07-01'),
(default, 'Joella Tan', '370H Alexandra Road', 94766173, 'joella.tan@gmail.com', '2020-01-01', '2021-01-01'),
(default, 'Brenda Wong', '22 Kallang Ave', 91733252, 'brenda.wong@gmail.com', '2019-02-01', '2021-02-01'),
-- full time instructors
(default, 'Chloe Lim', '20 Prince Edward Road', 92265595, 'chloe.lim@gmail.com', '2020-02-01', null),
(default, 'Benjamin Kok', '81 Marine Parade Central', 84470579, 'benjamin.kok@gmail.com', '2020-06-01', '2021-12-01'),
(default, 'Jovin Seah', '53 Ubi Avenue 1', 87488977, 'jovin.seah@gmail.com', '2019-05-01', null),
(default, 'Joshua Chan', '1 North Bridge Road', 94563049, 'joshua.chan@gmail.com', '2018-08-01', null),
(default, 'Justin Lim', '35 Kallang Pudding Road', 97416583, 'justin.lim@gmail.com', '2021-01-01', '2021-03-01'),
-- part time instructors
(default, 'Stefanie Tan', '360 Orchard Road', 93381811, 'stefanie.tan@gmail.com', '2021-01-01', '2021-10-01'),
(default, 'Jared Wong', '7 Pasir Panjang Road', 91841170, 'jared.wong@gmail.com', '2021-02-01', '2021-08-01'),
(default, 'June Lim', '1 Brooke Rd', 97416583, 'june.lim@gmail.com', '2019-08-01', '2021-05-01'),
(default, 'Historia Reiss', 'Blk 407b Fernvale Road', 82956254, 'historia.reiss@gmail.com', '2021-01-01', null),
(default, 'Eren Yeager', '244 Westwood Ave', 97390470, 'eren.yeager@gmail.com', '2020-03-01', null);

delete from FullTimeEmployees;
insert into FullTimeEmployees values
(7000, 1),
(8000, 2),
(5000, 3),
(7000, 4),
(8500, 5),
(9000, 6),
(6000, 7),
(6500, 8),
(5500, 9),
(6000, 10),
(6600, 11),
(7300, 12),
(7200, 13),
(6500, 14),
(6800, 15),
(7500, 16),
(8200, 17),
(8900, 18),
(5300, 19),
(5400, 20),
(6600, 21),
(6700, 22),
(6800, 23),
(5500, 24),
(5000, 25);

delete from PartTimeEmployees;
insert into PartTimeEmployees values
(40, 26),
(45, 27),
(37.5, 28),
(35, 29),
(50, 30);

delete from Administrators;
insert into Administrators values
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10);

delete from Managers;
insert into Managers values
(11),
(12),
(13),
(14),
(15),
(16),
(17),
(18),
(19),
(20);

delete from Instructors;
insert into Instructors values
(21),
(22),
(23),
(24),
(25),
(26),
(27),
(28),
(29),
(30);

delete from CourseAreas;
insert into CourseAreas values
('Algorithms and Theory', 11),
('Artificial Intelligence', 12),
('Game Design', 13),
('Computer Security', 14),
('Database Systems', 15),
('Computer Networking', 16),
('Parallel Computing', 17),
('Software Engineering', 18),
('Data Analytics', 19),
('Programming Languages', 20);

delete from FullTimeInstructors;
insert into FullTimeInstructors values
('Algorithms and Theory', 21),
('Artificial Intelligence', 22),
('Game Design', 23),
('Computer Security', 24),
('Database Systems', 25);

delete from PartTimeInstructors;
insert into PartTimeInstructors values
('Computer Networking', 26),
('Parallel Computing', 27),
('Software Engineering', 28),
('Data Analytics', 29),
('Programming Languages', 30);

-- The earliest session can start at 9am and the latest session (for each day) must end by 6pm, and no sessions are conducted between 12pm to 2pm
-- So the maximum duration should be 7 hours
delete from Courses;
alter sequence Courses_course_id_seq restart with 1;
insert into Courses values
(default, 4, 'Introduction to Database Systems', 'This course covers programming with SQL, relational tuple calculus, relational domain calculus and relational algebra.', 'Database Systems'),
(default, 4, 'Database Systems Implementation', 'This course provides an in-depth study of the concepts and implementation issues related to database management systems.', 'Database Systems'),
(default, 2, 'Introduction to Data Analytics', 'This course introduces key data analytic algorithms and techniques used in data–rich business analytics projects.', 'Data Analytics'),
(default, 3, 'Principles of Programming Languages', null, 'Programming Languages'),
(default, 5, 'Introduction to Parallel Computing', 'This course exposes students to hands-on parallel programming projects on real parallel machines.', 'Parallel Computing'),
(default, 7, 'Neural Networks and Deep Learning', 'This course provides students with the knowledge of deep neural network.', 'Artificial Intelligence'),
(default, 2, 'Introduction to Computer Networking', null, 'Computer Networking'),
(default, 2, 'Introduction to Software Engineering', 'This course covers object-oriented system analysis, system modelling, implementation and testing.', 'Software Engineering'),
(default, 5, 'Image Processing and Analysis', 'This course introduces the fundamental concepts underlying digital image processing.', 'Artificial Intelligence'),
(default, 3, 'Optimisation Algorithms', 'This course introduces approaches for finding good-enough solutions to NP-hard problems.', 'Algorithms and Theory'),
(default, 1, 'Game Design', 'This course explores the factors that make a game successful.', 'Game Design'),
(default, 3, 'Distributed Databases', null, 'Database Systems'),
(default, 4, 'Game Development', 'This course introduces techniques for electronic game design and programming.', 'Game Design'),
(default, 6, 'Multi-core Architectures', 'This course examines the design issues that are critical to modern parallel architectures.', 'Parallel Computing'),
(default, 3, 'Software Product Engineering', 'This course allows students to develop well-tested, user-friendly, production-quality software in teams.', 'Software Engineering'),
(default, 3, 'Big Data Engineering for Analytics', 'This course equips students with skills to engineer big data solutions.', 'Data Analytics'),
(default, 6, 'Natural Language Processing', null, 'Artificial Intelligence'),
(default, 4, 'Network Security', 'This course introduces the state-of-the-art techniques for addressing network security issues.', 'Computer Security'),
(default, 3, 'Programming Language Implementation', 'This course discusses implementation aspects of fundamental programming paradigms.', 'Programming Languages'),
(default, 2, 'Internet of Things', null, 'Computer Networking');

delete from CoursePackages;
alter sequence CoursePackages_package_id_seq restart with 1;
insert into CoursePackages values
(default, '2021-01-01', '2021-12-01', 5, '2021 Sale', '4000'),
(default, '2021-03-01', '2021-04-01', 1, 'March Sale', '500'),
(default, '2021-05-01', '2021-08-01', 2, 'Summer Break Sale', '800');

delete from CourseOfferings;
insert into CourseOfferings values(launch_date, start_date, end_date, registration_target, fees, admin_id, course_id)
('2021-01-01', '2021-01-01', '2021-03-01', 100, 300.00, 20, 1, 1),
('2021-02-01', '2021-02-01', '2021-04-01', 200, 400.00, 25, 2, 2),
('2021-03-01', '2021-03-01', '2021-05-01', 100, 500.00, 30, 3, 3),
('2021-04-01', '2021-04-01', '2021-06-01', 200, 600.00, 35, 4, 4),
('2021-05-01', '2021-05-01', '2021-07-01', 100, 700.00, 40, 5, 5),
('2021-06-01', '2021-06-01', '2021-08-01', 200, 600.00, 20, 6, 6),
('2021-07-01', '2021-07-01', '2021-09-01', 100, 500.00, 25, 7, 7),
('2021-08-01', '2021-08-01', '2021-10-01', 200, 400.00, 30, 8, 8),
('2021-09-01', '2021-09-01', '2021-11-01', 100, 300.00, 35, 9, 9),
('2021-10-01', '2021-10-01', '2021-12-01', 200, 200.00, 40, 10, 10);

delete from Sessions;
alter sequence Sessions_sess_id_seq restart with 1;
insert into Sessions values 
(default, 1, '2021-11-01 14:00:00', '2021-11-01 15:00:00', '2021-11-01', '2021-10-25', 21, 10, '2021-10-01'),
(default, 2, '2021-11-01 17:00:00', '2021-11-01 18:00:00', '2021-11-01', '2021-10-25', 21, 10, '2021-10-01'),
(default, 3, '2021-12-01 14:00:00', '2021-12-01 15:00:00', '2021-12-01', '2021-11-24', 21, 10, '2021-10-01'),
(default, 1, '2021-09-01 09:00:00', '2021-09-01 10:00:00', '2021-09-01', '2021-08-25', 22, 8, '2021-08-01'),
(default, 2, '2021-10-01 11:00:00', '2021-10-01 12:00:00', '2021-10-01', '2021-09-24', 22, 8, '2021-08-01'),
(default, 1, '2021-07-01 11:00:00', '2021-07-01 12:00:00', '2021-07-01', '2021-06-24', 26, 6, '2021-06-01'),
(default, 1, '2021-06-01 15:00:00', '2021-06-01 16:00:00', '2021-06-01', '2021-05-24', 27, 5, '2021-05-01'),
(default, 1, '2021-04-01 11:00:00', '2021-04-01 12:00:00', '2021-04-01', '2021-03-24', 29, 3, '2021-03-01');

delete from Customers;
alter sequence Customers_cust_id_seq restart with 1;
insert into Customers values
(default, '13 Lor 8 Toa Payoh', 98264332, 'Xia Cheng', 'xiacheng@gmail.com'),
(default, '51 New Bridge Road', 82654397, 'Shi Hui Min', 'huimin96@yahoo.com'),
(default, '437 Tanjong Katong Rd', 89776527, 'Abdul Hazirah', 'itzhazirah@email.com'),
(default, 'Blk 32 Hougang Street 19', 93522165, 'Carole Tay', 'caroleee@me.com'),
(default, 'Blk 194 Tampines Street 16', 81234562, 'Diana Yusoff', 'dddofff@icloud.com'),
(default, '9 Jalan Selaseh', 99286426, 'Kristen Teoh', 'kristen123@gmail.com'),
(default, 'Blk 39 Bedok Street 75', 88261126, 'Alicia Tan', 'alistar73@outlook.com'),
(default, '82 Pandan Valley Circle', 89235761, 'Danish Yacob', 'dyacob@rocketmail.com'),
(default, 'Blk 49 Lorong 6 Buangkok', 99111836, 'Carter Shum', 'carter@ymail.com'),
(default, '30 Punggol Hill', 98183329, 'Yong See Kew Alvira', 'alviraysk@gmail.com');

delete from CreditCards;
insert into CreditCards values
('4602659607038509', 725, '2024-08-01', 1),
('348773017925424', 135, '2021-04-01', 2),
('4347465053571468', 355, '2022-05-01', 3),
('6011160715370157', 890, '2023-06-01', 4),
('5204007499487609', 447, '2024-07-01', 5),
('4209949185032728', 123, '2025-08-01', 6),
('371075328374437', 865, '2026-09-01', 7),
('367421788551567', 981, '2027-10-01', 8),
('5491129751647597', 236, '2028-11-01', 9),
('4246936242452879', 576, '2029-12-01', 10);

delete from Registers;
insert into Registers values 
()

