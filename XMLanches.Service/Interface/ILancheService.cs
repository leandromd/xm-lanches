using System;
using System.Collections.Generic;
using System.Text;
using XMLanches.Model;

namespace XMLanches.Service.Interface
{
    public interface ILancheService
    {
        List<PedidoModel> AdicionarPedido(PedidoModel objeto);
        List<CardapioModel> RetornarCardapio();
        List<CardapioModel> RetornarCardapioIngredientes();
        List<CardapioModel> RetornarIngredientes();
    }
}
