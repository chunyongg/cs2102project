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

CALL add_course_offering(11, 1, 300, 200, '2021-05-21', '2021-05-11', 42, '{"(2021-05-21,\"2021-05-21 00:00:00\",1)"}' :: SessionInfo[])
-- AI
CALL add_course_offering(1, COURSE_ID , 100, 10, '2021-04-18', '2021-04-08', ADMIN_ID , );
