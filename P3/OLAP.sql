SELECT sales.dia_semana, sales.concelho, SUM(sales.unidades)
FROM Vendas AS sales
WHERE sales.ano
BETWEEN 2021 AND 2022
GROUP BY CUBE(sales.dia_semana, sales.concelho);

SELECT sales.concelho, sales.dia_semana, sales.cat, SUM(sales.unidades)
FROM Vendas AS sales
WHERE sales.distrito='Lisboa'
GROUP BY ROLLUP(sales.concelho, sales.dia_semana, sales.cat);