using System;
using System.Collections.Generic;
using System.Text;
using XMLanches.Model;

namespace XMLanches.Repository.Interface
{
    public interface ILancheRepository
    {
        List<PedidoModel> AdicionarPedido(PedidoModel objeto);
        List<CardapioModel> RetornarCardapioIngredientes(int opcao);
    }
}
