
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

DROP VIEW if exists replenishment_events_for_ivm;
CREATE VIEW replenishment_events_for_ivm
AS
        SELECT * FROM replenishment_event NATURAL JOIN product;
