drop schema public cascade;
create schema public;

create table Employees (
	emp_id serial primary key,
	emp_name text not null,
	emp_address text not null,
	emp_contact integer not null,
	emp_email text not null,
	join_date date not null,
	depart_date date
);
	
create table FullTimeEmployees (
	monthly_salary numeric(10,2) not null,
	emp_id integer primary key references Employees on delete cascade
);

create table PartTimeEmployees(
	hourly_rate numeric(10,2) not null,
	emp_id integer primary key references Employees on delete cascade
);
	
create table FullTimeSalary(
	salary_amt numeric(10,2) not null,
	payment_date date,
	days integer not null,
	emp_id integer references FullTimeEmployees,
	primary key(payment_date, emp_id)
);
	
create table PartTimeSalary(
	salary_amt numeric(10,2) not null,
	payment_date date,
	hours integer not null,
	emp_id integer references PartTimeEmployees,
	primary key(payment_date, emp_id)
);
	
create table Administrators(
	emp_id integer primary key references FullTimeEmployees on delete cascade
);
	
create table Managers(
	emp_id integer primary key references FullTimeEmployees on delete cascade
);
	
create table Instructors(
	emp_id integer primary key references Employees on delete cascade
);

create table CourseAreas (
	course_area text primary key,
	manager_id integer not null references Managers
);

create table FullTimeInstructors(
	course_area text not null references CourseAreas,
	emp_id integer primary key references FullTimeEmployees references Instructors on delete cascade
);
	
create table PartTimeInstructors(
	course_area text not null references CourseAreas,
	emp_id integer primary key references PartTimeEmployees references Instructors on delete cascade
);


create table Courses (
	course_id serial unique,
	duration integer not null,
	title text unique not null,
	description text,
	course_area text references CourseAreas on delete cascade,
	primary key(course_id, course_area)
);

create table CourseOfferings (
	offering_id integer primary key,
	launch_date date not null,
	start_date date not null,
	end_date date not null,
	registration_deadline date not null
		check(registration_deadline = start_date - 10),
	target_number_registrations integer not null,
	fees numeric(10,2) not null,
	seating_capacity integer not null,
	admin_id integer not null references Administrators,
	course_id integer references Courses(course_id) on delete cascade
);

create table Rooms (
	room_id serial primary key,
	room_location varchar(5) not null,
	seating_capacity integer not null
);

create table Sessions (
	sess_id serial primary key,
	sess_num integer not null,
	start_time timestamp not null
		check(start_time < end_time 
			  and date_part('hour', start_time) >= 9 
			  and date_part('hour', start_time) not in (12, 13)
			  and extract(dow from start_time) in (1, 2, 3, 4, 5)),
	end_time timestamp not null
		check (end_time > start_time
			  and date_part('hour', end_time) <= 18
			  and date_part('hour', end_time) not in (13, 14)
			  and extract(dow from end_time) in (1, 2, 3, 4, 5)),
	sess_date date not null,
	latest_cancel_date date
		check(latest_cancel_date = sess_date - 7),
	instructor_id integer not null references Instructors,
	offering_id integer not null references CourseOfferings(offering_id),
	room_id integer not null references Rooms
);

create table Customers (
	cust_id serial primary key,
	address text not null,
	phone integer not null,
	cust_name text not null,
	email text not null
);

create table CreditCards (
	cc_number varchar(16) primary key,
	cvv integer not null,
	expiry_date date not null,
	cust_id integer not null references Customers
);

create table CoursePackages (
	package_id serial primary key,
	sale_start_date date not null,
	sale_end_date date not null,
	num_free_registrations integer not null,
	package_name text not null,
	price numeric(10, 2) not null
);

create table Buys (
	buy_date date not null,
	redemptions_left integer not null,
	package_id integer references CoursePackages,
	cust_id integer references Customers on delete cascade,
	cc_number varchar(16) not null references CreditCards,
	primary key(cust_id, package_id)
);

create table Registers (
	register_date date not null,
	cust_id integer references Customers on delete cascade,
	sess_id integer references Sessions(sess_id),
	cc_number varchar(16) not null references CreditCards,
	primary key(cust_id, sess_id)
);

create table Cancels (
	cancel_date date not null,
	refund_amt numeric(10,2) not null,
	package_credit integer not null
		check(package_credit = 0 or package_credit = 1),
	cust_id integer references Customers,
	sess_id integer references Sessions(sess_id),
	primary key(cust_id, sess_id)
);

create table Redeems (
	redeem_date date not null,
	sess_id integer references Sessions(sess_id),
	package_id integer not null,
	cust_id integer,
	foreign key (package_id, cust_id) references Buys(package_id, cust_id),
	primary key(cust_id, sess_id)
);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGERS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Trigger for sess end time
CREATE OR REPLACE FUNCTION check_session_end()
RETURNS TRIGGER AS $$
DECLARE
    _course_id INTEGER;
    _duration INTEGER;
    _start_time TIMESTAMP;
    _end_time TIMESTAMP;
    _check_end_time TIMESTAMP;
BEGIN
    _start_time := NEW.start_time;
	_end_time := NEW.end_time;
    SELECT course_id INTO _course_id FROM CourseOfferings WHERE offering_id = NEW.offering_id;
    SELECT duration INTO _duration FROM Courses WHERE course_id = _course_id;
    SELECT (_start_time + (_duration||' hours')::INTERVAL) INTO _check_end_time;
    IF (_end_time <> _check_end_time) THEN
        RAISE EXCEPTION 'Duration of the session does not match the duration of the course';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_session_end_trigger
BEFORE INSERT OR UPDATE ON Sessions
FOR EACH ROW EXECUTE FUNCTION check_session_end();

-- Trigger for PartTime/FullTime: Instructor only paid once a month, and paid at the end of the month
CREATE OR REPLACE FUNCTION check_ft_salary_payment()
RETURNS TRIGGER AS $$
DECLARE
    _ft_payment_date DATE;
    _last_day_of_month DATE;
    _number_of_payment_dates INTEGER;
BEGIN
    SELECT payment_date INTO _ft_payment_date FROM FullTimeSalary;
    SELECT end_of_month(_ft_payment_date) INTO _last_day_of_month;
    SELECT COUNT(DISTINCT payment_date) INTO _number_of_payment_dates FROM FullTimeSalary 
        WHERE DATE_PART('month', payment_date) = DATE_PART('month', _last_day_of_month) 
        AND DATE_PART('year', payment_date) = DATE_PART('year', _last_day_of_month);
    IF (_ft_payment_date <> _last_day_of_month) THEN
        RAISE EXCEPTION 'Payment date is not at end of the month';
    END IF;
	IF (_number_of_payment_dates > 1) THEN
        RAISE EXCEPTION 'Salaries are paid more than once for this month';
	END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_ft_payment_date_trigger
BEFORE INSERT ON FullTimeSalary
FOR EACH ROW EXECUTE FUNCTION check_ft_salary_payment();

CREATE OR REPLACE FUNCTION check_pt_salary_payment()
RETURNS TRIGGER AS $$
DECLARE
    _pt_payment_date DATE;
    _last_day_of_month DATE;
    _number_of_payment_dates INTEGER;
BEGIN
    SELECT payment_date INTO _pt_payment_date FROM PartTimeSalary;
    SELECT end_of_month(_pt_payment_date) INTO _last_day_of_month;
    SELECT COUNT(DISTINCT payment_date) INTO _number_of_payment_dates FROM PartTimeSalary 
        WHERE DATE_PART('month', payment_date) = DATE_PART('month', _last_day_of_month) 
        AND DATE_PART('year', payment_date) = DATE_PART('year', _last_day_of_month);
    IF (_pt_payment_date <> _last_day_of_month) THEN
        RAISE EXCEPTION 'Payment date is not at end of the month';
    END IF;
	IF (_number_of_payment_dates > 1) THEN
        RAISE EXCEPTION 'Salaries are paid more than once for this month';
	END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_pt_payment_date_trigger
BEFORE INSERT ON PartTimeSalary
FOR EACH ROW EXECUTE FUNCTION check_pt_salary_payment();