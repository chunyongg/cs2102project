
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

--F14 DONE
-- active -> at least one used session
-- partially active -> all redeemed but at least one redeemed session that could be refunded if cancelled
CREATE OR REPLACE VIEW SessionsInOrder as
    select sess_id, sess_date, start_time
    from Sessions
    order by (sess_date, start_time) asc;

CREATE OR REPLACE FUNCTION get_at_least_partially_active_packages(IN c_id integer)
RETURNS TABLE (package_id integer)
AS $$
declare
    curs cursor for (select * from Buys B where B.cust_id = c_id);
    r record;
    s record;
begin
    open curs;
    loop
        fetch curs into r;
        exit when not found;
        if (r.redemptions_left >= 1) then -- partially active
            package_id := r.package_id;
            return next;
        else
            -- there exist a session where registered session is at least 7 days from today
            -- => partially active
            for s in (select RB.sess_id
                      from (Redeems natural join Buys) RB
                      where RB.package_id = r.package_id
                        and RB.latest_cancel_date >= CURRENT_DATE)
                loop
                    package_id := s.package_id;
                    return next;
                end loop;
        end if;
    end loop;
    close curs;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_my_course_package_table(IN c_id integer)
RETURNS TABLE (package_name text, price numeric, num_free_registrations integer,
redemptions_left integer, buy_date date, title text,
sess_date date, start_time timestamp)
AS $$
declare
    p record;
    s record;
    _course_id integer;
begin
    for p in select * from get_at_least_partially_active_packages(c_id)
    loop
        select CP.package_name, CP.price, CP.num_free_registrations
        into package_name, price, num_free_registrations
        from CoursePackages CP
        where CP.package_id = p.package_id;

        select B.redemptions_left, B.buy_date
        into redemptions_left, buy_date
        from Buys B
        where B.package_id = p.package_id and B.cust_id = c_id;

        for s in select sess_id
            from Redeems R
            where R.package_id = p.package_id
        loop
            _course_id := (select SCO.course_id
            from (Sessions natural join CourseOfferings)SCO
            where SCO.sess_id = s
                .sess_id);
            title := (select C.title from Courses C where C.course_id = _course_id);
            select SIO.sess_date, SIO.start_time
            into sess_date, start_time
            from SessionsInOrder SIO
            where SIO.sess_id = s.sess_id;
            return next;
        end loop;
    end loop;
end;
$$ LANGUAGE plpgsql;

create or replace function get_my_course_package(IN c_id integer)
returns json as $$
declare
    r record;
begin
    if ((select B.cust_id from Buys B where B.cust_id = c_id) is null) then
        raise notice 'Customer details did not buy any Course Package, unable to retrieve Course Package.';
    else
        for r in (select * from get_my_course_package_table(c_id))
        loop
            return row_to_json(r);
        end loop;
    end if;
end;
$$ language plpgsql;

-- Trigger for when inserting Redemptions into Redeems -> need ensure it corr to redemptions left in Buys
-- Redeem(redeem_date, sess_id, package_id, cust_id)
CREATE OR REPLACE FUNCTION redeem_sess_warning() RETURNS TRIGGER AS $$
declare
    r_left integer;
begin
    r_left := (select B.redemptions_left
        from Buys B
        where B.cust_id = New.cust_id
        and B.package_id = New.package_id);
    if ((select count(*) from Redeems R where R.cust_id = New.cust_id
        and R.package_id = New.package_id) < r_left) then
        return New;
    else
        raise notice 'There is no more redemptions left in the package, redemption of new session failed.';
    end if;

end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_cc_trigger
BEFORE INSERT ON Redeems
FOR EACH ROW EXECUTE FUNCTION redeem_sess_warning();

-------------------------------------------------------------

CREATE OR REPLACE VIEW SessionParticipants AS
    select cust_id, sess_id, null as package_id
    from Registers
    union
    select cust_id, sess_id, package_id
    from Redeems;

-- Self created function for F19 & F20
-- check if registered for any session for that offering, return the session_id else null
create or replace function checkRegisterSession(IN cid integer, IN oid integer)
returns integer as $$
    select SR.sess_id
    from (Sessions natural join Registers) SR -- by sess_id
    where SR.offering_id = oid
    and SR.cust_id = cid;
$$ language sql;

-- Self created function for F19 & F20 // NEED ADJUST
-- check if redeem any session for that offering, return the session_id else null
create or replace function checkRedeemSession(IN cid integer, IN oid integer)
returns integer as $$
    select SR.sess_id
    from (Sessions natural join Redeems) SR -- by sess_id
    where SR.offering_id = oid
    and SR.cust_id = cid;
$$ language sql;

--F19 NEED REFINEMENT
CREATE OR REPLACE PROCEDURE update_course_session(IN cid integer, IN oid integer, IN sid integer)
AS $$
declare
    rid integer;
    seat_capacity integer;
    num_registered integer;
begin
    rid := (select S.room_id from Sessions S where S.sess_id = sid and S.offering_id = oid);
    seat_capacity := (select R.seating_capacity from Rooms R where R.room_id = rid);
    num_registered := (select count(*) from Registers R where R.sess_id = sid);
    if (num_registered < seat_capacity) then
        if (checkRegisterSession(cid, oid) is not null) then
            UPDATE Registers
            SET sess_id = sid
            WHERE cust_id = cid;
        else
            UPDATE Redeems
            SET sess_id = sid
            WHERE cust_id = cid;
        end if;
    else
        raise notice 'Session is full, update of session failed, please try another one.';
    end if;
end;
$$ LANGUAGE plpgsql;

--F20 NEED REFINEMENT
CREATE OR REPLACE PROCEDURE cancel_registration(IN cid integer, IN oid integer)
AS $$
declare
    _sess_id integer;
    cancel_date date;
    _sess_date date;
    price numeric;
    refund_amt numeric;
    package_credit integer;
begin
    cancel_date := current_date;
    if (checkRegisterSession(cid, oid) is not null) then
        _sess_id := checkRegisterSession(cid, oid);
        package_credit := 0;
        price := (select CO.fees from CourseOfferings CO where CO.offering_id = oid);
        _sess_date := (select S.sess_date from Sessions S where S.sess_id = _sess_id and S.offering_id = oid);
        if ((select date_part('day',_sess_date-cancel_date)) >=7) then
            refund_amt := price * 9/10;
        end if;
        DELETE from Registers
        WHERE cust_id = cid
        and sess_id = _sess_id;
    end if;

    if (checkRedeemSession(cid, oid) is not null) then
        _sess_id := checkRedeemSession(cid, oid);
        refund_amt := 0;
        package_credit := 1;
        DELETE from Redeems
        WHERE cust_id = cid
        and sess_id = _sess_id;
    end if;

    INSERT INTO Cancels
        VALUES (cancel_date, refund_amt, package_credit, cid, sid);
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