drop schema public cascade;
create schema public;

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
	days integer not null check (days >= 0 and days <= 31),
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
	duration integer not null check (duration > 0 and duration <= 4),
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
		date_trunc('day', start_time) = sess_date
		and start_time < end_time
		and date_part('hour', start_time) >= 9
		and date_part('hour', start_time) not in (12, 13)
		and extract(
			dow
			from
				start_time
		) in (1, 2, 3, 4, 5)
	),
	end_time timestamp not null check (
		date_trunc('day', end_time) = sess_date
		and end_time > start_time
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
  cust_id integer,
  cc_number varchar(16) not null,
  primary key(cust_id, package_id)
);

create table Registers (
  register_date date not null,
  cust_id integer,
  sess_id integer references Sessions(sess_id),
  cc_number varchar(16) not null,
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


INSERT INTO employees VALUES (2, 'Joshua Lau', '14 Marshall Road', 93487131, 'joshua.lau@gmail.com', '2020-06-01', NULL);
INSERT INTO employees VALUES (3, 'Michelle Tan', '11 Bedok Reservoir Road', 93883567, 'michelle.tan@gmail.com', '2020-07-01', NULL);
INSERT INTO employees VALUES (4, 'Angeline Hill', '240 Macpherson Road', 84026810, 'angeline.hill@gmail.com', '2018-06-01', NULL);
INSERT INTO employees VALUES (5, 'Thomas Hackett', '19 Hougang Street', 88726293, 'thomas.hackett@gmail.com', '2019-05-01', NULL);
INSERT INTO employees VALUES (10, 'Jennie Kozey', '438 Alexandra Road', 83428645, 'jennie.kozey@gmail.com', '2019-04-01', NULL);
INSERT INTO employees VALUES (11, 'Zander Chong', 'Blk 123 Toa Payoh', 93980294, 'zander.chong@gmail.com', '2018-01-01', NULL);
INSERT INTO employees VALUES (12, 'Katheryn Brenda', 'Blk 129 Bishan Ave 3', 80525852, 'katheryn.brenda@gmail.com', '2020-09-01', NULL);
INSERT INTO employees VALUES (13, 'Devan Boyle', 'Blk 44 Braddell Ave 1', 87336198, 'devan.boyle@gmail.com', '2020-10-01', NULL);
INSERT INTO employees VALUES (14, 'David Sim', '25 Tuas Avenue 13', 98977879, 'david.sim@gmail.com', '2020-10-01', NULL);
INSERT INTO employees VALUES (15, 'Joanna Neo', '391A Orchard Road', 92352568, 'joanna.neo@gmail.com', '2020-09-01', NULL);
INSERT INTO employees VALUES (16, 'Joey Chua', '414 Yishun Ring Rd', 87531197, 'joey.chua@gmail.com', '2020-08-01', NULL);
INSERT INTO employees VALUES (17, 'Joe Doe', '91 Defu Lane', 92803670, 'joe.doe@gmail.com', '2017-02-15', NULL);
INSERT INTO employees VALUES (18, 'Patrick Loh', '315 Outram Road', 83235333, 'patrick.loh@gmail.com', '2020-01-01', NULL);
INSERT INTO employees VALUES (19, 'Joella Tan', '370H Alexandra Road', 94766173, 'joella.tan@gmail.com', '2020-01-01', NULL);
INSERT INTO employees VALUES (20, 'Brenda Wong', '22 Kallang Ave', 91733252, 'brenda.wong@gmail.com', '2019-02-01', NULL);
INSERT INTO employees VALUES (21, 'Chloe Lim', '20 Prince Edward Road', 91733252, 'chloe.lim@gmail.com', '2020-02-01', NULL);
INSERT INTO employees VALUES (23, 'Jovin Seah', '53 Ubi Avenue 1', 87488977, 'jovin.seah@gmail.com', '2021-05-01', NULL);
INSERT INTO employees VALUES (24, 'Joshua Chan', '1 North Bridge Road', 94563049, 'joshua.chan@gmail.com', '2018-08-01', NULL);
INSERT INTO employees VALUES (27, 'Farihah Riduan', '83 Bedok Reservoir Gate', 90648144, 'farihah.riduan@gmail.com', '2021-09-01', NULL);
INSERT INTO employees VALUES (34, 'Historia Reiss', 'Blk 407b Fernvale Road', 82956254, 'historia.reiss@gmail.com', '2021-01-01', NULL);
INSERT INTO employees VALUES (35, 'Eren Yeager', '244 Westwood Ave', 97390470, 'eren.yeager@gmail.com', '2020-03-01', NULL);
INSERT INTO employees VALUES (36, 'Stephen Tan', '63 West Coast Rd', 92287290, 'stephen.tan@gmail.com', '2021-05-01', NULL);
INSERT INTO employees VALUES (37, 'Yxavion Lim', '709 Tampines Street 54', 86215290, 'yxavion.lim@gmail.com', '2020-01-01', NULL);
INSERT INTO employees VALUES (39, 'Stuart Yip', '87 Tiong Bahru Walk', 81885290, 'stuart.yip@gmail.com', '2021-07-01', NULL);
INSERT INTO employees VALUES (1, 'Sarah Tan', 'Blk 123 Ang Mo Kio', 90001010, 'sarah.tan@gmail.com', '2020-05-01', '2021-10-01');
INSERT INTO employees VALUES (6, 'Lowell Ward', '180B Bencoolen Street', 94517022, 'lowell.ward@gmail.com', '2019-05-01', '2022-05-01');
INSERT INTO employees VALUES (7, 'Aniya Covy', '24 Chapel Rd', 81613371, 'aniya.covy@gmail.com', '2019-05-11', '2019-08-01');
INSERT INTO employees VALUES (8, 'Howard Peter', '150F East Coast Road', 92903217, 'howard.peter@gmail.com', '2019-05-01', '2021-08-01');
INSERT INTO employees VALUES (9, 'Eugenia Haley', '15 Serangoon Road', 91839949, 'eugenia.haley@gmail.com', '2019-05-01', '2019-08-01');
INSERT INTO employees VALUES (22, 'Benjamin Kok', '81 Marine Parade Central', 84470579, 'benjamin.kok@gmail.com', '2020-06-01', '2021-12-01');
INSERT INTO employees VALUES (25, 'Justin Lim', '35 Kallang Pudding Road', 97416583, 'justin.lim@gmail.com', '2021-01-01', '2021-03-01');
INSERT INTO employees VALUES (26, 'Sean Fang', 'Blk 27 Bedok Street 77', 90872861, 'sean.fang@gmail.com', '2020-09-01', '2021-09-01');
INSERT INTO employees VALUES (28, 'Sarah Oh', 'Blk 15 Ang Mo Kio Street 19', 93232348, 'sarah.oh@gmail.com', '2020-08-01', '2022-02-01');
INSERT INTO employees VALUES (29, 'Beth Choi', 'Blk 342 Jurong West Street 10', 82653413, 'beth.choi@gmail.com', '2021-01-01', '2023-01-01');
INSERT INTO employees VALUES (30, 'Lindsey Yeoh', 'Blk 199 Lorong 7 Lok Yang', 85431443, 'lindsey.yeoh@gmail.com', '2021-01-01', '2023-01-01');
INSERT INTO employees VALUES (31, 'Stefanie Tan', '360 Orchard Road', 93381811, 'stefanie.tan@gmail.com', '2021-01-01', '2021-10-01');
INSERT INTO employees VALUES (32, 'Jared Wong', '7 Pasir Panjang Road', 91841170, 'jared.wong@gmail.com', '2021-02-01', '2021-08-01');
INSERT INTO employees VALUES (33, 'June Lim', '1 Brooke Rd', 97416583, 'june.lim@gmail.com', '2019-08-01', '2021-05-01');
INSERT INTO employees VALUES (38, 'Ma Chen', '7 Thomson View', 98255196, 'ma.chen@gmail.com', '2021-04-01', '2021-04-01');
INSERT INTO employees VALUES (40, 'Hasna Mohammad', 'Blk 43 Marine Parade Street 27', 98983211, 'hasna.mohammad@gmail.com', '2020-01-01', '2021-01-01');

alter sequence Employees_emp_id_seq restart with 41;

INSERT INTO fulltimeemployees VALUES (3000.00, 1);
INSERT INTO fulltimeemployees VALUES (3000.00, 2);
INSERT INTO fulltimeemployees VALUES (3000.00, 3);
INSERT INTO fulltimeemployees VALUES (3000.00, 4);
INSERT INTO fulltimeemployees VALUES (3000.00, 5);
INSERT INTO fulltimeemployees VALUES (3000.00, 6);
INSERT INTO fulltimeemployees VALUES (3000.00, 7);
INSERT INTO fulltimeemployees VALUES (3000.00, 8);
INSERT INTO fulltimeemployees VALUES (3000.00, 9);
INSERT INTO fulltimeemployees VALUES (3000.00, 10);
INSERT INTO fulltimeemployees VALUES (4000.00, 11);
INSERT INTO fulltimeemployees VALUES (4000.00, 12);
INSERT INTO fulltimeemployees VALUES (4000.00, 13);
INSERT INTO fulltimeemployees VALUES (4000.00, 14);
INSERT INTO fulltimeemployees VALUES (4000.00, 15);
INSERT INTO fulltimeemployees VALUES (4000.00, 16);
INSERT INTO fulltimeemployees VALUES (4000.00, 17);
INSERT INTO fulltimeemployees VALUES (4000.00, 18);
INSERT INTO fulltimeemployees VALUES (4000.00, 19);
INSERT INTO fulltimeemployees VALUES (4000.00, 20);
INSERT INTO fulltimeemployees VALUES (5000.00, 21);
INSERT INTO fulltimeemployees VALUES (5000.00, 22);
INSERT INTO fulltimeemployees VALUES (5000.00, 23);
INSERT INTO fulltimeemployees VALUES (5000.00, 24);
INSERT INTO fulltimeemployees VALUES (5000.00, 25);
INSERT INTO fulltimeemployees VALUES (5000.00, 26);
INSERT INTO fulltimeemployees VALUES (5000.00, 27);
INSERT INTO fulltimeemployees VALUES (5000.00, 28);
INSERT INTO fulltimeemployees VALUES (5000.00, 29);
INSERT INTO fulltimeemployees VALUES (5000.00, 30);

INSERT INTO administrators VALUES (1);
INSERT INTO administrators VALUES (2);
INSERT INTO administrators VALUES (3);
INSERT INTO administrators VALUES (4);
INSERT INTO administrators VALUES (5);
INSERT INTO administrators VALUES (6);
INSERT INTO administrators VALUES (7);
INSERT INTO administrators VALUES (8);
INSERT INTO administrators VALUES (9);
INSERT INTO administrators VALUES (10);

INSERT INTO coursepackages VALUES (1, '2021-03-03', '2021-03-03', 1, '3-3 Sale Package', 100.00);
INSERT INTO coursepackages VALUES (2, '2021-04-01', '2021-04-15', 5, 'Flash Sale', 150.00);
INSERT INTO coursepackages VALUES (3, '2021-04-01', '2021-05-01', 6, 'Trial', 200.00);
INSERT INTO coursepackages VALUES (4, '2021-04-01', '2021-06-01', 7, 'Beginner Friendly', 300.00);
INSERT INTO coursepackages VALUES (5, '2021-04-01', '2021-07-01', 8, 'Best Value', 500.00);
INSERT INTO coursepackages VALUES (6, '2021-04-01', '2021-08-01', 9, 'Ultimate Edition', 1000.00);
INSERT INTO coursepackages VALUES (7, '2021-04-01', '2021-09-01', 10, 'Intermediate Package', 1300.00);
INSERT INTO coursepackages VALUES (8, '2021-04-01', '2021-10-01', 11, 'Comprehensive Package', 2000.00);
INSERT INTO coursepackages VALUES (9, '2021-04-01', '2021-11-01', 12, 'Expert Package', 2500.00);
INSERT INTO coursepackages VALUES (10, '2021-04-01', '2021-12-01', 13, 'Unlimited', 10000.00);

alter sequence CoursePackages_package_id_seq restart with 11;

INSERT INTO customers VALUES (1, '13 Lor 8 Toa Payoh', 98264332, 'Xia Cheng', 'xiacheng@gmail.com');
INSERT INTO customers VALUES (2, '51 New Bridge Road', 82654397, 'Shi Hui Min', 'huimin96@yahoo.com');
INSERT INTO customers VALUES (3, '437 Tanjong Katong Rd', 89776527, 'Abdul Hazirah', 'itzhazirah@email.com');
INSERT INTO customers VALUES (4, 'Blk 32 Hougang Street 19', 93522165, 'Carole Tay', 'caroleee@me.com');
INSERT INTO customers VALUES (5, 'Blk 194 Tampines Street 16', 81234562, 'Diana Yusoff', 'dddofff@icloud.com');
INSERT INTO customers VALUES (6, '9 Jalan Selaseh', 99286426, 'Kristen Teoh', 'kristen123@gmail.com');
INSERT INTO customers VALUES (7, 'Blk 39 Bedok Street 75', 88261126, 'Alicia Tan', 'alistar73@outlook.com');
INSERT INTO customers VALUES (8, '82 Pandan Valley Circle', 89235761, 'Danish Yacob', 'dyacob@rocketmail.com');
INSERT INTO customers VALUES (9, 'Blk 49 Lorong 6 Buangkok', 99111836, 'Carter Shum', 'carter@ymail.com');
INSERT INTO customers VALUES (10, '30 Punggol Hill', 98183329, 'Yong See Kew Alvira', 'alviraysk@gmail.com');
INSERT INTO customers VALUES (11, 'Blk 616D Gleason Grove Place', 95026183, 'Sedrick Skiles', 'sedrick@gmail.com');
INSERT INTO customers VALUES (12, 'Blk 5 Jalan Boyer', 97763128, 'Beryl Carroll', 'beryl.carroll@icloud.com');
INSERT INTO customers VALUES (13, '50 Jalan Lateh', 96656111, 'Lexus Ratke', 'lexus_ratke@fastmail.com');
INSERT INTO customers VALUES (14, '487 Crescent Link', 81836428, 'Peggy Tan', 'peggy78@mail.com');
INSERT INTO customers VALUES (15, '3 Phillip Street', 82357968, 'Sheryl Goh', 'sherylgoh@gmail.com');
INSERT INTO customers VALUES (16, '320 Lavender St', 97966656, 'Sherman Heng', 'shermanhengah@ymail.com');
INSERT INTO customers VALUES (17, '1 Kaki Bukit View', 81265434, 'Lucy Cheng', 'luckylucy@mail.com');
INSERT INTO customers VALUES (18, '279 Balestier Road', 98126456, 'Fatimah Bte Ahmed', 'fatimah@gmail.com');
INSERT INTO customers VALUES (19, '101B Up Cross St', 99864564, 'Lashimi Ramasamy', 'lashimi@yahoo.com.sg');
INSERT INTO customers VALUES (20, 'Blk 120 Serangoon Gardens', 87271543, 'Sarah Tan', 'sarah_tan@hotmail.com.sg');
INSERT INTO customers VALUES (21, 'Blk 281 Lorong 4 Lok Yang', 94928027, 'Nabila Salleh', 'nabilasalleh@outlook.com');
INSERT INTO customers VALUES (22, '23 Simei Center', 90816006, 'Preeti Sun', 'preeti@me.com');
INSERT INTO customers VALUES (23, '65 Chong Pang Green', 82936537, 'Adi Wahid', 'adi_wahid@email.com');
INSERT INTO customers VALUES (24, '7 Teck Ghee Road', 92298531, 'Amanda Hong', 'amandahong@gmail.com');
INSERT INTO customers VALUES (25, '6 Choa Chu Kang Hill', 83553470, 'Hassan Nasser', 'hassan@me.com');

alter sequence Customers_cust_id_seq restart with 26;

INSERT INTO creditcards VALUES ('4602659607038509', 725, '2022-01-01', 1);
INSERT INTO creditcards VALUES ('3487730179254246', 135, '2023-02-01', 2);
INSERT INTO creditcards VALUES ('4347465053571468', 355, '2024-03-01', 3);
INSERT INTO creditcards VALUES ('6011160715370157', 890, '2022-04-01', 4);
INSERT INTO creditcards VALUES ('5204007499487609', 447, '2023-05-01', 5);
INSERT INTO creditcards VALUES ('4209949185032728', 123, '2024-06-01', 6);
INSERT INTO creditcards VALUES ('3710753283744374', 865, '2022-07-01', 7);
INSERT INTO creditcards VALUES ('3674217885515676', 981, '2023-08-01', 8);
INSERT INTO creditcards VALUES ('5491129751647597', 236, '2024-09-01', 9);
INSERT INTO creditcards VALUES ('4246936242452879', 576, '2022-10-01', 10);
INSERT INTO creditcards VALUES ('3770148713541449', 282, '2023-11-01', 11);
INSERT INTO creditcards VALUES ('4716439600987074', 913, '2024-12-01', 12);
INSERT INTO creditcards VALUES ('4024007196118250', 642, '2022-12-01', 13);
INSERT INTO creditcards VALUES ('5598648621344095', 241, '2023-11-01', 14);
INSERT INTO creditcards VALUES ('4994864865055287', 173, '2024-10-01', 15);
INSERT INTO creditcards VALUES ('4255179226593710', 287, '2023-09-01', 16);
INSERT INTO creditcards VALUES ('3462414407196593', 752, '2022-08-01', 17);
INSERT INTO creditcards VALUES ('6346055242179659', 198, '2024-07-01', 18);
INSERT INTO creditcards VALUES ('4876053574214217', 953, '2023-06-01', 19);
INSERT INTO creditcards VALUES ('3283357111169600', 862, '2022-05-01', 20);
INSERT INTO creditcards VALUES ('4402703555407878', 218, '2024-04-01', 21);
INSERT INTO creditcards VALUES ('4713286671658115', 754, '2023-03-01', 22);
INSERT INTO creditcards VALUES ('5344835097660156', 893, '2022-02-01', 23);
INSERT INTO creditcards VALUES ('5392456596274919', 443, '2024-01-01', 24);
INSERT INTO creditcards VALUES ('3411892055157023', 369, '2023-12-01', 25);

INSERT INTO buys VALUES ('2021-04-10', 4, 2, 1, '4602659607038509');
INSERT INTO buys VALUES ('2021-04-10', 4, 2, 2, '3487730179254246');
INSERT INTO buys VALUES ('2021-04-10', 4, 3, 3, '4347465053571468');
INSERT INTO buys VALUES ('2021-04-10', 4, 4, 4, '6011160715370157');
INSERT INTO buys VALUES ('2021-04-10', 4, 5, 5, '5204007499487609');
INSERT INTO buys VALUES ('2021-04-10', 4, 6, 6, '4209949185032728');
INSERT INTO buys VALUES ('2021-04-10', 4, 7, 7, '3710753283744374');
INSERT INTO buys VALUES ('2021-04-10', 4, 8, 8, '3674217885515676');
INSERT INTO buys VALUES ('2021-04-10', 4, 9, 9, '5491129751647597');
INSERT INTO buys VALUES ('2021-04-10', 4, 10, 10, '4246936242452879');

INSERT INTO managers VALUES (11);
INSERT INTO managers VALUES (12);
INSERT INTO managers VALUES (13);
INSERT INTO managers VALUES (14);
INSERT INTO managers VALUES (15);
INSERT INTO managers VALUES (16);
INSERT INTO managers VALUES (17);
INSERT INTO managers VALUES (18);
INSERT INTO managers VALUES (19);
INSERT INTO managers VALUES (20);

INSERT INTO courseareas VALUES ('Algorithms and Theory', 11);
INSERT INTO courseareas VALUES ('Artificial Intelligence', 12);
INSERT INTO courseareas VALUES ('Game Design', 13);
INSERT INTO courseareas VALUES ('Computer Security', 14);
INSERT INTO courseareas VALUES ('Database Systems', 15);
INSERT INTO courseareas VALUES ('Computer Networking', 16);
INSERT INTO courseareas VALUES ('Parallel Computing', 17);
INSERT INTO courseareas VALUES ('Software Engineering', 18);
INSERT INTO courseareas VALUES ('Data Analytics', 19);
INSERT INTO courseareas VALUES ('Programming Languages', 20);

INSERT INTO instructors VALUES (21);
INSERT INTO instructors VALUES (22);
INSERT INTO instructors VALUES (23);
INSERT INTO instructors VALUES (24);
INSERT INTO instructors VALUES (25);
INSERT INTO instructors VALUES (26);
INSERT INTO instructors VALUES (27);
INSERT INTO instructors VALUES (28);
INSERT INTO instructors VALUES (29);
INSERT INTO instructors VALUES (30);
INSERT INTO instructors VALUES (31);
INSERT INTO instructors VALUES (32);
INSERT INTO instructors VALUES (33);
INSERT INTO instructors VALUES (34);
INSERT INTO instructors VALUES (35);
INSERT INTO instructors VALUES (36);
INSERT INTO instructors VALUES (37);
INSERT INTO instructors VALUES (38);
INSERT INTO instructors VALUES (39);
INSERT INTO instructors VALUES (40);

INSERT INTO fulltimeinstructors VALUES (21);
INSERT INTO fulltimeinstructors VALUES (22);
INSERT INTO fulltimeinstructors VALUES (23);
INSERT INTO fulltimeinstructors VALUES (24);
INSERT INTO fulltimeinstructors VALUES (25);
INSERT INTO fulltimeinstructors VALUES (26);
INSERT INTO fulltimeinstructors VALUES (27);
INSERT INTO fulltimeinstructors VALUES (28);
INSERT INTO fulltimeinstructors VALUES (29);
INSERT INTO fulltimeinstructors VALUES (30);

INSERT INTO parttimeemployees VALUES (3000.00, 31);
INSERT INTO parttimeemployees VALUES (3000.00, 32);
INSERT INTO parttimeemployees VALUES (3000.00, 33);
INSERT INTO parttimeemployees VALUES (3000.00, 34);
INSERT INTO parttimeemployees VALUES (3000.00, 35);
INSERT INTO parttimeemployees VALUES (3000.00, 36);
INSERT INTO parttimeemployees VALUES (3000.00, 37);
INSERT INTO parttimeemployees VALUES (3000.00, 38);
INSERT INTO parttimeemployees VALUES (3000.00, 39);
INSERT INTO parttimeemployees VALUES (3000.00, 40);

INSERT INTO parttimehoursworked VALUES (3, '2021-06-01', 32);
INSERT INTO parttimehoursworked VALUES (2, '2021-04-01', 32);

INSERT INTO parttimeinstructors VALUES (31);
INSERT INTO parttimeinstructors VALUES (32);
INSERT INTO parttimeinstructors VALUES (33);
INSERT INTO parttimeinstructors VALUES (34);
INSERT INTO parttimeinstructors VALUES (35);
INSERT INTO parttimeinstructors VALUES (36);
INSERT INTO parttimeinstructors VALUES (37);
INSERT INTO parttimeinstructors VALUES (38);
INSERT INTO parttimeinstructors VALUES (39);
INSERT INTO parttimeinstructors VALUES (40);

INSERT INTO specializations VALUES (21, 'Algorithms and Theory');
INSERT INTO specializations VALUES (21, 'Artificial Intelligence');
INSERT INTO specializations VALUES (22, 'Game Design');
INSERT INTO specializations VALUES (22, 'Computer Security');
INSERT INTO specializations VALUES (23, 'Database Systems');
INSERT INTO specializations VALUES (23, 'Computer Networking');
INSERT INTO specializations VALUES (24, 'Parallel Computing');
INSERT INTO specializations VALUES (24, 'Software Engineering');
INSERT INTO specializations VALUES (25, 'Data Analytics');
INSERT INTO specializations VALUES (25, 'Programming Languages');
INSERT INTO specializations VALUES (26, 'Algorithms and Theory');
INSERT INTO specializations VALUES (26, 'Game Design');
INSERT INTO specializations VALUES (27, 'Database Systems');
INSERT INTO specializations VALUES (27, 'Parallel Computing');
INSERT INTO specializations VALUES (28, 'Artificial Intelligence');
INSERT INTO specializations VALUES (28, 'Computer Security');
INSERT INTO specializations VALUES (29, 'Computer Networking');
INSERT INTO specializations VALUES (29, 'Software Engineering');
INSERT INTO specializations VALUES (30, 'Data Analytics');
INSERT INTO specializations VALUES (30, 'Programming Languages');
INSERT INTO specializations VALUES (31, 'Algorithms and Theory');
INSERT INTO specializations VALUES (31, 'Programming Languages');
INSERT INTO specializations VALUES (32, 'Artificial Intelligence');
INSERT INTO specializations VALUES (32, 'Data Analytics');
INSERT INTO specializations VALUES (33, 'Game Design');
INSERT INTO specializations VALUES (33, 'Parallel Computing');
INSERT INTO specializations VALUES (34, 'Computer Security');
INSERT INTO specializations VALUES (34, 'Computer Networking');
INSERT INTO specializations VALUES (35, 'Database Systems');
INSERT INTO specializations VALUES (36, 'Algorithms and Theory');
INSERT INTO specializations VALUES (36, 'Artificial Intelligence');
INSERT INTO specializations VALUES (36, 'Game Design');
INSERT INTO specializations VALUES (36, 'Computer Security');
INSERT INTO specializations VALUES (36, 'Database Systems');
INSERT INTO specializations VALUES (37, 'Computer Networking');
INSERT INTO specializations VALUES (37, 'Parallel Computing');
INSERT INTO specializations VALUES (37, 'Software Engineering');
INSERT INTO specializations VALUES (37, 'Data Analytics');
INSERT INTO specializations VALUES (37, 'Programming Languages');
INSERT INTO specializations VALUES (38, 'Algorithms and Theory');
INSERT INTO specializations VALUES (38, 'Game Design');
INSERT INTO specializations VALUES (38, 'Database Systems');
INSERT INTO specializations VALUES (38, 'Parallel Computing');
INSERT INTO specializations VALUES (38, 'Data Analytics');
INSERT INTO specializations VALUES (39, 'Artificial Intelligence');
INSERT INTO specializations VALUES (39, 'Computer Security');
INSERT INTO specializations VALUES (39, 'Computer Networking');
INSERT INTO specializations VALUES (39, 'Software Engineering');
INSERT INTO specializations VALUES (39, 'Programming Languages');
INSERT INTO specializations VALUES (40, 'Algorithms and Theory');
INSERT INTO specializations VALUES (40, 'Computer Networking');
INSERT INTO specializations VALUES (40, 'Software Engineering');

INSERT INTO courses VALUES (1, 1, 'Algorithms', 'Learn all about algorithms!', 'Algorithms and Theory');
INSERT INTO courses VALUES (2, 2, 'Artificial Intelligence', 'Learn about AI', 'Artificial Intelligence');
INSERT INTO courses VALUES (3, 3, 'Game Design', 'Design the best games', 'Game Design');
INSERT INTO courses VALUES (4, 1, 'Computer Security', 'Secure your computers', 'Computer Security');
INSERT INTO courses VALUES (5, 2, 'Database Systems', 'Learn about databases', 'Database Systems');
INSERT INTO courses VALUES (6, 3, 'Computer Networking', 'Learn about networks', 'Computer Networking');
INSERT INTO courses VALUES (7, 1, 'Parallel Computing', 'Learn about parallelism', 'Parallel Computing');
INSERT INTO courses VALUES (8, 2, 'Software Engineering', 'Learn about software engineering', 'Software Engineering');
INSERT INTO courses VALUES (9, 3, 'Data Analytics', 'Learn about data analytics', 'Data Analytics');
INSERT INTO courses VALUES (10, 1, 'Programming Languages', 'Learn about programming', 'Programming Languages');

alter sequence Courses_course_id_seq restart with 11;

INSERT INTO rooms VALUES (1, '01-01', 20);
INSERT INTO rooms VALUES (2, '01-02', 20);
INSERT INTO rooms VALUES (3, '01-03', 20);
INSERT INTO rooms VALUES (4, '01-04', 20);
INSERT INTO rooms VALUES (5, '01-05', 20);
INSERT INTO rooms VALUES (6, '02-01', 25);
INSERT INTO rooms VALUES (7, '02-02', 25);
INSERT INTO rooms VALUES (8, '02-03', 25);
INSERT INTO rooms VALUES (9, '02-04', 25);
INSERT INTO rooms VALUES (10, '02-05', 25);
INSERT INTO rooms VALUES (11, '03-01', 30);
INSERT INTO rooms VALUES (12, '03-02', 30);
INSERT INTO rooms VALUES (13, '03-03', 30);
INSERT INTO rooms VALUES (14, '03-04', 30);
INSERT INTO rooms VALUES (15, '03-05', 30);
INSERT INTO rooms VALUES (16, '04-01', 35);
INSERT INTO rooms VALUES (17, '04-02', 35);
INSERT INTO rooms VALUES (18, '04-03', 35);
INSERT INTO rooms VALUES (19, '04-04', 35);
INSERT INTO rooms VALUES (20, '04-05', 35);
INSERT INTO rooms VALUES (21, '05-01', 40);
INSERT INTO rooms VALUES (22, '05-02', 40);
INSERT INTO rooms VALUES (23, '05-03', 40);
INSERT INTO rooms VALUES (24, '05-04', 40);
INSERT INTO rooms VALUES (25, '05-05', 40);

alter sequence Rooms_room_id_seq restart with 26;

INSERT INTO courseofferings VALUES (1, '2021-03-23', '2021-06-02', '2021-06-02', '2021-05-23', 10, 100.00, 20, 1, 1);
INSERT INTO courseofferings VALUES (3, '2021-03-23', '2021-06-04', '2021-06-04', '2021-05-23', 12, 100.00, 20, 3, 3);
INSERT INTO courseofferings VALUES (4, '2021-03-23', '2021-06-02', '2021-06-02', '2021-05-23', 13, 100.00, 20, 4, 4);
INSERT INTO courseofferings VALUES (5, '2021-03-23', '2021-06-03', '2021-06-03', '2021-05-23', 14, 100.00, 20, 5, 5);
INSERT INTO courseofferings VALUES (6, '2021-03-23', '2021-06-04', '2021-06-04', '2021-05-23', 15, 100.00, 25, 6, 6);
INSERT INTO courseofferings VALUES (7, '2021-03-23', '2021-06-07', '2021-06-07', '2021-05-23', 16, 100.00, 25, 6, 7);
INSERT INTO courseofferings VALUES (8, '2021-03-23', '2021-06-08', '2021-06-08', '2021-05-23', 17, 100.00, 25, 8, 8);
INSERT INTO courseofferings VALUES (9, '2021-03-23', '2021-06-09', '2021-06-09', '2021-05-23', 18, 100.00, 25, 6, 9);
INSERT INTO courseofferings VALUES (10, '2021-03-23', '2021-06-02', '2021-06-02', '2021-05-23', 19, 100.00, 25, 10, 10);
INSERT INTO courseofferings VALUES (11, '2021-03-08', '2021-05-19', '2021-05-19', '2021-05-08', 10, 100.00, 40, 1, 1);
INSERT INTO courseofferings VALUES (12, '2021-03-09', '2021-05-20', '2021-05-20', '2021-05-09', 10, 100.00, 40, 1, 1);
INSERT INTO courseofferings VALUES (13, '2021-03-10', '2021-05-21', '2021-05-21', '2021-05-10', 10, 100.00, 20, 1, 2);
INSERT INTO courseofferings VALUES (14, '2021-03-13', '2021-05-24', '2021-05-24', '2021-05-13', 10, 100.00, 20, 1, 3);
INSERT INTO courseofferings VALUES (15, '2021-03-14', '2021-05-25', '2021-05-25', '2021-05-14', 10, 100.00, 25, 1, 4);
INSERT INTO courseofferings VALUES (16, '2021-03-15', '2021-05-26', '2021-05-26', '2021-05-15', 10, 100.00, 35, 1, 4);
INSERT INTO courseofferings VALUES (17, '2021-03-16', '2021-05-27', '2021-05-27', '2021-05-16', 10, 100.00, 30, 5, 5);
INSERT INTO courseofferings VALUES (18, '2021-03-20', '2021-05-31', '2021-05-31', '2021-05-20', 10, 100.00, 20, 3, 6);
INSERT INTO courseofferings VALUES (19, '2021-03-20', '2021-05-31', '2021-05-31', '2021-05-20', 10, 100.00, 20, 4, 7);
INSERT INTO courseofferings VALUES (20, '2021-03-21', '2021-06-01', '2021-06-01', '2021-05-21', 10, 100.00, 25, 10, 8);
INSERT INTO courseofferings VALUES (21, '2021-03-22', '2021-06-02', '2021-06-02', '2021-05-22', 10, 100.00, 40, 10, 9);
INSERT INTO courseofferings VALUES (22, '2021-03-24', '2021-06-03', '2021-06-03', '2021-05-23', 10, 100.00, 40, 2, 10);
INSERT INTO courseofferings VALUES (2, '2021-03-23', '2021-06-03', '2021-06-03', '2021-05-23', 11, 100.00, 45, 2, 2);

INSERT INTO sessions VALUES (1, 1, '2021-06-02 11:00:00', '2021-06-02 12:00:00', '2021-06-02', '2021-05-26', 21, 1, 1);
INSERT INTO sessions VALUES (2, 1, '2021-06-03 10:00:00', '2021-06-03 12:00:00', '2021-06-03', '2021-05-27', 21, 2, 2);
INSERT INTO sessions VALUES (3, 1, '2021-06-04 09:00:00', '2021-06-04 12:00:00', '2021-06-04', '2021-05-28', 22, 3, 3);
INSERT INTO sessions VALUES (4, 1, '2021-06-02 17:00:00', '2021-06-02 18:00:00', '2021-06-02', '2021-05-26', 22, 4, 4);
INSERT INTO sessions VALUES (5, 1, '2021-06-03 16:00:00', '2021-06-03 18:00:00', '2021-06-03', '2021-05-27', 23, 5, 5);
INSERT INTO sessions VALUES (6, 1, '2021-06-04 15:00:00', '2021-06-04 18:00:00', '2021-06-04', '2021-05-28', 23, 6, 6);
INSERT INTO sessions VALUES (7, 1, '2021-06-07 17:00:00', '2021-06-07 18:00:00', '2021-06-07', '2021-05-31', 24, 7, 7);
INSERT INTO sessions VALUES (8, 1, '2021-06-08 16:00:00', '2021-06-08 18:00:00', '2021-06-08', '2021-06-01', 24, 8, 8);
INSERT INTO sessions VALUES (9, 1, '2021-06-09 15:00:00', '2021-06-09 18:00:00', '2021-06-09', '2021-06-02', 30, 9, 9);
INSERT INTO sessions VALUES (10, 1, '2021-06-02 17:00:00', '2021-06-02 18:00:00', '2021-06-02', '2021-05-26', 30, 10, 10);
INSERT INTO sessions VALUES (11, 1, '2021-05-19 11:00:00', '2021-05-19 12:00:00', '2021-05-19', '2021-05-12', 21, 11, 21);
INSERT INTO sessions VALUES (12, 1, '2021-05-20 11:00:00', '2021-05-20 12:00:00', '2021-05-20', '2021-05-13', 21, 12, 21);
INSERT INTO sessions VALUES (13, 1, '2021-05-21 09:00:00', '2021-05-21 11:00:00', '2021-05-21', '2021-05-14', 21, 13, 3);
INSERT INTO sessions VALUES (14, 1, '2021-05-24 09:00:00', '2021-05-24 12:00:00', '2021-05-24', '2021-05-17', 22, 14, 3);
INSERT INTO sessions VALUES (15, 1, '2021-05-25 09:00:00', '2021-05-25 10:00:00', '2021-05-25', '2021-05-18', 22, 15, 6);
INSERT INTO sessions VALUES (16, 1, '2021-05-26 14:00:00', '2021-05-26 15:00:00', '2021-05-26', '2021-05-19', 22, 16, 17);
INSERT INTO sessions VALUES (17, 1, '2021-05-27 16:00:00', '2021-05-27 18:00:00', '2021-05-27', '2021-05-20', 23, 17, 14);
INSERT INTO sessions VALUES (18, 1, '2021-05-31 09:00:00', '2021-05-31 12:00:00', '2021-05-31', '2021-05-24', 23, 18, 2);
INSERT INTO sessions VALUES (19, 1, '2021-05-31 14:00:00', '2021-05-31 15:00:00', '2021-05-31', '2021-05-24', 24, 19, 4);
INSERT INTO sessions VALUES (20, 1, '2021-06-01 10:00:00', '2021-06-01 12:00:00', '2021-06-01', '2021-05-25', 24, 20, 6);
INSERT INTO sessions VALUES (21, 1, '2021-06-02 15:00:00', '2021-06-02 18:00:00', '2021-06-02', '2021-05-26', 32, 21, 23);
INSERT INTO sessions VALUES (22, 1, '2021-06-03 15:00:00', '2021-06-03 16:00:00', '2021-06-03', '2021-05-27', 30, 22, 24);
INSERT INTO sessions VALUES (23, 2, '2021-04-12 09:00:00', '2021-04-12 11:00:00', '2021-04-12', '2021-04-05', 32, 2, 6);

alter sequence Sessions_sess_id_seq restart with 24;

INSERT INTO registers VALUES ('2021-04-10', 2, 12, '3487730179254246');
INSERT INTO registers VALUES ('2021-04-10', 4, 14, '6011160715370157');
INSERT INTO registers VALUES ('2021-04-10', 6, 16, '4209949185032728');
INSERT INTO registers VALUES ('2021-04-10', 8, 18, '3674217885515676');
INSERT INTO registers VALUES ('2021-04-10', 10, 20, '4246936242452879');

INSERT INTO redeems VALUES ('2021-04-10', 1, 2, 1);
INSERT INTO redeems VALUES ('2021-04-10', 1, 2, 2);
INSERT INTO redeems VALUES ('2021-04-10', 1, 3, 3);
INSERT INTO redeems VALUES ('2021-04-10', 2, 3, 3);
INSERT INTO redeems VALUES ('2021-04-10', 2, 4, 4);
INSERT INTO redeems VALUES ('2021-04-10', 3, 4, 4);
INSERT INTO redeems VALUES ('2021-04-10', 4, 4, 4);
INSERT INTO redeems VALUES ('2021-04-10', 2, 5, 5);
INSERT INTO redeems VALUES ('2021-04-10', 3, 5, 5);
INSERT INTO redeems VALUES ('2021-04-10', 4, 5, 5);
INSERT INTO redeems VALUES ('2021-04-10', 5, 5, 5);
INSERT INTO redeems VALUES ('2021-04-10', 2, 6, 6);
INSERT INTO redeems VALUES ('2021-04-10', 3, 6, 6);
INSERT INTO redeems VALUES ('2021-04-10', 4, 6, 6);
INSERT INTO redeems VALUES ('2021-04-10', 5, 6, 6);
INSERT INTO redeems VALUES ('2021-04-10', 6, 6, 6);
INSERT INTO redeems VALUES ('2021-04-10', 2, 7, 7);
INSERT INTO redeems VALUES ('2021-04-10', 3, 7, 7);
INSERT INTO redeems VALUES ('2021-04-10', 4, 7, 7);
INSERT INTO redeems VALUES ('2021-04-10', 5, 7, 7);
INSERT INTO redeems VALUES ('2021-04-10', 6, 7, 7);
INSERT INTO redeems VALUES ('2021-04-10', 7, 7, 7);
INSERT INTO redeems VALUES ('2021-04-10', 2, 8, 8);
INSERT INTO redeems VALUES ('2021-04-10', 3, 8, 8);
INSERT INTO redeems VALUES ('2021-04-10', 4, 8, 8);
INSERT INTO redeems VALUES ('2021-04-10', 5, 8, 8);
INSERT INTO redeems VALUES ('2021-04-10', 6, 8, 8);
INSERT INTO redeems VALUES ('2021-04-10', 7, 8, 8);
INSERT INTO redeems VALUES ('2021-04-10', 8, 8, 8);
INSERT INTO redeems VALUES ('2021-04-10', 2, 9, 9);
INSERT INTO redeems VALUES ('2021-04-10', 3, 9, 9);
INSERT INTO redeems VALUES ('2021-04-10', 4, 9, 9);
INSERT INTO redeems VALUES ('2021-04-10', 5, 9, 9);
INSERT INTO redeems VALUES ('2021-04-10', 6, 9, 9);
INSERT INTO redeems VALUES ('2021-04-10', 7, 9, 9);
INSERT INTO redeems VALUES ('2021-04-10', 8, 9, 9);
INSERT INTO redeems VALUES ('2021-04-10', 9, 9, 9);
INSERT INTO redeems VALUES ('2021-04-10', 2, 10, 10);
INSERT INTO redeems VALUES ('2021-04-10', 3, 10, 10);
INSERT INTO redeems VALUES ('2021-04-10', 4, 10, 10);
INSERT INTO redeems VALUES ('2021-04-10', 5, 10, 10);
INSERT INTO redeems VALUES ('2021-04-10', 6, 10, 10);
INSERT INTO redeems VALUES ('2021-04-10', 7, 10, 10);
INSERT INTO redeems VALUES ('2021-04-10', 8, 10, 10);
INSERT INTO redeems VALUES ('2021-04-10', 9, 10, 10);
INSERT INTO redeems VALUES ('2021-04-10', 10, 10, 10);

INSERT INTO cancels VALUES ('2021-04-10', 0.00, 1, 2, 2);
INSERT INTO cancels VALUES ('2021-04-10', 0.00, 1, 3, 3);
INSERT INTO cancels VALUES ('2021-04-10', 0.00, 1, 4, 1);
INSERT INTO cancels VALUES ('2021-04-10', 0.00, 1, 5, 1);
INSERT INTO cancels VALUES ('2021-04-10', 0.00, 1, 6, 1);
INSERT INTO cancels VALUES ('2021-04-10', 0.00, 1, 7, 1);
INSERT INTO cancels VALUES ('2021-04-10', 0.00, 1, 8, 1);
INSERT INTO cancels VALUES ('2021-04-10', 0.00, 1, 9, 1);
INSERT INTO cancels VALUES ('2021-04-10', 0.00, 1, 10, 1);
INSERT INTO cancels VALUES ('2021-04-10', 90.00, 0, 1, 11);
INSERT INTO cancels VALUES ('2021-04-10', 90.00, 0, 3, 13);
INSERT INTO cancels VALUES ('2021-04-10', 90.00, 0, 5, 15);
INSERT INTO cancels VALUES ('2021-04-10', 90.00, 0, 7, 17);
INSERT INTO cancels VALUES ('2021-04-10', 90.00, 0, 9, 19);

INSERT INTO fulltimesalary VALUES (3000.00, '2021-04-30', 30, 1);
INSERT INTO fulltimesalary VALUES (3000.00, '2021-04-30', 30, 2);
INSERT INTO fulltimesalary VALUES (3000.00, '2021-04-30', 30, 3);
INSERT INTO fulltimesalary VALUES (3000.00, '2021-04-30', 30, 4);
INSERT INTO fulltimesalary VALUES (3000.00, '2021-04-30', 30, 5);
INSERT INTO fulltimesalary VALUES (3000.00, '2021-04-30', 30, 6);
INSERT INTO fulltimesalary VALUES (3000.00, '2021-04-30', 30, 7);
INSERT INTO fulltimesalary VALUES (3000.00, '2021-04-30', 30, 8);
INSERT INTO fulltimesalary VALUES (3000.00, '2021-04-30', 30, 9);
INSERT INTO fulltimesalary VALUES (3000.00, '2021-04-30', 30, 10);
INSERT INTO fulltimesalary VALUES (4000.00, '2021-04-30', 30, 11);
INSERT INTO fulltimesalary VALUES (4000.00, '2021-04-30', 30, 12);
INSERT INTO fulltimesalary VALUES (4000.00, '2021-04-30', 30, 13);
INSERT INTO fulltimesalary VALUES (4000.00, '2021-04-30', 30, 14);
INSERT INTO fulltimesalary VALUES (4000.00, '2021-04-30', 30, 15);
INSERT INTO fulltimesalary VALUES (4000.00, '2021-04-30', 30, 16);
INSERT INTO fulltimesalary VALUES (4000.00, '2021-04-30', 30, 17);
INSERT INTO fulltimesalary VALUES (4000.00, '2021-04-30', 30, 18);
INSERT INTO fulltimesalary VALUES (4000.00, '2021-04-30', 30, 19);
INSERT INTO fulltimesalary VALUES (4000.00, '2021-04-30', 30, 20);
INSERT INTO fulltimesalary VALUES (5000.00, '2021-04-30', 30, 21);
INSERT INTO fulltimesalary VALUES (5000.00, '2021-04-30', 30, 22);
INSERT INTO fulltimesalary VALUES (5000.00, '2021-04-30', 30, 23);
INSERT INTO fulltimesalary VALUES (5000.00, '2021-04-30', 30, 24);
INSERT INTO fulltimesalary VALUES (5000.00, '2021-04-30', 30, 26);
INSERT INTO fulltimesalary VALUES (5000.00, '2021-04-30', 30, 27);

INSERT INTO parttimesalary VALUES (0.00, '2021-04-30', 0, 31);
INSERT INTO parttimesalary VALUES (6000.00, '2021-04-30', 2, 32);
INSERT INTO parttimesalary VALUES (0.00, '2021-04-30', 0, 33);
INSERT INTO parttimesalary VALUES (0.00, '2021-04-30', 0, 34);
INSERT INTO parttimesalary VALUES (0.00, '2021-04-30', 0, 35);
INSERT INTO parttimesalary VALUES (0.00, '2021-04-30', 0, 36);
INSERT INTO parttimesalary VALUES (0.00, '2021-04-30', 0, 37);
INSERT INTO parttimesalary VALUES (0.00, '2021-04-30', 0, 38);
INSERT INTO parttimesalary VALUES (0.00, '2021-04-30', 0, 39);

-- OUTDATED, LATEST IN APPROVED_PROC


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGERS AND THEIR FUNCTIONS (put as a pair!)
-- Get instructor's work hours for that month
CREATE OR REPLACE FUNCTION get_monthly_hours (
    IN eid INTEGER, IN mth DOUBLE PRECISION, IN yr DOUBLE PRECISION, 
    OUT work_hours DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION AS $$
	WITH InstructorWorkRecords AS (
        SELECT DATE_PART('year', sess_date) AS year, DATE_PART('month', sess_date) AS month, instructor_id, SUM(extract (epoch from end_time - start_time)/3600) AS total_hours
        FROM Sessions
        GROUP BY instructor_id, DATE_PART('year', sess_date), DATE_PART('month', sess_date)
        ORDER BY month ASC
    )
    SELECT COALESCE(MAX(total_hours), 0)
    FROM InstructorWorkRecords
    WHERE instructor_id = eid
    AND month = mth
    AND year = yr;
$$ LANGUAGE sql;

-- Get employee's employment status
CREATE OR REPLACE FUNCTION get_emp_status (
    IN eid INTEGER, OUT status TEXT)
RETURNS TEXT AS $$
	WITH FT_EID AS (
		SELECT emp_id AS fteid
		FROM FullTimeEmployees
	), PT_EID AS (
        SELECT emp_id AS pteid
		FROM PartTimeEmployees
    )
    SELECT 
        CASE 
            WHEN (eid IN (SELECT fteid FROM FT_EID)) THEN 'Full Time'
            WHEN (eid IN (SELECT pteid FROM PT_EID)) THEN 'Part Time'
            ELSE NULL
        END AS status;
$$ LANGUAGE sql;

-- Get each session's hours (including breaks before and after the session)
CREATE OR REPLACE FUNCTION get_session_hours(
    IN session_id INTEGER, 
    OUT session_hours INTEGER[]
)
RETURNS INTEGER[] AS $$
SELECT ARRAY(
    SELECT * FROM generate_series(DATE_PART('hour', start_time)::INTEGER - 1, DATE_PART('hour', end_time)::INTEGER))
FROM Sessions
WHERE sess_id = session_id
$$ LANGUAGE sql;
-- Get each instructor's busy hours in a day
CREATE OR REPLACE FUNCTION get_total_session_hours(IN eid INTEGER, IN session_date DATE)
RETURNS TABLE(session_hours INTEGER[]) AS $$
SELECT array_agg(all_sessions_combined)
FROM (
  SELECT unnest(get_session_hours(sess_id))
  FROM Sessions
	WHERE instructor_id = eid
	AND sess_date = session_date
) AS dt(all_sessions_combined);
$$ LANGUAGE sql;

-- Get each session's hours
CREATE OR REPLACE FUNCTION get_session_hours_2(
    IN session_id INTEGER, 
    OUT session_hours INTEGER[]
)
RETURNS INTEGER[] AS $$
SELECT ARRAY(
    SELECT * FROM generate_series(DATE_PART('hour', start_time)::INTEGER, DATE_PART('hour', end_time)::INTEGER - 1))
FROM Sessions
WHERE sess_id = session_id
$$ LANGUAGE sql;

-- Get each instructor's avail hours in a day
CREATE OR REPLACE FUNCTION get_avail_hours(
    IN eid INTEGER, IN day DATE,
    OUT avail_hours INTEGER[]
)
RETURNS INTEGER[] AS $$
WITH avail_hours(array1, array2) AS (
    VALUES (array[9,10,11,14,15,16,17], 
        (SELECT array_agg(combined) 
        FROM (
            SELECT unnest(session_hours) 
            FROM get_total_session_hours(eid, day)
            ) as dt(combined)
        )
    )
)
SELECT CASE
	WHEN (array_agg(hour ORDER BY hour ASC) IS NULL AND (SELECT * FROM get_total_session_hours(eid, day)) IS NULL) THEN array[9,10,11,14,15,16,17]
	ELSE array_agg(hour ORDER BY hour ASC)
END
FROM avail_hours, unnest(array1) hour
WHERE hour <> all(array2)
$$ LANGUAGE sql;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F6, F7, F15, F16, F21, F22
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F6
-- CREATE OR REPLACE FUNCTION find_instructors (IN cid INTEGER, IN session_date DATE, IN session_hour INTEGER)
-- RETURNS TABLE (eid INTEGER, e_name TEXT) AS $$
--     SELECT emp_id, emp_name
--     FROM Employees
--     NATURAL JOIN Specializations
--     INNER JOIN Courses
--     ON Specializations.course_area = Courses.course_area
--     WHERE Courses.course_id = cid
--     AND (depart_date IS NULL OR (depart_date IS NOT NULL AND depart_date >= session_date))
--     AND session_hour = ANY(get_avail_hours(emp_id, session_date))
--     AND (
--         (get_emp_status(emp_id) = 'Part Time' AND get_monthly_hours(emp_id, DATE_PART('month', session_date), DATE_PART('year', session_date)) <= 29) 
--         OR get_emp_status(emp_id) = 'Full Time'
--     )
--     ORDER BY emp_id;
-- $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION find_instructors (IN cid INTEGER, IN session_date DATE, IN session_hour INTEGER)
RETURNS TABLE (eid INTEGER, e_name TEXT) AS $$
    SELECT emp_id, emp_name
    FROM Employees
    NATURAL JOIN Specializations
    INNER JOIN Courses
    ON Specializations.course_area = Courses.course_area
    WHERE Courses.course_id = cid
    AND (depart_date IS NULL OR (depart_date IS NOT NULL AND depart_date >= session_date))
    AND (ARRAY(SELECT generate_series(session_hour, session_hour + duration - 1))) <@ get_avail_hours(emp_id, session_date)
    AND (
        (get_emp_status(emp_id) = 'Part Time' AND get_monthly_hours(emp_id, DATE_PART('month', session_date), DATE_PART('year', session_date)) <= 29) 
        OR get_emp_status(emp_id) = 'Full Time'
    )
    AND extract(dow from session_date) in (1, 2, 3, 4, 5)
    ORDER BY emp_id;
$$ LANGUAGE sql;

-- F7
-- CREATE OR REPLACE FUNCTION get_available_instructors (
-- IN cid INTEGER, IN s_date DATE, IN e_date DATE)
-- RETURNS TABLE(emp_id INTEGER, emp_name TEXT, current_monthly_hours DOUBLE PRECISION, day DATE, avail_hours INTEGER[]) AS $$
-- SELECT DISTINCT emp_id, emp_name, get_monthly_hours(emp_id, DATE_PART('month', CURRENT_DATE), DATE_PART('year', CURRENT_DATE)), sess_date, get_avail_hours(emp_id, sess_date)
-- FROM Employees
-- NATURAL JOIN Specializations
-- INNER JOIN Courses
-- ON Specializations.course_area = Courses.course_area
-- INNER JOIN CourseOfferings
-- ON Courses.course_id = CourseOfferings.course_id
-- INNER JOIN Sessions
-- ON CourseOfferings.offering_id = Sessions.offering_id
-- WHERE Courses.course_id = cid
-- AND sess_date BETWEEN s_date AND e_date
-- AND (
--         (get_emp_status(emp_id) = 'Part Time' AND get_monthly_hours(emp_id, DATE_PART('month', sess_date), DATE_PART('year', sess_date)) <= 29) 
--         OR get_emp_status(emp_id) = 'Full Time'
-- );
-- $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_available_instructors (
IN cid INTEGER, IN s_date DATE, IN e_date DATE)
RETURNS TABLE(emp_id INTEGER, emp_name TEXT, current_monthly_hours DOUBLE PRECISION, day DATE, avail_hours INTEGER[]) AS $$
WITH AllSessionDates AS (
    SELECT date_trunc('day', dd):: DATE AS day
    FROM generate_series(s_date::TIMESTAMP , e_date::TIMESTAMP , '1 day'::interval) dd
    WHERE extract(dow from date_trunc('day', dd):: DATE) in (1, 2, 3, 4, 5)
)
SELECT DISTINCT Specializations.emp_id, emp_name, get_monthly_hours(Specializations.emp_id, DATE_PART('month', CURRENT_DATE), DATE_PART('year', CURRENT_DATE)), day, get_avail_hours(Specializations.emp_id, day)
FROM Employees
CROSS JOIN AllSessionDates
NATURAL JOIN Specializations
INNER JOIN Courses
ON Specializations.course_area = Courses.course_area
INNER JOIN CourseOfferings
ON Courses.course_id = CourseOfferings.course_id
WHERE Courses.course_id = cid
AND day BETWEEN s_date AND e_date
AND (
        (get_emp_status(Specializations.emp_id) = 'Part Time' AND get_monthly_hours(Specializations.emp_id, DATE_PART('month', day), DATE_PART('year', day)) + duration <= 30) 
        OR get_emp_status(Specializations.emp_id) = 'Full Time'
)
ORDER BY (emp_id, day) ASC;
$$ LANGUAGE sql;

-- F15
CREATE OR REPLACE FUNCTION get_available_course_offerings ()
RETURNS TABLE(c_title TEXT, c_area TEXT, s_date DATE, e_date DATE, r_deadline DATE, c_fee NUMERIC(10,2), num_remaining INTEGER) AS $$
    WITH RegistrationCount AS (
        SELECT CourseOfferings.offering_id, COUNT(Sessions.sess_id)  AS count
		FROM SessionParticipants
		NATURAL JOIN Sessions
		NATURAL RIGHT JOIN CourseOfferings
		GROUP BY CourseOfferings.offering_id
    )
    SELECT title, course_area, start_date, end_date, registration_deadline, fees, (CourseOfferings.seating_capacity - count) AS remaining
    FROM CourseOfferings
    INNER JOIN Courses
    ON CourseOfferings.course_id = Courses.course_id
	NATURAL JOIN RegistrationCount
    WHERE CURRENT_DATE <= registration_deadline
    AND remaining > 0
    ORDER BY (registration_deadline, title) ASC;
$$ LANGUAGE sql;

-- F16
CREATE OR REPLACE FUNCTION get_available_course_sessions (IN oid INTEGER)
RETURNS TABLE(session_date DATE, session_hour INTEGER, inst_name TEXT, seat_remaining INTEGER) AS $$
    WITH RegistrationCount AS (
        SELECT sess_id, (seating_capacity - COUNT(sess_id)) AS remaining
		FROM SessionParticipants
        NATURAL JOIN Sessions
        INNER JOIN Rooms
        ON Sessions.room_id = Rooms.room_id
		GROUP BY sess_id, seating_capacity
    ), SessionsWithZeroRegistration AS (
        SELECT sess_id, seating_capacity AS remaining 
        FROM Sessions INNER JOIN Rooms
        ON Sessions.room_id = Rooms.room_id
        EXCEPT
        SELECT sess_id, seating_capacity AS remaining 
        FROM SessionParticipants 
        NATURAL JOIN Sessions 
        INNER JOIN Rooms
        ON Sessions.room_id = Rooms.room_id
    ), TotalCount AS (
        SELECT * FROM RegistrationCount
        UNION
        SELECT * FROM SessionsWithZeroRegistration
    )
    SELECT sess_date, DATE_PART('hour', start_time), emp_name, remaining
    FROM Sessions
    INNER JOIN CourseOfferings
    ON Sessions.offering_id = CourseOfferings.offering_id
    INNER JOIN Employees
    ON Sessions.instructor_id = Employees.emp_id
    NATURAL LEFT JOIN TotalCount
    WHERE CURRENT_DATE <= registration_deadline
    AND remaining > 0
    AND CourseOfferings.offering_id = oid
    ORDER BY (sess_date, DATE_PART('hour', start_time)) ASC;
$$ LANGUAGE sql;

-- F21

CREATE OR REPLACE PROCEDURE update_instructor (oid INTEGER, s_num INTEGER, eid INTEGER) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sessions WHERE offering_id = oid) THEN
        RAISE EXCEPTION 'The offering does not exist';
    ELSIF NOT EXISTS (SELECT 1 FROM Sessions WHERE offering_id = oid AND sess_num = s_num) THEN
        RAISE EXCEPTION 'The session does not exist';
    ELSIF NOT EXISTS (SELECT 1 FROM Instructors WHERE emp_id = eid) THEN
        RAISE EXCEPTION 'The instructor does not exist';
    END IF;

    UPDATE Sessions
    SET instructor_id = eid
    WHERE offering_id = oid 
    AND sess_num = s_num;

END;
$$ LANGUAGE plpgsql;
-- F22
-- CREATE OR REPLACE PROCEDURE update_room (
--     oid INTEGER, s_num INTEGER, rid INTEGER
-- )
-- AS $$
--     WITH RegistrationCount AS (
--         SELECT sess_id AS session_id, COUNT(sess_id) AS count
-- 		FROM SessionParticipants
-- 		GROUP BY sess_id
-- 		ORDER BY sess_id
--     )
--     UPDATE Sessions
--     SET room_id = rid
--     From CourseOfferings
--     WHERE Sessions.offering_id = oid
--     AND sess_num = s_num
--     AND sess_date > CURRENT_DATE
--     AND ((SELECT count FROM RegistrationCount WHERE session_id = sess_id) <= (SELECT seating_capacity FROM Rooms WHERE room_id = rid));

CREATE OR REPLACE PROCEDURE update_room (oid INTEGER, s_num INTEGER, rid INTEGER) AS $$
DECLARE
    _sess_id INTEGER;
    _sess_date DATE;
    _sess_start_time TIMESTAMP;
    _sess_hours INTEGER[];

    _register_count INTEGER;
    _room_avail_hours INTEGER[];
BEGIN

    IF NOT EXISTS (SELECT 1 FROM Sessions WHERE offering_id = oid) THEN
        RAISE EXCEPTION 'The offering does not exist';
    ELSIF NOT EXISTS (SELECT 1 FROM Sessions WHERE offering_id = oid AND sess_num = s_num) THEN
        RAISE EXCEPTION 'The session does not exist';
    ELSIF NOT EXISTS (SELECT 1 FROM ROOMS WHERE ROOM_ID = rid) THEN
        RAISE EXCEPTION 'The room does not exist';
    END IF;

    SELECT sess_id INTO _sess_id FROM Sessions WHERE offering_id = oid and sess_num = s_num;
    SELECT sess_date INTO _sess_date FROM Sessions WHERE sess_id = _sess_id;
    SELECT start_time INTO _sess_start_time FROM Sessions WHERE sess_id = _sess_id;

    select _hours INTO _room_avail_hours FROM get_available_rooms(_sess_date, _sess_date) WHERE _room_id = rid;
    select session_hours INTO _sess_hours FROM get_session_hours_2(_sess_id);

    WITH RegistrationCount AS (
        SELECT sess_id, COUNT(sess_id) AS count
		FROM SessionParticipants
        NATURAL JOIN Sessions
        GROUP BY sess_id
    ), SessionsWithZeroRegistration AS (
        SELECT sess_id, 0 AS count
        FROM Sessions
        EXCEPT
        SELECT sess_id, 0 AS count 
        FROM SessionParticipants 
    ), TotalCount AS (
        SELECT * FROM RegistrationCount
        UNION
        SELECT * FROM SessionsWithZeroRegistration
    )
    SELECT count INTO _register_count FROM TotalCount WHERE sess_id = _sess_id;

    IF (_sess_hours <@ _room_avail_hours) THEN
        UPDATE Sessions
        SET room_id = rid
        WHERE Sessions.offering_id = oid
        AND sess_num = s_num;
    ELSE 
		RAISE EXCEPTION 'The room is unavailable';
    END IF;

END;
$$ LANGUAGE plpgsql;
