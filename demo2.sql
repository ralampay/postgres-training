DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS branches;

CREATE TABLE IF NOT EXISTS products (
	id INT,
	name VARCHAR(50),
	description TEXT
);

/* Add a constraint to column id as PRIMARY KEY */
ALTER TABLE products
  ADD CONSTRAINT pk_products 
    PRIMARY KEY (id);

/* Remove the constraint to change the id column data type*/
ALTER TABLE products
  DROP CONSTRAINT pk_products;

/* Create a Sequence to represent the autoincrement of id in products */
CREATE SEQUENCE products_id_seq
  AS integer START 1 OWNED BY products.id;

/* Attaching the sequence to products.id */
ALTER TABLE products
  ALTER COLUMN id SET DEFAULT nextval('products_id_seq');

/* Add a constraint to column id as PRIMARY KEY */
ALTER TABLE products
  ADD CONSTRAINT pk_products 
    PRIMARY KEY (id);

SELECT sequence_schema, sequence_name FROM information_schema.sequences ORDER BY sequence_name;

CREATE TABLE IF NOT EXISTS branches (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50)
);

/* Copy data from branches.csv into branches table*/
COPY branches(id, name)
  FROM '/home/ralampay/workspace/training/trainocate/postgres-training/branches.csv'
  WITH DELIMITER ',' CSV HEADER;

SELECT * FROM branches;

SELECT sequence_schema, sequence_name 
FROM information_schema.sequences 
ORDER BY sequence_name;

/* Set the sequence of branches to maximum of current branches */
SELECT SETVAL(
  'branches_id_seq',
  (
    SELECT MAX(id) FROM branches
  )
);


INSERT INTO branches (name) VALUES ('Branch X');

SELECT * FROM branches;

/* Dump content of branches to branches_2.csv */
/*
COPY branches
  TO '/home/ralampay/workspace/training/trainocate/postgres-training/branches_2.csv'
  WITH DELIMITER ',' CSV HEADER;
*/
