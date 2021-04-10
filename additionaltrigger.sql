-- Check that credit card not expired when purchasing course package

CREATE OR REPLACE FUNCTION check_cc_expiry() RETURNS TRIGGER AS $$
declare
    expiry date;
BEGIN
    expiry := (select CC.expiry_date
        from CreditCards CC
        where CC.cc_number = New.cc_number
        and CC.cust_id = New.cust_id);

    if (expiry <= current_date) then
        raise exception 'Credit Card has expired, please update CreditCard before buying a Course Package.';
    else
        return New;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_cc_trigger
BEFORE INSERT ON Buys
FOR EACH ROW EXECUTE FUNCTION check_cc_expiry();
