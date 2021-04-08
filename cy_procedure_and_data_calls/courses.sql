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

add_course_offering(
    offering_id integer,
    course_id integer,
    fees numeric,
    target_number integer,
    launch_date date,
    registration_deadline date,
    admin_id integer,
    session_items SessionInfo []
)

-- Algorithms
CALL add_course_offering(1, 1 , 100, 10, '2021-04-08', 
'2021-04-08', 1 , '{"(2021-04-19,\"2021-04-19 11:00:00\",1)"}' :: SessionInfo[]);
-- AI
CALL add_course_offering(2, 2 , 100, 11, '2021-04-08', 
'2021-04-08', 2 , '{"(2021-04-20,\"2021-04-20 10:00:00\",2)"}' :: SessionInfo[]);
-- Game Design
CALL add_course_offering(3, 3 , 100, 12, '2021-04-08', 
'2021-04-08', 3 , '{"(2021-04-21,\"2021-04-21 09:00:00\",3)"}' :: SessionInfo[]);
-- Computer Security
CALL add_course_offering(4, 4 , 100, 13, '2021-04-08', 
'2021-04-08', 4 , '{"(2021-04-19,\"2021-04-19 17:00:00\",4)"}' :: SessionInfo[]);
-- Database Systems
CALL add_course_offering(5, 5 , 100, 14, '2021-04-08', 
'2021-04-08', 5 , '{"(2021-04-20,\"2021-04-20 16:00:00\",5)"}' :: SessionInfo[]);
-- Networking
CALL add_course_offering(6, 6 , 100, 15, '2021-04-08', 
'2021-04-08', 6 , '{"(2021-04-21,\"2021-04-21 15:00:00\",6)"}' :: SessionInfo[]);
-- Parallel Computing
CALL add_course_offering(7, 7 , 100, 16, '2021-04-08', 
'2021-04-08', 7 , '{"(2021-04-22,\"2021-04-22 17:00:00\",7)"}' :: SessionInfo[]);
-- Software Engineering
CALL add_course_offering(8, 8 , 100, 17, '2021-04-08', 
'2021-04-08', 8 , '{"(2021-04-23,\"2021-04-23 16:00:00\",8)"}' :: SessionInfo[]);
-- Data Analytics
CALL add_course_offering(9, 9 , 100, 18, '2021-04-08', 
'2021-04-08', 9 , '{"(2021-04-26,\"2021-04-26 15:00:00\",9)"}' :: SessionInfo[]);
-- Programming Languages
CALL add_course_offering(10, 10 , 100, 19, '2021-04-08', 
'2021-04-08', 10 , '{"(2021-04-19,\"2021-04-27 17:00:00\",10)"}' :: SessionInfo[]);