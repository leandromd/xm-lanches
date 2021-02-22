use dbProvaMutant2014
GO



----------------------------


SELECT * FROM tbPedidoCardapioIngrediente (nolock) WHERE idPedidoCardapio = 9
SELECT * FROM tbPedidoCardapioIngrediente (nolock) WHERE idPedidoCardapio = 10

SELECT * FROM vwPedidoCardapioIngrediente (nolock) WHERE idPedidoCardapio = 9
SELECT * FROM vwPedidoCardapioIngrediente (nolock) WHERE idPedidoCardapio = 10


SELECT * FROM tbPedido (nolock) 

SELECT * FROM tbPedidoCardapio (nolock) WHERE idPedido = 3
SELECT * FROM tbPedidoCardapio (nolock) WHERE idPedido = 4
SELECT * FROM tbPedidoCardapio (nolock) WHERE idPedido = 5


SELECT * FROM vwPedidoCardapio (nolock) WHERE idPedido = 3
SELECT * FROM vwPedidoCardapio (nolock) WHERE idPedido = 4
SELECT * FROM vwPedidoCardapio (nolock) WHERE idPedido = 5
SELECT * FROM vwPedidoCardapio (nolock) WHERE idPedido = 6

/*
EXEC spExcluiDoPedido 3, 4
EXEC spExcluiDoPedido 3, 5

*/


EXEC sp_INS_UPD_Pedido @opcao = 1;
EXEC sp_INS_DEL_PedidoCardapio @opcao = 1, @idPedido = 25,  @idCardapio = 1, @qtQuantidade = 2;
EXEC sp_INS_DEL_PedidoCardapio @opcao = 1, @idPedido = 25,  @idCardapio = 2, @qtQuantidade = 1
EXEC sp_INS_DEL_PedidoCardapio @opcao = 2, @idPedido = 25 , @idPedidoCardapio = 62; 
EXEC sp_INS_DEL_PedidoCardapio @opcao = 2, @idPedido = 11 , @flLimpaTodoPedido = 1; 
EXEC sp_INS_UPD_Pedido @opcao = 3, @idPedido = 25;
EXEC sp_INS_UPD_Pedido @opcao = 3, @idPedido = 13;
EXEC sp_INS_UPD_Pedido @opcao = 3, @idPedido = 14;

EXEC sp_INS_DEL_PedidoCardapio @opcao = 1, @idPedido = 5 , @idCardapio = 1, @qtQuantidade = 2;
EXEC sp_INS_DEL_PedidoCardapio @opcao = 1, @idPedido = 5 , @idCardapio = 3, @qtQuantidade = 1;
EXEC sp_INS_DEL_PedidoCardapio @opcao = 2, @idPedido = 5, @idPedidoCardapio = 49;
EXEC sp_INS_DEL_PedidoCardapio @opcao = 2, @idPedido = 5, @flLimpaTodoPedido = 1;
EXEC sp_INS_DEL_PedidoCardapio @opcao = 1, @idPedido = 5 , @idCardapio = 3, @qtQuantidade = 2;

EXEC sp_INS_DEL_PedidoCardapio @opcao = 1, @idPedido = 26 , @idCardapio = 5, @qtQuantidade = 1;
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 26, @idPedidoCardapio = 64, @idIngrediente = 3, @qtQuantidade = 1; --carne 
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 26, @idPedidoCardapio = 64, @idIngrediente = 4, @qtQuantidade = 1; --ovo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 26, @idPedidoCardapio = 64, @idPedidoCardapioIngrediente = 29; --tirando

EXEC sp_INS_DEL_PedidoCardapio @opcao = 1, @idPedido = 23 , @idCardapio = 5, @qtQuantidade = 1;
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 60, @idIngrediente = 1, @qtQuantidade = 1; --alface
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 60, @idIngrediente = 4, @qtQuantidade = 1; --ovo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 60, @idIngrediente = 2, @qtQuantidade = 1; --bacon
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 60, @idIngrediente = 3, @qtQuantidade = 10; --carne 10x
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 60, @idIngrediente = 3, @qtQuantidade = 2; --carne 2x
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 60, @idIngrediente = 3, @qtQuantidade = 1; --carne
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 60, @idIngrediente = 5, @qtQuantidade = 1; --queijo 
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 23, @idPedidoCardapio = 60, @flLimpaTodoLanche = 1; --tirando


EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 4, @idPedidoCardapio = 9, @idIngrediente = 1, @qtQuantidade = 1; --alface
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 4, @idPedidoCardapio = 9, @idIngrediente = 3, @qtQuantidade = 2; --carne
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 4, @idPedidoCardapio = 9, @idIngrediente = 4, @qtQuantidade = 1; --ovo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 4, @idPedidoCardapio = 9, @idIngrediente = 2, @qtQuantidade = 4; --bacon
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 4, @idPedidoCardapio = 9, @idIngrediente = 5, @qtQuantidade = 1; --queijo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 4, @idPedidoCardapio = 9, @idIngrediente = 1, @qtQuantidade = 1; --alface de novo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 4, @idPedidoCardapio = 9, @idIngrediente = 1, @qtQuantidade = 1; --alface de novo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 4, @idPedidoCardapio = 9, @idIngrediente = 1, @qtQuantidade = 1; --alface de novo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 4, @idPedidoCardapio = 9, @idIngrediente = 1, @qtQuantidade = 1; --alface de novo

EXEC sp_INS_DEL_PedidoCardapio @opcao = 1, @idPedido = 40 , @idCardapio = 5, @qtQuantidade = 1;
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 40, @idPedidoCardapio = 161, @idIngrediente = 3, @qtQuantidade = 1; --carne
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 40, @idPedidoCardapio = 161, @idIngrediente = 5, @qtQuantidade = 1; --queijo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 40, @idPedidoCardapio = 161, @idIngrediente = 1, @qtQuantidade = 1; --alface de novo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 40, @idPedidoCardapio = 161, @idIngrediente = 1, @qtQuantidade = 1; --alface de novo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 40, @idPedidoCardapio = 161, @idIngrediente = 1, @qtQuantidade = 1; --alface de novo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 40, @idPedidoCardapio = 161, @idIngrediente = 1, @qtQuantidade = 1; --alface de novo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 40, @idPedidoCardapio = 161, @flLimpaTodoLanche = 1

EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 4, @idPedidoCardapio = 10, @idPedidoCardapioIngrediente = 38
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 4, @idPedidoCardapio = 10, @idPedidoCardapioIngrediente = 26
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 4, @idPedidoCardapio = 10, @idPedidoCardapioIngrediente = 23
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 4, @idPedidoCardapio = 10, @idPedidoCardapioIngrediente = 18
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 4, @idPedidoCardapio = 10, @idPedidoCardapioIngrediente = 16
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 4, @idPedidoCardapio = 10, @idPedidoCardapioIngrediente = 12
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 4, @idPedidoCardapio = 10, @idPedidoCardapioIngrediente = 14
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 4, @idPedidoCardapio = 10, @flLimpaTodoLanche = 1


EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 59, @idIngrediente = 1, @qtQuantidade = 1; --alface
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 59, @idIngrediente = 3, @qtQuantidade = 2; --carne
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 59, @idIngrediente = 4, @qtQuantidade = 1; --ovo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 59, @idIngrediente = 2, @qtQuantidade = 4; --bacon
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 59, @idIngrediente = 5, @qtQuantidade = 1; --queijo
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 23, @idPedidoCardapio = 59, @idPedidoCardapioIngrediente = 21
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 2, @idPedido = 23, @idPedidoCardapio = 59, @idPedidoCardapioIngrediente = 22


EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 23, @idPedidoCardapio = 10, @idIngrediente = 3, @qtQuantidade = 2; --carne


SELECT * FROM vwPedidoCardapio (nolock) WHERE idPedido= 93
SELECT * FROM vwPedidoCardapioIngrediente (nolock) WHERE idPedido= 93
SELECT * FROM tbPedidoCardapio (nolock) WHERE idPedido = 91
EXEC sp_INS_DEL_PersonalizadoIngrediente @opcao = 1, @idPedido = 91, @idPedidoCardapio = 151, @idIngrediente = 5, @qtQuantidade = 1; --


SELECT * FROM tbPedido (nolock)
SELECT * FROM tbPedidoCardapio (nolock)
SELECT * FROM vwPedidoCardapio WHERE idCardapio = 5

SELECT * FROM vwPedidoCardapio (nolock) WHERE idPedido = 23

SELECT * FROM tbPedidoCardapioIngrediente (nolock)
SELECT * FROM vwPedidoCardapioIngrediente (nolock) WHERE idPedido = 23





EXEC sp_SEL_Cardapio 1
EXEC sp_SEL_Cardapio 2
EXEC sp_SEL_Cardapio 2, NULL
EXEC sp_SEL_Cardapio 3


EXEC sp_INS_UPD_Pedido @opcao = 1;

EXEC sp_INS_UPD_Pedido @opcao = 1, @dsNomeChamada = 'LeandroMD';
EXEC sp_INS_UPD_Pedido @opcao = 1, @dsNomeChamada = 'LeandroMD', @nuCPF = '260';


SELECT * FROM tbPedido ORDER BY 1 DESC

SELECT * FROM tbPedido WHERE idPedido = 61
SELECT * FROM vwPedidoCardapio WHERE idPedido = 61




EXEC sp_INS_DEL_PedidoCardapio @opcao = 1, @idPedido = 52 , @idCardapio = 4, @qtQuantidade = 1;
EXEC sp_INS_DEL_PedidoCardapio @opcao = 2, @idPedido = 52 , @idPedidoCardapio = 71



