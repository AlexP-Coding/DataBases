-- 7.1
SELECT DISTINCT R.nome
FROM retalhista R, responsavel_por P 
WHERE R.tin = P.tin and P. nome_cat = 'Frutos'

/* Assuminndo que as entradas de cada tabela são relativamente
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
 diminuindo-se o nr entradas a comparar/percorrer e por isso dimiuindo o tempo de execução 
*/
CREATE INDEX retailer_tin ON responsible_for USING hash(retailer_tin);
/*
 hash(tin) em responsavel_por: 
  Dessa forma, compara-se apenas os tin de responsavel_por 
	com o mesmo hash code (e, por isso, de menores sub-grupos da tabela) que o 
	dos tin do retalhista, 
	diminuindo-se o nr de entradas a comparar/percorrer e por isso dimiuindo o tempo de execução 
*/
CREATE INDEX retailer_tin ON retailer USING hash(retailer_tin);
/*
 hash(tin) seria preferível ao default btree(tin) em retalhista: 
  Dessa forma, compara-se apenas os tin de responsavel_por 
	com o mesmo hash code (e, por isso, de menores sub-grupos da tabela) que o 
	dos tin do retalhista,
	diminuindo-se o nr de entradas a comparar/percorrer e por isso dimiuindo o tempo de execução 
*/


-- 7.2
SELECT T.nome, count(T.ean)
FROM produto P, tem_categoria T
WHERE p.cat = T.nome and P.desc like 'A%' 
GROUP BY T.nome

CREATE INDEX category_name_index ON product USING hash(category_name); 
/*
 hash(cat) em produto: 
   usando a mesma hash function, facilita-se comparação p.cat = T.nome 
	e group by pois reduz-se apenas a comparação e a divisão do agrupamento
	a entradas com um mesmo hash code
*/
CREATE INDEX desc_index ON product USING hash(product_descr);
/*
 btree(desc) em produto: 
   reduz-se procura a entradas no ramo da árvore de palavras iniciadas 
	pelas primeiras k letras do alfabeto ('A' inclusive)
*/