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
-- Entrar:
--  ssh ist197375@sigma.ist.utl.pt
--  psql -h db.tecnico.ulisboa.pt -U ist197375
-- Enviar: 
--  scp ivm.sql ist197375@sigma.ist.utl.pt:~/BD/Project/
--  scp carregamento.sql ist197375@sigma.ist.utl.pt:~/BD/Project/
--  scp ivm.sql carregamento.sql ist197375@sigma.ist.utl.pt:~/BD/Project/
-- Buscar: 
--  scp ist197375@sigma.ist.utl.pt:~/BD/Project/ivm.sql ./
--  scp ist197375@sigma.ist.utl.pt:~/BD/Project/carregamento.sql ./

----------------------------------------
-- TABLE CREATION
----------------------------------------

-- Named constraints are global to the database.
-- Therefore the following use the following naming rules:
--   1. pk_table for names of primary key constraints
--   2. fk_table_another for names of foreign key constraints

create table category (
	category_name varchar(255) not null,
	constraint pk_category primary key(category_name)
	-- RI-RE1 (non-applicable):
	-- O valor do atributo nome de qualquer registo da relação categoria 
	-- tem de existir em na relação categoria_simples ou na relação super_categoria
);

create table simple_category (
	category_name varchar(255) not null,
	constraint pk_simple_category primary key(category_name),
	constraint fk_simple_category_category foreign key(category_name) references category(category_name)
-- RI-RE2: O valor do aributo nome de qualquer registo de categoria_simples 
-- não pode existir em super_categoria
);

create table super_category (
	category_name varchar(255) not null,
	constraint pk_super_category primary key(category_name),
	constraint fk_super_category_category foreign key(category_name) references category(category_name)
-- RI-RE3: O valor do atributo nome de qualquer registo tem de existir 
-- no atributo super_categoria da relação constituída
);

create table has_other (
	super_category varchar(255) not null,
	child_category varchar(255) not null,
	constraint pk_has_other primary key(child_category),
	constraint fk_has_other_super_category foreign key(super_category) references super_category(category_name),
	constraint fk_has_other_category foreign key(child_category) references category(category_name)
-- RI-RE4 não podem existir valores repetidos dos atributos 
-- super_categoria e categoria 
-- numa sequência de registos relacionados pela FK categoria
-- RI-RE5: Para qualquer registo desta relação, 
-- verifica-se que os atributos super_categoria e categoria são distintos
);

create table product (
	product_ean char(13) not null,
	category_name varchar(255) not null,
	product_descr varchar(255),
	constraint pk_product primary key(product_ean),
	constraint fk_product_simple_category foreign key(category_name) references simple_category(category_name)
-- RI-RE6: O valor do atributo ean existente em qualquer registo da relação 
-- produto tem de existir também no atributo ean da relação tem_categoria
);

create table has_category (
	product_ean char(13) not null,
	category_name varchar(255) not null,
	constraint pk_has_category primary key(product_ean, category_name),
	constraint fk_has_category_product foreign key(product_ean) references product(product_ean),
	constraint fk_has_category_category foreign key(category_name) references category(category_name)
);

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
	constraint pk_installed_at primary key(ivm_serial_number, ivm_manuf),
	constraint fk_installed_at_ivm foreign key(ivm_serial_number, ivm_manuf) references ivm(ivm_serial_number, ivm_manuf),
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

create table retailer (
	retailer_tin varchar(9) not null,
	retailer_name varchar(255) not null unique,
	constraint pk_retailer primary key(retailer_tin)
-- RI-RE7: unique(name)
);

create table responsible_for (
	category_name varchar(255) not null,
	retailer_tin varchar(9) not null,
	ivm_serial_number numeric(5,0) not null,
	ivm_manuf varchar(255) not null,
	constraint pk_responsible_for primary key(retailer_tin, category_name, ivm_serial_number, ivm_manuf),
	constraint fk_responsible_for_category foreign key(category_name) references category(category_name),
	constraint fk_responsible_for_retailer foreign key(retailer_tin) references retailer(retailer_tin),
	constraint fk_responsible_for_ivm foreign key(ivm_serial_number, ivm_manuf) references ivm(ivm_serial_number, ivm_manuf)
);

create table replenishment_event (
	product_ean char(13) not null,
	shelf_nr numeric(16,0) not null,
	ivm_serial_number numeric(5,0) not null,
	ivm_manuf varchar(255) not null,
	event_instant date not null,
	replenished_units numeric(3, 0) not null,
	retailer_tin varchar(9) not null,
	constraint pk_replenishment_event primary key(product_ean, shelf_nr, ivm_serial_number, ivm_manuf, event_instant),
	constraint fk_replenishment_event_planogram foreign key(product_ean, shelf_nr, ivm_serial_number, ivm_manuf) references planogram(product_ean, shelf_nr, ivm_serial_number, ivm_manuf),
	constraint fk_replenishment_event_retailer foreign key(retailer_tin) references retailer(retailer_tin)
);


----------------------------------------
-- TRIGGERS, FUNCTIONS AND PROCEDURES
----------------------------------------

-- Category cannot contain itself
-------------------------------------
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


-- Deleting a category
-------------------------------------
DROP PROCEDURE if exists delete_cat(name);
CREATE OR REPLACE PROCEDURE delete_cat(name varchar(255))
AS
$$
    DECLARE ean planogram.product_ean%TYPE;
    DECLARE c CURSOR FOR SELECT * FROM planogram;
    DECLARE myvar planogram%ROWTYPE;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO myvar;
        EXIT WHEN NOT FOUND;
        SELECT myvar.product_ean INTO ean;
        IF ean IN (SELECT product_ean FROM product WHERE category_name=name) THEN
                DELETE FROM replenishment_event WHERE product_ean = ean;
                DELETE FROM planogram WHERE product_ean = ean;
        END IF;
    END LOOP;
    DELETE FROM responsible_for WHERE category_name=name;
    DELETE FROM shelf WHERE category_name=name;
    DELETE FROM product WHERE category_name=name;
    IF name IN (SELECT * FROM simple_category) THEN
        DELETE FROM simple_category WHERE category_name = name;
    ELSIF name IN (SELECT * FROM super_category) THEN
        DELETE FROM super_category WHERE category_name = name;
    END IF;
    DELETE FROM category WHERE category_name=name;
    CLOSE c;
END
$$ LANGUAGE plpgsql;


-- Product must participate in has_category: insert
----------------------------------------------------
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


-- Product must participate in has_category: update
----------------------------------------------------
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



-- Units Replenished <= Units on Planogram
----------------------------------------------------
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


-- Planogram product categories must belong to shelf
----------------------------------------------------

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
/*CREATE OR REPLACE FUNCTION chk_insert_planogram()
RETURNS TRIGGER AS
$$
BEGIN
	WITH cat_id AS (
		SELECT category_name
		FROM shelf
		WHERE ivm_manuf = NEW.ivm_manuf
		AND ivm_serial_number = NEW.ivm_serial_number
		AND shelf_nr = NEW.shelf_nr
	)
	, product_categories AS (
		SELECT category_name
		FROM has_category
		WHERE product_ean = NEW.product_ean
	)
	, RECURSIVE shelf_categories(child_category,super_category) AS (
    SELECT child_category,super_category
		FROM has_other 
		WHERE super_category == cat_id
		UNION ALL
    SELECT others.child_category, others.super_category
		FROM has_other others
		INNER JOIN shelf_categories
		ON others.super_category = shelf_categories.child_category
	)
	IF NOT EXISTS (
		SELECT category_name 
		from product_categories
		where category_name ==cat_id
		or category_name in (
			select child_category
			from shelf_categories
		)
	)
	THEN
		RAISE EXCEPTION 'Products categories not present in selected shelf';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;*/


----------------------------------------
-- VIEWS
----------------------------------------
DROP VIEW if exists Vendas;
CREATE VIEW Vendas(ean, cat, ano, trimestre, mes, dia_mes, dia_semana, distrito, concelho, unidades)
AS
	SELECT
	product_ean AS ean,
	category_name AS cat,
	EXTRACT(YEAR FROM event_instant) AS ano,
	ROUND(EXTRACT(MONTH FROM event_instant) / 4 + 1) AS trimestre,
	EXTRACT(MONTH FROM event_instant) AS mes,
	EXTRACT(DAY FROM event_instant) AS dia_mes,
	CASE
		WHEN EXTRACT(dow FROM event_instant) = 0 THEN 'Sunday'
		WHEN EXTRACT(dow FROM event_instant) = 1 THEN 'Monday'
		WHEN EXTRACT(dow FROM event_instant) = 2 THEN 'Tuesday'
                WHEN EXTRACT(dow FROM event_instant) = 3 THEN 'Wednesday'
                WHEN EXTRACT(dow FROM event_instant) = 4 THEN 'Thursday'
                WHEN EXTRACT(dow FROM event_instant) = 5 THEN 'Friday'
                WHEN EXTRACT(dow FROM event_instant) = 6 THEN 'Saturday'
	END dia_semana,
	point_district AS distrito,
	point_municipality AS concelho,
	replenished_units AS unidades
	FROM product NATURAL JOIN replenishment_event NATURAL JOIN installed_at NATURAL JOIN point_of_retail;
