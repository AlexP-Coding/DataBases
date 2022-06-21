DROP VIEW if exists replenishment_events_for_ivm;
CREATE VIEW replenishment_events_for_ivm
AS
	SELECT * FROM replenishment_event NATURAL JOIN product;
