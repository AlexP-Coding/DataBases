-- 7.1
SELECT DISTINCT R.nome
FROM retalhista R, responsavel_por P 
WHERE R.tin = P.tin and P. nome_cat = 'Frutos'

/* Assumindo que as entradas de cada tabela são relativamente
estáticas e não há modificações frequentes:*/
CREATE INDEX retailer_name_index ON retailer USING hash(retailer_name); 
/*
hash(nome) em retalhista: 
  Em "DISTINCT", compara-se apenas os valores de igual hash code 
	(e, por isso, de menores sub-grupos da tabela) para ver se são iguais, 
	diminuindo tempo de execução
*/
CREATE INDEX category_name_index ON responsible_for USING hash(category_name);
/*
 hash(nome_cat) em responsavel_por: 
  Dessa forma, compara-se apenas categorias com o mesmo
 hash code (e, por isso, de menores sub-grupos da tabela) que 'Frutos', 
 diminuindo-se o número entradas a comparar/percorrer e por isso dimiuindo o tempo de execução 
*/
CREATE INDEX responsible_for_tin_index ON responsible_for USING hash(retailer_tin);
/*
 hash(tin) em responsavel_por: 
  Dessa forma, compara-se apenas os tin de responsavel_por 
	com o mesmo hash code (e, por isso, de menores sub-grupos da tabela) que o 
	dos tin do retalhista, 
	diminuindo-se o número de entradas a comparar/percorrer e por isso dimiuindo o tempo de execução 
*/
CREATE INDEX retailer_tin_index ON retailer USING hash(retailer_tin);
/*
 hash(tin) seria preferível ao default btree(tin) em retalhista: 
  Dessa forma, compara-se apenas os tin de responsavel_por 
	com o mesmo hash code (e, por isso, de menores sub-grupos da tabela) que o 
	dos tin do retalhista,
	diminuindo-se o número de entradas a comparar/percorrer e por isso dimiuindo o tempo de execução 
*/


-- 7.2
SELECT T.nome, count(T.ean)
FROM produto P, tem_categoria T
WHERE p.cat = T.nome and P.desc like 'A%' 
GROUP BY T.nome

CREATE INDEX product_category_name_index ON product USING hash(category_name); 
CREATE INDEX has_category_name_index ON has_category USING hash(category_name); 
/*
 hash(cat) em produto, hash(nome) em tem_categoria: 
   usando a mesma hash function, facilita-se comparação "P.cat = T.nome" 
	e "group by" pois reduz-se apenas a comparação e a divisão dos agrupamentos
	a entradas com um mesmo hash code (e, por isso, de menores sub-grupos das suas respetivas tabelas),
	diminuindo-se o número de entradas a comparar/percorrer e por isso dimiuindo o tempo de execução
*/
CREATE INDEX product_descr_index ON product(product_descr);
/*
 btree(desc) em produto: 
   Usando btree, reduz-se procura a entradas no ramo da árvore de palavras iniciadas 
	por 'A' que, sendo a primeira letra do alfabeto, é um ramo que não demora a ser encontrado;
	assim, diminui-se o número de entradas a comparar/percorrer e por isso dimiui-se o tempo de execução
*/