-- database: banking_system

DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE IF NOT EXISTS customers (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS accounts CASCADE;
CREATE TABLE IF NOT EXISTS accounts (
  id SERIAL PRIMARY KEY,
  balance NUMERIC NOT NULL DEFAULT 0.0,
  customer_id INT NOT NULL,
  CONSTRAINT fk_customer_id
    FOREIGN KEY (customer_id)
      REFERENCES customers(id)
);

INSERT INTO customers (first_name, last_name) VALUES ('Raphael', 'Alampay');
INSERT INTO accounts (customer_id) VALUES (1);

-- SELECT * FROM accounts;

-- Create a function get_total_balance(customer_id) return numeric
DROP FUNCTION IF EXISTS get_total_balance;
CREATE OR REPLACE FUNCTION get_total_balance(
  customer_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
  total_balance NUMERIC := 0.0;
BEGIN
  SELECT SUM(balance) INTO total_balance FROM accounts WHERE customer_id = customer_id;

  RETURN total_balance;
END;$$;

-- Create a function deposit(id, amount) return BOOLEAN
DROP FUNCTION IF EXISTS deposit;
CREATE OR REPLACE FUNCTION deposit(
  _id INT,
  _amount NUMERIC
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  result BOOLEAN := TRUE;
  current_balance NUMERIC;
  new_balance NUMERIC;
BEGIN
  SELECT balance INTO current_balance FROM accounts WHERE accounts.id = _id;

  new_balance := current_balance + _amount;

  UPDATE accounts SET balance = new_balance WHERE accounts.id = _id;

  RETURN result;
END;$$;

-- Deposit 500 to account id 1
SELECT deposit(1, 500.0);

SELECT * FROM accounts;

-- Create a function withdraw(id, amount) return BOOLEAN
DROP FUNCTION IF EXISTS withdraw;
CREATE OR REPLACE FUNCTION withdraw(
  _id INT,
  _amount NUMERIC
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  result BOOLEAN := TRUE;
  current_balance NUMERIC;
  new_balance NUMERIC;
BEGIN
  SELECT balance INTO current_balance FROM accounts WHERE accounts.id = _id;

  new_balance := current_balance - _amount;

  -- set result to FALSE if new_balance < 0
  IF new_balance < 0 THEN
    result := FALSE;
    RAISE NOTICE 'Account % has insufficient balance % for withdrawal of amount %', _id, current_balance, _amount;
  ELSE
    UPDATE accounts SET balance = new_balance WHERE accounts.id = _id;
  END IF;

  RETURN result;
END;$$;

-- withdraw 1000
SELECT withdraw(1, 1100.0);
SELECT * FROM accounts;
