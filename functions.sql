--F3
CREATE OR REPLACE PROCEDURE add_customer(IN cust_name text, IN address text,
IN phone integer, IN email text,  IN cc_number integer, IN cvv integer, IN expiry_date date)
AS $$
DECLARE
    cust_id integer;
BEGIN
    INSERT INTO Customers
    VALUES (DEFAULT, address, phone, cust_name, email);

    cust_id := (select cust_id from Customers order by cust_id limit 1);

    INSERT INTO CreditCards
    VALUES (cc_number, cvv, expiry_date, cust_id);
END;
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
DECLARE
    buy_date date;
    redemptions_left integer;
    cc_number integer;
BEGIN
    if ((select cust_id from Customers C where C.cust_id = cust_id) is not null) then
        buy_date := (select now());
        redemptions_left := (select num_free_registrations from CoursePackages CP where CP.package_id = package_id);
        cc_number := (select cc_number from CreditCards CC where CC.cust_id = cust_id);
        INSERT INTO Buys
        VALUES (buy_date, redemptions_left, package_id, cust_id, cc_number);
    Else
        raise notice 'Customer details has not been added to system, purchase failed.';
    end if;
END;
$$ LANGUAGE plpgsql;

--F14
CREATE VIEW SessionsInOrder as
    select sess_id, sess_date, start_time
    from Sessions
    order by (sess_date, start_time) asc;

CREATE OR REPLACE FUNCTION get_my_course_package(IN cust_id integer)
RETURNS TABLE (package_name text, price numeric, num_free_registrations integer,
redemptions_left integer, buy_date date, title text,
sess_date date, start_time timestamp) AS $$
DECLARE
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
            return next;
        end loop;
    end loop;
end;
$$ LANGUAGE plpgsql;
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
        UPDATE Registers R
        SET R.sess_id = sess_id
        WHERE R.cust_id = cust_id;
    Else
        raise notice 'Session is full, update of session failed, please try another one.';
    end if;
end;
$$ LANGUAGE plpgsql;

--F20
CREATE OR REPLACE PROCEDURE cancel_registration(IN cust_id integer, IN offering_id integer)
AS $$
declare
    sess_id integer;
    cancel_date Date;
    sess_date Date;
    price numeric;
    refund_amt numeric;
    package_id integer;
    package_credit integer;
begin
    sess_id := (select sess_id from Registers R where R.cust_id = cust_id);
    if (sess_id is not null) then
        sess_date := (select sess_date from Sessions S where S.sess_id = sess_id and S.offering_id = offering_id);
        cancel_date := current_date;
        DELETE from Registers R
        WHERE R.cust_id = cust_id;
        package_id := (select package_id from Redeems R where R.cust_id = cust_id and R.sess_id = sess_id);
        if (package_id is not null) then
            package_credit := 1;
            refund_amt := 0;
        Else
            package_credit := 0;
            price := (select fees from CourseOfferings CO where CO.offering_id = offering_id);
        end if;
        if ((select date_part('day',sess_date-cancel_date)) >=7) then
            refund_amt := price * 9/10;
        end if;
        INSERT INTO Cancels
        values (cancel_date, refund_amt, package_credit, cust_id, sess_id);
    end if;
end;
$$ LANGUAGE plpgsql;
