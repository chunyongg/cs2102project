----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGERS AND THEIR FUNCTIONS (put as a pair!)

CREATE OR REPLACE FUNCTION check_is_not_admin_or_manager()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Administrators WHERE emp_id = NEW.emp_id) OR EXISTS (SELECT 1 FROM Administrators WHERE emp_id = NEW.emp_id) THEN
        RAISE EXCEPTION 'Part time employee must not be an administrator or manager';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;


DROP TRIGGER IF EXISTS check_part_time_employee ON PartTimeEmployees;
CREATE TRIGGER check_part_time_employee
BEFORE INSERT ON PartTimeEmployees
FOR EACH ROW EXECUTE FUNCTION check_is_not_admin_or_manager();

CREATE OR REPLACE FUNCTION check_removal_condition()
RETURNS TRIGGER AS $$
DECLARE 
temp_date date;
BEGIN 
IF (OLD.depart_date IS NOT NULL AND NEW.depart_date <> OLD.depart_date) THEN
    RAISE EXCEPTION 'Employee already removed';
END IF;

IF EXISTS (SELECT 1 FROM CourseAreas WHERE manager_id = OLD.emp_id) THEN 
    RAISE EXCEPTION 'A manager managing course areas cannot be removed';
END IF;

IF EXISTS (SELECT 1 FROM CourseOfferings WHERE admin_id = OLD.emp_id AND registration_deadline > NEW.depart_date) THEN 
    RAISE EXCEPTION 'An administrator handling a course offering with registration deadline after depart date cannot be removed';
END IF;

SELECT
    sess_date into temp_date
from
    Sessions
where
    instructor_id = OLD.emp_id
ORDER BY
    sess_date desc
LIMIT 1;
IF temp_date > NEW.depart_date THEN 
    RAISE EXCEPTION 'Instructor is teaching a session that starts after the instructor depart date';
END IF;

RETURN NEW;

END;
$$ LANGUAGE PLPGSQL;

-- Ensure instructor or manager or administrator being removed are not teaching any sessions after depart date,
-- managing any course areas, or handling any course offerings
DROP TRIGGER IF EXISTS check_employee_removal ON EMPLOYEES;
CREATE TRIGGER check_employee_removal
BEFORE UPDATE ON Employees
FOR EACH ROW
WHEN 
((NEW.depart_date IS NOT NULL and OLD.depart_date IS NULL)
OR (OLD.depart_date IS NOT NULL AND NEW.depart_date <> OLD.depart_date)
)
EXECUTE FUNCTION check_removal_condition();

CREATE OR REPLACE FUNCTION check_courseofferings_seating_capacity()
RETURNS TRIGGER AS $$
BEGIN 
IF (NEW.seating_capacity < NEW.target_number_registrations) THEN
    RAISE EXCEPTION 'Seating capacity must not be less than target registrations';
END IF;
RETURN NEW;
END 
$$ LANGUAGE PLPGSQL;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S FUNCTIONS

DROP TYPE IF EXISTS emp_type cascade;

DROP TYPE IF EXISTS emp_category cascade;

DROP TYPE IF EXISTS SessionInfo cascade;

CREATE TYPE emp_type AS ENUM ('full_time', 'part_time');

CREATE TYPE emp_category AS ENUM ('administrator', 'manager', 'instructor');

CREATE TYPE SessionInfo AS (
    session_date date,
    session_start timestamp,
    room_id integer
);


create or replace procedure add_employee(
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

DECLARE eid integer;

temp_area text;

BEGIN 

IF (category = 'administrator' AND type = 'part_time') THEN 
    RAISE EXCEPTION  'Administrator must be full time';
END IF;

IF (category = 'manager' AND type = 'part_time') THEN 
    RAISE EXCEPTION 'Manager must be full time';
END IF;

IF (category = 'administrator' and array_length(areas, 1) <> 0) 
THEN 
    RAISE EXCEPTION 'Administrator must have no course areas';
ELSIF (category <> 'administrator' and array_length(areas, 1) IS NULL) THEN 
    RAISE EXCEPTION 'Course area must be specified';
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
    ) RETURNING emp_id into eid;

IF (type = 'full_time') THEN
    INSERT INTO FullTimeEmployees values(salary, eid);
ELSE
    INSERT INTO PartTimeEmployees values(salary, eid);
END IF;

IF (category = 'instructor') THEN 
    INSERT INTO Instructors values(eid);
END IF;

IF (type = 'full_time' AND category ='instructor') THEN 

    INSERT INTO FullTimeInstructors values(eid);
END IF;

IF (type = 'part_time' AND category ='instructor') THEN 
    INSERT INTO PartTimeInstructors values(eid);
END IF;

    FOREACH temp_area IN ARRAY areas 
    LOOP 
        IF (NOT EXISTS (SELECT 1 FROM COURSEAREAS WHERE course_area = temp_area)) THEN
            RAISE EXCEPTION 'Course area does not exist';
        END IF;
    END LOOP;

IF (category = 'administrator') THEN
    INSERT INTO Administrators values(eid);
ELSIF (category = 'manager') THEN
    INSERT INTO Managers values(eid);
    FOREACH temp_area IN ARRAY areas LOOP
    UPDATE
        CourseAreas
    SET
        manager_id = eid
    where
        course_area = temp_area;
    END LOOP;

ELSE
        FOREACH temp_area IN ARRAY areas LOOP
            INSERT INTO SPECIALIZATIONS VALUES(eid, temp_area);
        END LOOP;
END IF;

COMMIT;
END;

$$ LANGUAGE plpgsql;

-- F2

CREATE OR REPLACE PROCEDURE remove_employee(
    eid integer,
    d_date date
) 
AS $$
DECLARE 
temp_date date;
BEGIN 
IF (NOT EXISTS (SELECT 1 FROM Employees where emp_id = eid)) THEN 
    RAISE EXCEPTION 'Employee does not exist';
END IF;

UPDATE
    Employees
SET
    depart_date = d_date
WHERE
    emp_id = eid;
END;

$$ LANGUAGE PLPGSQL;


-- F5
CREATE OR REPLACE PROCEDURE add_course(
    title text,
    description text,
    area text,
    duration integer
) AS $$ 
INSERT INTO Courses values (DEFAULT, duration, title, description, area);
$$ LANGUAGE SQL;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

