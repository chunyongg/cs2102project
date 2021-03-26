DROP TYPE emp_type cascade;

DROP TYPE emp_category cascade;

DROP TYPE SessionInfo cascade;

CREATE TYPE emp_type AS ENUM ('full_time', 'part_time');

CREATE TYPE emp_category AS ENUM ('administrator', 'manager', 'instructor');

CREATE TYPE SessionInfo AS (
    session_date date,
    session_start timestamp,
    room_id integer
);

-- Q1
create
or replace procedure add_employee(
    type emp_type,
    name TEXT,
    address TEXT,
    contact_number integer,
    email TEXT,
    salary numeric,
    join_date date,
    category emp_category,
    areas text []
) 
AS $$ 

DECLARE emp_id integer;

temp_area text;

BEGIN IF (category = 'administrator' and array_length(areas, 1) <> 0) 
THEN 
    RAISE exception 'Administrator must have no course areas';
END IF;

INSERT INTO
    Employees
values
    (
        DEFAULT,
        name,
        address,
        contact_number,
        email,
        join_date,
        null
    ) RETURNING emp_id into emp_id;

IF (emp_type = 'full_time') THEN
    INSERT INTO FullTimeEmployees values(salary, emp_id);
ELSE
    INSERT INTO PartTimeEmployees values(salary, emp_id);
END IF;

IF (category = 'administrator') THEN
    INSERT INTO Administrators values(emp_id);
ELSIF (category = 'manager') THEN
    INSERT INTO Managers values(emp_id);
    FOREACH temp_area IN ARRAY areas LOOP
    UPDATE
        CourseAreas
    SET
        manager_id = emp_id
    where
        course_area = temp_area;
    END LOOP;

ELSE
    INSERT INTO Instructors values(emp_id);
END IF;
COMMIT;
END;

$$ LANGUAGE plpgsql;

-- Q2
CREATE
OR REPLACE PROCEDURE remove_employee(
    eid integer,
    depart_date date,
    category emp_category
) AS $$ DECLARE temp_date date;

category text;

BEGIN 
IF (NOT EXISTS (SELECT 1 FROM Employees where emp_id = eid)) THEN 
    RAISE EXCEPTION 'Employee does not exist';
END IF;

IF (category = 'administrator'
    and NOT EXISTS (
        SELECT
            1
        FROM
            Administrators
        where
            emp_id = eid
        limit
            1
    )
) THEN RAISE EXCEPTION 'Administrator does not exist';

ELSIF (
    category = 'instructor'
    and NOT EXISTS (
        SELECT
            1
        FROM
            Instructors
        where
            emp_id = eid
        limit
            1
    )
) THEN RAISE EXCEPTION 'Instructor does not exist';

ELSIF (
    category = 'manager'
    and NOT EXISTS (
        SELECT
            1
        FROM
            Managers
        where
            emp_id = eid
        limit
            1
    )
) THEN RAISE EXCEPTION 'Manager does not exist';

END IF;

IF (
    category = 'manager'
    and EXISTS (
        SELECT
            1
        FROM
            CourseAreas
        where
            manager_id = eid
    )
) THEN RAISE EXCEPTION 'You cannot remove a manager that is managing a Course Area.';

END IF;

IF (category = 'instructor') THEN
SELECT
    sess_date into temp_date
from
    Sessions
where
    instructor_id = eid
ORDER BY
    sess_date desc
LIMIT 1;

ELSIF (category = 'administrator') THEN
SELECT
    registration_deadline into temp_date
from
    CourseOfferings
where
    admin_id = eid
ORDER BY
    registration_deadline
LIMIT 1;

END IF;

IF (
    category = 'instructor'
    and temp_date > depart_date
) THEN RAISE EXCEPTION 'Instructor is teaching a session that starts after the instructor depart date';

ELSIF (
    category = 'administrator'
    and temp_date > depart_date
) THEN RAISE EXCEPTION 'Administrator is handling a Course Offering whose registration deadline is after the administrator departure date';

END IF;

UPDATE
    Employees
SET
    depart_date = depart_date
WHERE
    emp_id = eid;
END;

$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE PROCEDURE add_course(
    title text,
    description text,
    area text,
    duration integer
) AS $$ BEGIN
INSERT INTO
    Courses
values
(DEFAULT, duration, title, description, area);

END;

$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION getSeatingCapacity(_session_items SessionInfo []) RETURNS INTEGER AS $$ DECLARE item SessionInfo;

room_capacity integer;

capacity integer;

BEGIN capacity := 0;

FOREACH item IN ARRAY _session_items LOOP
SELECT
    seating_capacity into room_capacity
from
    ROOMS
where
    room_id = (item).room_id;

capacity := capacity + room_capacity;

END LOOP;

RETURN capacity;

END;

$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION getStartDate(session_items SessionInfo []) 
RETURNS DATE AS $$ 
DECLARE 
curr_date date;
temp_date date;
item SessionInfo;

BEGIN
FOREACH item IN ARRAY _session_items LOOP
    curr_date = (item).session_date;
    IF (temp_date IS NULL or curr_date < temp_date) THEN 
        temp_date := curr_date;
    END IF; 
END LOOP;
RETURN temp_date;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION getCourseDuration(cid integer) 
RETURNS INTEGER AS $$ 
DECLARE
course_duration integer;
BEGIN 
SELECT duration into course_duration FROM Courses where course_id = cid;
RETURN course_duration;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION getEndDate(session_items SessionInfo []) 
RETURNS DATE AS $$
DECLARE 
curr_date date;
temp_date date;
item SessionInfo;

BEGIN
FOREACH item IN ARRAY _session_items LOOP
    curr_date = (item).session_date;
    IF (temp_date IS NULL or curr_date > temp_date) THEN 
        temp_date := curr_date;
    END IF; 
END LOOP;
RETURN temp_date;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE PROCEDURE add_offering(
    offering_id integer,
    start_date date,
    end_date date,
    seating_capacity integer,
    course_id integer,
    fees numeric,
    target_number integer,
    launch_date date,
    registration_deadline date,
    admin_id integer
) AS $$ BEGIN
INSERT INTO
    CourseOfferings
values
(
        offering_id,
        launch_date,
        start_date,
        end_date,
        registration_deadline,
        target_number,
        fees,
        seating_capacity,
        admin_id,
        course_id
    );

END;

$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE PROCEDURE create_sessions(course_id integer, launch_date date, duration integer, session_items SessionInfo []) AS $$ 
DECLARE 
item SessionInfo;
instructor_id integer;
session_number integer;
latest_cancellation date;
end_time timestamp;
BEGIN -- For each session,
session_number := 1;
-- Use find_instructors (Q6) to get available Instructors
-- If no instructors, raise exception
FOREACH item IN ARRAY _session_items LOOP
    SELECT eid into instructor_id from find_instructors(course_id, (item).session_date, (item).session_start) LIMIT 1;
    if (instructor_id is NULL) THEN 
        RAISE EXCEPTION 'No instructors available to conduct session';
    END IF;
    end_time := (item).session_start + interval '1h' * duration;
    latest_cancellation = (item).session_date - 7;
    INSERT INTO Sessions values(DEFAULT, 
                                session_number, 
                                (item).session_start,
                                 end_time, 
                                 (item).session_date, 
                                 latest_cancellation, 
                                 instructor_id, 
                                 course_id, 
                                 launch_date, 
                                 (item).room_id);
    session_number := session_number + 1;
END LOOP;
END $$ LANGUAGE PLPGSQL;

-- Adds a new Course Offering.
-- Aborts if there are no sessions, session dates are in the past, seating capacity is less than target number, or no instructors
-- are available for one or more sessions.
-- Session end time is determined by start time and duration of course 
CREATE
OR REPLACE PROCEDURE add_course_offering(
    offering_id integer,
    course_id integer,
    fees numeric,
    target_number integer,
    launch_date date,
    registration_deadline date,
    admin_id integer,
    session_items SessionInfo []
) AS $$ 
DECLARE 

seating_capacity integer;

start_date date;

end_date date;

duration integer;

BEGIN 

IF (array_length(session_items, 1) = 0) THEN 
    RAISE EXCEPTION 'There must be at least one session';
END IF;

seating_capacity := getSeatingCapacity(session_items);

IF (seating_capacity < target_number) THEN 
    RAISE EXCEPTION 'Seating capacity must not be less than target registrations';
END IF;

SELECT getStartDate(session_items) into start_date;

SELECT getEndDate(session_items) into end_date;

SELECT getCourseDuration(course_id) into duration;

CALL add_offering(
    offering_id,
    start_date,
    end_date,
    seating_capacity,
    course_id,
    fees,
    target_number,
    launch_date,
    registration_deadline,
    admin_id
);

CALL create_sessions(course_id, launch_date, duration, session_items);

COMMIT;

END;

$$ LANGUAGE plpgsql;