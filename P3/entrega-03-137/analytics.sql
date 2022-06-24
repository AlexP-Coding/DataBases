-- Numero total de artigos vendidos:


--  Num dado período (i.e. entre duas datas), 
-- por dia da semana, por concelho e no total
SELECT sales.dia_semana, sales.concelho, SUM(sales.unidades)
FROM Vendas AS sales
WHERE sales.ano
BETWEEN 2021 AND 2022
GROUP BY CUBE(sales.dia_semana, sales.concelho);

--  Num dado distrito (i.e. 'Lisboa'), 
-- por concelho, categoria, dia da semana e no total
SELECT sales.concelho, sales.dia_semana, sales.cat, SUM(sales.unidades)
FROM Vendas AS sales
WHERE sales.distrito='Lisboa'
GROUP BY ROLLUP(sales.concelho, sales.dia_semana, sales.cat);