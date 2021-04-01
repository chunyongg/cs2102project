--F3
CREATE OR REPLACE PROCEDURE add_customer(IN cust_name text, IN address text,
IN phone integer, IN email text,  IN cc_number integer, IN cvv integer, IN expiry_date date)
AS $$
declare
    cust_id integer;
begin
    INSERT INTO Customers
    VALUES (default, address, phone, cust_name, email);

    cust_id := (select cust_id from Customers order by cust_id limit 1);

    INSERT INTO CreditCards
    VALUES (cc_number, cvv, expiry_date, cust_id);
end;
$$ LANGUAGE plpgsql;

--F4
CREATE OR REPLACE PROCEDURE update_credit_card(IN cust_id integer,
IN cc_number integer, IN cvv integer, IN expiry_date date)
AS $$
Begin
    UPDATE CreditCards CC
    SET CC.cc_number = cc_number, CC.cvv = cvv, CC.expiry_date = expiry_date
    WHERE CC.cust_id = cust_id;
end;
$$ LANGUAGE plpgsql;

--F13
CREATE OR REPLACE PROCEDURE buy_course_package(IN cust_id integer, IN package_id integer)
AS $$
declare
    buy_date date;
    redemptions_left integer;
    cc_number integer;
begin
    if ((select cust_id from Customers C where C.cust_id = cust_id) is not null) then
        buy_date := (select now());
        redemptions_left := (select num_free_registrations from CoursePackages CP where CP.package_id = package_id);
        cc_number := (select cc_number from CreditCards CC where CC.cust_id = cust_id);
        INSERT INTO Buys
        VALUES (buy_date, redemptions_left, package_id, cust_id, cc_number);
    else
        raise notice 'Customer details has not been added to system, purchase failed.';
    end if;
end;
$$ LANGUAGE plpgsql;

--F14
CREATE VIEW SessionsInOrder as
    select sess_id, sess_date, start_time
    from Sessions
    order by (sess_date, start_time) asc;

CREATE OR REPLACE FUNCTION get_my_course_package(IN cust_id integer)
RETURNS TABLE (package_name text, price numeric, num_free_registrations integer,
redemptions_left integer, buy_date date, title text,
sess_date date, start_time timestamp)
AS $$
declare
    package_id integer;
    p record;
    s record;
    package_name text;
    sess_id integer;
    course_id integer;
    price numeric;
    num_free_reg integer;
    redemptions_left integer;
    buy_date date;
    title text;
    sess_date date;
    start_time timestamp;
begin
    for p in Select package_id
            from Buys B
            where B.cust_id = cust_id
            and B.redemptions_left <=1
    loop
        package_id := p.package_id;
        package_name := (select package_name from CoursePackages CP where CP.package_id = package_id);
        price := (select price from CoursePackages CP where CP.package_id = package_id);
        num_free_reg := (select num_free_registrations from CoursePackages CP where CP.package_id = package_id);
        redemptions_left := (select redemptions_left from Buys B where B.package_id = package_id);
        buy_date := (select buy_date from Buys B where B.package_id = package_id);
        for s in select sess_id
                from Redeems R
                where R.package_id = package_id
        loop
            sess_id := s.sess_id;
            course_id := (select course_id from Sessions S where S.sess_id = sess_id);
            title := (select title from Courses C where C.title = title);
            sess_date := (select sess_date from SessionsInOrder SIO where SIO.sess_id = sess_id);
            start_time := (select start_time from SessionsInOrder SIO where SIO.start_time = start_time);
            return row_to_json(row(package_name, price, num_free_reg,
                    redemptions_left, buy_date, title,
                    sess_date, start_time));
        end loop;
    end loop;
end;
$$ LANGUAGE plpgsql;

-- Self created function for F19 & F20
-- check if registered for any session for that offering, return the session_id else null
create or replace function checkRegisterSession(IN cust_id integer, IN offering_id integer)
returns integer as $$
    select SR.sess_id
    from (Sessions natural join Registers) SR -- by sess_id
    where SR.offering_id = offering_id;
$$ language sql;

-- Self created function for F19 & F20
-- check if redeem any session for that offering, return the session_id else null
create or replace function checkRedeemSession(IN cust_id integer, IN offering_id integer)
returns integer as $$
    select SR.sess_id
    from (Sessions natural join Redeems) SR -- by sess_id
    where SR.offering_id = offering_id;
$$ language sql;

--F19
CREATE OR REPLACE PROCEDURE update_course_session(IN cust_id integer, IN offering_id integer, IN sess_id integer)
AS $$
declare
    room_id integer;
    seating_capacity integer;
    num_registered integer;
begin
    room_id := (select room_id from Sessions S where S.sess_id = sess_id and S.offering_id = offering_id);
    seating_capacity := (select seating_cpacity from Rooms R where R.room_id = room_id);
    num_registered := (select count(*) from Registers R where R.sess_id = sess_id);
    if (num_registered < seating_capacity) then
        if (checkRegisterSession(cust_id, offering_id) is not null) then
            UPDATE Registers R
            SET R.sess_id = sess_id
            WHERE R.cust_id = cust_id;
        else
            UPDATE Redeems R
            SET R.sess_id = sess_id
            WHERE R.cust_id = cust_id;
        end if;
    else
        raise notice 'Session is full, update of session failed, please try another one.';
    end if;
end;
$$ LANGUAGE plpgsql;

--F20
CREATE OR REPLACE PROCEDURE cancel_registration(IN cust_id integer, IN offering_id integer)
AS $$
declare
    sess_id integer;
    cancel_date date;
    sess_date date;
    price numeric;
    refund_amt numeric;
    package_credit integer;
begin
    cancel_date := current_date;

    if (checkRegisterSession(cust_id, offering_id) is not null) then
        sess_id := checkRegisterSession(cust_id, offering_id);
        package_credit := 0;
        price := (select fees from CourseOfferings CO where CO.offering_id = offering_id);
        sess_date := (select sess_date from Sessions S where S.sess_id = sess_id and S.offering_id = offering_id);
        if ((select date_part('day',sess_date-cancel_date)) >=7) then
            refund_amt := price * 9/10;
        end if;
        DELETE from Registers R
        WHERE R.cust_id = cust_id
        and R.sess_id = sess_id;
    end if;

    if (checkRedeemSession(cust_id, offering_id) is not null) then
        sess_id := checkRedeemSession(cust_id, offering_id);
        refund_amt := 0;
        package_credit := 1;
        DELETE from Redeems R
        WHERE R.cust_id = cust_id
        and R.sess_id = sess_id;
    end if;

    INSERT INTO Cancels
        VALUES (cancel_date, refund_amt, package_credit, cust_id, sess_id);
end;
$$ LANGUAGE plpgsql;

-- F30
-- View sales generated by each manager
-- return table: manager name, manager total area count,
-- manager total course offering that ended that year,
-- manager total net registration fee for the course offerings,
-- course offering with highest total net registration fees (list more if draw).
-- total net reg fee = total reg by cc payments + total redemption reg fee
-- reg redemption fee = package fee/no. of sessions
-- must be one output for each manager
-- output sorted by asc order
CREATE VIEW ManagerDetails as
    select emp_id, emp_name
    from Managers natural left join Employees
    order by emp_name asc;

CREATE OR REPLACE FUNCTION get_manager_areas(IN emp_id integer)
RETURNS TABLE(course_area text) -- total course areas
AS $$
    select course_area
    from CourseAreas CA
    where CA.manager_id = emp_id;
$$ LANGUAGE sql;

-- Time range: only for current year
CREATE OR REPLACE FUNCTION get_total_course_offerings_of_area(IN course_area text)
RETURNS TABLE(course_id integer, course_title text, offering_id integer)
AS $$
declare
    curs cursor for (select course_id from Courses C where C.course_area = course_area);
    r record;
    o record;
begin
    open curs;
    loop
        fetch curs into r;
        exit when not found;
        course_id := r.course_id;
        course_title := (select title from Courses C where C.course_id = course_id);
        for o in (select offering_id
                from CourseOfferings CO
                where CO.course_id = course_id
                and date_part('year', CO.end_date) = date_part('year', current_date))
        loop
            offering_id := o.offering_id;
            return next;
        end loop;
    end loop;
    close curs;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_total_net_reg_fee_for_course_offering(IN offering_id integer)
RETURNS numeric
AS $$
declare
    register_fee integer;
    reg_count integer;
    total_net_reg_fee numeric;
    cust_package integer;
    package_redemptions integer;
    package_price numeric;
    sess_price numeric;
    acc_redeem_fee numeric;
    s record;
    c record;
begin
    total_net_reg_fee := 0;
    acc_redeem_fee := 0;
    register_fee := (select fees from CourseOfferings CO where CO.offering_id = offering_id);
    for s in (select sess_id from Sessions S where S.offering_id = offering_id)
    loop
        reg_count := (select count(*) from Registers R where R.sess_id = s.sess_id);
        total_net_reg_fee := total_net_reg_fee + (register_fee * reg_count);
        for c in (select cust_id from Redeems R where R.sess_id = sess_id)
        loop
            cust_package := (select package_id from Buys B where B.cust_id = cust_id);
            package_redemptions := (select num_free_registrations from CoursePackages CP where CP.package_id = cust_package);
            package_price := (select price from CoursePackages CP where CP.package_id = cust_package);
            sess_price := round(package_price/package_redemptions);
            acc_redeem_fee := acc_redeem_fee + sess_price;
        end loop;
        total_net_reg_fee := total_net_reg_fee + acc_redeem_fee;
    end loop;
    return total_net_reg_fee;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_all_areas_offerings_net_fee(IN emp_id integer)
RETURNS TABLE(course_area text, course_title text, offering_id integer, total_net_reg_fee numeric)
AS $$
declare
    curs cursor for (select course_title, offering_id from get_total_course_offerings_of_area(course_area));
    r record;
    a record;
begin
    for a in (select * from get_manager_areas(emp_id))
    loop
        course_area := a.course_area;
        open curs;
        loop
            fetch curs into r;
            exit when not found;
            course_title := r.course_title;
            offering_id := r.offering_id;
            total_net_reg_fee := get_total_net_reg_fee_for_course_offering(offering_id);
            return next;
        end loop;
        close curs;
    end loop;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION view_manager_report()
RETURNS TABLE(emp_name text,
total_course_area integer,
total_course_offering integer,
total_net_reg_fees numeric,
highest_net_reg_fee_course_offering text[])
AS $$
declare
    curs cursor for (select * from ManagerDetails);
    r record;
    a record;
    course_offering_count integer;
    top_offerings setof record;
begin
    open curs;
    loop
        fetch curs into r;
        exit when not found;
        emp_name := r.emp_name;
        total_course_area := (select count(*) from get_manager_areas(r.emp_id));
        total_course_offering := 0;
        total_net_reg_fees := 0;
        for a in (select * from get_manager_areas(r.emp_id))
        loop
            course_offering_count := (select count(*) from get_total_course_offerings_of_area(a.course_area));
            total_course_offering := total_course_offering + course_offering_count;
        end loop;
        total_net_reg_fees := (select sum(total_net_reg_fee) from get_all_areas_offerings_net_fee(r.emp_id));
        With TopCourseOffering as (
            select *
            from (get_all_areas_offerings_net_fee(r.emp_id)) T
            order by T.total_net_reg_fee desc)
        select TCO.course_name into top_offerings
        from TopCourseOffering TCO
        where TCO.total_net_reg_fee = (select max(total_net_reg_fee) from TopCourseOffering);
        for names in top_offerings
        loop
            highest_net_reg_fee_course_offering := array_append(highest_net_reg_fee_course_offering, names);
        end loop;
        return next;
    end loop;
end;
$$ LANGUAGE plpgsql;