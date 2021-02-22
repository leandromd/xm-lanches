using System;
using System.Collections.Generic;
using System.Text;

namespace XMLanches.Model
{
    public class PedidoServerModel
    {
        public string Pedido { get; set; }
        public string DataInicio { get; set; }
        public string DataFim { get; set; }

        public string ValorPedido { get; set; }
        public string NomeChamada { get; set; }
        public string CPF { get; set; }

        public string Item { get; set; }
        public string Cardapio { get; set; }
        public string Descricao { get; set; }

        public string Ingrediente { get; set; }
        public string ValorUnitario { get; set; }
        public string Quantidade { get; set; }

        public string Valor { get; set; }

        public string ValorPromocao { get; set; }

        public string ValorFinal { get; set; }


        public string Promocao { get; set; }
        public string Mensagem { get; set; }
    }
}
