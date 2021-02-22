USE dbProvaMutant2014
GO




INSERT INTO tbIngrediente (dsIngrediente) VALUES ('Alface'), ('Bacon'), ('Hambúrguer de carne'), ('Ovo'), ('Queijo');
GO


INSERT INTO tbIngredienteValor (idIngrediente, dtValor, vlValor) VALUES 
--1	Alface
(1, '2020-01-01', 0.35),
(1, '2021-01-01', 0.40),
--2	Bacon
(2, '2020-01-01', 1.90),
(2, '2021-01-01', 2.00),
--3	Hambúrguer de carne
(3, '2020-01-01', 2.90),
(3, '2021-01-01', 3.00),
--4	Ovo
(4, '2020-01-01', 0.80),
(4, '2021-01-01', 0.80),
--5	Queijo
(5, '2020-01-01', 1.40),
(5, '2021-01-01', 1.50);

GO


/*
--teste de ingrediente não mais ativo
--INSERT INTO tbIngrediente (dsIngrediente) VALUES ('Shimeji');
--INSERT INTO tbIngredienteValor (idIngrediente, dtValor, vlValor) VALUES (6, '2021-01-01', 3.00);
--UPDATE tbIngrediente SET flAtivo = 0 WHERE idIngrediente = 6
*/

--INSERT INTO tbCardapio (dsCardapio) VALUES ('X-Bacon'), ('X-Burger'),('X-Egg'),('X-Egg Bacon');
--INSERT INTO tbCardapio (dsCardapio) VALUES ('Lanche personalizado');
--UPDATE tbCardapio SET flPersonalizado = 1 WHERE idCardapio = 5



INSERT INTO tbCardapioIngrediente (idCardapio, idIngrediente, qtQuantidade) VALUES
--1	X-Bacon		-> Bacon, hambúrguer de carne e queijo		=> 2, 3 e 5		
(1, 2, 1),
(1, 3, 1),
(1, 5, 1),
--2	X-Burger	-> Hambúrguer de carne e queijo				=> 3 e 5				
(2, 3, 1),
(2, 5, 1),
--3	X-Egg		-> Ovo, hambúrguer de carne e queijo		=> 4, 3 e 5		
(3, 4, 1),
(3, 3, 1),
(3, 5, 1),
--4	X-Egg Bacon -> Ovo, bacon, hambúrguer de carne e queijo	=> 4, 2, 3 e 5	
(4, 4, 1),
(4, 2, 1),
(4, 3, 1),
(4, 5, 1);


/*
SELECT * FROM tbIngrediente (nolock);  
SELECT * FROM tbIngredienteValor (nolock);
SELECT idIngrediente, MAX(dtValor) AS dtUltimoValor FROM tbIngredienteValor (nolock) GROUP BY idIngrediente;


	
SELECT * FROM vwIngredienteValorAtual (nolock) ORDER BY idIngrediente

SELECT * FROM tbCardapio (nolock);  
SELECT * FROM tbCardapioIngrediente (nolock);  
SELECT * FROM vwCardapioIngrediente (nolock);  


---------------------------------------------------------------------

SELECT * FROM vwCardapioIngrediente	(nolock) ORDER BY idCardapio;


SELECT idCardapio, SUM(vlValorIngrediente) AS vlValorCardapio FROM vwCardapioIngrediente (nolock)	GROUP BY idCardapio;
*/

--SELECT * FROM vwCardapioIngredienteValor (nolock) ORDER BY idCardapio;


INSERT INTO tbPromocao (dsPromocao, dsRegra) VALUES
('Light', 'Se o lanche tem alface e não tem bacon, ganha 10% de desconto.'),
('Muita carne', 'A cada 3 porções de carne o cliente só paga 2. Se o lanche tiver 6 porções, o cliente pagará 4. Assim por diante...'),
('Muito queijo', 'A cada 3 porções de queijo o cliente só paga 2. Se o lanche tiver 6 porções, o cliente pagará 4. Assim por diante...');

/*
INSERT INTO tbPromocao (dsPromocao, dsRegra) VALUES
('Teste Ovo', 'Se o lanche tem ovo e não tem carne, ganha 20% de desconto.')

UPDATE tbPromocao SET flAtivo = 0 WHERE idPromocao = 4
*/

--SELECT * FROM tbPromocao (nolock) ORDER BY idPromocao

--SELECT * FROM tbIngrediente (nolock)


--1	Light	Se o lanche tem alface e não tem bacon, ganha 10% de desconto.
INSERT INTO tbPromocaoParametroIngrediente (idPromocao, idIngrediente, flTemNoPacote, qtDescontoPacote) VALUES (1, 1, 1, 10)
INSERT INTO tbPromocaoParametroIngrediente (idPromocao, idIngrediente, flNaoTemNoPacote, qtDescontoPacote) VALUES (1, 2, 1, 10)

--2	Muita carne	A cada 3 porções de carne o cliente só paga 2. Se o lanche tiver 6 porções, o cliente pagará 4. Assim por diante...
INSERT INTO tbPromocaoParametroIngrediente (idPromocao, idIngrediente, qtLeveX, qtPagueY) VALUES (2, 3, 3, 2)

--3	Muito queijo	A cada 3 porções de queijo o cliente só paga 2. Se o lanche tiver 6 porções, o cliente pagará 4. Assim por diante...
INSERT INTO tbPromocaoParametroIngrediente (idPromocao, idIngrediente, qtLeveX, qtPagueY) VALUES (3, 5, 3, 2)

--4	('Teste Ovo', 'Se o lanche tem ovo e não tem carne, ganha 20% de desconto.')
INSERT INTO tbPromocaoParametroIngrediente (idPromocao, idIngrediente, flTemNoPacote, qtDescontoPacote) VALUES (4, 4, 1, 20)
INSERT INTO tbPromocaoParametroIngrediente (idPromocao, idIngrediente, flNaoTemNoPacote, qtDescontoPacote) VALUES (4, 3, 1, 20)


/*
SELECT * FROM   tbPromocaoParametroIngrediente (nolock) 


EXEC sp_SEL_Cardapio 1
EXEC sp_SEL_Cardapio 2
EXEC sp_SEL_Cardapio 3
*/

