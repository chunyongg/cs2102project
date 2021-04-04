
--F3 DONE
CREATE OR REPLACE PROCEDURE add_customer(IN c_name text, IN c_address text,
IN c_phone integer, IN c_email text,  IN c_cc_number varchar(16),
IN c_cc_cvv integer, IN c_cc_expiry_date date)
AS $$
declare
    cid integer;
begin
    INSERT INTO Customers
    VALUES (default, c_address, c_phone, c_name, c_email)
    RETURNING cust_id into cid;

    INSERT INTO CreditCards
    VALUES (c_cc_number, c_cc_cvv, c_cc_expiry_date, cid);
end;
$$ LANGUAGE plpgsql;
--F4 DONE
CREATE OR REPLACE PROCEDURE update_credit_card(IN c_cust_id integer,
IN c_cc_number varchar(16), IN c_cc_cvv integer, IN c_cc_expiry_date date)
AS $$
Begin
    if ((select cust_id from Customers C where C.cust_id = c_cust_id) is not null) then
        UPDATE CreditCards
        SET cust_id = c_cust_id, cvv = c_cc_cvv, expiry_date = c_cc_expiry_date
        WHERE cc_number = c_cc_number;
    else
        raise notice 'Customer details has not been added to system, updating of Credit Card failed.';
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_cc() RETURNS TRIGGER AS $$
BEGIN
    if (New.expiry_date <= current_date) then
        raise notice 'Credit Card has expired, please update with a valid card.';
        return null;
    else return New;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_cc_trigger
BEFORE UPDATE ON CreditCards
FOR EACH ROW EXECUTE FUNCTION update_cc();

--F13 DONE
CREATE OR REPLACE PROCEDURE buy_course_package(IN c_id integer, IN pkg_id integer)
AS $$
declare
    buy_date date;
    redemptions_left integer;
    cc_number varchar(16);
begin
    if ((select cust_id from Customers C where C.cust_id = c_id) is null) then
        raise notice 'Customer details has not been added to system, purchase failed.';
    elsif ((select package_id from CoursePackages CP where CP.package_id = pkg_id) is null) then
        raise notice 'Package does not exist in the system, purchase failed.';
    else
        buy_date := (select now());
        redemptions_left := (select CP.num_free_registrations from CoursePackages CP where CP.package_id = pkg_id);
        cc_number := (select CC.cc_number from CreditCards CC where CC.cust_id = c_id);
        INSERT INTO Buys
        VALUES (buy_date, redemptions_left, pkg_id, c_id, cc_number);
    end if;
end;
$$ LANGUAGE plpgsql;

--F14 NEED REFINEMENT
CREATE OR REPLACE VIEW SessionsInOrder as
    select sess_id, sess_date, start_time
    from Sessions
    order by (sess_date, start_time) asc;

CREATE OR REPLACE FUNCTION get_my_course_package_table(IN c_id integer)
RETURNS TABLE (package_name text, price numeric, num_free_registrations integer,
redemptions_left integer, buy_date date, title text,
sess_date date, start_time timestamp)
AS $$
declare
    _package_id integer;
    p record;
    s record;
    _package_name text;
    _sess_id integer;
    _course_id integer;
    _price numeric;
    num_free_reg integer;
    _redemptions_left integer;
    _buy_date date;
    _title text;
    _sess_date date;
    _start_time timestamp;
begin
    for p in Select package_id
            from Buys B
            where B.cust_id = c_id
            and B.redemptions_left >= 1
    loop
        _package_id := p.package_id;
        _package_name := (select CP.package_name from CoursePackages CP where CP.package_id = _package_id);
        _price := (select CP.price from CoursePackages CP where CP.package_id = _package_id);
        num_free_reg := (select CP.num_free_registrations from CoursePackages CP where CP.package_id = _package_id);
        _redemptions_left := (select B.redemptions_left from Buys B
            where B.package_id = _package_id and B.cust_id = c_id);
        _buy_date := (select B.buy_date from Buys B
            where B.package_id = _package_id and B.cust_id = c_id);
        for s in select sess_id
                from Redeems R
                where R.package_id = _package_id
        loop
            _sess_id := s.sess_id;
            _course_id := (select S.course_id from Sessions S where S.sess_id = _sess_id);
            _title := (select C.title from Courses C where C.title = title);
            _sess_date := (select SIO.sess_date from SessionsInOrder SIO where SIO.sess_id = _sess_id);
            _start_time := (select SIO.start_time from SessionsInOrder SIO where SIO.start_time = _start_time);
            return next;
        end loop;
    end loop;
end;
$$ LANGUAGE plpgsql;

create or replace function get_my_course_package(IN cust_id integer)
returns json as $$
declare
    table_result json;
begin
    table_result := (select row_to_json(get_my_course_package_table(cust_id)) from get_my_course_package_table(cust_id));
    return table_result;
end;
$$ language plpgsql;

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

CREATE OR REPLACE VIEW SessionParticipants AS
    select cust_id, sess_id, null as package_id
    from Registers
    union
    select cust_id, sess_id, package_id
    from Redeems;

--F19 NEED REFINEMENT
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

--F20 NEED REFINEMENT
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

-- F30 NEED REFINEMENT
-- View sales generated by each manager
-- return table: manager name, manager total area count,
-- manager total course offering that ended that year,
-- manager total net registration fee for the course offerings,
-- course offering with highest total net registration fees (list more if draw).
-- total net reg fee = total reg by cc payments + total redemption reg fee
-- reg redemption fee = package fee/no. of sessions
-- must be one output for each manager
-- output sorted by asc order
CREATE OR REPLACE VIEW ManagerDetails as
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
    area_curs cursor for (select course_id from Courses C where C.course_area = course_area);
    r record;
    o record;
begin
    open area_curs;
    loop
        fetch area_curs into r;
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
    close area_curs;
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
    r_curs cursor for (select course_title, offering_id from get_total_course_offerings_of_area(course_area));
    r record;
    a record;
begin
    for a in (select * from get_manager_areas(emp_id))
    loop
        course_area := a.course_area;
        open r_curs;
        loop
            fetch r_curs into r;
            exit when not found;
            course_title := r.course_title;
            offering_id := r.offering_id;
            total_net_reg_fee := get_total_net_reg_fee_for_course_offering(offering_id);
            return next;
        end loop;
        close r_curs;
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
            from get_all_areas_offerings_net_fee(r.emp_id) as T
            order by T.total_net_reg_fee desc)
        select array(
            select TCO.course_name
            from TopCourseOffering TCO
            where TCO.total_net_reg_fee = (select max(total_net_reg_fee) from TopCourseOffering))
        as highest_net_reg_fee_course_offering;
        return next;
    end loop;
    close curs;
end;
$$ LANGUAGE plpgsql;