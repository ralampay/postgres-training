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
  maintaining_balance NUMERIC NOT NULL DEFAULT 500.0,
  CONSTRAINT fk_customer_id
    FOREIGN KEY (customer_id)
      REFERENCES customers(id)
);

DROP TABLE IF EXISTS account_transactions CASCADE;
CREATE TABLE IF NOT EXISTS account_transactions (
  id SERIAL PRIMARY KEY,
  amount NUMERIC NOT NULL,
  transaction_type VARCHAR(1) NOT NULL,
  account_id INT NOT NULL,
  CONSTRAINT fk_account_id
    FOREIGN KEY (account_id)
      REFERENCES accounts(id)
);

ALTER TABLE account_transactions
  ADD CONSTRAINT check_transaction_type
  CHECK (transaction_type IN ('W', 'D'));

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
SELECT deposit(1, 1500.0);

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
  _maintaining_balance NUMERIC;
BEGIN
  SELECT balance, maintaining_balance INTO current_balance, _maintaining_balance FROM accounts WHERE accounts.id = _id;

  new_balance := current_balance - _amount;

  -- set result to FALSE if new_balance < 0
  IF new_balance < _maintaining_balance THEN
    result := FALSE;
    RAISE NOTICE 'Account % has insufficient balance % for withdrawal of amount % below %', _id, current_balance, _amount, _maintaining_balance;
  ELSE
    UPDATE accounts SET balance = new_balance WHERE accounts.id = _id;
  END IF;

  RETURN result;
END;$$;


DROP PROCEDURE IF EXISTS p_withdraw;
CREATE OR REPLACE PROCEDURE p_withdraw(
  _id INT,
  _amount NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
  current_balance NUMERIC;
  new_balance NUMERIC;
  result BOOLEAN;
BEGIN
  SELECT withdraw(_id, _amount) INTO result;

  IF result THEN
    INSERT INTO account_transactions (account_id, amount, transaction_type) VALUES (_id, _amount, 'W');
  END IF;
END;$$;

-- withdraw 100
CALL p_withdraw(1, 100.0);
SELECT * FROM accounts;
