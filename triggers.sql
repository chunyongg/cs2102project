CREATE OR REPLACE FUNCTION enforce_PartTimeSalary_Reference()
RETURNS TRIGGER AS $$
DECLARE 
hrs_worked INTEGER;
mo_year date;
hourly_pay numeric(10,2);
BEGIN 
    mo_year := date_trunc('month', NEW.payment_date);
    SELECT coalesce((SELECT hours_worked FROM PartTimeHoursWorked
    WHERE emp_id = NEW.emp_id
    AND month_year = mo_year), 0) INTO hrs_worked;
    IF hrs_worked <> NEW.hours THEN 
        RAISE EXCEPTION 'Part time employee only worked % hours this month', hrs_worked;
    END IF;
    SELECT hourly_rate INTO hourly_pay FROM PartTimeEmployees WHERE emp_id = NEW.emp_id;
    IF NEW.salary_amt <> hourly_pay * NEW.hours THEN 
        RAISE EXCEPTION 'Part time salary does not tally with hours worked';
    END IF;
RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS enforce_PartTimeSalary ON PartTimeSalary;
CREATE TRIGGER enforce_PartTimeSalary
BEFORE INSERT OR UPDATE ON PartTimeSalary
FOR EACH ROW EXECUTE FUNCTION enforce_PartTimeSalary_Reference();
