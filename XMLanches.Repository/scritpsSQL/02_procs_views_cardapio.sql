USE dbProvaMutant2014
GO



---------------------------------------------------------------------
GO
/***************************************************************************************/
CREATE VIEW vwIngredienteValorAtual 
/***************************************************************************************/
AS

	SELECT I.idIngrediente, I.dsIngrediente, V.vlValor
	FROM 
		--tabela de ingredientes 
		tbIngrediente (nolock) AS I 
	
		--tabela de valores de ingredientes (que podem ser alter�veis ao longo do tempo, por conta de infla��o, defla��o, varia��es do mercado etc.)
		INNER JOIN tbIngredienteValor (nolock) AS V  ON I.idIngrediente = V.idIngrediente 
	
		--agrupamento da tabela de valores atuais de ingredientes  (pega a �ltima "cota��o" do ingrediente da tabela de valores)
		INNER JOIN ( SELECT idIngrediente, MAX(dtValor) AS dtUltimoValor FROM tbIngredienteValor (nolock) GROUP BY idIngrediente ) AS U  ON V.idIngrediente = U.idIngrediente AND V.dtValor = U.dtUltimoValor

	WHERE I.flAtivo = 1;
GO
/***************************************************************************************/



--DROP VIEW vwCardapioIngrediente 
GO
/***************************************************************************************/
CREATE VIEW vwCardapioIngrediente 
/***************************************************************************************/
AS 
	
	SELECT	CA.idCardapio, CA.dsCardapio, 
		
			CI.idIngrediente, IG.dsIngrediente, 

			qtQuantidadeIngrediente = CI.qtQuantidade,  
			vlValorIngrediente = (IG.vlValor * CI.qtQuantidade),
			
			CA.flPersonalizado
	FROM 
		--tabela com nomes dos lanches
		tbCardapio (nolock) AS CA 

		--tabela com ingredientes de cada lanche
		INNER JOIN tbCardapioIngrediente (nolock) AS CI ON CA.idCardapio = CI.idCardapio 

		--view de ingredientes e seus valores
		INNER JOIN vwIngredienteValorAtual (nolock) AS IG ON CI.idIngrediente = IG.idIngrediente

	WHERE CA.flAtivo = 1

	UNION 

	SELECT  CP.idCardapio, CP.dsCardapio, 
			idIngrediente = 0, dsIngrediente = '', 
			qtQuantidade = 0,  vlValorIngrediente = 0,
			flPersonalizado
	FROM 
		--lanche personalziados
		tbCardapio (nolock) AS CP 
	WHERE CP.flPersonalizado = 1 AND CP.flAtivo = 1;

GO
/***************************************************************************************/



--DROP VIEW vwCardapioValor 
GO
/***************************************************************************************/
CREATE VIEW vwCardapioValor 
/***************************************************************************************/
AS 
	
	SELECT CA.idCardapio, CA.dsCardapio, VC.vlValorCardapio, CA.flPersonalizado
	FROM 
		--tabela do card�pio (apenas nomes)
		tbCardapio (nolock) AS CA	
		
		--agrupamento com valores dos ingredientes somados para cada item do card�pio
		INNER JOIN ( SELECT idCardapio, SUM(vlValorIngrediente) as vlValorCardapio FROM vwCardapioIngrediente (nolock) GROUP BY idCardapio ) AS VC ON CA.idCardapio = VC.idCardapio;

GO
/***************************************************************************************/


--DROP VIEW vwCardapioIngredienteValor 
GO
/***************************************************************************************/
CREATE VIEW vwCardapioIngredienteValor 
/***************************************************************************************/
AS 
	
	SELECT CA.idCardapio, CA.dsCardapio, CA.idIngrediente, CA.dsIngrediente, CA.qtQuantidadeIngrediente, CA.vlValorIngrediente , VC.vlValorCardapio, CA.flPersonalizado
	FROM 
		--view do card�pio (nomes + ingredientes)
		vwCardapioIngrediente (nolock) AS CA	
		
		--agrupamento com valores dos ingredientes somados para cada item do card�pio
		INNER JOIN ( SELECT idCardapio, SUM(vlValorIngrediente) as vlValorCardapio FROM vwCardapioIngrediente (nolock) GROUP BY idCardapio ) AS VC ON CA.idCardapio = VC.idCardapio;

GO
/***************************************************************************************/


--DROP PROCEDURE sp_SEL_Cardapio
GO
/***************************************************************************************/
CREATE PROCEDURE sp_SEL_Cardapio
/***************************************************************************************/
/*
proc que consulta dados do cardarpio ou dos ingredientes
*/
	  @opcao		tinyint  
	 /*
	 1 = consulta de lanches do card�pio (uma linha por lanche) 
	 2 = consulta de lanches do card�pio com seus ingredientes (cada lanche tem v�rias linhas: seus ingredientes)
	 3 = consulta de ingredientes (uma linha por ingrediente) 
	 */

	 ,@idCardapio	bigint = NULL /*opcional, passado apenas para op��o 2 */

AS BEGIN

	DECLARE @retorno TABLE (  [idCardapio]		 int
							 ,[dsCardapio]		 varchar(50)
							 ,[vlValorCardapio]	 numeric(10, 2)

							 ,[idIngrediente]			int
							 ,[dsIngrediente]			varchar(50)
							 ,[qtQuantidadeIngrediente]	int
							 ,[vlValorIngrediente]		numeric(10, 2)

							 ,[flPersonalizado]			bit
						  );


	------------- verifica op��o passada por par�metro ------------- 

	IF (@opcao = 1)
	BEGIN
		------------- 1 = consulta de lanches do card�pio (uma linha por lanche) ------------- 
		INSERT INTO @retorno 
				(idCardapio, dsCardapio, vlValorCardapio, flPersonalizado)
			SELECT 
				idCardapio, dsCardapio, vlValorCardapio, flPersonalizado 
			FROM vwCardapioValor (nolock);
		---------------------------------------------------------------------------------------
	END
	ELSE
	BEGIN
		IF (@opcao = 2)
		BEGIN
			------------- 2 = consulta de lanches do card�pio com seus ingredientes (cada lanche tem v�rias linhas: seus ingredientes) ------------- 
			INSERT INTO @retorno 
					(idCardapio, dsCardapio, vlValorCardapio, 
					idIngrediente, dsIngrediente, qtQuantidadeIngrediente, vlValorIngrediente, 
					flPersonalizado)
				SELECT 
					idCardapio, dsCardapio, vlValorCardapio, 
					idIngrediente, dsIngrediente, qtQuantidadeIngrediente, vlValorIngrediente,
					flPersonalizado 
				FROM vwCardapioIngredienteValor (nolock)
				WHERE idCardapio = ISNULL(@idCardapio, idCardapio); --se n�o for passado o di, traz trodos
			------------------------------------------------------------------------------------------------------------------------------------------
		END		
		ELSE
		BEGIN
			IF (@opcao = 3)
			BEGIN
				------------- 3 = consulta de ingredientes (uma linha por ingrediente) -------------
				INSERT INTO @retorno
						(idIngrediente, dsIngrediente, vlValorIngrediente)
					SELECT 
						idIngrediente, dsIngrediente, vlValor 
					FROM vwIngredienteValorAtual (nolock);
				------------------------------------------------------------------------------------
			END		
			ELSE
			BEGIN
				------------- op��o inexistente ------------- 
				RAISERROR('Op��o inv�lida', 16,1);          
				RETURN -1;          
			END
		END
	END

	--retorno da proc
	SELECT * FROM @retorno ORDER BY idCardapio, dsIngrediente;
	RETURN;

END
	
	
GO	
/***************************************************************************************/