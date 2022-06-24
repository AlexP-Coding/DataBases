--  Qual o nome do retalhista (ou retalhistas) 
-- responsáveis pela reposição do maior número de categorias?
SELECT retailer_name 
FROM retailer 
WHERE retailer_tin IN (
SELECT retailer_tin
FROM responsible_for 
GROUP BY retailer_tin
HAVING COUNT(category_name) >= ALL
	(SELECT COUNT(category_name)
	FROM responsible_for
	GROUP BY retailer_tin)
);

--  Qual o nome do ou dos retalhistas que são responsaveis 
-- por todas as categorias simples?
SELECT retailer_name 
FROM retailer
WHERE retailer_tin IN (
	SELECT retailer_tin 
	FROM responsible_for 
	WHERE category_name IN (
		SELECT category_name 
		FROM simple_category
		)
);

-- Quais os produtos (ean) que nunca foram repostos?
SELECT product_ean 
FROM product EXCEPT (SELECT product_ean FROM replenishment_event);

--  Quais os produtos (ean) que foram repostos 
-- sempre pelo mesmo retalhista?
SELECT product_ean
FROM replenishment_event
GROUP BY product_ean
HAVING COUNT(DISTINCT retailer_tin) = 1;
