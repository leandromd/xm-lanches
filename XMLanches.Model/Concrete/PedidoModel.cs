using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace XMLanches.Model
{
    public class PedidoModel : CardapioModel
    {
        //dados básicos do pedido
        public int IdPedido { get; set; }
        public DateTime? DtInicioPedido { get; set; }
        public DateTime? DtConclusaoPedido { get; set; }

        //somatório dos VlValorFinal dos itens do pedido 
        public double VlPedido { get; set; }

        //dados opcionais do pedido
        public string DsNomeChamada { get; set; }
        public string NuCPF { get; set; }


        //dados dos itens (lanches) inseridos ao pedido (os dados do lanche mesmo estão na CardapioModel herdada)
        public int IdPedidoCardapio { get; set; }
       
        public double VlValorUnitario { get; set; }
        public int QtQuantidade { get; set; }

        //valor vindo do cardápio ou da composição do personalizado sem aplicar promoções
        public double VlValor { get; set; }

        //valor do desconto (a subtrair de VlValor) calculado ao aplicar promoções
        public double VlPromocao { get; set; }

        //valor que o cliente pagará (VlValor - VlPromocao)
        public double VlValorFinal { get; set; }

        //texto informativo da promoção (ou promoções, por serem acumulativas) aplicada(s)
        public string ObsPromocao { get; set; }



        //composição de ingredientes a um lanche personalizado
        public int IdPedidoCardapioIngrediente { get; set; }

        //dados do "lanche personalizado" (isso é um dos itens do cardápio) 
        //dados dos ingredientes que compõem a personalização herdados de CardapioModel
        public double VlValorPersonalizado { get; set; }


        //os campos abaixo equivalem, respectivamente, a (VlValorIngrediente) e (VlValorIngrediente * QtQuantidadeIngrediente) da CardapioModel
        public double VlValorUnitarioIngrediente { get; set; }
        public double VlValorIngredientePersonalizado { get; set; }
    }
}
