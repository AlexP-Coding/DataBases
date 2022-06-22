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
