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
    if ((select SPS.sess_id
        from (SessionParticipants natural join Sessions) SPS
        where SPS.cust_id = New.cust_id
        and SPS.offering_id = oid
        limit 1) is not null) then
        raise exception 'Customer has already registered for one of the sessions in the course.';
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
    seat_limit := (select R.seating_capacity
        from Sessions S, Rooms R
        where S.sess_id = New.sess_id
        and S.room_id = R.room_id);
    seats_taken := (select count(*)
        from (SessionParticipants natural join Sessions)SPS
        where SPS.sess_id = New.sess_id);
    if (seats_taken < seat_limit) then
        return new;
    else
        raise exception 'This Session is full, please try another Session.';
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER register_exceeded_session_trigger
BEFORE INSERT ON Registers
FOR EACH ROW EXECUTE FUNCTION seating_capacity_limit();

CREATE TRIGGER redeem_exceeded_session_trigger
BEFORE INSERT ON Redeems
FOR EACH ROW EXECUTE FUNCTION seating_capacity_limit();

-- Enforce only 1 active/partially package per buyer TRIGGER
-- 'Each customer can have at most one active
-- or partially active package'
CREATE OR REPLACE FUNCTION active_package_limit() RETURNS TRIGGER AS $$
declare
BEGIN
    if (TG_OP = 'INSERT') then
        if ((select B.package_id
            from Buys B
            where B.cust_id = New.cust_id
            and B.redemptions_left > 0
            limit 1) is not null) then -- active
            return exception 'Customer can only have one active package.';
        elsif ((select B.package_id
                  from Buys B, Redeems R, Sessions S
                  where B.cust_id = New.cust_id
                    and B.package_id = R.package_id
                    and R.sess_id = S.sess_id
                    and S.latest_cancel_date >= CURRENT_DATE
                    limit 1) is not null) then -- partially active
            return exception 'Customer can only have one partially active package.';
        else
            return new;
        end if;
    elsif (TG_OP = 'UPDATE' and NEW.package_id <> OLD.package_id) then
        if ((select B.package_id
            from Buys B
            where B.cust_id = New.cust_id
            and B.package_id <> New.package_id
            and B.redemptions_left > 0
            limit 1) is not null) then -- another existing active
            return exception 'Customer can only have one active package.';
        elsif ((select B.package_id
                  from Buys B, Redeems R, Sessions S
                  where B.cust_id = New.cust_id
                    and B.package_id = R.package_id
                    and R.package_id <> New.package_id
                    and R.sess_id = S.sess_id
                    and S.latest_cancel_date >= CURRENT_DATE
                    limit 1) is not null) then -- another partially active
            return exception 'Customer can only have one partially active package.';
        else
            return new;
        end if;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER buy_excessive_active_package_trigger
BEFORE INSERT OR UPDATE ON Buys
FOR EACH ROW EXECUTE FUNCTION active_package_limit();

-- Trigger for when inserting Redemptions into Redeems -> need ensure it corr to redemptions left in Buys
-- Redeem(redeem_date, sess_id, package_id, cust_id)

CREATE OR REPLACE FUNCTION redeem_sess() RETURNS TRIGGER AS $$
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
        raise exception 'There is no more redemptions left in the package, redemption of new session failed.';
    end if;

end;
$$ LANGUAGE plpgsql;

-- Trigger on Updating CreditCard
-- Check expiry day is not before current date
CREATE TRIGGER redeem_session_trigger
BEFORE INSERT ON Redeems
FOR EACH ROW EXECUTE FUNCTION redeem_sess();

CREATE OR REPLACE FUNCTION update_cc() RETURNS TRIGGER AS $$
BEGIN
    if (New.expiry_date <= current_date) then
        raise exception 'Credit Card has expired, please update with a valid card.';
    else return New;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_cc_trigger
BEFORE UPDATE ON CreditCards
FOR EACH ROW EXECUTE FUNCTION update_cc();