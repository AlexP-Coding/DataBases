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
