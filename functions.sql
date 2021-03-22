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
CREATE OR REPLACE PROCEDURE update_credit_card(IN cust_id integer, IN cc_number integer, IN cvv integer, IN
    expiry_date
date)
AS $$
    UPDATE CreditCards
    SET cc_number = cc_number, cvv = cvv, expiry_date = expiry_date
    WHERE cust_id = cust_id;
$$ LANGUAGE SQL;

--F13


--F14

