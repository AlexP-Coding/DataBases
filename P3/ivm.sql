drop table if exists ivm cascade;
drop table if exists category cascade;
drop table if exists simple_category cascade;
drop table if exists super_category cascade;
drop table if exists has_other cascade;
drop table if exists product cascade;
drop table if exists has_category cascade;
drop table if exists point_of_retail cascade;
drop table if exists installed_at cascade;
drop table if exists shelf cascade;
drop table if exists planogram cascade;
drop table if exists retailer cascade;
drop table if exists responsible_for cascade;
drop table if exists replenishment_event cascade;
----------------------------------------
-- Table Creation
----------------------------------------

-- Named constraints are global to the database.
-- Therefore the following use the following naming rules:
--   1. pk_table for names of primary key constraints
--   2. fk_table_another for names of foreign key constraints

create table category (
	category_name varchar(255) not null,
	constraint pk_category primary key(category_name)
);

create table simple_category (
	category_name varchar(255) not null,
	constraint pk_simple_category primary key(category_name),
	constraint fk_simple_category_category foreign key(category_name) references category(category_name)
);

create table super_category (
	category_name varchar(255) not null,
	constraint pk_super_category primary key(category_name),
	constraint fk_super_category_category foreign key(category_name) references category(category_name)
);

create table has_other (
	super_category varchar(255) not null,
	child_category varchar(255) not null,
	constraint pk_has_other primary key(child_category),
	constraint fk_has_other_super_category foreign key(super_category) references super_category(category_name),
	constraint fk_has_other_category foreign key(child_category) references category(category_name)
);

CREATE OR REPLACE FUNCTION chk_category_loop()
RETURNS TRIGGER AS
$$
BEGIN 
	IF NEW.super_category = NEW.child_category THEN
		RAISE EXCEPTION 'A category must not contain itself';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chk_category_loop
BEFORE UPDATE OR INSERT ON has_other
FOR EACH ROW EXECUTE PROCEDURE chk_category_loop();

create table product (
	product_ean char(13) not null,
	category_name varchar(255) not null,
	product_descr varchar(255),
	constraint pk_product primary key(product_ean),
	constraint fk_product_category foreign key(category_name) references category(category_name)
);

create table has_category (
	product_ean char(13) not null,
	category_name varchar(255) not null,
	constraint pk_has_category primary key(product_ean, category_name),
	constraint fk_has_category_product foreign key(product_ean) references product(product_ean),
	constraint fk_has_category_category foreign key(category_name) references category(category_name)
);

CREATE OR REPLACE FUNCTION chk_insert_product()
RETURNS TRIGGER AS
$$
BEGIN
	INSERT INTO has_category
	VALUES (NEW.product_ean, NEW.category_name);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chk_insert_product
AFTER INSERT ON product
FOR EACH ROW EXECUTE PROCEDURE chk_insert_product();

CREATE OR REPLACE FUNCTION chk_update_product()
RETURNS TRIGGER AS
$$
BEGIN
	UPDATE has_category
	SET category_name = NEW.category_name
	WHERE product_ean = NEW.product_ean;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chk_update_product
AFTER UPDATE ON product
FOR EACH ROW EXECUTE PROCEDURE chk_update_product();


create table ivm (
	ivm_serial_number numeric(5,0) not null, -- numeric ?
	ivm_manuf varchar(255) not null, -- varchar ?
	constraint pk_ivm primary key(ivm_serial_number, ivm_manuf)
);

create table point_of_retail (
	point_name varchar(255) not null,
	point_district varchar(255) not null,
	point_municipality varchar(255) not null,
	constraint pk_point_of_retail primary key(point_name)
);

create table installed_at (
	ivm_serial_number numeric(5,0) not null,
	ivm_manuf varchar(255) not null,
	point_name varchar(255) not null,
	constraint pk_installed_at primary key(ivm_manuf, ivm_serial_number, point_name),
	constraint fk_installed_at_ivm foreign key(ivm_manuf, ivm_serial_number) references ivm(ivm_manuf, ivm_serial_number),
	constraint fk_installed_at_point_of_retail foreign key(point_name) references point_of_retail(point_name)
);

create table shelf (
	shelf_nr numeric(16,0) not null, --?
	ivm_serial_number numeric(5,0) not null,
	ivm_manuf varchar(255) not null,
	shelf_height numeric(5, 2) not null, -- ?
	category_name varchar(255) not null,
	constraint pk_shelf primary key(shelf_nr, ivm_serial_number, ivm_manuf),
	constraint fk_shelf_ivm foreign key(ivm_serial_number, ivm_manuf) references ivm(ivm_serial_number, ivm_manuf),
	constraint fk_shelf_category foreign key(category_name) references category(category_name)
);

create table planogram (
	product_ean char(13) not null,
	shelf_nr numeric(16,0) not null,
	ivm_serial_number numeric(5,0) not null,
	ivm_manuf varchar(255) not null,
	faces_seen numeric(16, 0) not null,
	units numeric(3, 0) not null,
	loc numeric(3, 0) not null,
	constraint pk_planogram primary key(product_ean, shelf_nr, ivm_serial_number, ivm_manuf),
	constraint fk_planogram_product foreign key(product_ean) references product(product_ean),
	constraint fk_planogram_shelf foreign key(shelf_nr, ivm_serial_number, ivm_manuf) references shelf(shelf_nr, ivm_serial_number, ivm_manuf)
);


--------
--- Um Produto só pode ser reposto numa Prateleira que apresente 
---(pelo menos) uma das Categorias desse produto
--  Cenas q se sabe:
--  -> 1 produto, 1 pelo menos 1 categoria
--  -> 1 prateleira numa dada maquina, 1 categoria
-- select k.category_name as cats from shelf k where shelf_nr=1 and
-- ivm_serial_number='54623' and ivm_manuf ='Mars Inc.';
--  Passos Hierarquicos (guardados para se for preciso para o website):
--  1o, Ver Prateleira
--  2o, Ver categoria da Prateleira
--  3o, Ver subcategorias da Prateleira (Aka desdobrar arvore toda)
--  4o, ver se alguma dessas subcategorias e igual a do produto

CREATE OR REPLACE FUNCTION chk_insert_planogram()
RETURNS TRIGGER AS
$$
BEGIN
	IF NOT EXISTS (
		SELECT category_name
		FROM shelf
		WHERE ivm_manuf = NEW.ivm_manuf
		AND ivm_serial_number = NEW.ivm_serial_number
		AND shelf_nr = NEW.shelf_nr
		AND category_name IN (
			SELECT category_name
			FROM has_category
			WHERE product_ean = NEW.product_ean
			)
		)
	THEN
		RAISE EXCEPTION 'Products categories not present in selected shelf';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chk_insert_planogram
BEFORE INSERT ON planogram
FOR EACH ROW EXECUTE PROCEDURE chk_insert_planogram();

-- Might help with website, hierarchy!
-- https://stackoverflow.com/questions/11051506/how-to-get-hierarchy-of-employees-for-a-manager-in-mysql
--CREATE OR REPLACE FUNCTION chk_insert_planogram()
--RETURNS TRIGGER AS
--$$
--BEGIN
--	IF 
--	p.category_name != 
--	ELSE IF 
--		p.category_name
--		FROM (
--			SELECT product p, shelf s
--			WHERE p.product_ean = NEW.product_ean
--			AND s.category_name= NEW.category_name
--		)
--		NOT IN (
--			SELECT * 
--			FROM has_other h, category s
--			WHERE h.super_category = s.category_name
--			OR h.super_category IN (
--				SELECT child_category
--				FROM has_other
--				WHERE super_category = s.category_name
--			)
--		)
--	END IF;
--END;
--$$ LANGUAGE plpgsql;

create table retailer (
	retailer_tin numeric(16,0) not null,
	retailer_name varchar(255) not null unique,
	constraint pk_retailer primary key(retailer_tin)
);

create table responsible_for (
	ivm_serial_number numeric(5,0) not null,
	ivm_manuf varchar(255) not null,
	retailer_tin numeric(16,0) not null,
	category_name varchar(255) not null,
	constraint pk_responsible_for primary key(ivm_serial_number, ivm_manuf, retailer_tin, category_name),
	constraint fk_responsible_for_ivm foreign key(ivm_serial_number, ivm_manuf) references ivm(ivm_serial_number, ivm_manuf),
	constraint fk_responsible_for_retailer foreign key(retailer_tin) references retailer(retailer_tin),
	constraint fk_responsible_for_category foreign key(category_name) references category(category_name)
);

create table replenishment_event (
	product_ean char(13) not null,
	shelf_nr numeric(16,0) not null,
	ivm_serial_number numeric(5,0) not null,
	ivm_manuf varchar(255) not null,
	event_instant varchar(255) not null,
	replenished_units numeric(3, 0) not null,
	retailer_tin numeric(16,0) not null,
	constraint pk_replenishment_event primary key(product_ean, shelf_nr, ivm_serial_number, ivm_manuf, event_instant),
	constraint fk_replenishment_event_planogram foreign key(product_ean, shelf_nr, ivm_serial_number, ivm_manuf) references planogram(product_ean, shelf_nr, ivm_serial_number, ivm_manuf),
	constraint fk_replenishment_event_retailer foreign key(retailer_tin) references retailer(retailer_tin)
);

CREATE OR REPLACE FUNCTION chk_units_exceeded()
RETURNS TRIGGER AS
$$
DECLARE
	T planogram%ROWTYPE;
BEGIN
	SELECT *
	INTO T
	FROM planogram
	WHERE product_ean = NEW.product_ean;
	IF T.units < NEW.replenished_units THEN
		RAISE EXCEPTION 'Number of replenished units may not exceed the number of allowed units set in the planogram';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chk_units_replenishment_event
BEFORE UPDATE OR INSERT ON replenishment_event 
FOR EACH ROW EXECUTE PROCEDURE chk_units_exceeded();
