use dbProvaMutant2014
GO


--DROP VIEW vwPedidoCardapio
GO
/***************************************************************************************/
CREATE VIEW vwPedidoCardapio
/***************************************************************************************/
AS 

	SELECT 
		 PE.idPedido, PE.dtInicioPedido, PE.dtConclusaoPedido, PE.dsNomeChamada, PE.nuCPF, PE.vlPedido
		,PC.idPedidoCardapio
		,PC.idCardapio 
		,	CA.dsCardapio, CA.vlValorCardapio  AS vlValorUnitario
		,PC.qtQuantidade 
		,PC.vlValor 
		,PC.vlPromocao 
		,PC.vlValorFinal

		,PC.obsPromocao
		 
		FROM 
			--tabela de pedidos
			tbPedido (nolock) AS PE
		
			--tabela de itens de pedidos (usando LEFT para mostrar quando um pedido estiver sem itens)
			LEFT JOIN tbPedidoCardapio AS PC ON PE.idPedido = PC.idPedido
			
			--view de dados do card�pio (usando LEFT para mostrar quando um pedido estiver sem itens)
			LEFT JOIN vwCardapioValor (nolock) AS CA ON PC.idCardapio = CA.idCardapio

GO
/***************************************************************************************/


--DROP VIEW vwPedidoCardapioIngrediente
GO
/***************************************************************************************/
CREATE VIEW vwPedidoCardapioIngrediente
/***************************************************************************************/
AS 
	
	SELECT 
	
		 PE.idPedido --, PE.dtInicioPedido, PE.dtConclusaoPedido, PE.dsNomeChamada, PE.nuCPF, 
		,PE.vlPedido

		,PE.idPedidoCardapio
		,PE.idCardapio 
		,	PE.dsCardapio, PE.vlValorUnitario
		,PE.qtQuantidade 
		,PE.vlValor AS vlValorPersonalizado 
		,PE.vlPromocao 
		,PE.vlValorFinal

		,PE.obsPromocao

		,CI.idPedidoCardapioIngrediente
		,CI.idIngrediente
		,IG.dsIngrediente
		
		,CI.qtQuantidade				AS qtQuantidadeIngrediente
		,IG.vlValor						AS vlValorUnitarioIngrediente
		,(IG.vlValor * CI.qtQuantidade) AS vlValorIngredientePersonalizado

	FROM 
		--view com nomes dos lanches
		vwPedidoCardapio (nolock) AS PE

		--tabela com ingredientes de cada lanche (usando LEFT para mostrar quando um lanche personalizado estiver sem ingredientes)
		LEFT JOIN tbPedidoCardapioIngrediente (nolock) AS CI ON PE.idPedidoCardapio = CI.idPedidoCardapio 

		--view de ingredientes e seus valores (usando LEFT para mostrar quando um lanche personalizado estiver sem ingredientes)
		LEFT JOIN vwIngredienteValorAtual (nolock) AS IG ON CI.idIngrediente = IG.idIngrediente

	WHERE 
		--apenas lanches personalizados
		PE.idCardapio IN (SELECT TOP 1 idCardapio FROM tbCardapio (nolock) WHERE flPersonalizado = 1 ORDER BY idCardapio DESC);

GO
/***************************************************************************************/


--DROP FUNCTION fnRetornaSituacaoPedido
GO
/***************************************************************************************/
CREATE FUNCTION fnRetornaSituacaoPedido
/***************************************************************************************/
/*
function que retorna se um pedido existe ou n�o, se ainda est� em aberto ou n�o, se tem itens vinculados a ele ou n�o, e um texto de  mensagem (retorna em forma de uma tabela simples)
*/
	(@idPedido bigint)

RETURNS @retorno TABLE (flPedidoExistente bit, flPedidoAberto bit, flPedidoVazio bit, dsMensagem varchar(100))

BEGIN
	
	DECLARE @dtConclusaoPedido	datetime = NULL;

	------------ consulta registro do pedido ------------ 
	SELECT @dtConclusaoPedido = dtConclusaoPedido FROM tbPedido (nolock) WHERE idPedido = @idPedido;
	
	IF (@@ROWCOUNT = 0)
	BEGIN
		------------ n�o achou o pedido ------------ 
		INSERT INTO @retorno VALUES (0, NULL, NULL, 'Pedido n�o encontrado');
	END
	ELSE 
	BEGIN 		
		------------ verifica se tem data de conclus�o ------------ 
		DECLARE @flPedidoAberto bit = 0;
		IF (@dtConclusaoPedido IS NULL) SET @flPedidoAberto  = 1;

		------------ consulta se o pedido tem itens relacionados a ele ------------ 
		IF NOT EXISTS ( SELECT 1 FROM tbPedidoCardapio (nolock) WHERE idPedido = @idPedido)
			INSERT INTO @retorno VALUES (1, @flPedidoAberto, 1, 'Pedido sem itens adicionados');
		ELSE
			INSERT INTO @retorno VALUES (1, @flPedidoAberto, 0, IIF( @flPedidoAberto = 1, 'Pedido ainda em aberto', 'Pedido j� finalizado') );
	END

	RETURN;

END
GO
/***************************************************************************************/




--DROP FUNCTION fnVerificaItemPedido
GO
/***************************************************************************************/
CREATE FUNCTION fnVerificaItemPedido
/***************************************************************************************/
/*
function que verifica se aquele item do pedido pertence mesmo ao pedido
*/
	(@idPedido bigint, @idPedidoCardapio bigint)

RETURNS bit

BEGIN
	
	DECLARE @retorno bit = 0;

	------------ consulta se o item do pedido � mesmo daquele pedio  ------------ 
	IF EXISTS ( SELECT 1 FROM tbPedidoCardapio (nolock) WHERE idPedido = @idPedido AND idPedidoCardapio = @idPedidoCardapio )
		SET @retorno = 1;

	RETURN @retorno;

END
GO
/***************************************************************************************/


--DROP FUNCTION fnVerificaSituacaoPersonalizado
GO
/***************************************************************************************/
CREATE FUNCTION fnVerificaSituacaoPersonalizado
/***************************************************************************************/
/*
function que retorna se um item de pedido � ou n�o um lanche personalizado
*/
	(@idPedidoCardapio	bigint)

RETURNS bit

BEGIN
	
	DECLARE @retorno bit = 0;

	------------ consulta registro do item do pedido (que deve exsitir na base), ao mesmo tempo que verifica se � um lanche personalizado ------------ 
	IF (EXISTS (
		SELECT 1 
		FROM tbPedidoCardapio (nolock)
		WHERE idPedidoCardapio = @idPedidoCardapio
			AND idCardapio IN (SELECT TOP 1 idCardapio FROM tbCardapio (nolock) WHERE flPersonalizado = 1 ORDER BY idCardapio DESC)
		))
		SET @retorno = 1;
	
	RETURN @retorno;

END
GO

/***************************************************************************************/



--DROP FUNCTION fnRetornaPromocao
GO
/***************************************************************************************/
CREATE FUNCTION fnRetornaPromocao
/***************************************************************************************/
/*
function que retorna o valor do desconto  daquele lanche personalizado conforme as regras das promo��es
*/
	(@idPedidoCardapio	bigint)

RETURNS @retorno TABLE (vlPromocao numeric(10, 2), obsPromocao varchar(1024))

BEGIN

	--teste debug DECLARE @composicao TABLE (idIngrediente int, qtQuantidade int, vlValor numeric (10, 2))
	--INSERT INTO @composicao 
	--SELECT idIngrediente, qtQuantidade , vlValor FROM tbPedidoCardapioIngrediente (nolock) WHERE idPedidoCardapio = 60; 
	--SELECT @vlTotalComposicao = SUM(vlValor) FROM @composicao;
	--select @vlTotalComposicao, * from @composicao
	--teste debug declare @idPedidoCardapio bigint = 60;

	
	DECLARE @vlPromocaoParcial numeric(10, 2) = 0,  @vlPromocaoTotal numeric(10, 2) = 0
	DECLARE @obsPromocaoParcial varchar(1024) = NULL, @obsPromocaoTotal varchar(1024) = NULL;


	------------ traz dados daquela composi��o de lanche personalizado do pedido para uma vari�vel de mem�ria ------------ 
	DECLARE @composicao TABLE (idIngrediente int, qtQuantidade int, vlValor numeric (10, 2));
	INSERT INTO @composicao 
		SELECT idIngrediente, qtQuantidade, vlValor FROM tbPedidoCardapioIngrediente (nolock) WHERE idPedidoCardapio = @idPedidoCardapio; 


	--select * from tbPromocao (nolock)
	/*
	1	Light	Se o lanche tem alface e n�o tem bacon, ganha 10% de desconto.
	2	Muita carne	A cada 3 por��es de carne o cliente s� paga 2. Se o lanche tiver 6 por��es, ocliente pagar� 4. Assim por diante...
	3	Muito queijo	A cada 3 por��es de queijo o cliente s� paga 2. Se o lanche tiver 6 por��es, ocliente pagar� 4. Assim por diante...
	*/


	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------ verifica se encaixa na promo��o 2 "Muita carne" A cada 3 por��es de carne o cliente s� paga 2. Se o lanche tiver 6 por��es, o cliente pagar� 4. Assim por diante... -------------- 
	------------ verifica se encaixa na promo��o 3 "Muito queijo" A cada 3 por��es de queijo o cliente s� paga 2. Se o lanche tiver 6 por��es, o cliente pagar� 4. Assim por diante... ------------ 
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	--------- agrupado por ingrediente, levanta as quantidades de cada um, e quantas por��es entram ou n�o na regra do desconto "Leve X pague Y"
	DECLARE @qtRelacaoDescontoLevePague TABLE (idIngrediente int, qtSemDesconto int, qtComDesconto int, obsPromocao varchar(1024));
	INSERT INTO @qtRelacaoDescontoLevePague
		SELECT 
			CI.idIngrediente,
		
			--se � uma promo��o do tipo "Leve X pague Y", os m�ltiplos de X devem ser multiplicar por Y e dividir por X para se ter o desconto (ou seja, "desconsiderar" o Y a cada X alcan�ado) 
			--e como a promo��o considera os m�ltiplos (a "cada" Y comprado), o resto da divis�o Y/X n�o entra no desconto (pois n�o "chegou" no pr�ximo m�ltiplo, ou seja, n�o chegou na pr�xima promo��o), e o que entra no desconto, se aplica a raz�o do c�lculo
			qtSemDesconto = ( qtTotalIngrediente % qtLeveX ), 
			qtComDesconto = ( ( qtTotalIngrediente - ( qtTotalIngrediente % qtLeveX ) ) * PA.qtPagueY ) / PA.qtLeveX ,

			--apenas para informa��o, traz os textos das promo��es
			obsPromocao = PR.dsPromocao + ': ' + PR.dsRegra

		FROM 
			----- agrupa as quantidades dos ingredientes do lanche -----
			( SELECT idIngrediente, SUM(qtQuantidade) AS qtTotalIngrediente FROM @composicao GROUP BY idIngrediente ) AS CI 

			----- verifica se existe algum ingrediente que esteja configurado em alguma promo��o de "Leve X pague Y" -----
			INNER JOIN tbPromocaoParametroIngrediente (nolock) AS PA ON CI.idIngrediente = PA.idIngrediente AND PA.qtLeveX IS NOT NULL AND PA.qtPagueY IS NOT NULL

			----- cruza com tabela de promo��es -----
			INNER JOIN tbPromocao (nolock) AS PR ON PA.idPromocao = PR.idPromocao
	
		WHERE 
			-- verifica se � um promo��o ativa -----
			PR.flAtivo = 1

			-- e verifica se a quantidade encontrada no lacnhe � maior ou igual � quantidade de "Leve X" configurada
			AND CI.qtTotalIngrediente >= PA.qtLeveX;


	--------- cruza o resultado acima (que tem apenas as quantidades consideradas para o desconto)  --------- 
	DECLARE @vlRelacaoDescontoLevePague TABLE (idIngrediente int, vlSemDesconto numeric(10,2), vlComDesconto numeric(10,2), obsPromocao varchar(1024), vlTotalIngrediente numeric(10,2));		
	INSERT INTO @vlRelacaoDescontoLevePague
		SELECT 
			DS.idIngrediente,
			vlSemDesconto	= DS.qtSemDesconto * IG.vlValor,
			vlComDesconto	= DS.qtComDesconto * IG.vlValor,
			DS.obsPromocao,
			CI.vlTotalIngrediente
		FROM 
			@qtRelacaoDescontoLevePague DS

			---- com a view de ingredientes (para multiplicar por seus valores unit�rios) ---
			INNER JOIN vwIngredienteValorAtual (nolock) AS IG ON DS.idIngrediente = IG.idIngrediente

			---- com a somat�ria vinda orginalmente do pedido daquele ingrediente ---
			INNER JOIN (SELECT idIngrediente, SUM(vlValor) AS vlTotalIngrediente FROM @composicao GROUP BY idIngrediente) AS CI ON DS.idIngrediente = CI.idIngrediente;


	--------- com o resultado acima, soma para todos os ingredientes que entraram na regra os valores vindos dos c�lculos da promo��o;  e tira a diferen�a com o somat�ria vinda orginalmente do pedido daquele ingrediente------- 
	SELECT 
		@vlPromocaoParcial = SUM(vlTotalIngrediente) - ( SUM(vlSemDesconto) + SUM(vlComDesconto) )  
	FROM @vlRelacaoDescontoLevePague;

	--teste debug select * FROM @vlRelacaoDescontoLevePague;

	------- pega tamb�m a jun��o dos textos de todas as promo��es aplicadas -------------
	SELECT @obsPromocaoParcial = STRING_AGG(obsPromocao, ' | ')  FROM @vlRelacaoDescontoLevePague;

	--------- soma com os demais c�lculos de promo��es (considerando que s�o promo��es acumulativas) , al�m de concatenar os nomes das promo��es ------- 
	SET @vlPromocaoTotal  =  @vlPromocaoTotal  + ISNULL(@vlPromocaoParcial, 0); 
	SET @obsPromocaoTotal =  CONCAT_WS( ' | ', @obsPromocaoTotal, @obsPromocaoParcial ); 

	--teste debug select @vlPromocaoParcial

	------ adiciona no recordset em mem�ria uma linha com ingrediente "fake", mas apenas para lan�ar valor o desconto (que entrar� em c�lculos de somat�rias de outras regras) -----
	INSERT INTO @composicao SELECT 0, 0, ISNULL(@vlPromocaoParcial, 0) * (-1); 



	----------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------
	------------ verifica se encaixa na promo��o 1 "Light" Se o lanche tem alface e n�o tem bacon, ganha 10% de desconto. ------------ 
	----------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------


	----- faz um loop por todas configua��es do tipo "Tem ingrediente X mas n�o tem ingrediente Y " para poder testar uma a uma com os dados do lanche -----
	DECLARE @idPromocaoLoop int, @qtDescontoLoop numeric(5,2), @obsDescontoLoop varchar(1024);
	DECLARE @PromocaoPacote TABLE (idPromocao int, qtDescontoPacote numeric(5,2), obsDescontoLoop varchar(1024), foi bit);

	INSERT INTO @PromocaoPacote 
		SELECT 
			PA.idPromocao, 
			PA.qtDescontoPacote, 
			obsPromocao = PR.dsPromocao + ': ' + PR.dsRegra,
			foi = 0 
		FROM 
			--tabela de par�metros
			tbPromocaoParametroIngrediente (nolock) AS PA
			
			--tabela de promo��es
			INNER JOIN tbPromocao (nolock) AS PR ON PA.idPromocao = PR.idPromocao
		
		WHERE 
			-- pega apenas registros de configura��o referentes a "tem / n�o tem no pacote" -----
			(flTemNoPacote = 1 OR flNaoTemNoPacote = 1)  

			-- pega apenas promo��es ativas -----
			AND PR.flAtivo = 1

		GROUP BY PA.idPromocao, PA.qtDescontoPacote, (PR.dsPromocao + ': ' + PR.dsRegra);

	--loop pela tabela de mem�ria acima
	WHILE ( EXISTS (SELECT 1 FROM @PromocaoPacote WHERE foi = 0) )
	BEGIN
		
		--pega ID do pacote, percentual de desconto e texto da promo��o
		SELECT TOP 1 
			@idPromocaoLoop = idPromocao, 
			@qtDescontoLoop = qtDescontoPacote, 
			@obsDescontoLoop = obsDescontoLoop
		FROM @PromocaoPacote WHERE foi = 0;

		--- aplica regras destas configura��es do loop na recordset da composi��o do lanche ----
		DECLARE @flRegraTemNoPacote		bit = 0;
		DECLARE @flRegraNaoTemNoPacote	bit = 0;

		IF EXISTS ( SELECT 1 FROM 
						---- composi��o do lanche ----
						@composicao AS CI 

						----- cruza os ingredientes com as configura��es de EXISTE daquela promo��o do loop -----
						INNER JOIN tbPromocaoParametroIngrediente (nolock) AS PA 
							ON CI.idIngrediente = PA.idIngrediente AND 
							PA.idPromocao = @idPromocaoLoop AND 
							PA.flTemNoPacote = 1)
		BEGIN	
			SET @flRegraTemNoPacote = 1;
		END

		IF NOT EXISTS ( SELECT 1 FROM 
						---- composi��o do lanche ----
						@composicao AS CI 

						----- cruza os ingredientes com as configura��es de N�O EXISTE daquela promo��o do loop -----
						INNER JOIN tbPromocaoParametroIngrediente (nolock) AS PA 
							ON CI.idIngrediente = PA.idIngrediente AND 
							PA.idPromocao = @idPromocaoLoop AND 
							PA.flNaoTemNoPacote = 1)
		BEGIN	
			SET @flRegraNaoTemNoPacote = 1;
		END

		------ se as duas regras deram TRUE (existe um e n�o existe o outro) -----
		IF (@flRegraTemNoPacote = 1 AND @flRegraNaoTemNoPacote = 1)
		BEGIN

			--- traz o valor total da composi��o do lanche ----
			DECLARE @vlTotalComposicao numeric(10, 2)= 0;
			SELECT @vlTotalComposicao = SUM(vlValor) FROM @composicao;

			--- � calculado o desconto percentual, al�m de pegar o texto da promo��o  ----
			SET @vlPromocaoParcial = CONVERT(numeric(10, 2), @vlTotalComposicao * (@qtDescontoLoop / 100));
			SET @obsPromocaoParcial = @obsDescontoLoop;

			--------- soma com os demais c�lculos de promo��es (considerando que s�o promo��es acumulativas) , al�m de concatenar os nomes das promo��es ------- 
			SET @vlPromocaoTotal  =  @vlPromocaoTotal  + ISNULL(@vlPromocaoParcial, 0); 
			SET @obsPromocaoTotal =  CONCAT_WS( ' | ', @obsPromocaoTotal, @obsPromocaoParcial ); 

			--teste debug select @vlPromocaoParcial
			
			------ adiciona no recordset em mem�ria uma linha com ingrediente "fake", mas apenas para lan�ar valor o desconto (que entrar� em c�lculos de somat�rias de outras regras) -----
			INSERT INTO @composicao SELECT 0, 0, ISNULL(@vlPromocaoParcial, 0) * (-1); 

		END

		
		--pr�xima volta do loop
		UPDATE @PromocaoPacote SET foi = 1 WHERE idPromocao = @idPromocaoLoop;
	END




	---------------------------------------------------------------------------------------------------------------------------------------------------
	-------- retorna o valor do desconto (descontos, por pode ser acumulativo) daquele lanche junto com um texto com nos nomes das promo��es ----------
	---------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO @retorno VALUES (@vlPromocaoTotal, @obsPromocaoTotal);

	RETURN;

END
GO

/***************************************************************************************/




--DROP PROCEDURE sp_INS_UPD_Pedido
GO
/***************************************************************************************/
CREATE PROCEDURE sp_INS_UPD_Pedido
/***************************************************************************************/
/*
proc que "abre" um novo pedido e recupera o registro rec�m criado (com seu n�mero) ou finaliza um pedido existente e retorna o recordset do pedido e seus itens
*/
	 @opcao			tinyint  /*1 = inserir, 3 = finalizar */

	/*par�metro usado em 1 = inserir*/
	,@dtInicioPedido	datetime		= NULL

	/*par�metros usado em 3 = finalizar*/
	,@idPedido				bigint		= NULL
	,@dtConclusaoPedido		datetime	= NULL

	/*par�metros opcionais usados em ambas op��es*/
	,@dsNomeChamada			varchar(50) = NULL
	,@nuCPF					varchar(14) = NULL

AS BEGIN

	------------- verifica op��o passada por par�metro ------------- 
	DECLARE @msgSucesso varchar(100), @count bigint;


	IF (@opcao = 1)  /*1 = inserir*/
	BEGIN

		------------- preenche data se for null ------------- 
		IF (@dtInicioPedido IS NULL) SET @dtInicioPedido = GETDATE();

		------------- realiza a inser��o na base com daquela data (e dos outros campos, se passados) e recupera o ID criado ------------- 
		BEGIN TRAN
			INSERT INTO tbPedido 
			(dtInicioPedido, dsNomeChamada, nuCPF) VALUES 
			(@dtInicioPedido, @dsNomeChamada, @nuCPF);

			SELECT @idPedido = @@IDENTITY, @count = @@ROWCOUNT;
		COMMIT

		------------- verifica se deu erro ------------- 
		IF (@@ERROR <> 0)
		BEGIN          
			ROLLBACK;
			RAISERROR('Erro ao criar novo pedido', 16,1);          
			RETURN -1;          
		END          
		ELSE
		BEGIN
			IF (@count = 0) 
			BEGIN
				RAISERROR('Erro ao criar novo pedido', 16,1);          
				RETURN -1;          
			END
			ELSE
				SET @msgSucesso = 'Novo pedido criado com sucesso';
		END

	END	
	ELSE
	BEGIN
		IF (@opcao = 3)  /*3 = finalizar*/
		BEGIN

			------------- verifica par�metros ------------- 
			IF (@idPedido IS NULL) 
			BEGIN
				RAISERROR('Pedido a finalizar n�o informado', 16,1);          
				RETURN -1;          
			END

			------------- preenche data se for null ------------- 
			IF (@dtConclusaoPedido IS NULL) SET @dtConclusaoPedido = GETDATE();
		
			
			------------- verifica se pedido existe, se j� foi fechado ou se tem n�o itens adicionados (n�o se pode finalizar um pedido nestas condi��es) ------------- 
			DECLARE @flPedidoExistente bit, @flPedidoAberto bit, @flPedidoVazio bit, @dsMensagem varchar(100);
			SELECT  @flPedidoExistente  = flPedidoExistente,
					@flPedidoAberto		= flPedidoAberto, 
					@flPedidoVazio		= flPedidoVazio,
					@dsMensagem			= dsMensagem FROM dbo.fnRetornaSituacaoPedido(@idPedido);

			IF (@flPedidoExistente = 0 OR @flPedidoAberto = 0 OR @flPedidoVazio = 1) 
			BEGIN
				RAISERROR(@dsMensagem, 16,1);          
				RETURN -1;          
			END


			------------- atualiza na base de pedido com aquela data (os demais campos apenas atualizar se tiverem foam passados por par�metros, se n�o, mant�m o que tem na base) ------------- 
			BEGIN TRAN
				UPDATE tbPedido SET 
								 dtConclusaoPedido	= @dtConclusaoPedido 
								,dsNomeChamada		= IIF(@dsNomeChamada IS NOT NULL, @dsNomeChamada, dsNomeChamada)
								,nuCPF				= IIF(@nuCPF		 IS NOT NULL, @nuCPF,		  nuCPF)
				WHERE idPedido = @idPedido;

				SET @count = @@ROWCOUNT;
			COMMIT

			------------- verifica se deu erro ------------- 
			IF (@@ERROR <> 0)
			BEGIN          
				ROLLBACK;
				RAISERROR('Erro ao finalizar pedido', 16,1);          
				RETURN -1;          
			END          
			ELSE
			BEGIN
				IF (@count = 0) 
				BEGIN
					RAISERROR('Erro ao finalizar novo pedido', 16,1);          
					RETURN -1;          
				END
				ELSE
					SET @msgSucesso = 'Pedido finalizado com sucesso';
			END
			
		END
		ELSE
		BEGIN
			------------- op��o inexistente ------------- 
			RAISERROR('Op��o inv�lida', 16,1);          
			RETURN -1;          
		END

	END

	------------- mensagem de sucesso junto com o recordset com o pedido (e seus itens quando for finaliza��o) ------------- 
	SELECT mensagem = @msgSucesso, * FROM vwPedidoCardapio (nolock) WHERE idPedido = @idPedido;
	RETURN;

END

GO
/***************************************************************************************/


--DROP PROCEDURE sp_INS_DEL_PedidoCardapio
GO
/***************************************************************************************/
CREATE PROCEDURE sp_INS_DEL_PedidoCardapio
/***************************************************************************************/
/*
proc que insere OU apaga um item do card�pio ao pedido e retorna um recordset com os itens do pedido at� ent�o
*/
	 @opcao			tinyint  /*1 = inserir, 2 = deletar*/

	 /*par�metro usado em ambas op��es*/
	,@idPedido			bigint

	/*par�metros usados em 1 = inserir*/
	,@idCardapio		int	= NULL
	,@qtQuantidade		int	= NULL

	/*par�metros usados em 2 = deletar*/
	,@idPedidoCardapio	int	= NULL
	,@flLimpaTodoPedido bit = 0		--se este par�metro � passado, limpa todos os itens daquele pedido ("reinicia")

AS BEGIN

	------------- verifica se o pedido existe e se j� foi fechado (n�o se pode mexer num pedido se for o caso) ------------- 
	DECLARE @flPedidoExistente bit , @flPedidoAberto bit, @flPedidoVazio	bit, @dsMensagem varchar(100);
	SELECT  @flPedidoExistente  = flPedidoExistente,
			@flPedidoAberto		= flPedidoAberto, 
			@flPedidoVazio		= flPedidoVazio,
			@dsMensagem			= dsMensagem FROM dbo.fnRetornaSituacaoPedido(@idPedido);

	IF (@flPedidoExistente = 0 OR @flPedidoAberto = 0) 
	BEGIN
		RAISERROR(@dsMensagem, 16,1);          
		RETURN -1;          
	END

	------------- verifica op��o passada por par�metro ------------- 
	DECLARE @msgSucesso varchar(100), @count bigint;

	IF (@opcao = 2)  /*2 = deletar*/
	BEGIN 

			------------- verifica se o item passado por par�metro faz parte mesmo do pedido ------------- 
			IF (dbo.fnVerificaItemPedido (@idPedido, @idPedidoCardapio)  = 0)
			BEGIN
				RAISERROR('Item do pedido n�o pertence ao pedido', 16,1);          
				RETURN -1;          
			END

			------------- verifica se pedido tem algum item adicionado  ------------- 
			IF (@flPedidoVazio = 1) 
			BEGIN
				RAISERROR(@dsMensagem, 16,1);          
				RETURN -1;          
			END

			------------- verifica par�metros ------------- 
			IF (@idPedidoCardapio IS NULL AND @flLimpaTodoPedido = 0) 
			BEGIN
				RAISERROR('Item do pedido a excluir n�o informado', 16,1);          
				RETURN -1;          
			END

			------------- realiza a dele��o na base (daquele item ou de todos do pedido) ------------- 
			BEGIN TRAN
				IF (@flLimpaTodoPedido = 0)
					DELETE FROM tbPedidoCardapio WHERE  idPedidoCardapio = @idPedidoCardapio;
				ELSE
					DELETE FROM tbPedidoCardapio WHERE  idPedido		 = @idPedido;

				SET @count = @@ROWCOUNT;
			COMMIT

			------------- verifica se deu erro ------------- 
			IF (@@ERROR <> 0)
			BEGIN          
				ROLLBACK;
				RAISERROR('Erro ao excluir item do pedido', 16,1);          
				RETURN -1;          
			END          
			ELSE
			BEGIN
				IF (@count = 0) 
				BEGIN
					RAISERROR('Nenhum item do card�pio foi exclu�do do pedido', 16,1);          
					RETURN -1;          
				END
				ELSE
					SET @msgSucesso = 'Item do card�pio exclu�do do pedido com sucesso';
			END

	END
	ELSE 
	BEGIN

		IF (@opcao = 1)  /*1 = inserir*/
		BEGIN

			------------- verifica par�metros ------------- 
			IF (@idCardapio IS NULL OR @qtQuantidade IS NULL OR @idCardapio = 0 OR @qtQuantidade = 0) 
			BEGIN
				RAISERROR('Informa��es do card�pio escolhido n�o informadas', 16,1);          
				RETURN -1;          
			END

			------------- consulta valor do ingrediente ------------- 
			DECLARE @vlValorLinha numeric(10,2);
			SELECT @vlValorLinha = vlValorCardapio FROM vwCardapioValor (nolock) WHERE idCardapio = @idCardapio;
			SET @vlValorLinha = @qtQuantidade * @vlValorLinha; 

			------------- realiza a inser��o na base -------------
			BEGIN TRAN
				INSERT INTO tbPedidoCardapio 
				(idPedido,	idCardapio,  qtQuantidade,  vlValor,	   vlPromocao,  vlValorFinal) VALUES 
				(@idPedido, @idCardapio, @qtQuantidade, @vlValorLinha, 0,			@vlValorLinha);

				SET @count = @@ROWCOUNT;
			COMMIT

			------------- verifica se deu erro ------------- 
			IF (@@ERROR <> 0)
			BEGIN          
				ROLLBACK;
				RAISERROR('Erro ao inserir item do card�pio ao pedido', 16,1);          
				RETURN -1;          
			END
			ELSE
			BEGIN
				IF (@count = 0) 
				BEGIN
					RAISERROR('Erro ao inserir item do card�pio ao pedido', 16,1);          
					RETURN -1;          
				END
				ELSE
					SET @msgSucesso = 'Item do card�pio inserido ao pedido com sucesso';
			END
       
		END
		ELSE
		BEGIN
			------------- op��o inexistente ------------- 
			RAISERROR('Op��o inv�lida', 16,1);          
			RETURN -1;          
		END

	END

	------------- ap�s inserir ou apagar, consulta itens daquele pedido atualizados e joga em tabela de mem�ria ------------- 
	DECLARE @linhas TABLE (  [idPedido]			 bigint
							,[dtInicioPedido]	 datetime
							,[dtConclusaoPedido] datetime
							,[dsNomeChamada]	 varchar(50)
							,[nuCPF]			 varchar(14)
							,[vlPedido]			 numeric(10, 2)
												 
							,[idPedidoCardapio]	 bigint
							,[idCardapio]		 int
							,[dsCardapio]		 varchar(50)
							,[vlValorUnitario]	 numeric(10, 2)
							
							,[qtQuantidade]		 int
							,[vlValor]			 numeric(10, 2)
							,[vlPromocao]		 numeric(10, 2) 
							,[vlValorFinal]		 numeric(10, 2)

							,[obsPromocao]		 varchar(1024)
						  );
	INSERT INTO @linhas	SELECT * FROM vwPedidoCardapio (nolock) WHERE idPedido = @idPedido;

	------------- soma todos os itens daquele pedido ------------- 
	DECLARE @vlValorTotal numeric(10,2);
	SELECT @vlValorTotal = SUM(vlValor) FROM @linhas;

	------------- atualiza valor total daquele pedido, bem como o recordset de sa�da ------------- 
	BEGIN TRAN
		UPDATE @linhas	SET vlPedido = @vlValorTotal;
		UPDATE tbPedido SET vlPedido = ISNULL(@vlValorTotal, 0) WHERE idPedido = @idPedido;
	COMMIT

	------------- verifica se deu erro ------------- 
	IF (@@ERROR <> 0)
	BEGIN          
		ROLLBACK;
		RAISERROR('Erro ao recalcular valor do pedido', 16,1);          
		RETURN -1;          
	END          

	------------- mensagem de sucesso junto com o recordset com o pedido e seus itens atualizados ------------- 
	SELECT mensagem = @msgSucesso, * FROM @linhas	
	RETURN;

END

GO

/***************************************************************************************/



--DROP PROCEDURE sp_INS_DEL_PersonalizadoIngrediente
GO
/***************************************************************************************/
CREATE PROCEDURE sp_INS_DEL_PersonalizadoIngrediente
/***************************************************************************************/
/*
proc que insere ou apaga um ingrediente a um lanche personalizado do pedido, atualiza o pedido e retorna um recordset os ingredientes do lanche at� ent�o
*/
	 @opcao				tinyint  /*1 = inserir, 2 = deletar*/
	
	 /*par�metros usados em ambas op��es*/	 
	,@idPedido			bigint
	,@idPedidoCardapio	bigint

	/*par�metros usados em 1 = inserir*/
	,@idIngrediente					int		= NULL
	,@qtQuantidade					int		= NULL

	/*par�metro usado em 2 = deletar*/
	,@idPedidoCardapioIngrediente	bigint = NULL
	,@flLimpaTodoLanche bit = 0		--se este par�metro � passado, retira todos os ingredientes daquele lanche ("reinicia")

AS BEGIN


	------------- verifica se o item passado por par�metro faz parte mesmo do pedido ------------- 
	IF (dbo.fnVerificaItemPedido (@idPedido, @idPedidoCardapio)  = 0)
	BEGIN
		RAISERROR('Item do pedido n�o pertence ao pedido', 16,1);          
		RETURN -1;          
	END

	------------- verifica se o pedido existe e se j� foi fechado (n�o se pode mexer num pedido se for o caso) ------------- 
	DECLARE @flPedidoExistente bit, @flPedidoAberto bit, @dsMensagem varchar(100);
	SELECT  @flPedidoExistente  = flPedidoExistente,
			@flPedidoAberto		= flPedidoAberto, 
			@dsMensagem			= dsMensagem FROM dbo.fnRetornaSituacaoPedido(@idPedido);

	IF (@flPedidoExistente = 0 OR @flPedidoAberto = 0) 
	BEGIN
		RAISERROR(@dsMensagem, 16,1);          
		RETURN -1;          
	END

	------------- verifica se o item do � um um lanche personalizado ------------- 
	DECLARE @flLanchePersonalizado bit = 0;
	SET @flLanchePersonalizado = dbo.fnVerificaSituacaoPersonalizado(@idPedidoCardapio);
	IF (@flLanchePersonalizado  = 0)
	BEGIN
		RAISERROR('O lanche escolhido n�o pode ser personalizado', 16,1);          
		RETURN -1;          
	END

	------------- verifica op��o passada por par�metro ------------- 
	DECLARE @msgSucesso varchar(100), @erro bigint, @count bigint;

	IF (@opcao = 2)  /*2 = deletar*/
	BEGIN 

			------------- verifica par�metros ------------- 
			IF (@idPedidoCardapioIngrediente IS NULL AND @flLimpaTodoLanche = 0) 
			BEGIN
				RAISERROR('Ingrediente do lanche a excluir n�o informado', 16,1);          
				RETURN -1;          
			END

			------------- realiza a dele��o na base (daquele igrediente ou de todos do lanche)------------- 
			BEGIN TRAN
				IF (@flLimpaTodoLanche = 0)
					DELETE FROM tbPedidoCardapioIngrediente WHERE  idPedidoCardapioIngrediente = @idPedidoCardapioIngrediente;
				ELSE
					DELETE FROM tbPedidoCardapioIngrediente WHERE  idPedidoCardapio			   = @idPedidoCardapio;
				SET @count = @@ROWCOUNT;

			COMMIT

			------------- verifica se deu erro ------------- 
			IF (@@ERROR <> 0)
			BEGIN          
				ROLLBACK;
				RAISERROR('Erro ao retirar ingrediente do lanche personalizado', 16,1);          
				RETURN -1;          
			END   
			ELSE
			BEGIN
				IF (@count = 0) 
				BEGIN
					RAISERROR('Nenhum ingrediente foi retirado do lanche personalizado', 16,1);          
					RETURN -1;          
				END
				ELSE
					SET @msgSucesso = 'Ingrediente retirado do lanche personalizado com sucesso';
			END

	END
	ELSE 
	BEGIN

		IF (@opcao = 1)  /*1 = inserir*/
		BEGIN

			------------- verifica par�metros ------------- 
			IF (@idIngrediente IS NULL OR @qtQuantidade IS NULL) 
			BEGIN
				RAISERROR('Informa��es do ingrediente escolhido n�o informadas', 16,1);          
				RETURN -1;          
			END

			------------- consulta valor do ingrediente ------------- 
			DECLARE @vlValorIngrediente numeric(10,2);
			SELECT @vlValorIngrediente = vlValor FROM vwIngredienteValorAtual (nolock) WHERE idIngrediente = @idIngrediente;
			SET @vlValorIngrediente = @qtQuantidade * @vlValorIngrediente; 

			------------- realiza a inser��o na base -------------
			BEGIN TRAN
				INSERT INTO tbPedidoCardapioIngrediente 
				(idPedidoCardapio,	idIngrediente,  qtQuantidade,  vlValor) VALUES 
				(@idPedidoCardapio, @idIngrediente, @qtQuantidade, @vlValorIngrediente);

				SET @count = @@ROWCOUNT;
			COMMIT

			------------- verifica se deu erro ------------- 
			IF (@@ERROR <> 0)
			BEGIN          
				ROLLBACK;
				RAISERROR('Erro ao inserir ingrediente do lanche personalizado', 16,1);          
				RETURN -1;          
			END          
			ELSE
			BEGIN
				IF (@count = 0) 
				BEGIN
					RAISERROR('Erro ao inserir ingrediente do lanche personalizado', 16,1);          
					RETURN -1;          
				END
				ELSE
					SET @msgSucesso = 'Ingrediente inserido ao lanche personalizado com sucesso';
			END
	
		END
		ELSE
		BEGIN
			------------- op��o inexistente ------------- 
			RAISERROR('Op��o inv�lida', 16,1);          
			RETURN -1;          
		END

	END

	------------- ap�s inserir ou apagar, consulta ingredientes daquele lanche atualizados e joga em tabela de mem�ria ------------- 
	DECLARE @composicao TABLE ( [idPedido]				bigint
								,[vlPedido]				numeric(10, 2)

								,[idPedidoCardapio]		bigint
								,[idCardapio]			int
								,[dsCardapio]			varchar(50)
								,[vlValorUnitario]		numeric(10, 2)

								,[qtQuantidade]			int
								,[vlValorPersonalizado]	numeric(10, 2)
								,[vlPromocao]			numeric(10, 2) 
								,[vlValorFinal]			numeric(10, 2)

								,[obsPromocao]			varchar(1024)

								,[idPedidoCardapioIngrediente]		bigint
								,[idIngrediente]					int
								,[dsIngrediente]					varchar(50)
								,[qtQuantidadeIngrediente]			int
								,[vlValorUnitarioIngrediente]		numeric(10, 2)
								,[vlValorIngredientePersonalizado]	numeric(10, 2)
							);
	INSERT INTO @composicao	SELECT * FROM vwPedidoCardapioIngrediente (nolock) WHERE idPedidoCardapio = @idPedidoCardapio;

	------------- soma todos os ingredientes daquela personaliza��o ------------- 
	DECLARE @vlValorLanche numeric(10,2);
	SELECT @vlValorLanche = SUM(vlValorIngredientePersonalizado) FROM @composicao;

	------------- calcula se entra em alguma promo��o (ou em mais de uma, se forem acumulativas) ------------- 
	DECLARE @vlValorPromocao numeric(10,2), @obsPromocao varchar(1024);
	SELECT @vlValorPromocao = vlPromocao, @obsPromocao = obsPromocao  FROM  dbo.fnRetornaPromocao(@idPedidoCardapio);

	------------- atualiza valor total daquele lanche, bem como o recordset de sa�da ------------- 
	BEGIN TRAN
		UPDATE @composicao	SET vlValorPersonalizado = ISNULL(@vlValorLanche, 0), 
								vlPromocao			 = ISNULL(@vlValorPromocao, 0), 
								obsPromocao			 = @obsPromocao, 
								vlValorFinal		 = ISNULL(@vlValorLanche, 0) - ISNULL(@vlValorPromocao, 0);

		UPDATE tbPedidoCardapio SET vlValor		 = ISNULL(@vlValorLanche, 0), 
									vlPromocao	 = ISNULL(@vlValorPromocao, 0), 
									obsPromocao	 = @obsPromocao, 
									vlValorFinal = ISNULL(@vlValorLanche, 0) -ISNULL(@vlValorPromocao, 0)  
								WHERE idPedidoCardapio = @idPedidoCardapio;
	COMMIT

	------------- verifica se deu erro ------------- 
	IF (@@ERROR <> 0)
	BEGIN          
		ROLLBACK;
		RAISERROR('Erro ao recalcular valor do lanche personalizado', 16,1);          
		RETURN -1;          
	END          

	------------- soma todos os itens daquele pedido ------------- 
	DECLARE @vlValorTotal numeric(10,2);
	SELECT @vlValorTotal = SUM(vlValor) FROM vwPedidoCardapio (nolock) WHERE idPedido = @idPedido;

	------------- atualiza valor total daquele pedido, bem como o recordset de sa�da ------------- 
	BEGIN TRAN
		UPDATE @composicao	SET vlPedido = @vlValorTotal;
		UPDATE tbPedido SET vlPedido = ISNULL(@vlValorTotal, 0) WHERE idPedido = @idPedido;
	COMMIT

	------------- verifica se deu erro ------------- 
	IF (@@ERROR <> 0)
	BEGIN          
		ROLLBACK;
		RAISERROR('Erro ao recalcular valor do pedido', 16,1);          
		RETURN -1;          
	END          

	------------- mensagem de sucesso junto com o recordset com o pedido e seus itens atualizados ------------- 
	SELECT mensagem = @msgSucesso, * FROM @composicao	
	RETURN;

END

GO 
/***************************************************************************************/

