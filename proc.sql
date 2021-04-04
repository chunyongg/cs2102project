----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S FUNCTIONS

-- F25 pay_salary
-- Function is rejected if it is not end of the month
-- Part time employee pay is calculated by hours worked multiplied by hourly rate
-- Full time employee pay is calculated by work days/total days * monthly salary

CREATE OR REPLACE FUNCTION get_number_days(d date) 
RETURNS INTEGER AS $$ 
    RETURN DATE_PART('days', d);
$$ LANGUAGE PLPGSQL;

-- Calculates payroll for full time employees who left this month or have not left yet
CREATE OR REPLACE FUNCTION pay_fullTimeEmployees()
RETURNS TABLE AS $$  
DECLARE 
r record;
mon_salary numeric(10,2);
d_date date;
eid integer;
curr_date date;
month_end date;
work_days integer;
last_work_day double precision;
BEGIN 
-- Calculate work days
    SELECT current_date INTO curr_date;
    SELECT end_of_month(current_date) into month_end;
    FOR r IN SELECT * FROM FullTimeEmployees FE NATURAL JOIN EMPLOYEES E 
    WHERE E.depart_date IS NULL 
    OR date_part('month', E.depart_date) >= date_part('month', curr_date)
        LOOP 
            eid:= r.emp_id;
            mon_salary := r.monthly_salary;
            d_date := r.depart_date;
            IF (d_date IS NULL OR date_part('month', d_date) > date_part('month', curr_date)) THEN 
                work_days := get_number_days(month_end);
            ELSE 
                work_days := get_number_days(d_date);
            END IF;

            RETURN NEXT;
        END LOOP;
END; 
$$ LANGUAGE PLPGSQL;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
