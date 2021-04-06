--TRIGGERS
-- Register Session Trigger
-- If the customer has already registered for the course,
-- the customer cannot register again
-- 'For each course offered by the company,
-- a customer can register for at most one of
-- its sessions'
-- use CourseOfferings, Sessions, SessionParticipants
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
-- 'A course offering is said to be available
-- if the number of registrations received is no
-- more than its seating capacity; otherwise, we say
-- that a course offering is fully booked'
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

--

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

--
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

--
