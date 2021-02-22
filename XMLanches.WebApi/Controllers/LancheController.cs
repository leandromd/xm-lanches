using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using XMLanches.Model;
using XMLanches.Service;
//using XMLanches.Service.Interface;
using static XMLanches.Model.Enum.LancheEnumExtensions;
using AcceptVerbsAttribute = System.Web.Http.AcceptVerbsAttribute;
using RouteAttribute = System.Web.Http.RouteAttribute;
using RoutePrefixAttribute = System.Web.Http.RoutePrefixAttribute;


namespace XMLanches.WebApi.Controllers
{

    [RoutePrefix("api/xmenlanches")]
    public class LancheController : ApiController
    {

        [System.Web.Http.AcceptVerbs("GET")]
        [Route("GetCardapio")]
        public List<CardapioServerModel> GetCardapio()
        {
            /* 
             * O objetivo do método GetCardapio é retornar uma 
             * consulta de lanches do cardápio (uma linha por lanche) 
             */

            List<CardapioModel> consulta = new List<CardapioModel>();
            List<CardapioServerModel> retorno = new List<CardapioServerModel>();
            try
            {
                LancheService _service = new LancheService();
                consulta = _service.RetornarCardapio();

                foreach (var item in consulta)
                {
                    retorno.Add(new CardapioServerModel
                    {
                        Codigo = item.IdCardapio.ToString(),
                        Cardapio = item.DsCardapio,
                        Valor = item.VlValorCardapio.ToString(),
                        Personalizavel = (item.FlPersonalizado ? "S" : "N"),
                        Mensagem = "",
                    });
                }
                return retorno;
            }
            catch (Exception ex)
            {
                retorno.Add(new CardapioServerModel
                {
                    Mensagem = ((int)(LancheEnum.ErroExcGetCardapio)).ToString() + " - " + LancheEnum.ErroExcGetCardapio.Descricao() + " (" + ex.Message + ")",
                });
                return retorno;
            }
        }



        [System.Web.Http.AcceptVerbs("POST")]
        [Route("GetIngredientes")]
        public List<IngredienteServerModel> GetIngredientes(PedidoServerModel objeto)
        {
            /* 
             * O objetivo do método GetIngredientes é retornar uma 
             * consulta de ingredientes (uma linha por ingrediente) 
             * de um lanche (quando passado o id) ou a listagem de todos ingredientes para consulta (quando sem parametros)
             */

            List<CardapioModel> consulta = new List<CardapioModel>();
            List<IngredienteServerModel> retorno = new List<IngredienteServerModel>();
            try
            {
                if (objeto == null) objeto = new PedidoServerModel();
                PedidoModel parametros = new PedidoModel();
                if (!string.IsNullOrEmpty(objeto.Cardapio))             
                {
                    int tempInt;
                    if (int.TryParse(objeto.Cardapio, out tempInt)) parametros.IdCardapio = tempInt;
                }

                LancheService _service = new LancheService();
                if (parametros.IdCardapio != 0)
                    consulta = _service.RetornarCardapioIngredientes(parametros);
                else
                    consulta = _service.RetornarIngredientes();

                foreach (var item in consulta)
                {
                    retorno.Add(new IngredienteServerModel
                    {
                        Codigo = item.IdIngrediente.ToString(),
                        Ingrediente = item.DsIngrediente,
                        Quantidade = item.QtQuantidadeIngrediente.ToString(),
                        Valor = item.VlValorIngrediente.ToString(),
                        Mensagem = "",
                    });
                }
                return retorno;
            }
            catch (Exception ex)
            {
                retorno.Add(new IngredienteServerModel
                {
                    Mensagem = ((int)(LancheEnum.ErroExcGetIngredientes)).ToString() + " - " + LancheEnum.ErroExcGetIngredientes.Descricao() + " (" + ex.Message + ")",
                });
                return retorno;
            }
        }


        [System.Web.Http.AcceptVerbs("POST")]
        [Route("AddPedido")]
        //[Route("AddPedido/{objeto}")]
        public string AddPedido(PedidoServerModel objeto)
        {
            /* 
             * O objetivo do método AddPedido é criar um novo pedido na base (vazio, ainda sem itens)
             * Pode-se ou não passar os dados de Nome de Chamada e CPF
             * O retorno é o Id do Pedido  
             */
            List<PedidoModel> consulta = new List<PedidoModel>();
            try
            {
                if (objeto == null) objeto = new PedidoServerModel();

                PedidoModel parametros = new PedidoModel();
                parametros.DsNomeChamada = objeto.NomeChamada;
                parametros.NuCPF = objeto.CPF;

                if (string.IsNullOrEmpty(objeto.DataInicio))
                    parametros.DtInicioPedido = DateTime.Now;
                else
                {
                    DateTime tempData;
                    if (DateTime.TryParse(objeto.DataInicio, out tempData))
                        parametros.DtInicioPedido = tempData;
                }
                LancheService _service = new LancheService();
                consulta = _service.AdicionarPedido(parametros);

                if (consulta.Count == 0)
                    throw new Exception("Erro ao abrir o pedido");
                else
                {
                    if (consulta[0].IdPedido == 0)
                        throw new Exception("Erro ao abrir o pedido");
                }

                return consulta[0].IdPedido.ToString();
            }
            catch (Exception ex)
            {
                string Mensagem = ((int)(LancheEnum.ErroExcAddPedido)).ToString() + " - " + LancheEnum.ErroExcAddPedido.Descricao() + " (" + ex.Message + ")";
                return Mensagem;
            }
        }


        [System.Web.Http.AcceptVerbs("POST")]
        [Route("AddItemPedido")]
        public List<PedidoServerModel> AddItemPedido(PedidoServerModel objeto)
        {
            /* 
             * O objetivo do método AddItemPedido é adicionar um item do cardápio ao pedido
             * O retorno é a relação atualizada dos itens do pedido
             */
            List<PedidoServerModel> retorno = new List<PedidoServerModel>();
            List<PedidoModel> consulta = new List<PedidoModel>();
            try
            {
                if (objeto == null) objeto = new PedidoServerModel();
                PedidoModel parametros = new PedidoModel();

                int tempInt;
                if (int.TryParse(objeto.Pedido, out tempInt)) parametros.IdPedido = tempInt;
                if (int.TryParse(objeto.Cardapio, out tempInt)) parametros.IdCardapio = tempInt;
                if (int.TryParse(objeto.Quantidade, out tempInt)) parametros.QtQuantidade = tempInt;

                LancheService _service = new LancheService();
                consulta = _service.AdicionarItemPedido(parametros);
                retorno = conversaoPedidoModel(consulta);
                return retorno;
            }
            catch (Exception ex)
            {
                retorno.Add(new PedidoServerModel
                {
                    Mensagem = ((int)(LancheEnum.ErroExcAddItemPedido)).ToString() + " - " + LancheEnum.ErroExcAddItemPedido.Descricao() + " (" + ex.Message + ")",
                });
                return retorno;
            }
        }

        [System.Web.Http.AcceptVerbs("POST")]
        [Route("DelItemPedido")]
        public List<PedidoServerModel> DelItemPedido(PedidoServerModel objeto)
        {
            /* 
             * O objetivo do método DelItemPedido é remover um item do pedido
             * O retorno é a relação atualizada dos itens do pedido
             */
            List<PedidoServerModel> retorno = new List<PedidoServerModel>();
            List<PedidoModel> consulta = new List<PedidoModel>();
            try
            {
                if (objeto == null) objeto = new PedidoServerModel();
                PedidoModel parametros = new PedidoModel();

                int tempInt;
                if (int.TryParse(objeto.Pedido, out tempInt)) parametros.IdPedido = tempInt;
                if (int.TryParse(objeto.Item, out tempInt)) parametros.IdPedidoCardapio = tempInt;

                LancheService _service = new LancheService();
                consulta = _service.RemoverItemPedido(parametros);
                retorno = conversaoPedidoModel(consulta);
                return retorno;
            }
            catch (Exception ex)
            {
                retorno.Add(new PedidoServerModel
                {
                    Mensagem = ((int)(LancheEnum.ErroExcDelItemPedido)).ToString() + " - " + LancheEnum.ErroExcDelItemPedido.Descricao() + " (" + ex.Message + ")",
                });
                return retorno;
            }
        }

        [System.Web.Http.AcceptVerbs("POST")]
        [Route("AddIngredientePersonalizado")]
        public List<IngredienteServerModel> AddIngredientePersonalizado(PedidoServerModel objeto)
        {
            /* 
             * O objetivo do método AddIngredientePersonalizado é adicionar um ingrediente a um lanche personalizado
             * O retorno é a relação atualizada da composição do lanche
             */
            List<IngredienteServerModel> retorno = new List<IngredienteServerModel>();
            List<PedidoModel> consulta = new List<PedidoModel>();
            try
            {
                if (objeto == null) objeto = new PedidoServerModel();
                PedidoModel parametros = new PedidoModel();

                int tempInt;
                if (int.TryParse(objeto.Pedido, out tempInt)) parametros.IdPedido = tempInt;
                if (int.TryParse(objeto.Item, out tempInt)) parametros.IdPedidoCardapio = tempInt;
                if (int.TryParse(objeto.Ingrediente, out tempInt)) parametros.IdIngrediente = tempInt;
                if (int.TryParse(objeto.Quantidade, out tempInt)) parametros.QtQuantidadeIngrediente = tempInt;

                LancheService _service = new LancheService();
                consulta = _service.AdicionarIngredientePersonalizado(parametros);
                retorno = conversaoIngredienteModel(consulta);
                return retorno;
            }
            catch (Exception ex)
            {
                retorno.Add(new IngredienteServerModel
                {
                    Mensagem = ((int)(LancheEnum.ErroExcAddIngredientePersonalizado)).ToString() + " - " + LancheEnum.ErroExcAddIngredientePersonalizado.Descricao() + " (" + ex.Message + ")",
                });
                return retorno;
            }
        }


        //-----------------------------------------
        private List<PedidoServerModel> conversaoPedidoModel(List<PedidoModel> objeto)
        {
            /* 
             * método para fazer a "troca de bandeja", convetendo resultado vindo do repositório em forma de lista de objeto com tipos variados
             * para uma uma lista de objetos mais semples (com apenas atributos string e nomes mais simplificados, que são o retorno da WebApi)
             */
            List<PedidoServerModel> leitura = new List<PedidoServerModel>();
            try
            {

                foreach (var item in objeto)
                {
                    leitura.Add(new PedidoServerModel
                    {
                        ValorPedido = item.VlPedido.ToString(),

                        Item = item.IdPedidoCardapio.ToString(),
                        Descricao = item.DsCardapio,

                        ValorUnitario = item.VlValorUnitario.ToString(),
                        Quantidade = item.QtQuantidade.ToString(),
                        Valor = item.VlValor.ToString(),
                        ValorPromocao = item.VlPromocao.ToString(),
                        ValorFinal = item.VlValorFinal.ToString(),
                        Promocao = item.ObsPromocao,

                        Mensagem = item.MensagemRetorno,
                    });
                }
                return leitura;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }


        private List<IngredienteServerModel> conversaoIngredienteModel(List<PedidoModel> objeto)
        {
            /* 
             * método para fazer a "troca de bandeja", convetendo resultado vindo do repositório em forma de lista de objeto com tipos variados
             * para uma uma lista de objetos mais semples (com apenas atributos string e nomes mais simplificados, que são o retorno da WebApi)
             */
            List<IngredienteServerModel> leitura = new List<IngredienteServerModel>();
            try
            {

                foreach (var item in objeto)
                {
                    leitura.Add(new IngredienteServerModel
                    {
                        Codigo = item.IdIngrediente.ToString(),
                        Ingrediente = item.DsIngrediente,
                        Quantidade = item.QtQuantidadeIngrediente.ToString(),

                        ValorUnitario = item.VlValorUnitario.ToString(),
                        ValorPromocao = item.VlPromocao.ToString(),
                        Valor = item.VlValorFinal.ToString(),
                        Promocao = item.ObsPromocao,

                        ValorLanche = item.VlValor.ToString(),
                        ValorPedido = item.VlPedido.ToString(),

                        Mensagem = item.MensagemRetorno,
                    });
                }
                return leitura;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }



    }
}