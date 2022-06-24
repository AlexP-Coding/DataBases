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
-- TABLE CREATION
----------------------------------------

-- Named constraints are global to the database.
-- Therefore the following use the following naming rules:
--   1. pk_table for names of primary key constraints
--   2. fk_table_another for names of foreign key constraints

create table category (
	category_name varchar(255) not null,
	constraint pk_category primary key(category_name)
	--  RI-RE1 (non-applicable):
	-- O valor do atributo nome de qualquer registo da relação categoria 
	-- tem de existir em na relação categoria_simples ou na relação super_categoria
);

create table simple_category (
	category_name varchar(255) not null,
	constraint pk_simple_category primary key(category_name),
	constraint fk_simple_category_category foreign key(category_name) references category(category_name)
--  RI-RE2: O valor do aributo nome de qualquer registo de categoria_simples 
-- não pode existir em super_categoria
);

create table super_category (
	category_name varchar(255) not null,
	constraint pk_super_category primary key(category_name),
	constraint fk_super_category_category foreign key(category_name) references category(category_name)
--  RI-RE3: O valor do atributo nome de qualquer registo tem de existir 
-- no atributo super_categoria da relação constituída
);

create table has_other (
	super_category varchar(255) not null,
	child_category varchar(255) not null,
	constraint pk_has_other primary key(child_category),
	constraint fk_has_other_super_category foreign key(super_category) references super_category(category_name),
	constraint fk_has_other_category foreign key(child_category) references category(category_name)
--  RI-RE4 não podem existir valores repetidos dos atributos 
-- super_categoria e categoria 
-- numa sequência de registos relacionados pela FK categoria
--  RI-RE5: Para qualquer registo desta relação, 
-- verifica-se que os atributos super_categoria e categoria são distintos
);

create table product (
	product_ean char(13) not null,
	category_name varchar(255) not null,
	product_descr varchar(255),
	constraint pk_product primary key(product_ean),
	constraint fk_product_simple_category foreign key(category_name) references simple_category(category_name)
--  RI-RE6: O valor do atributo ean existente em qualquer registo da relação 
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
	ivm_serial_number numeric(5,0) not null,
	ivm_manuf varchar(255) not null,
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
	shelf_nr numeric(16,0) not null,
	ivm_serial_number numeric(5,0) not null,
	ivm_manuf varchar(255) not null,
	shelf_height numeric(5, 2) not null,
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



---------------------------------------------------------------------------
-- (RI) - Added here because otherwise some features won't work as intended
--      - Replicated at ICs.sql
----------------------------------------------------------------------------

-- (RI-1) Uma Categoria não pode estar contida em si propria
-------------------------------------------------------------
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


--  RI-RE6: O valor do atributo ean existente em qualquer registo 
-- da relacao produto tem de existir também no atributo ean da relação tem_categoria
-- (insert)
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


--  RI-RE6: O valor do atributo ean existente em qualquer registo 
-- da relacao produto tem de existir também no atributo ean da relação tem_categoria
-- (update)
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


-- (RI-4) O numero de unidades repostas num Evento de Reposicao 
-- nao pode exceder o número de unidades especificado no Planograma
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


--  (RI-5) Um Produto so pode ser reposto numa Prateleira 
-- que apresente (pelo menos) uma das Categorias desse produto
---------------------------------------------------------------
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


--------------------------------------------------
-- EXTRAS (FUNCTIONS, STORED PROCEDURES, TRIGGERS)
--------------------------------------------------

-- Inserting a sub-category
-------------------------------------
CREATE OR REPLACE PROCEDURE add_sub(father varchar(255), new varchar(255))
AS
$$
BEGIN
        INSERT INTO category values(new);
        INSERT INTO simple_category values(new);
        IF father NOT IN (SELECT * FROM super_category) THEN
                INSERT INTO super_category values(father);
        END IF;
        INSERT INTO has_other values(father, new);
END;
$$ LANGUAGE plpgsql;


-- Deleting a category
-------------------------------------
DROP PROCEDURE if exists delete_cat(name);
CREATE OR REPLACE PROCEDURE delete_cat(name varchar(255))
AS
$$
    DECLARE ean has_category.product_ean%TYPE;
    DECLARE c_aux CURSOR FOR (SELECT * FROM has_category WHERE category_name=name);
    DECLARE myvar has_category%ROWTYPE;
BEGIN
    OPEN c_aux;
    LOOP
        FETCH c_aux INTO myvar;
        EXIT WHEN NOT FOUND;
        SELECT myvar.product_ean INTO ean;
        DELETE FROM has_category WHERE product_ean = ean;
	DELETE FROM replenishment_event WHERE product_ean = ean;
        DELETE FROM planogram WHERE product_ean = ean;
    END LOOP;
    UPDATE has_other SET super_category = (SELECT super_category FROM has_other WHERE child_category=name) WHERE super_category=name; 
    DELETE FROM responsible_for WHERE category_name=name;
    DELETE FROM shelf WHERE category_name=name;
    DELETE FROM product WHERE category_name=name;

	DELETE FROM has_other WHERE child_category = name;
        DELETE FROM simple_category WHERE category_name = name;
	DELETE FROM has_other WHERE super_category = name;
        DELETE FROM super_category WHERE category_name = name;

    DELETE FROM category WHERE category_name=name;
    CLOSE c_aux;
END
$$ LANGUAGE plpgsql;


-- List sub-categories, all depths
----------------------------------------------------
CREATE OR REPLACE FUNCTION list_subs(name varchar(255)) 
RETURNS table(category_name varchar(255))
AS
$$
WITH RECURSIVE list_aux(super_name) AS (
    SELECT
        child_category
    FROM
        has_other
    WHERE
        super_category=name
    UNION
        SELECT
            child_category
        FROM
            has_other h INNER JOIN list_aux l ON h.super_category = l.super_name 
) SELECT
    *
FROM
    list_aux;
$$ LANGUAGE sql;



----------------------------------------
-- DATA INSERTION
----------------------------------------

insert into ivm values(54623, 'Mars Inc.');
insert into ivm values(61824, 'Mars Inc.');
insert into ivm values(73719, 'Paytec');
insert into ivm values(84712, 'Seaga');

insert into category values('Tubérculos');
insert into category values('Batata');
insert into category values('Batata Frita');
insert into category values('Batata Cozida');
insert into category values('Doces');
insert into category values('Tabletes');
insert into category values('Bolachas');
insert into category values('Belgas');
insert into category values('Wafers');
insert into category values('Congelados');
insert into category values('Carne');
insert into category values('Laticínios');
insert into category values('Doces Simples');
insert into category values('Pão congelado');
insert into category values('Carnes Vermelhas');
insert into category values('Carnes Brancas');
insert into category values('Vegetais');
insert into category values('Leite');
insert into category values('Iogurtes');
insert into category values('Águas');
insert into category values('Cereais');
insert into category values('Vinhos');

insert into super_category values('Tubérculos');
insert into super_category values('Batata');
insert into super_category values('Doces');
insert into super_category values('Bolachas');
insert into super_category values('Congelados');
insert into super_category values('Carne');
insert into super_category values('Laticínios');
insert into simple_category values('Batata');
insert into simple_category values('Tabletes');
insert into simple_category values('Doces Simples');
insert into simple_category values('Pão congelado');
insert into simple_category values('Carnes Vermelhas');
insert into simple_category values('Carnes Brancas');
insert into simple_category values('Vegetais');
insert into simple_category values('Leite');
insert into simple_category values('Iogurtes');
insert into simple_category values('Águas');
insert into simple_category values('Cereais');
insert into simple_category values('Vinhos');

insert into product values('0000000000001', 'Carnes Vermelhas','Orelha de porco');
insert into product values('0000000000002', 'Tabletes', 'Chocolate Milka');
insert into product values('0000000000003', 'Cereais', 'Cereais Chocapic');
insert into product values('0000000000004', 'Iogurtes', 'Iogurte de morango');
insert into product values('0000000000005', 'Vinhos', 'Vinho Branco');
insert into product values('0000000000006', 'Vinhos', 'Vinho Tinto');
insert into product values('0000000000007', 'Vegetais', 'Couve-flor');
insert into product values('0000000000008', 'Leite', 'Leite de chocolate');
insert into product values('0000000000009', 'Batata', 'Batata');
insert into product values('0000000000010', 'Doces Simples', 'Pintarolas');
insert into product values('0000000000011', 'Doces Simples', 'Gelatina de Morango');
insert into product values('0000000000012', 'Carnes Brancas','Frango inteiro');
insert into product values('0000000000013', 'Vegetais', 'Cenoura');
insert into product values('0000000000014', 'Águas', 'Água Penacova');

---

insert into has_other values('Tubérculos', 'Batata');
insert into has_other values('Batata', 'Batata Frita');
insert into has_other values('Batata', 'Batata Cozida');
insert into has_other values('Doces', 'Tabletes');
insert into has_other values('Doces', 'Doces Simples');
insert into has_other values('Doces', 'Bolachas');
insert into has_other values('Bolachas', 'Wafers');
insert into has_other values('Bolachas', 'Belgas');
insert into has_other values('Carne', 'Carnes Vermelhas');
insert into has_other values('Carne', 'Carnes Brancas');
insert into has_other values('Congelados', 'Pão congelado');
insert into has_other values('Laticínios', 'Leite');
insert into has_other values('Laticínios', 'Iogurtes');

insert into shelf values(1, 54623, 'Mars Inc.', 60.00, 'Tabletes');
insert into shelf values(2, 54623, 'Mars Inc.', 40.00, 'Batata');
insert into shelf values(1, 61824, 'Mars Inc.', 100.00, 'Carnes Vermelhas');
insert into shelf values(2, 61824, 'Mars Inc.', 20.00, 'Doces Simples');
insert into shelf values(4, 61824, 'Mars Inc.', 30.00, 'Leite');
insert into shelf values(1, 73719, 'Paytec', 100.00, 'Leite');
insert into shelf values(3, 73719, 'Paytec', 60.00, 'Águas');
insert into shelf values(1, 84712, 'Seaga', 100.00, 'Carnes Vermelhas');
insert into shelf values(3, 84712, 'Seaga', 100.00, 'Tabletes');
insert into shelf values(4, 84712, 'Seaga', 70.00, 'Vegetais');

insert into planogram values('0000000000002', 1, 54623, 'Mars Inc.', 5, 4, 3);
insert into planogram values('0000000000009', 2, 54623, 'Mars Inc.', 1, 20, 0);
insert into planogram values('0000000000010', 2, 61824, 'Mars Inc.', 1, 5, 2);
insert into planogram values('0000000000011', 2, 61824, 'Mars Inc.', 1, 5, 2);
insert into planogram values('0000000000008', 1, 73719, 'Paytec', 3, 10, 1);
insert into planogram values('0000000000013', 4, 84712, 'Seaga', 4, 1, 2);

insert into point_of_retail values('Galp', 'Lisboa', 'Loures');
insert into point_of_retail values('Repsol', 'Lisboa', 'Cidade Nova');
insert into point_of_retail values('Prio', 'Algarve', 'Montegordo');
insert into point_of_retail values('Diesel', 'Alentejo', 'Porto Covo');

insert into installed_at values(54623, 'Mars Inc.', 'Galp');
insert into installed_at values(61824, 'Mars Inc.', 'Repsol');
insert into installed_at values(84712, 'Seaga', 'Diesel');
insert into installed_at values(73719, 'Paytec', 'Diesel');

insert into retailer values('909025806', 'Solbel');
insert into retailer values('801013754', 'Continente');
insert into retailer values('701013754', 'Jerónimo Martins');
insert into retailer values('602712215', 'E.Leclerc');
insert into retailer values('501748680', 'Losk');
insert into retailer values('406996794', 'Niuma');

insert into responsible_for values('Tabletes', '801013754', '54623', 'Mars Inc.');
insert into responsible_for values('Tubérculos', '701013754', '54623', 'Mars Inc.');
insert into responsible_for values('Águas', '406996794', '54623', 'Mars Inc.');
insert into responsible_for values('Águas', '406996794', '61824', 'Mars Inc.');
insert into responsible_for values('Tabletes', '909025806', '61824', 'Mars Inc.');
insert into responsible_for values('Carnes Vermelhas', '501748680', '61824', 'Mars Inc.');
insert into responsible_for values('Águas', '406996794', '73719', 'Paytec');
insert into responsible_for values('Carnes Vermelhas', '909025806', '73719', 'Paytec');
insert into responsible_for values('Leite', '602712215', '73719', 'Paytec');
insert into responsible_for values('Vegetais', '801013754', '84712', 'Seaga');
insert into responsible_for values('Águas', '501748680', '84712', 'Seaga');
insert into responsible_for values('Cereais', '602712215', '84712', 'Seaga');

insert into replenishment_event values('0000000000009', 2, '54623', 'Mars Inc.', '26/11/2022', 2, '801013754');
insert into replenishment_event values('0000000000002', 1, '54623', 'Mars Inc.', '24/10/2022', 2, '801013754');
insert into replenishment_event values('0000000000010', 2, '61824', 'Mars Inc.', '25/11/2022', 3, '801013754');
insert into replenishment_event values('0000000000010', 2, '61824', 'Mars Inc.', '26/11/2022', 3, '801013754');
insert into replenishment_event values('0000000000010', 2, '61824', 'Mars Inc.', '17/4/2021', 4, '909025806');
insert into replenishment_event values('0000000000011', 2, '61824', 'Mars Inc.', '20/7/2021', 4, '909025806');
insert into replenishment_event values('0000000000008', 1, '73719', 'Paytec', '11/10/2021', 1, '602712215');
insert into replenishment_event values('0000000000013', 4, '84712', 'Seaga', '6/10/2022', 1, '501748680');
insert into replenishment_event values('0000000000013', 4, '84712', 'Seaga', '3/1/2022', 1, '501748680');
insert into replenishment_event values('0000000000013', 4, '84712', 'Seaga', '26/11/2022', 1, '406996794');
