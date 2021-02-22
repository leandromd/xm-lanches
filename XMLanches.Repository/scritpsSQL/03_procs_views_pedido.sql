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
			
			--view de dados do cardápio (usando LEFT para mostrar quando um pedido estiver sem itens)
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
function que retorna se um pedido existe ou não, se ainda está em aberto ou não, se tem itens vinculados a ele ou não, e um texto de  mensagem (retorna em forma de uma tabela simples)
*/
	(@idPedido bigint)

RETURNS @retorno TABLE (flPedidoExistente bit, flPedidoAberto bit, flPedidoVazio bit, dsMensagem varchar(100))

BEGIN
	
	DECLARE @dtConclusaoPedido	datetime = NULL;

	------------ consulta registro do pedido ------------ 
	SELECT @dtConclusaoPedido = dtConclusaoPedido FROM tbPedido (nolock) WHERE idPedido = @idPedido;
	
	IF (@@ROWCOUNT = 0)
	BEGIN
		------------ não achou o pedido ------------ 
		INSERT INTO @retorno VALUES (0, NULL, NULL, 'Pedido não encontrado');
	END
	ELSE 
	BEGIN 		
		------------ verifica se tem data de conclusão ------------ 
		DECLARE @flPedidoAberto bit = 0;
		IF (@dtConclusaoPedido IS NULL) SET @flPedidoAberto  = 1;

		------------ consulta se o pedido tem itens relacionados a ele ------------ 
		IF NOT EXISTS ( SELECT 1 FROM tbPedidoCardapio (nolock) WHERE idPedido = @idPedido)
			INSERT INTO @retorno VALUES (1, @flPedidoAberto, 1, 'Pedido sem itens adicionados');
		ELSE
			INSERT INTO @retorno VALUES (1, @flPedidoAberto, 0, IIF( @flPedidoAberto = 1, 'Pedido ainda em aberto', 'Pedido já finalizado') );
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

	------------ consulta se o item do pedido é mesmo daquele pedio  ------------ 
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
function que retorna se um item de pedido é ou não um lanche personalizado
*/
	(@idPedidoCardapio	bigint)

RETURNS bit

BEGIN
	
	DECLARE @retorno bit = 0;

	------------ consulta registro do item do pedido (que deve exsitir na base), ao mesmo tempo que verifica se é um lanche personalizado ------------ 
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
function que retorna o valor do desconto  daquele lanche personalizado conforme as regras das promoções
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


	------------ traz dados daquela composição de lanche personalizado do pedido para uma variável de memória ------------ 
	DECLARE @composicao TABLE (idIngrediente int, qtQuantidade int, vlValor numeric (10, 2));
	INSERT INTO @composicao 
		SELECT idIngrediente, qtQuantidade, vlValor FROM tbPedidoCardapioIngrediente (nolock) WHERE idPedidoCardapio = @idPedidoCardapio; 


	--select * from tbPromocao (nolock)
	/*
	1	Light	Se o lanche tem alface e não tem bacon, ganha 10% de desconto.
	2	Muita carne	A cada 3 porções de carne o cliente só paga 2. Se o lanche tiver 6 porções, ocliente pagará 4. Assim por diante...
	3	Muito queijo	A cada 3 porções de queijo o cliente só paga 2. Se o lanche tiver 6 porções, ocliente pagará 4. Assim por diante...
	*/


	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------ verifica se encaixa na promoção 2 "Muita carne" A cada 3 porções de carne o cliente só paga 2. Se o lanche tiver 6 porções, o cliente pagará 4. Assim por diante... -------------- 
	------------ verifica se encaixa na promoção 3 "Muito queijo" A cada 3 porções de queijo o cliente só paga 2. Se o lanche tiver 6 porções, o cliente pagará 4. Assim por diante... ------------ 
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	--------- agrupado por ingrediente, levanta as quantidades de cada um, e quantas porções entram ou não na regra do desconto "Leve X pague Y"
	DECLARE @qtRelacaoDescontoLevePague TABLE (idIngrediente int, qtSemDesconto int, qtComDesconto int, obsPromocao varchar(1024));
	INSERT INTO @qtRelacaoDescontoLevePague
		SELECT 
			CI.idIngrediente,
		
			--se é uma promoção do tipo "Leve X pague Y", os múltiplos de X devem ser multiplicar por Y e dividir por X para se ter o desconto (ou seja, "desconsiderar" o Y a cada X alcançado) 
			--e como a promoção considera os múltiplos (a "cada" Y comprado), o resto da divisão Y/X não entra no desconto (pois não "chegou" no próximo múltiplo, ou seja, não chegou na próxima promoção), e o que entra no desconto, se aplica a razão do cálculo
			qtSemDesconto = ( qtTotalIngrediente % qtLeveX ), 
			qtComDesconto = ( ( qtTotalIngrediente - ( qtTotalIngrediente % qtLeveX ) ) * PA.qtPagueY ) / PA.qtLeveX ,

			--apenas para informação, traz os textos das promoções
			obsPromocao = PR.dsPromocao + ': ' + PR.dsRegra

		FROM 
			----- agrupa as quantidades dos ingredientes do lanche -----
			( SELECT idIngrediente, SUM(qtQuantidade) AS qtTotalIngrediente FROM @composicao GROUP BY idIngrediente ) AS CI 

			----- verifica se existe algum ingrediente que esteja configurado em alguma promoção de "Leve X pague Y" -----
			INNER JOIN tbPromocaoParametroIngrediente (nolock) AS PA ON CI.idIngrediente = PA.idIngrediente AND PA.qtLeveX IS NOT NULL AND PA.qtPagueY IS NOT NULL

			----- cruza com tabela de promoções -----
			INNER JOIN tbPromocao (nolock) AS PR ON PA.idPromocao = PR.idPromocao
	
		WHERE 
			-- verifica se é um promoção ativa -----
			PR.flAtivo = 1

			-- e verifica se a quantidade encontrada no lacnhe é maior ou igual à quantidade de "Leve X" configurada
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

			---- com a view de ingredientes (para multiplicar por seus valores unitários) ---
			INNER JOIN vwIngredienteValorAtual (nolock) AS IG ON DS.idIngrediente = IG.idIngrediente

			---- com a somatória vinda orginalmente do pedido daquele ingrediente ---
			INNER JOIN (SELECT idIngrediente, SUM(vlValor) AS vlTotalIngrediente FROM @composicao GROUP BY idIngrediente) AS CI ON DS.idIngrediente = CI.idIngrediente;


	--------- com o resultado acima, soma para todos os ingredientes que entraram na regra os valores vindos dos cálculos da promoção;  e tira a diferença com o somatória vinda orginalmente do pedido daquele ingrediente------- 
	SELECT 
		@vlPromocaoParcial = SUM(vlTotalIngrediente) - ( SUM(vlSemDesconto) + SUM(vlComDesconto) )  
	FROM @vlRelacaoDescontoLevePague;

	--teste debug select * FROM @vlRelacaoDescontoLevePague;

	------- pega também a junção dos textos de todas as promoções aplicadas -------------
	SELECT @obsPromocaoParcial = STRING_AGG(obsPromocao, ' | ')  FROM @vlRelacaoDescontoLevePague;

	--------- soma com os demais cálculos de promoções (considerando que são promoções acumulativas) , além de concatenar os nomes das promoções ------- 
	SET @vlPromocaoTotal  =  @vlPromocaoTotal  + ISNULL(@vlPromocaoParcial, 0); 
	SET @obsPromocaoTotal =  CONCAT_WS( ' | ', @obsPromocaoTotal, @obsPromocaoParcial ); 

	--teste debug select @vlPromocaoParcial

	------ adiciona no recordset em memória uma linha com ingrediente "fake", mas apenas para lançar valor o desconto (que entrará em cálculos de somatórias de outras regras) -----
	INSERT INTO @composicao SELECT 0, 0, ISNULL(@vlPromocaoParcial, 0) * (-1); 



	----------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------
	------------ verifica se encaixa na promoção 1 "Light" Se o lanche tem alface e não tem bacon, ganha 10% de desconto. ------------ 
	----------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------


	----- faz um loop por todas configuações do tipo "Tem ingrediente X mas não tem ingrediente Y " para poder testar uma a uma com os dados do lanche -----
	DECLARE @idPromocaoLoop int, @qtDescontoLoop numeric(5,2), @obsDescontoLoop varchar(1024);
	DECLARE @PromocaoPacote TABLE (idPromocao int, qtDescontoPacote numeric(5,2), obsDescontoLoop varchar(1024), foi bit);

	INSERT INTO @PromocaoPacote 
		SELECT 
			PA.idPromocao, 
			PA.qtDescontoPacote, 
			obsPromocao = PR.dsPromocao + ': ' + PR.dsRegra,
			foi = 0 
		FROM 
			--tabela de parâmetros
			tbPromocaoParametroIngrediente (nolock) AS PA
			
			--tabela de promoções
			INNER JOIN tbPromocao (nolock) AS PR ON PA.idPromocao = PR.idPromocao
		
		WHERE 
			-- pega apenas registros de configuração referentes a "tem / não tem no pacote" -----
			(flTemNoPacote = 1 OR flNaoTemNoPacote = 1)  

			-- pega apenas promoções ativas -----
			AND PR.flAtivo = 1

		GROUP BY PA.idPromocao, PA.qtDescontoPacote, (PR.dsPromocao + ': ' + PR.dsRegra);

	--loop pela tabela de memória acima
	WHILE ( EXISTS (SELECT 1 FROM @PromocaoPacote WHERE foi = 0) )
	BEGIN
		
		--pega ID do pacote, percentual de desconto e texto da promoção
		SELECT TOP 1 
			@idPromocaoLoop = idPromocao, 
			@qtDescontoLoop = qtDescontoPacote, 
			@obsDescontoLoop = obsDescontoLoop
		FROM @PromocaoPacote WHERE foi = 0;

		--- aplica regras destas configurações do loop na recordset da composição do lanche ----
		DECLARE @flRegraTemNoPacote		bit = 0;
		DECLARE @flRegraNaoTemNoPacote	bit = 0;

		IF EXISTS ( SELECT 1 FROM 
						---- composição do lanche ----
						@composicao AS CI 

						----- cruza os ingredientes com as configurações de EXISTE daquela promoção do loop -----
						INNER JOIN tbPromocaoParametroIngrediente (nolock) AS PA 
							ON CI.idIngrediente = PA.idIngrediente AND 
							PA.idPromocao = @idPromocaoLoop AND 
							PA.flTemNoPacote = 1)
		BEGIN	
			SET @flRegraTemNoPacote = 1;
		END

		IF NOT EXISTS ( SELECT 1 FROM 
						---- composição do lanche ----
						@composicao AS CI 

						----- cruza os ingredientes com as configurações de NÃO EXISTE daquela promoção do loop -----
						INNER JOIN tbPromocaoParametroIngrediente (nolock) AS PA 
							ON CI.idIngrediente = PA.idIngrediente AND 
							PA.idPromocao = @idPromocaoLoop AND 
							PA.flNaoTemNoPacote = 1)
		BEGIN	
			SET @flRegraNaoTemNoPacote = 1;
		END

		------ se as duas regras deram TRUE (existe um e não existe o outro) -----
		IF (@flRegraTemNoPacote = 1 AND @flRegraNaoTemNoPacote = 1)
		BEGIN

			--- traz o valor total da composição do lanche ----
			DECLARE @vlTotalComposicao numeric(10, 2)= 0;
			SELECT @vlTotalComposicao = SUM(vlValor) FROM @composicao;

			--- é calculado o desconto percentual, além de pegar o texto da promoção  ----
			SET @vlPromocaoParcial = CONVERT(numeric(10, 2), @vlTotalComposicao * (@qtDescontoLoop / 100));
			SET @obsPromocaoParcial = @obsDescontoLoop;

			--------- soma com os demais cálculos de promoções (considerando que são promoções acumulativas) , além de concatenar os nomes das promoções ------- 
			SET @vlPromocaoTotal  =  @vlPromocaoTotal  + ISNULL(@vlPromocaoParcial, 0); 
			SET @obsPromocaoTotal =  CONCAT_WS( ' | ', @obsPromocaoTotal, @obsPromocaoParcial ); 

			--teste debug select @vlPromocaoParcial
			
			------ adiciona no recordset em memória uma linha com ingrediente "fake", mas apenas para lançar valor o desconto (que entrará em cálculos de somatórias de outras regras) -----
			INSERT INTO @composicao SELECT 0, 0, ISNULL(@vlPromocaoParcial, 0) * (-1); 

		END

		
		--próxima volta do loop
		UPDATE @PromocaoPacote SET foi = 1 WHERE idPromocao = @idPromocaoLoop;
	END




	---------------------------------------------------------------------------------------------------------------------------------------------------
	-------- retorna o valor do desconto (descontos, por pode ser acumulativo) daquele lanche junto com um texto com nos nomes das promoções ----------
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
proc que "abre" um novo pedido e recupera o registro recém criado (com seu número) ou finaliza um pedido existente e retorna o recordset do pedido e seus itens
*/
	 @opcao			tinyint  /*1 = inserir, 3 = finalizar */

	/*parâmetro usado em 1 = inserir*/
	,@dtInicioPedido	datetime		= NULL

	/*parâmetros usado em 3 = finalizar*/
	,@idPedido				bigint		= NULL
	,@dtConclusaoPedido		datetime	= NULL

	/*parâmetros opcionais usados em ambas opções*/
	,@dsNomeChamada			varchar(50) = NULL
	,@nuCPF					varchar(14) = NULL

AS BEGIN

	------------- verifica opção passada por parãmetro ------------- 
	DECLARE @msgSucesso varchar(100), @count bigint;


	IF (@opcao = 1)  /*1 = inserir*/
	BEGIN

		------------- preenche data se for null ------------- 
		IF (@dtInicioPedido IS NULL) SET @dtInicioPedido = GETDATE();

		------------- realiza a inserção na base com daquela data (e dos outros campos, se passados) e recupera o ID criado ------------- 
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

			------------- verifica parâmetros ------------- 
			IF (@idPedido IS NULL) 
			BEGIN
				RAISERROR('Pedido a finalizar não informado', 16,1);          
				RETURN -1;          
			END

			------------- preenche data se for null ------------- 
			IF (@dtConclusaoPedido IS NULL) SET @dtConclusaoPedido = GETDATE();
		
			
			------------- verifica se pedido existe, se já foi fechado ou se tem não itens adicionados (não se pode finalizar um pedido nestas condições) ------------- 
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


			------------- atualiza na base de pedido com aquela data (os demais campos apenas atualizar se tiverem foam passados por parâmetros, se não, mantém o que tem na base) ------------- 
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
			------------- opção inexistente ------------- 
			RAISERROR('Opção inválida', 16,1);          
			RETURN -1;          
		END

	END

	------------- mensagem de sucesso junto com o recordset com o pedido (e seus itens quando for finalização) ------------- 
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
proc que insere OU apaga um item do cardápio ao pedido e retorna um recordset com os itens do pedido até então
*/
	 @opcao			tinyint  /*1 = inserir, 2 = deletar*/

	 /*parâmetro usado em ambas opções*/
	,@idPedido			bigint

	/*parâmetros usados em 1 = inserir*/
	,@idCardapio		int	= NULL
	,@qtQuantidade		int	= NULL

	/*parâmetros usados em 2 = deletar*/
	,@idPedidoCardapio	int	= NULL
	,@flLimpaTodoPedido bit = 0		--se este parãmetro é passado, limpa todos os itens daquele pedido ("reinicia")

AS BEGIN

	------------- verifica se o pedido existe e se já foi fechado (não se pode mexer num pedido se for o caso) ------------- 
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

	------------- verifica opção passada por parãmetro ------------- 
	DECLARE @msgSucesso varchar(100), @count bigint;

	IF (@opcao = 2)  /*2 = deletar*/
	BEGIN 

			------------- verifica se o item passado por parâmetro faz parte mesmo do pedido ------------- 
			IF (dbo.fnVerificaItemPedido (@idPedido, @idPedidoCardapio)  = 0)
			BEGIN
				RAISERROR('Item do pedido não pertence ao pedido', 16,1);          
				RETURN -1;          
			END

			------------- verifica se pedido tem algum item adicionado  ------------- 
			IF (@flPedidoVazio = 1) 
			BEGIN
				RAISERROR(@dsMensagem, 16,1);          
				RETURN -1;          
			END

			------------- verifica parâmetros ------------- 
			IF (@idPedidoCardapio IS NULL AND @flLimpaTodoPedido = 0) 
			BEGIN
				RAISERROR('Item do pedido a excluir não informado', 16,1);          
				RETURN -1;          
			END

			------------- realiza a deleção na base (daquele item ou de todos do pedido) ------------- 
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
					RAISERROR('Nenhum item do cardápio foi excluído do pedido', 16,1);          
					RETURN -1;          
				END
				ELSE
					SET @msgSucesso = 'Item do cardápio excluído do pedido com sucesso';
			END

	END
	ELSE 
	BEGIN

		IF (@opcao = 1)  /*1 = inserir*/
		BEGIN

			------------- verifica parâmetros ------------- 
			IF (@idCardapio IS NULL OR @qtQuantidade IS NULL OR @idCardapio = 0 OR @qtQuantidade = 0) 
			BEGIN
				RAISERROR('Informações do cardápio escolhido não informadas', 16,1);          
				RETURN -1;          
			END

			------------- consulta valor do ingrediente ------------- 
			DECLARE @vlValorLinha numeric(10,2);
			SELECT @vlValorLinha = vlValorCardapio FROM vwCardapioValor (nolock) WHERE idCardapio = @idCardapio;
			SET @vlValorLinha = @qtQuantidade * @vlValorLinha; 

			------------- realiza a inserção na base -------------
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
				RAISERROR('Erro ao inserir item do cardápio ao pedido', 16,1);          
				RETURN -1;          
			END
			ELSE
			BEGIN
				IF (@count = 0) 
				BEGIN
					RAISERROR('Erro ao inserir item do cardápio ao pedido', 16,1);          
					RETURN -1;          
				END
				ELSE
					SET @msgSucesso = 'Item do cardápio inserido ao pedido com sucesso';
			END
       
		END
		ELSE
		BEGIN
			------------- opção inexistente ------------- 
			RAISERROR('Opção inválida', 16,1);          
			RETURN -1;          
		END

	END

	------------- após inserir ou apagar, consulta itens daquele pedido atualizados e joga em tabela de memória ------------- 
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

	------------- atualiza valor total daquele pedido, bem como o recordset de saída ------------- 
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
proc que insere ou apaga um ingrediente a um lanche personalizado do pedido, atualiza o pedido e retorna um recordset os ingredientes do lanche até então
*/
	 @opcao				tinyint  /*1 = inserir, 2 = deletar*/
	
	 /*parâmetros usados em ambas opções*/	 
	,@idPedido			bigint
	,@idPedidoCardapio	bigint

	/*parâmetros usados em 1 = inserir*/
	,@idIngrediente					int		= NULL
	,@qtQuantidade					int		= NULL

	/*parâmetro usado em 2 = deletar*/
	,@idPedidoCardapioIngrediente	bigint = NULL
	,@flLimpaTodoLanche bit = 0		--se este parãmetro é passado, retira todos os ingredientes daquele lanche ("reinicia")

AS BEGIN


	------------- verifica se o item passado por parâmetro faz parte mesmo do pedido ------------- 
	IF (dbo.fnVerificaItemPedido (@idPedido, @idPedidoCardapio)  = 0)
	BEGIN
		RAISERROR('Item do pedido não pertence ao pedido', 16,1);          
		RETURN -1;          
	END

	------------- verifica se o pedido existe e se já foi fechado (não se pode mexer num pedido se for o caso) ------------- 
	DECLARE @flPedidoExistente bit, @flPedidoAberto bit, @dsMensagem varchar(100);
	SELECT  @flPedidoExistente  = flPedidoExistente,
			@flPedidoAberto		= flPedidoAberto, 
			@dsMensagem			= dsMensagem FROM dbo.fnRetornaSituacaoPedido(@idPedido);

	IF (@flPedidoExistente = 0 OR @flPedidoAberto = 0) 
	BEGIN
		RAISERROR(@dsMensagem, 16,1);          
		RETURN -1;          
	END

	------------- verifica se o item do é um um lanche personalizado ------------- 
	DECLARE @flLanchePersonalizado bit = 0;
	SET @flLanchePersonalizado = dbo.fnVerificaSituacaoPersonalizado(@idPedidoCardapio);
	IF (@flLanchePersonalizado  = 0)
	BEGIN
		RAISERROR('O lanche escolhido não pode ser personalizado', 16,1);          
		RETURN -1;          
	END

	------------- verifica opção passada por parãmetro ------------- 
	DECLARE @msgSucesso varchar(100), @erro bigint, @count bigint;

	IF (@opcao = 2)  /*2 = deletar*/
	BEGIN 

			------------- verifica parâmetros ------------- 
			IF (@idPedidoCardapioIngrediente IS NULL AND @flLimpaTodoLanche = 0) 
			BEGIN
				RAISERROR('Ingrediente do lanche a excluir não informado', 16,1);          
				RETURN -1;          
			END

			------------- realiza a deleção na base (daquele igrediente ou de todos do lanche)------------- 
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

			------------- verifica parâmetros ------------- 
			IF (@idIngrediente IS NULL OR @qtQuantidade IS NULL) 
			BEGIN
				RAISERROR('Informações do ingrediente escolhido não informadas', 16,1);          
				RETURN -1;          
			END

			------------- consulta valor do ingrediente ------------- 
			DECLARE @vlValorIngrediente numeric(10,2);
			SELECT @vlValorIngrediente = vlValor FROM vwIngredienteValorAtual (nolock) WHERE idIngrediente = @idIngrediente;
			SET @vlValorIngrediente = @qtQuantidade * @vlValorIngrediente; 

			------------- realiza a inserção na base -------------
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
			------------- opção inexistente ------------- 
			RAISERROR('Opção inválida', 16,1);          
			RETURN -1;          
		END

	END

	------------- após inserir ou apagar, consulta ingredientes daquele lanche atualizados e joga em tabela de memória ------------- 
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

	------------- soma todos os ingredientes daquela personalização ------------- 
	DECLARE @vlValorLanche numeric(10,2);
	SELECT @vlValorLanche = SUM(vlValorIngredientePersonalizado) FROM @composicao;

	------------- calcula se entra em alguma promoção (ou em mais de uma, se forem acumulativas) ------------- 
	DECLARE @vlValorPromocao numeric(10,2), @obsPromocao varchar(1024);
	SELECT @vlValorPromocao = vlPromocao, @obsPromocao = obsPromocao  FROM  dbo.fnRetornaPromocao(@idPedidoCardapio);

	------------- atualiza valor total daquele lanche, bem como o recordset de saída ------------- 
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

	------------- atualiza valor total daquele pedido, bem como o recordset de saída ------------- 
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

