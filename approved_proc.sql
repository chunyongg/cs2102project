----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGERS AND THEIR FUNCTIONS (put as a pair!)

CREATE OR REPLACE FUNCTION insertHoursWorked_partTimeInstructor()
RETURNS TRIGGER AS $$
DECLARE 
inst_id integer;
new_hours_worked integer;
BEGIN 
    inst_id := NEW.instructor_id;
        IF (NOT EXISTS (SELECT 1 FROM PartTimeInstructors WHERE emp_id = inst_id)) THEN 
        RETURN NULL;
    END IF;
        new_hours_worked := get_difference_in_hours(NEW.end_time, NEW.start_time);
        INSERT INTO PartTimeHoursWorked 
        VALUES (new_hours_worked, date_trunc('month', NEW.sess_date), inst_id)
        ON CONFLICT (month_year, emp_id) DO UPDATE SET hours_worked = EXCLUDED.hours_worked + new_hours_worked;
    RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS insert_part_time_hours ON SESSIONS;
CREATE TRIGGER insert_part_time_hours
AFTER INSERT ON SESSIONS 
FOR EACH ROW EXECUTE FUNCTION insertHoursWorked_partTimeInstructor();

CREATE OR REPLACE FUNCTION removeHoursWorked_partTimeInstructor()
RETURNS TRIGGER AS $$
DECLARE 
inst_id integer;
old_hours_worked integer;
BEGIN 
    inst_id := OLD.instructor_id;
        IF (NOT EXISTS (SELECT 1 FROM PartTimeInstructors WHERE emp_id = inst_id)) THEN 
        RETURN NULL;
    END IF;
    old_hours_worked := get_difference_in_hours(OLD.end_time, OLD.start_time);

    UPDATE PartTimeHoursWorked
    SET hours_worked = hours_worked - old_hours_worked
    WHERE emp_id = OLD.instructor_id AND month_year = date_trunc('month', OLD.sess_date);
    RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS after_sess_delete_update_pt_hours ON SESSIONS;
CREATE TRIGGER after_sess_delete_update_pt_hours
AFTER DELETE ON SESSIONS
FOR EACH ROW EXECUTE FUNCTION removeHoursWorked_partTimeInstructor();


CREATE OR REPLACE FUNCTION updateHoursWorked_partTimeInstructor()
RETURNS TRIGGER AS $$
DECLARE 
inst_id integer;
hours_worked integer;
old_hours_worked integer;
new_hours_worked integer;
BEGIN 
    inst_id := NEW.instructor_id;

    old_hours_worked := get_difference_in_hours(OLD.end_time, OLD.start_time);
    new_hours_worked := get_difference_in_hours(NEW.end_time, NEW.start_time);

    INSERT INTO PartTimeHoursWorked 
    VALUES (new_hours_worked, date_trunc('month', NEW.sess_date), inst_id)
    ON CONFLICT (month_year, emp_id) DO UPDATE SET hours_worked = EXCLUDED.hours_worked + new_hours_worked;
    
    UPDATE PartTimeHoursWorked
    SET hours_worked = hours_worked - old_hours_worked
    WHERE emp_id = OLD.instructor_id AND month_year = date_trunc('month', OLD.sess_date);

RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS update_part_time_hours ON Sessions; 
CREATE TRIGGER update_part_time_hours
AFTER UPDATE ON SESSIONS 
FOR EACH ROW EXECUTE FUNCTION updateHoursWorked_partTimeInstructor();

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)

CREATE OR REPLACE FUNCTION get_number_days(d date) 
RETURNS INTEGER AS $$ 
	SELECT DATE_PART('days', d);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION get_difference_in_hours(t1 timestamp, t2 timestamp) 
RETURNS INTEGER AS $$
SELECT EXTRACT(EPOCH FROM t1 - t2)/3600
$$ LANGUAGE SQL;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S FUNCTIONS


-- F25 pay_salary
-- Function is rejected if it is not end of the month
-- Part time employee pay is calculated by hours worked multiplied by hourly rate
-- Full time employee pay is calculated by work days/total days * monthly salary
-- Calculates payroll for full time employees who left this month or have not left yet

CREATE OR REPLACE FUNCTION calculate_first_work_day(j_date date)
RETURNS INTEGER AS $$
DECLARE 
BEGIN 
            IF (date_part('month', j_date) = date_part('month', current_date) 
            AND date_part('year', j_date) = date_part('year', current_date)) THEN 
                RETURN EXTRACT(DAY FROM j_date);
            ELSE 
                RETURN 1;
            END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION calculate_last_work_day(d_date date) 
RETURNS INTEGER AS $$
DECLARE 
month_end date;
BEGIN 
SELECT end_of_month(current_date) into month_end;
IF (d_date IS NOT NULL 
    AND date_part('month', d_date) = date_part('month', current_date) 
    AND date_part('year', d_date) = date_part('year', current_date)) THEN 
RETURN get_number_days(d_date);
ELSE 
RETURN get_number_days(month_end);
END IF;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION find_hours_worked(d date, emp_id integer)
RETURNS INTEGER AS $$
SELECT PHRS.hours_worked FROM PartTimeHoursWorked PHRS
WHERE PHRS.emp_id = emp_id 
AND PHRS.month_year = date_trunc('month', d)
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION pay_fullTimeEmployees()
RETURNS TABLE(
emp_id integer, 
name text, 
status text, 
days_worked integer,
worked_hours integer,
hour_rate numeric(10,2),
monthly_salary numeric(10,2), 
salary_earned numeric(10,2)
) AS $$  
DECLARE 
r record;
curr_date date;
month_end date;
last_work_day integer;
first_work_day integer;
total_days_in_month integer;
BEGIN 
    SELECT current_date INTO curr_date;
    SELECT end_of_month(current_date) into month_end;
    FOR r IN SELECT * FROM FullTimeEmployees FE NATURAL JOIN EMPLOYEES E 
    WHERE E.depart_date IS NULL 
    OR date_part('month', E.depart_date) >= date_part('month', curr_date)
        LOOP 
            emp_id := r.emp_id;
            name := r.emp_name;
            status := 'Full Time';
            monthly_salary := r.monthly_salary;

            SELECT calculate_last_work_day(r.depart_date) INTO last_work_day;
            SELECT calculate_first_work_day(r.join_date) INTO first_work_day;
            SELECT date_part('days', month_end) INTO total_days_in_month;

            days_worked := last_work_day - first_work_day + 1;
            salary_earned := ((days_worked::float / total_days_in_month) * monthly_salary)::numeric(10,2);

            INSERT INTO FullTimeSalary VALUES(salary_earned, month_end, days_worked, emp_id);
        
            RETURN NEXT;
        END LOOP;
END; 
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION pay_PartTimeEmployees()
RETURNS TABLE(
emp_id integer, 
name text, 
status text, 
days_worked integer,
worked_hours integer,
hour_rate numeric(10,2),
monthly_salary numeric(10,2), 
salary_earned numeric(10,2)
) AS $$
DECLARE 
r record;
month_end date;
BEGIN 
    SELECT end_of_month(current_date) into month_end;
    FOR r IN SELECT * FROM PartTimeEmployees FE NATURAL JOIN EMPLOYEES E 
    WHERE E.depart_date IS NULL 
    OR date_part('month', E.depart_date) >= date_part('month', current_date)
    LOOP 
        emp_id := r.emp_id;
        name := r.emp_name;
        status := 'Part Time';
        worked_hours := coalesce(find_hours_worked(current_date, emp_id), 0);
        hour_rate := r.hourly_rate;
        salary_earned := worked_hours * hour_rate;
        INSERT INTO PartTimeSalary VALUES(salary_earned, month_end, worked_hours, emp_id);
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION PAY_SALARY()
RETURNS TABLE(
emp_id integer, 
name text, 
status text, 
days_worked integer,
worked_hours integer,
hour_rate numeric(10,2),
monthly_salary numeric(10,2), 
salary_earned numeric(10,2)
) AS $$
    SELECT * FROM pay_fullTimeEmployees() 
    UNION 
    SELECT * FROM pay_PartTimeEmployees();
$$ LANGUAGE SQL;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
