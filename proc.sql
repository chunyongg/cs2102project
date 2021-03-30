CREATE OR REPLACE FUNCTION end_of_month(month date)
RETURNS DATE as $$
BEGIN
RETURN (select (date_trunc('month', $1) + interval '1 month' - interval '1 day')::date);
END;
$$ language PLPGSQL;

CREATE OR REPLACE FUNCTION start_of_month(month date)
RETURNS DATE as $$
DECLARE 
BEGIN
RETURN (SELECT date_trunc('month', month));
END;
$$ language PLPGSQL;

CREATE OR REPLACE FUNCTION subtract_month( month date)
RETURNS DATE AS $$ 
BEGIN
    RETURN month - interval '1 month';
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_salary(month date) 
RETURNS NUMERIC(10,2) AS $$
DECLARE 
month_start date;
full_time_salary integer;
part_time_salary integer;
BEGIN 
SELECT start_of_month(month) into month_start;
SELECT COALESCE((SELECT sum(salary_amt) from FullTimeSalary WHERE payment_date >= month_start AND payment_date <= month), 0) 
into full_time_salary;
SELECT COALESCE((SELECT sum(salary_amt) from PartTimeSalary WHERE payment_date >= month_start AND payment_date <= month), 0) 
into part_time_salary;

RETURN full_time_salary + part_time_salary;

END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_sales(month date) 
RETURNS NUMERIC(10,2) AS $$
DECLARE 
totalSales NUMERIC(10,2);
month_start date;
BEGIN 
SELECT start_of_month(month) into month_start;
with BuysWithPrice as (
    SELECT buy_date, price from Buys natural join CoursePackages
)
SELECT sum(price) into totalSales from BuysWithPrice 
WHERE buy_date >= month_start AND buy_date <= month;
RETURN COALESCE(totalSales, 0);
END; 
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_registration_fees(month date) 
RETURNS NUMERIC(10,2) AS $$
DECLARE 
month_start date;
totalFees integer;
BEGIN 
SELECT start_of_month(month) into month_start;
with RegistersThisMonth as (
    SELECT sess_id FROM Registers natural join Sessions 
    WHERE register_date >= month_start AND register_date <= month 
)
SELECT sum(fees) into totalFees from RegistersThisMonth natural join CourseOfferings;
RETURN COALESCE(totalFees, 0);
END; 
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_refunded_fees(month date) 
RETURNS NUMERIC(10,2) AS $$
DECLARE 
totalRefund numeric(10,2);
month_start date;
BEGIN 
SELECT start_of_month(month) into month_start;
SELECT sum(refund_amt) into totalRefund from Cancels
WHERE cancel_date >= month_start AND cancel_date <= month;
RETURN coalesce(totalRefund, 0);
END; 
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_course_redemptions(month date) 
RETURNS INTEGER AS $$
DECLARE 
month_start date;
BEGIN 
SELECT start_of_month(month) into month_start;
RETURN (SELECT count(*) FROM Redeems 
WHERE redeem_date >= month_start AND redeem_date <= month);
END; 
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION view_summary_report(numberMonths integer) 
RETURNS TABLE(
    monthYear TEXT,
    salary NUMERIC(10,2),
    sales NUMERIC(10,2), 
    registration_fees NUMERIC(10,2), 
    refunds NUMERIC(10,2), 
    redemptions integer)
AS $$ 

DECLARE 
t_date date;
month_end date;
number_previous_months integer;

BEGIN 

IF (numberMonths IS NULL) THEN 
    RAISE EXCEPTION 'Number of months cannot be null';
END IF;

IF (numberMonths < 1) THEN 
    RAISE EXCEPTION 'Number of months must be at least 1';
END IF;

SELECT current_date into t_date;
SELECT end_of_month(t_date) into month_end;

FOR counter IN 1..numberMonths
    LOOP 
    SELECT TO_CHAR(month_end, 'Month YYYY') INTO monthYear;
    SELECT get_salary(month_end) INTO salary;
    SELECT get_sales(month_end) INTO sales;
    SELECT get_registration_fees(month_end) INTO registration_fees;
    SELECT get_refunded_fees(month_end) INTO refunds;
    SELECT get_course_redemptions(month_end) INTO redemptions;
    RETURN NEXT;
    SELECT subtract_month(month_end) INTO month_end;
    SELECT end_of_month(month_end) INTO month_end;
    END LOOP;
RETURN;
END;
$$ LANGUAGE PLPGSQL;
