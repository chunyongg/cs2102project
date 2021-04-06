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
-- admins (emp_id 1 - 10)
(default, 'Sarah Tan', 'Blk 123 Ang Mo Kio', 90001010, 'sarah.tan@gmail.com', '2020-05-01', '2021-10-01'),                       -- emp_id = 1, depart in oct 2021 (can use)
(default, 'Joshua Lau', '14 Marshall Road', 93487131, 'joshua.lau@gmail.com', '2020-06-01', null),                               -- emp_id = 2
(default, 'Michelle Tan', '11 Bedok Reservoir Road', 93883567, 'michelle.tan@gmail.com', '2020-07-01', null),                    -- emp_id = 3
(default, 'Angeline Hill', '240 Macpherson Road', 84026810, 'angeline.hill@gmail.com', '2018-06-01', null),                      -- emp_id = 4
(default, 'Thomas Hackett', '19 Hougang Street', 88726293, 'thomas.hackett@gmail.com', '2019-05-01', null),                      -- emp_id = 5
(default, 'Lowell Ward', '180B Bencoolen Street', 94517022, 'lowell.ward@gmail.com', '2019-05-01', '2022-05-01'),                -- emp_id = 6
(default, 'Aniya Covy', '24 Chapel Rd', 81613371, 'aniya.covy@gmail.com', '2019-05-11', '2019-08-01'),                           -- emp_id = 7
(default, 'Howard Peter', '150F East Coast Road', 92903217, 'howard.peter@gmail.com', '2019-05-01', '2021-08-01'),               -- emp_id = 8
(default, 'Eugenia Haley', '15 Serangoon Road', 91839949, 'eugenia.haley@gmail.com', '2019-05-01', '2019-08-01'),                -- emp_id = 9
(default, 'Jennie Kozey', '438 Alexandra Road', 83428645, 'jennie.kozey@gmail.com', '2019-04-01', null),                         -- emp_id = 10
-- managers (emp_id 11 - 20)
(default, 'Zander Chong', 'Blk 123 Toa Payoh', 93980294, 'zander.chong@gmail.com', '2018-01-01', null),                          -- emp_id = 11
(default, 'Katheryn Brenda', 'Blk 129 Bishan Ave 3', 80525852, 'katheryn.brenda@gmail.com', '2020-09-01', null),                 -- emp_id = 12
(default, 'Devan Boyle', 'Blk 44 Braddell Ave 1', 87336198, 'devan.boyle@gmail.com', '2020-10-01', null),                        -- emp_id = 13
(default, 'David Sim', '25 Tuas Avenue 13', 98977879, 'david.sim@gmail.com', '2020-10-01', null),                                -- emp_id = 14
(default, 'Joanna Neo', '391A Orchard Road', 92352568, 'joanna.neo@gmail.com', '2020-09-01', '2021-12-01'),                      -- emp_id = 15 
(default, 'Joey Chua', '414 Yishun Ring Rd', 87531197, 'joey.chua@gmail.com', '2020-08-01', '2021-12-01'),                       -- emp_id = 16
(default, 'Joe Doe', '91 Defu Lane', 92803670, 'joe.doe@gmail.com', '2017-02-15', '2021-03-01'),                                 -- emp_id = 17
(default, 'Patrick Loh', '315 Outram Road', 83235333, 'patrick.loh@gmail.com', '2020-01-01', '2020-07-01'),                      -- emp_id = 18
(default, 'Joella Tan', '370H Alexandra Road', 94766173, 'joella.tan@gmail.com', '2020-01-01', '2021-01-01'),                    -- emp_id = 19
(default, 'Brenda Wong', '22 Kallang Ave', 91733252, 'brenda.wong@gmail.com', '2019-02-01', '2021-02-01'),                       -- emp_id = 20
-- full time instructors (emp_id 21 - 30)2
(default, 'Chloe Lim', '20 Prince Edward Road', 92265595, 'chloe.lim@gmail.com', '2020-02-01', null),                            -- emp_id = 21
(default, 'Benjamin Kok', '81 Marine Parade Central', 84470579, 'benjamin.kok@gmail.com', '2020-06-01', '2021-12-01'),           -- emp_id = 22, depart in dec 2021 (can use)
(default, 'Jovin Seah', '53 Ubi Avenue 1', 87488977, 'jovin.seah@gmail.com', '2021-05-01', null),                                -- emp_id = 23, join in may 2021 (cannot use in apr)
(default, 'Joshua Chan', '1 North Bridge Road', 94563049, 'joshua.chan@gmail.com', '2018-08-01', null),                          -- emp_id = 24
(default, 'Justin Lim', '35 Kallang Pudding Road', 97416583, 'justin.lim@gmail.com', '2021-01-01', '2021-03-01'),                -- emp_id = 25, depart in mar 2021 (cannot use)
(default, 'Sean Fang', 'Blk 27 Bedok Street 77', 90872861, 'sean.fang@gmail.com', '2020-09-01', '2021-09-01'),                   -- emp_id = 26, depart in sep 2021 (can use)
(default, 'Farihah Riduan', '83 Bedok Reservoir Gate', 90648144, 'farihah.riduan@gmail.com', '2021-09-01', null),                -- emp_id = 27, join in sep 2021 (cannot use in apr - aug)
(default, 'Sarah Oh', 'Blk 15 Ang Mo Kio Street 19', 9323-2348, 'sarah.oh@gmail.com', '2020-08-01', '2022-02-01'),               -- emp_id = 28, depart in feb 2022 (can use)
(default, 'Beth Choi', 'Blk 342 Jurong West Street 10', 82653413, 'beth.choi@gmail.com', '2021-01-01', '2023-01-01'),            -- emp_id = 29, depart in jan 2023 (can use)
(default, 'Lindsey Yeoh', 'Blk 199 Lorong 7 Lok Yang', 85431443, 'lindsey.yeoh@gmail.com', '2021-01-01', '2023-01-01'),          -- emp_id = 30, depart in jan 2023 (can use)
-- part time instructors (emp_id 31 - 40)
(default, 'Stefanie Tan', '360 Orchard Road', 93381811, 'stefanie.tan@gmail.com', '2021-01-01', '2021-10-01'),                   -- emp_id = 31, depart in oct 2021 (can use)
(default, 'Jared Wong', '7 Pasir Panjang Road', 91841170, 'jared.wong@gmail.com', '2021-02-01', '2021-08-01'),                   -- emp_id = 32, depart in aug 2021 (can use)
(default, 'June Lim', '1 Brooke Rd', 97416583, 'june.lim@gmail.com', '2019-08-01', '2021-05-01'),                                -- emp_id = 33, depart in may 2021 (can use)
(default, 'Historia Reiss', 'Blk 407b Fernvale Road', 82956254, 'historia.reiss@gmail.com', '2021-01-01', null),                 -- emp_id = 34
(default, 'Eren Yeager', '244 Westwood Ave', 97390470, 'eren.yeager@gmail.com', '2020-03-01', null),                             -- emp_id = 35
(default, 'Stephen Tan', '63 West Coast Rd', 92287290, 'stephen.tan@gmail.com', '2021-05-01', null),                             -- emp_id = 36, join in may 2021 (cannot use in apr)
(default, 'Yxavion Lim', '709 Tampines Street 54', 86215290, 'yxavion.lim@gmail.com', '2020-01-01', null),                       -- emp_id = 37
(default, 'Ma Chen', '7 Thomson View', 98255196, 'ma.chen@gmail.com', '2020-01-01', '2021-04-01'),                               -- emp_id = 38, depart in apr 2021 (cannot use)
(default, 'Stuart Yip', '87 Tiong Bahru Walk', 81885290, 'stuart.yip@gmail.com', '2021-07-01', null),                            -- emp_id = 39, join in jul 2021 (cannot use in apr - june)
(default, 'Hasna Mohammad', 'Blk 43 Marine Parade Street 27', 98983211, 'hasna.mohammad@gmail.com', '2020-01-01', '2021-01-01'); -- emp_id = 40,depart in jan 2021 (cannot use)

delete from FullTimeEmployees;
insert into FullTimeEmployees values
-- admins
(2000, 1),
(2000, 2),
(2000, 3),
(2000, 4),
(2000, 5),
(2000, 6),
(2000, 7),
(2000, 8),
(2000, 9),
(2000, 10),
-- managers
(4000, 11),
(4000, 12),
(4000, 13),
(4000, 14),
(4000, 15),
(4000, 16),
(4000, 17),
(4000, 18),
(4000, 19),
(4000, 20),
-- full time instructors
(3000, 21),
(3000, 22),
(3000, 23),
(3000, 24),
(3000, 25),
(3000, 26),
(4000, 27),
(4000, 28),
(4000, 29),
(4000, 30);

delete from PartTimeEmployees;
insert into PartTimeEmployees values
(20, 31),
(20, 32),
(20, 33),
(20, 34),
(20, 35),
(20, 36),
(20, 37),
(20, 38),
(20, 39),
(20, 40);

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
(30),
(31),
(32),
(33),
(34),
(35),
(36),
(37),
(38),
(39),
(40);

delete from FullTimeInstructors;
insert into FullTimeInstructors values
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

delete from PartTimeInstructors;
insert into PartTimeInstructors values
(31),
(32),
(33),
(34),
(35),
(36),
(37),
(38),
(39),
(40);

-- Each manager manages zero or more course areas.
-- Each course area is managed by exactly one manager. 
-- Each course offering is managed by the manager of that course area.
delete from CourseAreas;
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

delete from Specializations;
insert into Specializations values
-- emp_id = 21 (FT), course areas = 1, 2
(21, 'Algorithms and Theory'),
(21, 'Artificial Intelligence'),
-- emp_id = 22 (FT), course areas = 3, 4
(22, 'Game Design'),
(22, 'Computer Security'),
-- emp_id = 23 (FT), course areas = 5, 6
(23, 'Database Systems'),
(23, 'Computer Networking'),
-- emp_id = 24 (FT), course areas = 7, 8
(24, 'Parallel Computing'),
(24, 'Software Engineering'),
-- emp_id = 25 (FT), course areas = 9, 10
(25, 'Data Analytics'),
(25, 'Programming Languages'),
-- emp_id = 26 (FT), course areas = 1, 3
(26, 'Algorithms and Theory'),
(26, 'Game Design'),
-- emp_id = 27 (FT), course areas = 5, 7
(27, 'Database Systems'),
(27, 'Parallel Computing'),
-- emp_id = 28 (FT), course areas = 2, 4
(28, 'Artificial Intelligence'),
(28, 'Computer Security'),
-- emp_id = 29 (FT), course areas = 6, 8
(29, 'Computer Networking'),
(29, 'Software Engineering'),
-- emp_id = 30 (FT), course areas = 9, 10
(30, 'Data Analytics'),
(30, 'Programming Languages'),
-- emp_id = 31 (PT), course areas = 1, 10
(31, 'Algorithms and Theory'),
(31, 'Programming Languages'),
-- emp_id = 32 (PT), course areas = 2, 9
(32, 'Artificial Intelligence'),
(32, 'Data Analytics'),
-- emp_id = 33 (PT), course areas = 3, 7
(33, 'Game Design'),
(33, 'Parallel Computing'),
-- emp_id = 34 (PT), course areas = 4, 6
(34, 'Computer Security'),
(34, 'Computer Networking'),
-- emp_id = 35 (PT), course area = 5
(35, 'Database Systems'),
-- emp_id = 36 (PT), course areas = 1, 2, 3, 4, 5
(36, 'Algorithms and Theory'),
(36, 'Artificial Intelligence'),
(36, 'Game Design'),
(36, 'Computer Security'),
(36, 'Database Systems'),
-- emp_id = 37 (PT), course areas = 6, 7, 8, 9, 10
(37, 'Computer Networking'),
(37, 'Parallel Computing'),
(37, 'Software Engineering'),
(37, 'Data Analytics'),
(37, 'Programming Languages'),
-- emp_id = 38 (PT), course areas = 1, 3, 5, 7, 9
(38, 'Algorithms and Theory'),
(38, 'Game Design'),
(38, 'Database Systems'),
(38, 'Parallel Computing'),
(38, 'Data Analytics'),
-- emp_id = 39 (PT), course areas = 2, 4, 6, 8, 10
(39, 'Artificial Intelligence'),
(39, 'Computer Security'),
(39, 'Computer Networking'),
(39, 'Software Engineering'),
(39, 'Programming Languages'),
-- emp_id = 40 (PT), course areas = 1, 6, 8
(40, 'Algorithms and Theory'),
(40, 'Computer Networking'),
(40, 'Software Engineering');

delete from Courses;
alter sequence Courses_course_id_seq restart with 1;
insert into Courses values
-- course area 1: Algorithms and Theory (course_id = 1)
(default, 1, 'Optimisation Algorithms', 'This course introduces approaches for finding good-enough solutions to NP-hard problems.', 'Algorithms and Theory'),
-- course area 2: Artificial Intelligence (course_ids = 2, 3, 4, 5)
(default, 2, 'Neural Networks and Deep Learning', 'This course provides students with the knowledge of deep neural network.', 'Artificial Intelligence'),
(default, 3, 'Image Processing and Analysis', 'This course introduces the fundamental concepts underlying digital image processing.', 'Artificial Intelligence'),
(default, 1, 'Distributed Databases', null, 'Database Systems'),
(default, 2, 'Natural Language Processing', null, 'Artificial Intelligence'),
-- course area 3: Game Design (course_ids = 6, 7)
(default, 3, 'Game Design', 'This course explores the factors that make a game successful.', 'Game Design'),
(default, 1, 'Game Development', 'This course introduces techniques for electronic game design and programming.', 'Game Design'),
-- course area 4: Computer Security (course_id = 8)
(default, 2, 'Network Security', 'This course introduces the state-of-the-art techniques for addressing network security issues.', 'Computer Security'),
-- course area 5: Database Systems (course_ids = 9, 10)
(default, 3, 'Introduction to Database Systems', 'This course covers programming with SQL, relational tuple calculus, relational domain calculus and relational algebra.', 'Database Systems'),  
(default, 1, 'Database Systems Implementation', 'This course provides an in-depth study of the concepts and implementation issues related to database management systems.', 'Database Systems'),
-- course area 6: Computer Networking (course_ids = 11, 12)
(default, 2, 'Introduction to Computer Networking', null, 'Computer Networking'),
(default, 3, 'Internet of Things', null, 'Computer Networking'),
-- course area 7: Parallel Computing (course_ids = 13, 14)
(default, 1, 'Introduction to Parallel Computing', 'This course exposes students to hands-on parallel programming projects on real parallel machines.', 'Parallel Computing'),
(default, 2, 'Multi-core Architectures', 'This course examines the design issues that are critical to modern parallel architectures.', 'Parallel Computing'),
-- course area 8: Software Engineering (course_ids = 15, 16)
(default, 3, 'Introduction to Software Engineering', 'This course covers object-oriented system analysis, system modelling, implementation and testing.', 'Software Engineering'),
(default, 1, 'Software Product Engineering', 'This course allows students to develop well-tested, user-friendly, production-quality software in teams.', 'Software Engineering'),
-- course area 9: Data Analytics (course_ids = 17, 18)
(default, 2, 'Introduction to Data Analytics', 'This course introduces key data analytic algorithms and techniques used in data–rich business analytics projects.', 'Data Analytics'),
(default, 3, 'Big Data Engineering for Analytics', 'This course equips students with skills to engineer big data solutions.', 'Data Analytics'),
-- course area 10: Programming Languages (course_ids = 19, 20)
(default, 1, 'Principles of Programming Languages', null, 'Programming Languages'),
(default, 2, 'Programming Language Implementation', 'This course discusses implementation aspects of fundamental programming paradigms.', 'Programming Languages');

delete from CourseOfferings;
insert into CourseOfferings values
-- offering_id, launch_date, start_date, end_date, registration_deadline, registration_target, fees, seating_capacity, admin_id, course_id
-- Each course can be offered mutiple times per year
-- The offerings for the same course have different launch dates
-- Each course offering consists of one or more sessions

-- course_id = 1 (course area 1)
(1, '2021-05-01', '2021-05-03', '2021-05-07', '2021-04-23', 100, 500, 100, 1, 1),
(2, '2021-05-15', '2021-05-17', '2021-05-21', '2021-05-07', 100, 500, 100, 2, 1),

-- course_id = 2 (course area 2)
(3, '2021-05-01', '2021-05-03', '2021-05-07', '2021-04-23', 100, 500, 100, 3, 2),

-- course_id = 6 (course area 3)
(4, '2021-05-01', '2021-05-03', '2021-09-06', '2021-04-23', 100, 500, 100, 4, 6),

-- course_id = 8 (course area 4)
(5, '2021-06-01', '2021-07-01', '2021-07-29', '2021-06-21', 100, 500, 100, 5, 8),

-- course_id = 9 (course area 5)
(6, '2021-06-01', '2021-07-01', '2021-07-15', '2021-06-21', 75, 500, 75, 6, 9),

-- course_id = 11 (course area 6)
(7, '2021-06-01', '2021-07-01', '2021-07-02', '2021-06-21', 50, 500, 50, 7, 11),

-- course_id = 13 (course area 7)
(8, '2021-07-01', '2021-08-02', '2021-08-02', '2021-07-23', 25, 500, 25, 8, 13),

-- course_id = 15 (course area 8)
(9, '2021-08-01', '2021-09-01', '2021-11-01', '2021-08-22', 75, 500, 75, 9, 15),

-- course_id = 17 (course area 9)
(10, '2021-09-01', '2021-10-01', '2021-10-08', '2021-09-21', 50, 500, 50, 10, 17),

-- course_id = 19 (course area 10)
(11, '2021-10-01', '2021-11-10', '2022-01-10', '2021-09-21', 90, 500, 90, 1, 19);

delete from Sessions;
alter sequence Sessions_sess_id_seq restart with 1;
insert into Sessions values 
-- sess_id, sess_num, start_time, end_time, sess_date, latest_cancel_date, instructor_id, offering_id, room_id
-- The sessions for a course offering are numbered consecutively starting from 1; we refer to these as session numbers

-- offering_id = 1, course_id = 1, course_area = 1, possible instructor_id = FT(21, 26), PT(31, 36, 38, 40)
-- sess_id = 1, 2, 3, 4, 5 (5, 95)

-- 21
-- 26: depart in dec 2021
-- 31: depart in oct 2021
-- 36: join in may 2021
-- 38: departed in apr 2021
-- 40: departed in jan 2021
(default, 1, '2021-05-03 09:00:00', '2021-05-03 10:00:00', '2021-05-03', '2021-04-26', 21, 1, 1),
(default, 2, '2021-05-04 09:00:00', '2021-05-04 10:00:00', '2021-05-04', '2021-04-27', 21, 1, 1),
(default, 3, '2021-05-05 09:00:00', '2021-05-05 10:00:00', '2021-05-05', '2021-04-28', 21, 1, 1),
(default, 4, '2021-05-06 09:00:00', '2021-05-06 10:00:00', '2021-05-06', '2021-04-29', 21, 1, 1),
(default, 5, '2021-05-07 09:00:00', '2021-05-07 10:00:00', '2021-05-07', '2021-04-30', 21, 1, 1),

-- offering_id = 2, course_id = 1, course_area = 1, possible instructor_id = FT(21, 26), PT(31, 36, 38, 40)
-- sess_id = 6, 7, 8, 9, 10 (5, 95)

-- 21
-- 26: depart in dec 2021
-- 31: depart in oct 2021
-- 36: join in may 2021
-- 38: departed in apr 2021
-- 40: departed in jan 2021

(default, 1, '2021-05-17 14:00:00', '2021-05-17 15:00:00', '2021-05-17', '2021-05-10', 21, 2, 2),
(default, 2, '2021-05-18 14:00:00', '2021-05-18 15:00:00', '2021-05-18', '2021-05-11', 21, 2, 2),
(default, 3, '2021-05-19 14:00:00', '2021-05-19 15:00:00', '2021-05-19', '2021-05-12', 21, 2, 2),
(default, 4, '2021-05-20 14:00:00', '2021-05-20 15:00:00', '2021-05-20', '2021-05-13', 21, 2, 2),
(default, 5, '2021-05-21 14:00:00', '2021-05-21 15:00:00', '2021-05-21', '2021-05-14', 21, 2, 2),

-- offering_id = 3, course_id = 2, course_area = 2, possible instructor_id = FT(21, 28), PT(32, 36, 39)
-- sess_id = 11, 12, 13, 14, 15 (5, 95)

-- 21
-- 28: depart in feb 2022
-- 32: depart in aug 2021
-- 36: join in may 2021
-- 39: join in jul 2021
(default, 1, '2021-05-03 09:00:00', '2021-05-03 11:00:00', '2021-05-03', '2021-04-26', 28, 3, 3),
(default, 2, '2021-05-04 09:00:00', '2021-05-04 11:00:00', '2021-05-04', '2021-04-27', 28, 3, 3),
(default, 3, '2021-05-05 09:00:00', '2021-05-05 11:00:00', '2021-05-05', '2021-04-28', 28, 3, 3),
(default, 4, '2021-05-06 09:00:00', '2021-05-06 11:00:00', '2021-05-06', '2021-04-29', 28, 3, 3),
(default, 5, '2021-05-07 09:00:00', '2021-05-07 11:00:00', '2021-05-07', '2021-04-30', 28, 3, 3),

-- offering_id = 4, course_id = 6, course_area = 3, possible instructor_id = FT(22, 26), PT(33, 36, 38)
-- sess_id = 16, 17, 18, 19, 20 (5, 95)

-- 22: depart in dec 2021
-- 26: depart in dec 2021
-- 33: depart in may 2021
-- 36: join in may 2021
-- 38: departed in apr 2021
(default, 1, '2021-05-03 15:00:00', '2021-05-03 18:00:00', '2021-05-03', '2021-04-26', 22, 4, 4),
(default, 2, '2021-06-07 15:00:00', '2021-06-07 18:00:00', '2021-06-07', '2021-05-31', 22, 4, 4),
(default, 3, '2021-07-05 15:00:00', '2021-07-05 18:00:00', '2021-07-05', '2021-06-28', 22, 4, 4),
(default, 4, '2021-08-02 15:00:00', '2021-08-02 18:00:00', '2021-08-02', '2021-07-26', 22, 4, 4),
(default, 5, '2021-09-06 15:00:00', '2021-09-06 18:00:00', '2021-09-06', '2021-08-30', 22, 4, 4),

-- offering_id = 5, course_id = 8, course_area = 4, possible instructor_id = FT(22, 28), PT(34, 36, 39)
-- sess_id = 21, 22, 23, 24, 25 (5, 95)

-- 22: depart in dec 2021
-- 28: depart in feb 2022
-- 34
-- 36: join in may 2021
-- 39: join in jul 2021
(default, 1, '2021-07-01 16:00:00', '2021-07-01 18:00:00', '2021-07-01', '2021-06-24', 22, 5, 5),
(default, 2, '2021-07-08 16:00:00', '2021-07-08 18:00:00', '2021-07-08', '2021-07-01', 22, 5, 5),
(default, 3, '2021-07-15 16:00:00', '2021-07-15 18:00:00', '2021-07-15', '2021-07-08', 22, 5, 5),
(default, 4, '2021-07-22 16:00:00', '2021-07-22 18:00:00', '2021-07-22', '2021-07-15', 22, 5, 5),
(default, 5, '2021-07-29 16:00:00', '2021-07-29 18:00:00', '2021-07-29', '2021-07-22', 22, 5, 5),

-- offering_id = 6, course_id = 9, course_area = 5, possible instructor_id = FT(23, 27), PT(35, 36, 38)
-- sess_id = 26, 27, 28 (3, 72)

-- 23: join in may 2021
-- 27: depart in feb 2022
-- 35
-- 36: join in may 2021
-- 38: departed in apr 2021
(default, 1, '2021-07-01 14:00:00', '2021-07-01 17:00:00', '2021-07-01', '2021-06-24', 23, 6, 6),
(default, 2, '2021-07-08 14:00:00', '2021-07-08 17:00:00', '2021-07-08', '2021-07-01', 23, 6, 6),
(default, 3, '2021-07-15 14:00:00', '2021-07-15 17:00:00', '2021-07-15', '2021-07-08', 23, 6, 6),

-- offering_id = 7, course_id = 11, course_area = 6, possible instructor_id = FT(23, 29), PT(34, 37, 39, 40)
-- sess_id = 29, 30 (3, 47)

-- 23: join in may 2021
-- 29: depart in jan 2023
-- 34
-- 37
-- 39: join in jul 2021
-- 40: departed in jan 2021
(default, 1, '2021-07-01 10:00:00', '2021-07-01 12:00:00', '2021-07-01', '2021-06-24', 23, 7, 7),
(default, 2, '2021-07-02 10:00:00', '2021-07-02 12:00:00', '2021-07-02', '2021-06-25', 23, 7, 7),

-- offering_id = 8, course_id = 13, course_area = 7, possible instructor_id = FT(24, 27), PT(33, 37, 38)
-- sess_id = 31 (3, 22)

-- 24
-- 27: depart in feb 2022
-- 33: depart in may 2021
-- 37
-- 38: departed in apr 2021
(default, 1, '2021-08-02 10:00:00', '2021-08-02 11:00:00', '2021-08-02', '2021-07-26', 24, 8, 8),

-- offering_id = 9, course_id = 15, course_area = 8, possible instructor_id = FT(24, 29), PT(37, 39, 40)
-- sess_id = 32, 33, 34 (3, 72)

-- 24
-- 29: depart in jan 2023
-- 37
-- 39: join in jul 2021
-- 40: departed in jan 2021
(default, 1, '2021-09-01 09:00:00', '2021-09-01 12:00:00', '2021-09-01', '2021-08-25', 24, 9, 9),
(default, 2, '2021-10-01 09:00:00', '2021-10-01 12:00:00', '2021-10-01', '2021-09-24', 24, 9, 9),
(default, 3, '2021-11-01 09:00:00', '2021-11-01 12:00:00', '2021-11-01', '2021-10-25', 24, 9, 9),

-- offering_id = 10, course_id = 17, course_area = 9, possible instructor_id = FT(25, 30), PT(32, 37, 38)
-- sess_id = 35, 36 (3, 47)

-- 25: depart in mar 2021
-- 30: depart in jan 2023
-- 32: depart in aug 2021
-- 37
-- 38: departed in apr 2021
-- 40: departed in jan 2021
(default, 1, '2021-10-01 15:00:00', '2021-10-01 17:00:00', '2021-10-01', '2021-09-24', 25, 10, 10),
(default, 2, '2021-10-08 15:00:00', '2021-10-08 17:00:00', '2021-10-08', '2021-10-01', 25, 10, 10),

-- offering_id = 11, course_id = 19, course_area = 10, possible instructor_id = FT(25, 30), PT(31, 37, 39)
-- sess_id = 37, 38, 39 (0, 90)

-- 25: departed in mar 2021
-- 30: depart in jan 2023
-- 31: depart in oct 2021
-- 37
-- 39: join in jul 2021
(default, 1, '2021-11-10 09:00:00', '2021-11-10 10:00:00', '2021-11-10', '2021-11-03', 25, 11, 11),
(default, 2, '2021-12-10 09:00:00', '2021-12-10 10:00:00', '2021-12-10', '2021-12-03', 25, 11, 11),
(default, 3, '2022-01-10 09:00:00', '2022-01-10 10:00:00', '2022-01-10', '2022-01-03', 25, 11, 11);

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
(default, '30 Punggol Hill', 98183329, 'Yong See Kew Alvira', 'alviraysk@gmail.com'),
(default, 'Blk 616D Gleason Grove Place', 95026183, 'Sedrick Skiles', 'sedrick@gmail.com'),
(default, 'Blk 5 Jalan Boyer', 97763128, 'Beryl Carroll', 'beryl.carroll@icloud.com'),
(default, '50 Jalan Lateh', 96656111, 'Lexus Ratke', 'lexus_ratke@fastmail.com'),
(default, '487 Crescent Link', 81836428, 'Peggy Tan', 'peggy78@mail.com'),
(default, '3 Phillip Street', 82357968, 'Sheryl Goh', 'sherylgoh@gmail.com'),
(default, '320 Lavender St', 97966656, 'Sherman Heng', 'shermanhengah@ymail.com'),
(default, '1 Kaki Bukit View', 81265434, 'Lucy Cheng', 'luckylucy@mail.com'),
(default, '279 Balestier Road', 98126456, 'Fatimah Bte Ahmed', 'fatimah@gmail.com'),
(default, '101B Up Cross St', 99864564, 'Lashimi Ramasamy', 'lashimi@yahoo.com.sg'),
(default, 'Blk 120 Serangoon Gardens', 87271543, 'Sarah Tan', 'sarah_tan@hotmail.com.sg'),
(default, 'Blk 281 Lorong 4 Lok Yang', 94928027, 'Nabila Salleh', 'nabilasalleh@outlook.com'),
(default, '23 Simei Center', 90816006, 'Preeti Sun', 'preeti@me.com'),
(default, '65 Chong Pang Green', 82936537, 'Adi Wahid', 'adi_wahid@email.com'),
(default, '7 Teck Ghee Road', 92298531, 'Amanda Hong', 'amandahong@gmail.com'),
(default, '6 Choa Chu Kang Hill', 83553470, 'Hassan Nasser', 'hassan@me.com');

delete from CreditCards;
insert into CreditCards values
('4602659607038509', 725, '2022-01-01', 1),
('3487730179254246', 135, '2023-02-01', 2),
('4347465053571468', 355, '2024-03-01', 3),
('6011160715370157', 890, '2022-04-01', 4),
('5204007499487609', 447, '2023-05-01', 5),
('4209949185032728', 123, '2024-06-01', 6),
('3710753283744374', 865, '2022-07-01', 7),
('3674217885515676', 981, '2023-08-01', 8),
('5491129751647597', 236, '2024-09-01', 9),
('4246936242452879', 576, '2022-10-01', 10),
('3770148713541449', 282, '2023-11-01', 11),
('4716439600987074', 913, '2024-12-01', 12),
('4024007196118250', 642, '2022-12-01', 13),
('5598648621344095', 241, '2023-11-01', 14),
('4994864865055287', 173, '2024-10-01', 15),
('4255179226593710', 287, '2023-09-01', 16),
('3462414407196593', 752, '2022-08-01', 17),
('6346055242179659', 198, '2024-07-01', 18),
('4876053574214217', 953, '2023-06-01', 19),
('3283357111169600', 862, '2022-05-01', 20),
('4402703555407878', 218, '2024-04-01', 21),
('4713286671658115', 754, '2023-03-01', 22),
('5344835097660156', 893, '2022-02-01', 23),
('5392456596274919', 443, '2024-01-01', 24),
('3411892055157023', 369, '2023-12-01', 25);

delete from Registers;
insert into Registers values 

-- customer 1 (oid = 1, 2, 3, 4, 5)
('2021-04-23', 1,  1,   '4602659607038509'),
('2021-05-07', 1,  6,   '4602659607038509'),
('2021-04-23', 1,  11,  '4602659607038509'),
('2021-04-23', 1,  16,  '4602659607038509'),
('2021-06-21', 1,  21,  '4602659607038509'),
-- customer 2 (oid = 6, 7, 8)
('2021-06-21', 2,  26,  '3487730179254246'),
('2021-06-21', 2,  29,  '3487730179254246'),
('2021-07-23', 2,  31,  '3487730179254246'),
-- customer 3 (oid = 9, 10)
('2021-08-22', 3,  32,  '4347465053571468'),
('2021-09-21', 3,  35,  '4347465053571468'),
-- customer 4 (oid = 1, 2, 3, 4, 5)
('2021-04-23', 4,  2,   '6011160715370157'),
('2021-05-07', 4,  7,   '6011160715370157'),
('2021-04-23', 4,  12,  '6011160715370157'),
('2021-04-23', 4,  17,  '6011160715370157'),
('2021-06-21', 4,  22,  '6011160715370157'),
-- customer 5 (oid = 1, 2, 3, 4, 5)
('2021-04-23', 5,  3,   '5204007499487609'),
('2021-05-07', 5,  8,   '5204007499487609'),
('2021-04-23', 5,  13,  '5204007499487609'),
('2021-04-23', 5,  18,  '5204007499487609'),
('2021-06-21', 5,  23,  '5204007499487609'),
-- customer 6 (oid = 1, 2, 3, 4, 5)
('2021-04-23', 6,  4,   '4209949185032728'),
('2021-05-07', 6,  9,   '4209949185032728'),
('2021-04-23', 6,  14,  '4209949185032728'),
('2021-04-23', 6,  19,  '4209949185032728'),
('2021-06-21', 6,  24,  '4209949185032728'),
-- customer 7 (oid = 1, 2, 3, 4, 5)
('2021-04-23', 7,  5,   '3710753283744374'),
('2021-05-07', 7,  10,  '3710753283744374'),
('2021-04-23', 7,  15,  '3710753283744374'),
('2021-04-23', 7,  20,  '3710753283744374'),
('2021-06-21', 7,  21,  '3710753283744374'),
-- customer 8 (oid = 6, 8, 10)
('2021-06-21', 8,  27,  '3674217885515676'),
('2021-07-23', 8,  31,  '3674217885515676'),
('2021-09-21', 8,  36,  '3674217885515676'),
-- customer 9 (oid = 7, 9)
('2021-06-21', 9,  30,  '5491129751647597'),
('2021-08-22', 9,  33,  '5491129751647597'),
-- customer 10 (oid = 6, 7, 8, 9, 10)
('2021-07-06', 10, 26, '4246936242452879'),
('2021-07-06', 10, 29, '4246936242452879'),
('2021-07-06', 10, 31, '4246936242452879'),
('2021-07-06', 10, 32, '4246936242452879'),
('2021-07-06', 10, 35, '4246936242452879');

-- Remaining customers for old sessions:

-- ('2021-07-07', 11, ?, '3770148713541449'),
-- ('2021-07-08', 12, ?, '4716439600987074'),
-- ('2021-07-09', 13, ?, '4024007196118250'),
-- ('2021-07-10', 14, ?, '5598648621344095'),
-- ('2021-07-11', 15, ?, '4994864865055287'),
-- ('2021-07-12', 16, ?, '4255179226593710'),
-- ('2021-07-13', 17, ?, '3462414407196593'),
-- ('2021-07-14', 18, ?, '6346055242179659'),
-- ('2021-07-15', 19, ?, '4876053574214217'),
-- ('2021-07-16', 20, ?, '3283357111169600'),
-- ('2021-07-17', 21, ?, '4402703555407878'),
-- ('2021-07-18', 22, ?, '4713286671658115');

-- nobody registered for oid = 11
-- nobody registered for sess_id = 25, 28, 34, 37, 38, 39
-- customer 23, 24, 25 register nothing

delete from Buys;
insert into Buys values 