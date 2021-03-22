-- to reset serial number
ALTER SEQUENCE <tablename>_<id>_seq RESTART WITH 1
-- e.g. ALTER SEQUENCE employees_emp_id_seq RESTART WITH 1

-- Rooms table
insert into Rooms values
(default, '01-01', 20),
(default, '01-02', 20),
(default, '01-03', 20),
(default, '01-04', 20),
(default, '01-05', 20),
(default, '02-01', 25),
(default, '02-02', 25),
(default, '02-03', 25),
(default, '02-04', 25),
(default, '02-05', 25),
(default, '03-01', 30),
(default, '03-02', 30),
(default, '03-03', 30),
(default, '03-04', 30),
(default, '03-05', 30),
(default, '04-01', 35),
(default, '04-02', 35),
(default, '04-03', 35),
(default, '04-04', 35),
(default, '04-05', 35),
(default, '05-01', 40),
(default, '05-02', 40),
(default, '05-03', 40),
(default, '05-04', 40),
(default, '05-05', 40);

-- Employees table
insert into Employees values
(default, 'Sarah Tan', 'Blk 123 Ang Mo Kio', 90001010, 'sarah.tan@gmail.com', '2020-05-10', '2020-10-10'),
(default, 'Joshua Lau', '14 Marshall Road', 93487131, 'joshua.lau@gmail.com', '2020-06-13', null),
(default, 'Michelle Tan', '11 Bedok Reservoir Road', 93883567, 'michelle.tan@gmail.com', '2020-07-01', null),
(default, 'Angeline Hill', '240 Macpherson Road', 84026810, 'angeline.hill@gmail.com', '2018-06-01', null),
(default, 'Thomas Hackett', '19 Hougang Street', 88726293, 'thomas.hackett@gmail.com', '2019-05-17', null),
(default, 'Lowell Ward', '180B Bencoolen Street', 94517022, 'lowell.ward@gmail.com', '2019-05-15', '2019-08-16'),
(default, 'Aniya Covy', '24 Chapel Rd', 81613371, 'aniya.covy@gmail.com', '2019-05-11', '2019-08-18'),
(default, 'Howard Peter', '150F East Coast Road', 92903217, 'howard.peter@gmail.com', '2019-05-13', '2019-08-13'),
(default, 'Eugenia Haley', '15 Serangoon Road', 91839949, 'eugenia.haley@gmail.com', '2019-05-10', '2019-08-11'),
(default, 'Jennie Kozey', '438 Alexandra Road', 83428645, 'jennie.kozey@gmail.com', '2019-04-18', null),
(default, 'Zander Chong', 'Blk 123 Toa Payoh', 93980294, 'zander.chong@gmail.com', '2018-01-05', null),
(default, 'Katheryn Brenda', 'Blk 129 Bishan Ave 3', 80525852, 'katheryn.brenda@gmail.com', '2020-09-16', null),
(default, 'Devan Boyle', 'Blk 44 Braddell Ave 1', 87336198, 'devan.boyle@gmail.com', '2020-10-25', null),
(default, 'David Sim', '25 Tuas Avenue 13', 98977879, 'david.sim@gmail.com', '2020-10-13', null),
(default, 'Joanna Neo', '391A Orchard Road', 92352568, 'joanna.neo@gmail.com', '2020-09-15', '2020-12-23'),
(default, 'Joey Chua', '414 Yishun Ring Rd', 87531197, 'joey.chua@gmail.com', '2020-08-19', '2020-12-19'),
(default, 'Joe Doe', '91 Defu Lane', 92803670, 'joe.doe@gmail.com', '2017-02-15', '2021-03-22'),
(default, 'Patrick Loh', '315 Outram Road', 83235333, 'patrick.loh@gmail.com', '2020-01-16', '2020-07-01'),
(default, 'Joella Tan', '370H Alexandra Road', 94766173, 'joella.tan@gmail.com', '2020-01-05', '2021-01-13'),
(default, 'Brenda Wong', '22 Kallang Ave', 91733252, 'brenda.wong@gmail.com', '2019-02-01', '2021-02-01'),
(default, 'Chloe Lim', '20 Prince Edward Road', 92265595, 'chloe.lim@gmail.com', '2020-02-13', null),
(default, 'Benjamin Kok', '81 Marine Parade Central', 84470579, 'benjamin.kok@gmail.com', '2020-06-16', '2020-12-20'),
(default, 'Jovin Seah', '53 Ubi Avenue 1', 87488977, 'jovin.seah@gmail.com', '2019-05-13', '2020-06-29'),
(default, 'Joshua Chan', '1 North Bridge Road', 94563049, 'joshua.chan@gmail.com', '2018-08-16', '2020-09-01'),
(default, 'Justin Lim', '35 Kallang Pudding Road', 97416583, 'justin.lim@gmail.com', '2021-01-02', '2021-03-01');