using System;
using System.Collections.Generic;
using System.Text;

namespace XMLanches.Model
{
    public class IngredienteServerModel
    {
        //dados dos ingredientes 
        public string Codigo { get; set; }
        public string Ingrediente { get; set; }

        //composição do ingredientes nos lanches
        public string Quantidade { get; set; }
        public string Valor { get; set; }
        public string ValorUnitario { get; set; }
        public string ValorPromocao { get; set; }
        public string ValorLanche { get; set; }
        public string ValorPedido { get; set; }
        public string Promocao { get; set; }

        public string Mensagem { get; set; }

    }
}
