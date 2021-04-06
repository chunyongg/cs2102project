-------------------------------------------------------------

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
-- session id not changing for second example
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

    IF (new_sid is null) then
        raise exception 'Session does not exist.';
    ELSIF (not exists (select C.cust_id from Customers C where C.cust_id = cid)) then
        raise exception 'Customer does not exist in the system, purchase failed.';
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
    if not exists(select SP.cust_id from SessionParticipants SP where SP.cust_id = cid) then
        raise exception 'Customer did not register for any sessions, cancellation process failed.';
    elsif not exists(select CO.offering_id from CourseOfferings CO where CO.offering_id = oid) then
        raise exception 'Offering does not exist in the system, please check again.';
    else
        _sess_id := (select SPS.sess_id
            from (SessionParticipants natural join Sessions)SPS
            where SPS.offering_id = oid
            and SPS.cust_id = cid);
        if (_sess_id) is null then
            raise exception 'Customer did not register for any sessions in the offering, please check again.';
        elsif ((select S.start_time from Sessions S where S.sess_id = _sess_id) <= localtimestamp) then
            raise exception 'Session has started, cancellation of registration is not allowed.';
        else
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
    end if;
end;
$$ LANGUAGE plpgsql;

