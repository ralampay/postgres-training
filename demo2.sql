DROP TABLE IF EXISTS products;

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
SELECT * FROM information_schema.tables;
