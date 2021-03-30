-- Test -- Expected Value
SELECT get_sales('2019-03-01') -- 0
SELECT get_sales('2030-03-01') -- 0
SELECT get_sales('2021-03-01') -- non-null positive value
SELECT get_salary('2019-03-01') -- 0
SELECT get_salary('2030-03-01') -- 0
SELECT get_salary('2021-03-01') -- non-null positive value
SELECT get_registration_fees('2021-07-30') -- non-null positive value
SELECT get_registration_fees('2019-07-30') -- 0
SELECT get_registration_fees('2021-07-30') -- 0
SELECT get_course_redemptions('2021-03-05') --1
SELECT get_course_redemptions('2019-04-05') -- 0
SELECT get_course_redemptions('2030-04-05') -- 0
SELECT get_refunded_fees('2021-03-01') -- non-null positive value
SELECT get_refunded_fees('2019-03-01') -- 0
SELECT get_refunded_fees('2030-04-05') -- 0
SELECT * FROM view_summary_report(0) -- Error
SELECT * FROM view_summary_report(-3) -- Error
SELECT * FROM view_summary_report(null) -- Error
SELECT * FROM view_summary_report(200) -- Lots of rows with zeros in them rows 
SELECT * FROM view_summary_report(3) --  5 columns, 3 rows, all non-null values
