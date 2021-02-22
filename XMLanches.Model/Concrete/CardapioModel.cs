using System;

namespace XMLanches.Model
{
    public class CardapioModel
    {
        //dados dos lanches
        public int IdCardapio { get; set; }
        public string DsCardapio { get; set; }
        public double VlValorCardapio { get; set; }
        public bool FlPersonalizado { get; set; }


        //dados dos ingredientes 
        public int IdIngrediente { get; set; }
        public string DsIngrediente { get; set; }


        //composição do ingredientes nos lanches
        public int QtQuantidadeIngrediente { get; set; }
        public double VlValorIngrediente { get; set; }


        //quando as proc de CRUD retornam algum mensagem de retorno de sucesso (ou erro)
        public string MensagemRetorno { get; set; }


        //quando alguma exception do C# acontece 
        public string ErroRetornado { get; set; }
        public int CodErroRetornado { get; set; }
    }
}
