
insert into ivm values(54623, 'Mars Inc.');
insert into ivm values(61824, 'Mars Inc.');
insert into ivm values(73719, 'Paytec');
insert into ivm values(84712, 'Seaga');

insert into category values('Águas');
insert into category values('Vegetais');
insert into category values('Tubérculos');
insert into category values('Laticínios');
insert into category values('Congelados');
insert into category values('Pão congelado');
insert into category values('Carne');
insert into category values('Carnes Vermelhas');
insert into category values('Vinhos');
insert into category values('Leite');
insert into category values('Batata');
insert into category values('Cereais');
insert into category values('Doces');
insert into category values('Tabletes');

insert into super_category values('Tubérculos');
insert into super_category values('Doces');
insert into super_category values('Congelados');
insert into super_category values('Carne');
insert into super_category values('Laticínios');
insert into simple_category values('Batata');
insert into simple_category values('Tabletes');
insert into simple_category values('Pão congelado');
insert into simple_category values('Carnes Vermelhas');
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
insert into product values('0000000000010', 'Doces', 'Pintarolas');
insert into product values('0000000000011', 'Doces', 'Gelatina de Morango');
insert into product values('0000000000012', 'Carnes Brancas','Frango inteiro');
insert into product values('0000000000013', 'Vegetais', 'Cenoura');
insert into product values('0000000000014', 'Águas', 'Água Penacova');

---

insert into has_other values('Tubérculos', 'Batata');
insert into has_other values('Doces', 'Tabletes');
insert into has_other values('Carne', 'Carnes Vermelhas');
insert into has_other values('Congelados', 'Pão congelado');
insert into has_other values('Laticínios', 'Leite');
insert into has_other values('Laticínios', 'Iogurtes');

insert into shelf values(1, 54623, 'Mars Inc.', 60.00, 'Tabletes');
insert into shelf values(2, 54623, 'Mars Inc.', 40.00, 'Tubérculos');
insert into shelf values(1, 61824, 'Mars Inc.', 100.00, 'Carne');
insert into shelf values(2, 61824, 'Mars Inc.', 20.00, 'Doces');
insert into shelf values(4, 61824, 'Mars Inc.', 30.00, 'Leite');
insert into shelf values(1, 73719, 'Paytec', 100.00, 'Laticínios');
insert into shelf values(3, 73719, 'Paytec', 60.00, 'Águas');
insert into shelf values(1, 84712, 'Seaga', 100.00, 'Carnes Vermelhas');
insert into shelf values(3, 84712, 'Seaga', 100.00, 'Doces');
insert into shelf values(4, 84712, 'Seaga', 70.00, 'Vegetais');

insert into planogram values('0000000000002', 1, 54623, 'Mars Inc.', 5, 4, 3);
insert into planogram values('0000000000009', 2, 54623, 'Mars Inc.', 1, 20, 0);
insert into planogram values('0000000000010', 2, 61824, 'Mars Inc.', 1, 5, 2);
insert into planogram values('0000000000008', 1, 73719, 'Paytec', 3, 10, 1);
insert into planogram values('0000000000011', 3, 84712, 'Seaga', 3, 10, 1);
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
insert into responsible_for values('Carne', '501748680', '61824', 'Mars Inc.');
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
insert into replenishment_event values('0000000000008', 1, '73719', 'Paytec', '11/10/2021', 1, '602712215');
insert into replenishment_event values('0000000000013', 4, '84712', 'Seaga', '6/10/2022', 1, '501748680');
insert into replenishment_event values('0000000000011', 3, '84712', 'Seaga', '4/1/2022', 3, '801013754');
insert into replenishment_event values('0000000000013', 4, '84712', 'Seaga', '3/1/2022', 1, '501748680');
insert into replenishment_event values('0000000000013', 4, '84712', 'Seaga', '26/11/2022', 1, '406996794');

