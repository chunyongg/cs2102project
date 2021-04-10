
-- Trigger on Updating CreditCard
-- Check expiry day is not before current date

CREATE OR REPLACE FUNCTION update_cc() RETURNS TRIGGER AS $$
BEGIN
    if (New.expiry_date < current_date) then
        raise exception 'Credit Card has expired, please update with a valid card.';
    else
        return New;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_cc_trigger
BEFORE INSERT or UPDATE ON CreditCards
FOR EACH ROW EXECUTE FUNCTION update_cc();

-- Check that credit card not expired when purchasing course package

CREATE OR REPLACE FUNCTION check_cc_expiry() RETURNS TRIGGER AS $$
declare
    expiry date;
BEGIN
    expiry := (select CC.expiry_date
        from CreditCards CC
        where CC.cc_number = New.cc_number
        and CC.cust_id = New.cust_id);

    if (expiry < current_date) then
        raise exception 'Credit Card has expired, please update CreditCard before buying a Course Package.';
    else
        return New;
    end if;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER buy_check_cc_trigger
BEFORE INSERT OR UPDATE ON Buys
FOR EACH ROW EXECUTE FUNCTION check_cc_expiry();

CREATE TRIGGER reg_check_cc_trigger
BEFORE INSERT OR UPDATE ON Registers
FOR EACH ROW EXECUTE FUNCTION check_cc_expiry();
