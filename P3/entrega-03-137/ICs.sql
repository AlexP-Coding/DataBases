----------------------------------------
-- TRIGGERS, FUNCTIONS AND PROCEDURES
-----------------------------------------


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
