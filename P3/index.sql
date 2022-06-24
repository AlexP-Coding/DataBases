-- 7.1
SELECT DISTINCT R.nome
FROM retalhista R, responsavel_por P 
WHERE R.tin = P.tin and P. nome_cat = 'Frutos'

CREATE INDEX retailer_name_index ON retailer USING hash(retailer_name); 
/*
hash(nome) em retalhista: 
  no distinct compara apenas os valores no mesmo "contentor" 
 para ver se são iguais, diminuindo tempo de pesquisa
*/
CREATE INDEX category_name_index ON responsible_for USING hash(category_name);
/*
 hash(nome_cat) seria preferível ao default btree no responsavel_por: 
 dessa forma, comparava-se apenas os nome_cat com o mesmo hash code que 'Frutos'
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
	a itens com um mesmo hash code
*/
CREATE INDEX desc_index ON product USING hash(product_descr);
/*
 btree(desc) em produto: 
   reduz-se procura a itens no ramo da árvore de palavras iniciadas 
	pelas primeiras k letras do alfabeto ('A' inclusive)
*/