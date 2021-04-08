----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS (place functions that you think can help everyone here!)
CREATE OR REPLACE FUNCTION get_manager_areas(IN emp_id integer)
RETURNS TABLE(course_area text) -- total course areas
AS $$
    select course_area
    from CourseAreas CA
    where CA.manager_id = emp_id;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_at_least_partially_active_package(IN c_id integer)
RETURNS integer AS $$
declare
    pid integer;
begin
    pid := (select B.package_id
        from Buys B
        where B.cust_id = c_id
        and B.redemptions_left >= 1);
    if (pid is not null) then -- active
        return pid;
    else
        -- there exist a session where registered session is at least 7 days from today
        -- => partially active
        pid := (select B.package_id
                from Buys B natural join Redeems R natural join Sessions S
                where B.cust_id = c_id
                and B.package_id = R.package_id
                and R.sess_id = S.sess_id
                and S.latest_cancel_date >= CURRENT_DATE);
        if (pid is not null) then
            return pid;
        else
            return null;
        end if;
    end if;
end;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGERS AND THEIR FUNCTIONS (put as a pair!)
-- A customer can only register for at most one sessions for each course offering
CREATE OR REPLACE FUNCTION course_session_limit() RETURNS TRIGGER AS $$
declare
    oid integer;
BEGIN
    oid := (select S.offering_id from Sessions S where S.sess_id = New.sess_id);
    if (exists (select SPS.sess_id
        from (SessionParticipants natural join Sessions) SPS
        where SPS.cust_id = New.cust_id
        and SPS.offering_id = oid)) then
        raise exception 'Customer is trying to register for more than one session
            from the same course offering. Process aborted.';
    else
        return new;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER register_session_limit_trigger
BEFORE INSERT ON Registers
FOR EACH ROW EXECUTE FUNCTION course_session_limit();

CREATE TRIGGER redeem_session_limit_trigger
BEFORE INSERT ON Redeems
FOR EACH ROW EXECUTE FUNCTION course_session_limit();

-- Check Seating Capacity Trigger
-- Only can join/change course offering if there is still seat available for new course offering
CREATE OR REPLACE FUNCTION seating_capacity_limit() RETURNS TRIGGER AS $$
declare
    seats_taken integer;
    seat_limit integer;
BEGIN
    if (TG_OP = 'INSERT' or (TG_OP = 'UPDATE' and old.sess_id <> new.sess_id)) then
        seat_limit := (select R.seating_capacity
            from Sessions S natural join Rooms R
            where S.sess_id = New.sess_id);
        seats_taken := (select count(*)
            from SessionParticipants SP
            where SP.sess_id = New.sess_id);
        if (seats_taken < seat_limit) then
            return new;
        else
            raise exception 'This Session is full, please try another Session.';
        end if;
    else
        return new;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER register_exceeded_session_trigger
BEFORE INSERT OR UPDATE ON Registers
FOR EACH ROW EXECUTE FUNCTION seating_capacity_limit();

CREATE TRIGGER redeem_exceeded_session_trigger
BEFORE INSERT OR UPDATE ON Redeems
FOR EACH ROW EXECUTE FUNCTION seating_capacity_limit();

-- Enforce only 1 active/partially package per buyer TRIGGER
-- 'Each customer can have at most one active
-- or partially active package'
CREATE OR REPLACE FUNCTION active_package_limit() RETURNS TRIGGER AS $$
declare
BEGIN
    if (TG_OP = 'INSERT') then
        if (exists (select B.package_id
            from Buys B
            where B.cust_id = New.cust_id
            and B.redemptions_left > 0)) then -- active
            raise exception 'Customer can only have one active package.';
        elsif (exists (select B.package_id
                from Buys B natural join Redeems R natural join Sessions S
                where B.cust_id = New.cust_id
                and S.latest_cancel_date >= CURRENT_DATE)) then -- partially active
            raise exception 'Customer can only have one partially active package.';
        else
            return new;
        end if;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER buy_excessive_active_package_trigger
BEFORE INSERT ON Buys
FOR EACH ROW EXECUTE FUNCTION active_package_limit();

-- Trigger for when inserting Redemptions into Redeems -> need ensure it corr to redemptions left in Buys
-- Redeem(redeem_date, sess_id, package_id, cust_id)

CREATE OR REPLACE FUNCTION redeem_sess() RETURNS TRIGGER AS $$
declare
    r_left integer;
begin
    select redemptions_left into r_left
        from Buys
        where cust_id = New.cust_id
        and package_id = New.package_id;
    if (r_left = 0) then
        raise exception 'There is no more redemptions left in the package, redemption of new session failed.';
    else
        return new;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER redeem_session_trigger
BEFORE INSERT ON Redeems
FOR EACH ROW EXECUTE FUNCTION redeem_sess();

-- Trigger on Updating CreditCard
-- Check expiry day is not before current date

CREATE OR REPLACE FUNCTION update_cc() RETURNS TRIGGER AS $$
BEGIN
    if (New.expiry_date <= current_date) then
        raise exception 'Credit Card has expired, please update with a valid card.';
    else
        return New;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_cc_trigger
BEFORE INSERT or UPDATE ON CreditCards
FOR EACH ROW EXECUTE FUNCTION update_cc();

-- Check that current date within sale range before buying course package

CREATE OR REPLACE FUNCTION check_sale_period()
RETURNS TRIGGER AS $$
declare
    _sale_start date;
    _sale_end date;
begin
    select CP.sale_start_date, CP.sale_end_date
        into _sale_start, _sale_end
        from CoursePackages CP
        where CP.package_id = New.package_id;
        if (CURRENT_DATE not between _sale_start and _sale_end) then
            raise exception 'Course Package not available for Sale.';
        end if;
        return New;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER buy_package_trigger
BEFORE INSERT ON Buys
FOR EACH ROW EXECUTE FUNCTION check_sale_period();

-- Do not allow change in session if session started
CREATE OR REPLACE FUNCTION check_session_period()
RETURNS TRIGGER AS $$
declare
    _curr_sess_start date;
    _new_sess_start date;
begin
    select S.start_time
    into _curr_sess_start
    from Sessions S
    where S.sess_id = old.sess_id;
    select S.start_time
    into _new_sess_start
    from Sessions S
    where S.sess_id = new.sess_id;
    if (_curr_sess_start <= LOCALTIMESTAMP or _new_sess_start <= LOCALTIMESTAMP) THEN
	    RAISE EXCEPTION 'Session already started';
    end if;
    return New;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER change_reg_session_trigger
BEFORE UPDATE ON Registers
FOR EACH ROW EXECUTE FUNCTION check_session_period();

CREATE TRIGGER change_redeem_session_trigger
BEFORE UPDATE ON Redeems
FOR EACH ROW EXECUTE FUNCTION check_session_period();
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHUN YONG'S FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RUI EN's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XINYEE's FUNCTIONS
--F3
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
    if (exists (select cust_id from Customers C where C.cust_id = c_cust_id)) then
        UPDATE CreditCards
        SET cc_number = c_cc_number, cvv = c_cc_cvv, expiry_date = c_cc_expiry_date
        WHERE cust_id = c_cust_id;
    else
        raise exception 'Customer does not exist in the system, updating of Credit Card failed.';
    end if;
end;
$$ LANGUAGE plpgsql;

--F13 DONE
CREATE OR REPLACE PROCEDURE buy_course_package(IN c_id integer, IN pkg_id integer)
AS $$
declare
    buy_date date;
    redemptions_left integer;
    cc_number varchar(16);
begin
    if (not exists (select cust_id from Customers C where C.cust_id = c_id)) then
        raise exception 'Customer does not exist in the system, purchase failed.';
    elsif ((select package_id from CoursePackages CP where CP.package_id = pkg_id) is null) then
        raise exception 'Package does not exist in the system, purchase failed.';
    else
        buy_date := (select CURRENT_DATE);
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

CREATE OR REPLACE FUNCTION get_my_course_package_table(IN c_id integer)
RETURNS TABLE (package_name text, buy_date date, price numeric(10,2), num_free_registrations integer,
redemptions_left integer, title text,
sess_date date, start_time double precision)
AS $$
declare
    pid integer;
    s record;
    _course_id integer;
begin
    pid := get_at_least_partially_active_package(c_id);

    select CP.package_name, CP.price, CP.num_free_registrations
    into package_name, price, num_free_registrations
    from CoursePackages CP
    where CP.package_id = pid;

    select B.redemptions_left, B.buy_date
    into redemptions_left, buy_date
    from Buys B
    where B.package_id = pid and B.cust_id = c_id;

    for s in select sess_id
        from Redeems natural join SessionsInOrder
        where package_id = pid
        and cust_id = c_id

    loop
        _course_id := (select SCO.course_id
        from (Sessions natural join CourseOfferings)SCO
        where SCO.sess_id = s.sess_id);
        title := (select C.title from Courses C where C.course_id = _course_id);
        select SIO.sess_date, date_part('hour', SIO.start_time)
        into sess_date, start_time
        from SessionsInOrder SIO
        where SIO.sess_id = s.sess_id;
        return next;
    end loop;
end;
$$ LANGUAGE plpgsql;

create or replace function get_my_course_package(IN c_id integer)
returns json[] as $$
declare
    r record;
    result json[]; --
begin
    result := null;
    if (not exists (select C.cust_id from Customers C where C.cust_id = c_id)) then
        raise exception 'Customer does not exist in the system, please check again.';
    end if;
    if (not exists (select B.cust_id from Buys B where B.cust_id = c_id)) then
        raise exception 'Customer did not buy any Course Package, unable to retrieve Course Package.';
    else
        for r in (select * from get_my_course_package_table(c_id))
        loop
            result := array_append(result, row_to_json(r));
        end loop;
        if (result is null) then
            raise exception 'Customer has no active/inactive Course Package.';
        else
            return result;
        end if;
    end if;
end;
$$ language plpgsql

CREATE OR REPLACE VIEW SessionParticipants AS
    select cust_id, sess_id, null as package_id
    from Registers
    union
    select cust_id, sess_id, package_id
    from Redeems;

-- Self created function for F19 & F20
-- check if registered for any session for that offering, return boolean
create or replace function checkRegisterSession(IN cid integer, IN sid integer)
returns boolean as $$
begin
    return exists (select R.sess_id
    from Registers R
    where R.sess_id = sid
    and R.cust_id = cid);
end;
$$ language plpgsql;

-- Self created function for F19 & F20
-- check if redeem any session for that offering, return boolean
create or replace function checkRedeemSession(IN cid integer, IN sid integer)
returns boolean as $$
begin
    return exists (select R.sess_id
    from Redeems R
    where R.sess_id = sid
    and R.cust_id = cid);
end;
$$ language plpgsql;

--F19 DONE
CREATE OR REPLACE PROCEDURE update_course_session(IN cid integer, IN oid integer, IN _sess_num integer)
AS $$
declare
    rid integer;
    old_sid integer;
    new_sid integer;
begin
    SELECT sess_id
        INTO old_sid
        FROM SessionParticipants NATURAL JOIN Sessions
        WHERE cust_id = cid
        AND offering_id = oid;

    SELECT sess_id
        INTO new_sid
        FROM Sessions
        WHERE offering_id = oid
        AND sess_num = _sess_num;

    IF (not exists (select C.cust_id from Customers C where C.cust_id = cid)) then
        raise exception 'Customer does not exist in the system, purchase failed.';
    ELSIF (new_sid is null) then
        raise exception 'Session does not exist.';
    ELSIF (not exists(select SP.cust_id from SessionParticipants SP where SP.cust_id = cid)) then
        raise exception 'Customer did not register for any sessions, updating of session failed.';
    ELSIF (not exists (select SPS.sess_id FROM (SessionParticipants natural join Sessions)SPS
        where SPS.cust_id = cid AND SPS.offering_id = oid)) THEN
            raise exception 'Customer is not registered in a session of the input course offering.';
    ELSIF exists(select SPS.sess_id
        from (SessionParticipants natural join Sessions)SPS
        where SPS.cust_id = cid
        and SPS.offering_id = oid
        and SPS.sess_num = _sess_num) then
        raise exception 'Customer is already enrolled in the course session.';
    ELSE
        if (checkRegisterSession(cid, old_sid) is true) then
            UPDATE Registers
            SET sess_id = new_sid
            WHERE cust_id = cid;
        elseif (checkRedeemSession(cid, old_sid) is true) then
            UPDATE Redeems
            SET sess_id = new_sid
            WHERE cust_id = cid;
        end if;
    end if;
end;
$$ LANGUAGE plpgsql;

--F20 DONE
CREATE OR REPLACE PROCEDURE cancel_registration(IN cid integer, IN oid integer)
AS $$
declare
    _sess_id integer;
    cancel_date date;
    _sess_date date;
    _latest_date date;
    pid integer;
    price numeric(10,2);
    refund_amt numeric(10,2);
    package_credit integer;
begin
    cancel_date := current_date;
    _sess_id := (select SPS.sess_id
            from (SessionParticipants natural join Sessions)SPS
            where SPS.offering_id = oid
            and SPS.cust_id = cid);

    IF not exists (select C.cust_id from Customers C where C.cust_id = cid) then
        raise exception 'Customer does not exist in the system, purchase failed.';
    ELSIF not exists(select CO.offering_id from CourseOfferings CO where CO.offering_id = oid) then
        raise exception 'Offering does not exist in the system, please check again.';
    ELSIF not exists(select SP.cust_id from SessionParticipants SP where SP.cust_id = cid) then
        raise exception 'Customer did not register for any sessions, cancellation process failed.';
    ELSIF (_sess_id) is null then
        raise exception 'Customer did not register for any sessions in the offering, please check again.';
    ELSIF ((select S.start_time from Sessions S where S.sess_id = _sess_id) <= localtimestamp) then
        raise exception 'Session has started, cancellation of registration is not allowed.';
    ELSE
        if (checkRegisterSession(cid, _sess_id)) then
            package_credit := 0;
            price := (select CO.fees from CourseOfferings CO where CO.offering_id = oid);
            _sess_date := (select S.sess_date
                from Sessions S
                where S.sess_id = _sess_id
                and S.offering_id = oid);
            _latest_date := (select S.latest_cancel_date
                from Sessions S
                where S.sess_id = _sess_id
                and S.offering_id = oid);
            if (select (cancel_date <= _latest_date)) then
                refund_amt := price * 9/10;
            else
                refund_amt := 0;
            end if;
            DELETE from Registers
            WHERE cust_id = cid
            and sess_id = _sess_id;
            INSERT INTO Cancels
            VALUES (cancel_date, refund_amt, package_credit, cid, _sess_id);
        elsif (checkRedeemSession(cid, _sess_id)) then
            refund_amt := 0;
            _latest_date := (select S.latest_cancel_date
                from Sessions S
                where S.sess_id = _sess_id
                and S.offering_id = oid);
            pid := (select SP.package_id
                from SessionParticipants SP
                where SP.cust_id = cid
                and SP.sess_id = _sess_id);
                DELETE from Redeems
                WHERE cust_id = cid
                and sess_id = _sess_id;
            if (select (cancel_date <= _latest_date)) then
                package_credit := 1;
                UPDATE Buys
                SET redemptions_left =  redemptions_left + 1
                WHERE cust_id = cid
                and package_id = pid;
            else
                package_credit := 0;
            end if;
            INSERT INTO Cancels
                VALUES (cancel_date, refund_amt, package_credit, cid, _sess_id);
        end if;
    end if;
end;
$$ LANGUAGE plpgsql;

-- F30 DONE
-- View sales generated by each manager
-- return table: manager name, manager total area count,
-- manager total course offering that ended that year,
-- manager total net registration fee for the course offerings,
-- course offering with highest total net registration fees (list more if draw).
-- total net reg fee = total reg by cc payments + total redemption reg fee
-- reg redemption fee = package fee/no. of sessions
-- must be one output for each manager
-- output sorted by asc order

-- Time range: only for current year
CREATE OR REPLACE FUNCTION get_total_course_offerings_of_area(IN _course_area text)
RETURNS TABLE(course_id integer, course_title text, offering_id integer)
AS $$
declare
    area_curs cursor for (select C.course_id from Courses C where C.course_area = _course_area);
    r record;
    o record;
begin
    open area_curs;
    loop
        fetch area_curs into r;
        exit when not found;
        course_id := r.course_id;
        course_title := (select C.title from Courses C where C.course_id = r.course_id);
        for o in (select CO.offering_id
                from CourseOfferings CO
                where CO.course_id = r.course_id
                and date_part('year', CO.end_date) = date_part('year', current_date))
        loop
            offering_id := o.offering_id;
            return next;
        end loop;
    end loop;
    close area_curs;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_total_course_offerings_for_area_under_manager(IN emp_id integer)
RETURNS integer AS $$
declare
    a text;
    course_offering_count integer;
    total_course_offering integer;
begin
    total_course_offering := 0;
    for a in (select * from get_manager_areas(emp_id)) -- manager take care of everything under the area
        loop
            course_offering_count := (select count(*) from get_total_course_offerings_of_area(a));
            total_course_offering := total_course_offering + course_offering_count;
        end loop;
    return total_course_offering;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_total_net_reg_fee_for_course_offering(IN _offering_id integer)
RETURNS numeric(10,2)
AS $$
declare
    register_fee integer;
    reg_count integer;
    total_net_reg_fee numeric(10,2);
    package_redemptions integer;
    package_price numeric(10,2);
    sess_price numeric(10,2);
    acc_redeem_fee numeric(10,2);
    s integer;
    c integer;
begin
    total_net_reg_fee := 0;
    acc_redeem_fee := 0;
    sess_price := 0;
    register_fee := (select CO.fees from CourseOfferings CO where CO.offering_id = _offering_id);
    for s in (select distinct SPS.sess_id
        from (SessionParticipants natural join Sessions)SPS
        where SPS.offering_id = _offering_id)
    loop
        reg_count := (select count(*) from Registers R where R.sess_id = s);
        total_net_reg_fee := total_net_reg_fee + (register_fee * reg_count);
        for c in (select R.package_id from Redeems R where R.sess_id = s)
        loop
            select CP.num_free_registrations, CP.price
            into package_redemptions, package_price
            from CoursePackages CP
            where CP.package_id = c;
            sess_price := floor(package_price/package_redemptions);
            acc_redeem_fee := acc_redeem_fee + sess_price;
        end loop;
        total_net_reg_fee := total_net_reg_fee + acc_redeem_fee;
    end loop;
    return total_net_reg_fee;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_all_areas_offerings_net_fee(IN emp_id integer)
RETURNS TABLE(course_area text, course_title text, offering_id integer, total_net_reg_fee numeric(10,2))
AS $$
declare
    _course_area text;
    r_curs cursor for (select TCOA.course_title, TCOA.offering_id
    from get_total_course_offerings_of_area(_course_area) as TCOA);
    r record;
    a record;
begin
    for a in (select * from get_manager_areas(emp_id))
    loop
        _course_area := a.course_area;
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

-- Try infuse in rank for to get same top ranking for highest net reg fee
CREATE OR REPLACE FUNCTION view_manager_report()
RETURNS TABLE(emp_name text,
total_course_area integer,
total_course_offering integer,
total_net_reg_fees numeric(10,2),
highest_net_reg_fee_course_offering text[])
AS $$
declare
    curs cursor for (select * from ManagerDetails);
    r record;
begin
    open curs;
    loop
        fetch curs into r;
        exit when not found;
        emp_name := r.emp_name;
        total_course_area := (select count(*) from get_manager_areas(r.emp_id));
        total_course_offering := get_total_course_offerings_for_area_under_manager(r.emp_id);
        total_net_reg_fees := (select sum(total_net_reg_fee) from get_all_areas_offerings_net_fee(r.emp_id));
        if (total_net_reg_fees is null) then
            total_net_reg_fees := 0.00;
        end if;
        With TopCourseOffering as (
            select *
            from get_all_areas_offerings_net_fee(r.emp_id)T
            order by T.total_net_reg_fee desc)
        select array(
            select TCO.course_title
            from TopCourseOffering TCO
            where TCO.total_net_reg_fee = (select max(total_net_reg_fee) from TopCourseOffering)
            and TCO.total_net_reg_fee <> 0)
        into highest_net_reg_fee_course_offering;
        return next;
    end loop;
    close curs;
end;
$$ LANGUAGE plpgsql;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MICH's FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

