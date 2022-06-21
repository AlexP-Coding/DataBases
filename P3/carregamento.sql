
insert into ivm values(54623, 'Mars Inc.');
insert into ivm values(91824, 'Mars Inc.');
insert into ivm values(91734, 'Paytec');
insert into ivm values(84712, 'Seaga');

insert into category values('Águas');
insert into category values('Vegetais');
insert into category values('Tubérculos');
insert into category values('Laticínios');
insert into category values('Congelados');
insert into category values('Pão congelado');
insert into category values('Carne');
insert into category values('Porco');
insert into category values('Vinhos');
insert into category values('Leite');
insert into category values('Batata');
insert into category values('Cereais');
insert into category values('Doces');
insert into category values('Tabletes');

insert into super_category values('Vinhos');
insert into super_category values('Tubérculos');
insert into super_category values('Congelados');
insert into super_category values('Laticínios');
insert into super_category values('Vegetais');
insert into super_category values('Carne');
insert into super_category values('Doces');
insert into simple_category values('Tabletes');
insert into simple_category values('Leite');
insert into simple_category values('Águas');
insert into simple_category values('Porco');
insert into simple_category values('Pão congelado');
insert into simple_category values('Cereais');
insert into simple_category values('Batata');

insert into product values('2466881097426', 'Porco','Orelha de porco');
insert into product values('2916348454168', 'Batata', 'Batata');
insert into product values('3072558779790', 'Cereais', 'Cereais Chocapic');
insert into product values('6010440030530', 'Laticínios', 'Iogurte de morango');
insert into product values('6608024404321', 'Vinhos', 'Vinho Branco');
insert into product values('7009667363536', 'Vinhos', 'Vinho Tinto');
insert into product values('7559992648401', 'Vegetais', 'Couve-flor');
insert into product values('7441503902471', 'Laticínios', 'Leite de chocolate');
insert into product values('7569290774222', 'Tabletes', 'Chocolate Milka');
insert into product values('8079544896855', 'Doces', 'Pintarolas');
insert into product values('8407837792023', 'Vegetais', 'Cenoura');
insert into product values('8451711541269', 'Carne','Frango inteiro');
insert into product values('9535718049874', 'Águas', 'Água Luso');
insert into product values('9852223948688', 'Águas', 'Água Penacova');

---

insert into has_other values('Tubérculos', 'Batata');
insert into has_other values('Doces', 'Tabletes');
insert into has_other values('Carne', 'Porco');
insert into has_other values('Congelados', 'Pão congelado');
insert into has_other values('Laticínios', 'Leite');

insert into shelf values(1, 54623, 'Mars Inc.', 60.00, 'Tabletes');
insert into shelf values(2, 54623, 'Mars Inc.', 40.00, 'Tubérculos');
insert into shelf values(1, 84712, 'Seaga', 100.00, 'Porco');
insert into shelf values(3, 84712, 'Seaga', 100.00, 'Doces');
insert into shelf values(4, 84712, 'Seaga', 70.00, 'Vegetais');
insert into shelf values(1, 91734, 'Paytec', 100.00, 'Leite');
insert into shelf values(3, 91734, 'Paytec', 60.00, 'Águas');
insert into shelf values(1, 91824, 'Mars Inc.', 100.00, 'Carne');
insert into shelf values(2, 91824, 'Mars Inc.', 20.00, 'Doces');
insert into shelf values(4, 91824, 'Mars Inc.', 30.00, 'Leite');

insert into planogram values('2916348454168', 1, 54623, 'Mars Inc.', 5, 4, 3);
insert into planogram values('8079544896855', 1, 54623, 'Mars Inc.', 3, 10, 1);
insert into planogram values('9535718049874', 1, 54623, 'Mars Inc.', 2, 3, 1);
insert into planogram values('7569290774222', 2, 54623, 'Mars Inc.', 1, 20, 0);
insert into planogram values('8407837792023', 3, 84712, 'Seaga', 3, 10, 1);
insert into planogram values('9535718049874', 4, 84712, 'Seaga', 4, 1, 2);
insert into planogram values('8079544896855', 2, 91824, 'Mars Inc.', 1, 5, 2);
insert into planogram values('7441503902471', 1, 91734, 'Paytec', 3, 10, 1);
insert into planogram values('9535718049874', 1, 91824, 'Mars Inc.', 1, 2, 1);


insert into point_of_retail values('Galp', 'Lisboa', 'Loures');
insert into point_of_retail values('Repsol', 'Lisboa', 'Cidade Nova');
insert into point_of_retail values('Prio', 'Algarve', 'Montegordo');
insert into point_of_retail values('Diesel', 'Alentejo', 'Porto Covo');

insert into installed_at values(54623, 'Mars Inc.', 'Galp');
insert into installed_at values(91824, 'Mars Inc.', 'Repsol');
insert into installed_at values(84712, 'Seaga', 'Diesel');
insert into installed_at values(91734, 'Paytec', 'Diesel');

insert into retailer values('909025806', 'Solbel');
insert into retailer values('901013754', 'Continente');
insert into retailer values('907546188', 'Jerónimo Martins');
insert into retailer values('902712215', 'E.Leclerc');
insert into retailer values('901748680', 'Losk');
insert into retailer values('906996794', 'Niuma');

insert into responsible_for values('Doces', '909025806', '54623', 'Mars Inc.');
insert into responsible_for values('Tabletes', '901013754', '54623', 'Mars Inc.');
insert into responsible_for values('Tubérculos', '907546188', '54623', 'Mars Inc.');
insert into responsible_for values('Águas', '906996794', '54623', 'Mars Inc.');
insert into responsible_for values('Águas', '906996794', '91824', 'Mars Inc.');
insert into responsible_for values('Doces', '909025806', '91824', 'Mars Inc.');
insert into responsible_for values('Carne', '901748680', '91824', 'Mars Inc.');
insert into responsible_for values('Vegetais', '901013754', '84712', 'Seaga');
insert into responsible_for values('Cereais', '902712215', '84712', 'Seaga');
insert into responsible_for values('Águas', '901748680', '84712', 'Seaga');
insert into responsible_for values('Águas', '906996794', '91734', 'Paytec');
insert into responsible_for values('Porco', '909025806', '91734', 'Paytec');
insert into responsible_for values('Leite', '902712215', '91734', 'Paytec');

insert into replenishment_event values('9535718049874', 1, '54623', 'Mars Inc.', '26/11/2022', 3, '906996794');
insert into replenishment_event values('9535718049874', 1, '54623', 'Mars Inc.', '25/11/2022', 3, '906996794');
insert into replenishment_event values('9535718049874', 1, '54623', 'Mars Inc.', '24/11/2022', 3, '906996794');
insert into replenishment_event values('7569290774222', 2, '54623', 'Mars Inc.', '24/10/2022', 2, '901013754');

insert into replenishment_event values('8079544896855', 2, '91824', 'Mars Inc.', '17/4/2021', 4, '909025806');
insert into replenishment_event values('9535718049874', 1, '91824', 'Mars Inc.', '6/10/2022', 2, '906996794');

insert into replenishment_event values('8407837792023', 3, '84712', 'Seaga', '4/1/2022', 3, '901013754');
insert into replenishment_event values('9535718049874', 4, '84712', 'Seaga', '3/1/2022', 2, '901748680');

insert into replenishment_event values('7441503902471', 1, '91734', 'Paytec', '11/10/2021', 1, '902712215');
