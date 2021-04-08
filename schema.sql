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
	monthly_salary numeric(10, 2) not null check (monthly_salary > 0),
	emp_id integer primary key references Employees on delete cascade
);

create table PartTimeEmployees(
	hourly_rate numeric(10, 2) not null check (hourly_rate > 0),
	emp_id integer primary key references Employees on delete cascade
);

create table FullTimeSalary(
	salary_amt numeric(10, 2) not null check (salary_amt >= 0),
	payment_date date,
	days integer not null check (days >= 0),
	emp_id integer references FullTimeEmployees,
	primary key(payment_date, emp_id)
);

Create table PartTimeHoursWorked (
	hours_worked integer DEFAULT 0 check (hours_worked >= 0),
	month_year date check (date_part('day', month_year) = 1),
	emp_id integer references PartTimeEmployees,
	primary key (month_year, emp_id)
);

create table PartTimeSalary(
	salary_amt numeric(10, 2) not null check (salary_amt >= 0),
	payment_date date,
	hours integer not null check (hours >= 0),
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
  emp_id integer primary key references FullTimeEmployees references Instructors on delete cascade
);

create table Specializations(
  emp_id integer references Instructors,
  course_area text references CourseAreas,
  primary key (emp_id, course_area)
);

create table PartTimeInstructors(
  emp_id integer primary key references PartTimeEmployees references Instructors on delete cascade
);

create table Courses (
	course_id serial unique,
	duration integer not null check (duration > 0),
	title text unique not null,
	description text,
	course_area text references CourseAreas on delete cascade,
	primary key(course_id, course_area)
);

create table CourseOfferings (
	offering_id integer primary key,
	launch_date date not null check(launch_date <= registration_deadline),
	start_date date not null check (start_date <= end_date),
	end_date date not null,
	registration_deadline date not null check(registration_deadline <= start_date - 10),
	target_number_registrations integer not null,
	fees numeric(10, 2) not null check (fees >= 0),
	seating_capacity integer not null check (seating_capacity > 0),
	admin_id integer not null references Administrators,
	course_id integer references Courses(course_id) on delete cascade,
	unique(course_id, launch_date)
);

create table Rooms (
  room_id serial primary key,
  room_location varchar(5) not null,
  seating_capacity integer not null
);

create table Sessions (
	sess_id serial primary key,
	sess_num integer not null check (sess_num > 0),
	start_time timestamp not null check(
		start_time < end_time
		and date_part('hour', start_time) >= 9
		and date_part('hour', start_time) not in (12, 13)
		and extract(
			dow
			from
				start_time
		) in (1, 2, 3, 4, 5)
	),
	end_time timestamp not null check (
		end_time > start_time
		and date_part('hour', end_time) <= 18
		and date_part('hour', end_time) not in (13, 14)
		and extract(
			dow
			from
				end_time
		) in (1, 2, 3, 4, 5)
	),
	sess_date date not null,
	latest_cancel_date date check(latest_cancel_date = sess_date - 7),
	instructor_id integer not null references Instructors,
	offering_id integer not null references CourseOfferings(offering_id),
	room_id integer not null references Rooms,
	unique(offering_id, sess_num)
);

create table Customers (
  cust_id serial primary key,
  address text not null,
  phone integer not null,
  cust_name text not null,
  email text not null,
  unique(cust_id, address, phone, cust_name, email)
);

create table CreditCards (
  cc_number varchar(16),
  cvv integer not null,
  expiry_date date not null,
  cust_id integer unique not null references Customers,
  primary key(cc_number, cust_id)
);

create table CoursePackages (
	package_id serial primary key,
	sale_start_date date not null check (sale_start_date <= sale_end_date),
	sale_end_date date not null,
	num_free_registrations integer not null check (num_free_registrations > 0),
	package_name text not null,
	price numeric(10, 2) not null check(price >= 0)
);

create table Buys (
	buy_date date not null,
	redemptions_left integer not null check (redemptions_left >= 0),
	package_id integer references CoursePackages,
	cust_id integer references Customers on delete cascade,
	cc_number varchar(16) not null references CreditCards,
	primary key(cust_id, package_id)
);

create table Registers (
  register_date date not null,
  cust_id integer,
  sess_id integer references Sessions(sess_id),
  cc_number varchar(16) not null,
  foreign key (cust_id, cc_number) references CreditCards(cust_id, cc_number) on delete cascade,
  primary key(cust_id, sess_id)
);


create table Cancels (
	cancel_date date not null,
	refund_amt numeric(10, 2) not null check (refund_amt >= 0),
	package_credit integer not null check(
		package_credit = 0
		or package_credit = 1
	),
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
-- VIEWS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SessionParticipants AS
	SELECT cust_id, sess_id, null as package_id
	FROM Registers
	UNION
	SELECT cust_id, sess_id, package_id
	FROM Redeems;


CREATE OR REPLACE VIEW INSTRUCTORSPECIALIZATIONS AS
SELECT * FROM SPECIALIZATIONS;

CREATE OR REPLACE VIEW EmployeeTypes AS 
	SELECT emp_id, 'administrator' as emp_type FROM Administrators
	UNION 
	SELECT emp_id, 'manager' as emp_type FROM Managers
	UNION 
	SELECT emp_id, 'instructor' as emp_type FROM Instructors;

CREATE OR REPLACE VIEW EmployeeWorkingTypes AS 
	SELECT emp_id, 'full time' as emp_type FROM FullTimeEmployees
	UNION 
	SELECT emp_id, 'part time' as emp_type FROM PartTimeEmployees;

CREATE OR REPLACE VIEW InstructorWorkingTypes AS 
	SELECT emp_id, 'full time' as emp_type FROM FullTimeInstructors
	UNION 
	SELECT emp_id, 'part time' as emp_type FROM PartTimeInstructors;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE VIEW SessionsInOrder AS
    select sess_id, sess_date, start_time
    from Sessions
    order by (sess_date, start_time) asc;

CREATE OR REPLACE VIEW ManagerDetails AS
    select emp_id, emp_name
    from Managers natural left join Employees
    order by emp_name asc;

