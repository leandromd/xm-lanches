using System;
using System.Collections.Generic;
using XMLanches.Model;
using XMLanches.Repository;
//using XMLanches.Repository.Interface;
using XMLanches.Service.Interface;

namespace XMLanches.Service
{
    public class LancheService //: ILancheService
    {
        private enum opcaoConsulta
        {
            consultaCardapio = 1,
            consultaCardapioIngredientes = 2,
            consultaIngredientes = 3,
        }

        private enum opcaoCrud
        {
            adiciona = 1,
            remove = 2,
        }

        //private readonly ILancheRepository _repository;
        //public LancheService(ILancheRepository repository)
        //{
        //    _repository = repository;
        //}

        public List<PedidoModel> AdicionarPedido(PedidoModel objeto)
        {
            List<PedidoModel> retorno = new List<PedidoModel>();
            try
            {
                LancheRepository _repository = new LancheRepository();
                retorno = _repository.AdicionarPedido(objeto);
                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public List<CardapioModel> RetornarCardapio()
        {
            List<CardapioModel> retorno = new List<CardapioModel>();
            try
            {
                LancheRepository _repository = new LancheRepository();
                retorno = _repository.RetornarCardapioIngredientes((int)(opcaoConsulta.consultaCardapio));
                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public List<CardapioModel> RetornarCardapioIngredientes(PedidoModel objeto)
        {
            List<CardapioModel> retorno = new List<CardapioModel>();
            try
            {
                LancheRepository _repository = new LancheRepository();
                retorno = _repository.RetornarCardapioIngredientes((int)(opcaoConsulta.consultaCardapioIngredientes), objeto);
                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public List<CardapioModel> RetornarIngredientes()
        {
            List<CardapioModel> retorno = new List<CardapioModel>();
            try
            {
                LancheRepository _repository = new LancheRepository();
                retorno = _repository.RetornarCardapioIngredientes((int)(opcaoConsulta.consultaIngredientes));
                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public List<PedidoModel> AdicionarItemPedido(PedidoModel objeto)
        {
            List<PedidoModel> retorno = new List<PedidoModel>();
            try
            {
                LancheRepository _repository = new LancheRepository();
                retorno = _repository.AdicionarRemoverItemPedido(objeto, (int)(opcaoCrud.adiciona));
                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public List<PedidoModel> RemoverItemPedido(PedidoModel objeto)
        {
            List<PedidoModel> retorno = new List<PedidoModel>();
            try
            {
                LancheRepository _repository = new LancheRepository();
                retorno = _repository.AdicionarRemoverItemPedido(objeto, (int)(opcaoCrud.remove));
                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public List<PedidoModel> AdicionarIngredientePersonalizado(PedidoModel objeto)
        {
            List<PedidoModel> retorno = new List<PedidoModel>();
            try
            {
                LancheRepository _repository = new LancheRepository();
                retorno = _repository.AdicionarRemoverIngredientePersonalizado(objeto, (int)(opcaoCrud.adiciona));
                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }
    }
}
