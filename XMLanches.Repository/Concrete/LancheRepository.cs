using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using XMLanches.Model;
using XMLanches.Repository.Interface;

namespace XMLanches.Repository
{
    public class LancheRepository : Concrete.RepositorioDataBase, ILancheRepository
    {
        public List<PedidoModel> AdicionarPedido(PedidoModel objeto)
        {
            List<PedidoModel> retorno = new List<PedidoModel>();
            try
            {
                string proc = "sp_INS_UPD_Pedido";
                SqlParameter p_Opc = new SqlParameter("@opcao", 1);
                SqlParameter p_Ini = new SqlParameter("@dtInicioPedido", objeto.DtInicioPedido);
                SqlParameter p_Nom = new SqlParameter("@dsNomeChamada", objeto.DsNomeChamada);
                SqlParameter p_Cpf = new SqlParameter("@nuCPF", objeto.NuCPF);

                var reader = ExecutaStoredProcedureDataReader(proc, p_Opc, p_Ini, p_Nom, p_Cpf);

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        PedidoModel obj = new PedidoModel();

                        //----------------------- dados do pedido ----------------------//
                        if (!string.IsNullOrEmpty(reader["mensagem"].ToString()))
                            obj.MensagemRetorno = reader["mensagem"].ToString();

                        if (!string.IsNullOrEmpty(reader["idPedido"].ToString()))
                            obj.IdPedido = Convert.ToInt32(reader["idPedido"].ToString());

                        if (!string.IsNullOrEmpty(reader["dtInicioPedido"].ToString()))
                            obj.DtInicioPedido = Convert.ToDateTime(reader["dtInicioPedido"].ToString());

                        if (!string.IsNullOrEmpty(reader["dsNomeChamada"].ToString()))
                            obj.DsNomeChamada = reader["dsNomeChamada"].ToString();

                        if (!string.IsNullOrEmpty(reader["nuCPF"].ToString().Trim()))
                            obj.NuCPF = reader["nuCPF"].ToString();

                        retorno.Add(obj);
                    }
                }
                reader.Close();

                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }


        public List<CardapioModel> RetornarCardapioIngredientes(int opcao)
        {
            //abaixo o método é uma sobrecarga deste, para pegar o segundo parâmetro
            return RetornarCardapioIngredientes(opcao, new PedidoModel());
        }

        public List<CardapioModel> RetornarCardapioIngredientes(int opcao, PedidoModel objeto)
        {
            List<CardapioModel> retorno = new List<CardapioModel>();
            try
            {
                SqlDataReader reader;
                string proc = "sp_SEL_Cardapio";
                SqlParameter p_Opc = new SqlParameter("@opcao", opcao);

                if (objeto == null || objeto.IdCardapio == 0)
                    reader = ExecutaStoredProcedureDataReader(proc, p_Opc);
                else
                {
                    SqlParameter p_Car = new SqlParameter("@idCardapio", objeto.IdCardapio);
                    reader = ExecutaStoredProcedureDataReader(proc, p_Opc, p_Car);
                }

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        PedidoModel obj = new PedidoModel();

                        //----------------------- lanches do cardápio ----------------------//
                        if (!string.IsNullOrEmpty(reader["IdCardapio"].ToString()))
                            obj.IdCardapio = Convert.ToInt32(reader["IdCardapio"].ToString());

                        if (!string.IsNullOrEmpty(reader["DsCardapio"].ToString()))
                            obj.DsCardapio = reader["DsCardapio"].ToString();

                        if (!string.IsNullOrEmpty(reader["VlValorCardapio"].ToString()))
                            obj.VlValorCardapio = Convert.ToDouble(reader["VlValorCardapio"].ToString());


                        //----------------------- ingredientes ----------------------//
                        if (!string.IsNullOrEmpty(reader["IdIngrediente"].ToString()))
                            obj.IdIngrediente = Convert.ToInt32(reader["IdIngrediente"].ToString());

                        if (!string.IsNullOrEmpty(reader["DsIngrediente"].ToString()))
                            obj.DsIngrediente = reader["DsIngrediente"].ToString();

                        if (!string.IsNullOrEmpty(reader["VlValorIngrediente"].ToString()))
                            obj.VlValorIngrediente = Convert.ToDouble(reader["VlValorIngrediente"].ToString());


                        //----------------------- lanche personalizado ----------------------//
                        if (!string.IsNullOrEmpty(reader["QtQuantidadeIngrediente"].ToString()))
                            obj.QtQuantidadeIngrediente = Convert.ToInt32(reader["QtQuantidadeIngrediente"].ToString());

                        if (!string.IsNullOrEmpty(reader["FlPersonalizado"].ToString()))
                            obj.FlPersonalizado = (reader["FlPersonalizado"].ToString().ToUpper() == "TRUE");



                        retorno.Add(obj);
                    }
                }
                reader.Close();

                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public List<PedidoModel> AdicionarRemoverItemPedido(PedidoModel objeto, int opcao)
        {
            List<PedidoModel> retorno = new List<PedidoModel>();
            try
            {
                SqlDataReader reader;
                string proc = "sp_INS_DEL_PedidoCardapio";
                SqlParameter p_Opc = new SqlParameter("@opcao", opcao);
                SqlParameter p_Ped = new SqlParameter("@idPedido", objeto.IdPedido);
                switch (opcao)
                {
                    case 1: //adicionar
                        SqlParameter p_Car = new SqlParameter("@idCardapio", objeto.IdCardapio);
                        SqlParameter p_Qtd = new SqlParameter("@qtQuantidade", objeto.QtQuantidade);
                        reader = ExecutaStoredProcedureDataReader(proc, p_Opc, p_Ped, p_Car, p_Qtd);
                        break;

                    case 2: //remover
                        SqlParameter p_Itm = new SqlParameter("@idPedidoCardapio", objeto.IdPedidoCardapio);
                        reader = ExecutaStoredProcedureDataReader(proc, p_Opc, p_Ped, p_Itm);
                        break;

                    default:
                        throw new Exception("Opção inválida");

                }

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        PedidoModel obj = new PedidoModel();

                        //----------------------- dados do pedido ----------------------//
                        if (!string.IsNullOrEmpty(reader["VlPedido"].ToString()))
                            obj.VlPedido = Convert.ToDouble(reader["VlPedido"].ToString());

                        //----------------------- dados do item do pedido ----------------------//
                        if (!string.IsNullOrEmpty(reader["IdPedidoCardapio"].ToString()))
                            obj.IdPedidoCardapio = Convert.ToInt32(reader["IdPedidoCardapio"].ToString());

                        if (!string.IsNullOrEmpty(reader["VlValorUnitario"].ToString()))
                            obj.VlValorUnitario = Convert.ToDouble(reader["VlValorUnitario"].ToString());

                        if (!string.IsNullOrEmpty(reader["QtQuantidade"].ToString()))
                            obj.QtQuantidade = Convert.ToInt32(reader["QtQuantidade"].ToString());

                        if (!string.IsNullOrEmpty(reader["VlValor"].ToString()))
                            obj.VlValor = Convert.ToDouble(reader["VlValor"].ToString());

                        if (!string.IsNullOrEmpty(reader["VlPromocao"].ToString()))
                            obj.VlPromocao = Convert.ToDouble(reader["VlPromocao"].ToString());

                        if (!string.IsNullOrEmpty(reader["VlValorFinal"].ToString()))
                            obj.VlValorFinal = Convert.ToDouble(reader["VlValorFinal"].ToString());

                        if (!string.IsNullOrEmpty(reader["ObsPromocao"].ToString()))
                            obj.ObsPromocao = reader["ObsPromocao"].ToString();

                        //----------------------- dados do lanche ----------------------//
                        if (!string.IsNullOrEmpty(reader["DsCardapio"].ToString()))
                            obj.DsCardapio = reader["DsCardapio"].ToString();

                        //----------------------- caso queira retornar mensagem de sucesso ou de erro da proc  ----------------------//
                        if (!string.IsNullOrEmpty(reader["mensagem"].ToString()))
                            obj.MensagemRetorno = reader["mensagem"].ToString();

                        retorno.Add(obj);
                    }
                }
                reader.Close();

                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }


        public List<PedidoModel> AdicionarRemoverIngredientePersonalizado(PedidoModel objeto, int opcao)
        {
            List<PedidoModel> retorno = new List<PedidoModel>();
            try
            {
                SqlDataReader reader;
                string proc = "sp_INS_DEL_PersonalizadoIngrediente";
                SqlParameter p_Opc = new SqlParameter("@opcao", opcao);
                SqlParameter p_Ped = new SqlParameter("@idPedido", objeto.IdPedido);
                SqlParameter p_Itm = new SqlParameter("@idPedidoCardapio", objeto.IdPedidoCardapio);
                switch (opcao)
                {
                    case 1: //adicionar
                        SqlParameter p_Ing = new SqlParameter("@idIngrediente", objeto.IdIngrediente);
                        SqlParameter p_Qtd = new SqlParameter("@qtQuantidade", objeto.QtQuantidade);
                        reader = ExecutaStoredProcedureDataReader(proc, p_Opc, p_Ped, p_Itm, p_Ing, p_Qtd);
                        break;

                    case 2: //remover
                        SqlParameter p_Id = new SqlParameter("@idPedidoCardapioIngrediente", objeto.IdPedidoCardapioIngrediente);
                        reader = ExecutaStoredProcedureDataReader(proc, p_Opc, p_Ped, p_Itm, p_Id);
                        break;

                    default:
                        throw new Exception("Opção inválida");

                }

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        PedidoModel obj = new PedidoModel();

                        //----------------------- dados do pedido ----------------------//
                        if (!string.IsNullOrEmpty(reader["VlPedido"].ToString()))
                            obj.VlPedido = Convert.ToDouble(reader["VlPedido"].ToString());

                        //----------------------- dados do item do pedido ----------------------//
                        if (!string.IsNullOrEmpty(reader["IdPedidoCardapio"].ToString()))
                            obj.IdPedidoCardapio = Convert.ToInt32(reader["IdPedidoCardapio"].ToString());

                        //----------------------- dados da personalização do lanche ----------------------//
                        if (!string.IsNullOrEmpty(reader["IdPedidoCardapioIngrediente"].ToString()))
                            obj.IdPedidoCardapioIngrediente = Convert.ToInt32(reader["IdPedidoCardapioIngrediente"].ToString());

                        if (!string.IsNullOrEmpty(reader["ObsPromocao"].ToString()))
                            obj.ObsPromocao = reader["ObsPromocao"].ToString();


                        //valores do lanche (antes e após promoção)
                        if (!string.IsNullOrEmpty(reader["VlValorPersonalizado"].ToString()))
                            obj.VlValorPersonalizado = Convert.ToDouble(reader["VlValorPersonalizado"].ToString());

                        if (!string.IsNullOrEmpty(reader["VlPromocao"].ToString()))
                            obj.VlPromocao = Convert.ToDouble(reader["VlPromocao"].ToString());

                        if (!string.IsNullOrEmpty(reader["VlValorFinal"].ToString()))
                            obj.VlValorFinal = Convert.ToDouble(reader["VlValorFinal"].ToString());


                        //dados dos ingrediente
                        if (!string.IsNullOrEmpty(reader["IdIngrediente"].ToString()))
                            obj.IdIngrediente= Convert.ToInt32(reader["IdIngrediente"].ToString());

                        if (!string.IsNullOrEmpty(reader["DsIngrediente"].ToString()))
                            obj.DsIngrediente = reader["DsIngrediente"].ToString();

                        if (!string.IsNullOrEmpty(reader["QtQuantidadeIngrediente"].ToString()))
                            obj.QtQuantidadeIngrediente = Convert.ToInt32(reader["QtQuantidadeIngrediente"].ToString());

                        if (!string.IsNullOrEmpty(reader["VlValorUnitarioIngrediente"].ToString()))
                            obj.VlValorUnitarioIngrediente= Convert.ToDouble(reader["VlValorUnitarioIngrediente"].ToString());

                        if (!string.IsNullOrEmpty(reader["VlValorIngredientePersonalizado"].ToString()))
                            obj.VlValorIngredientePersonalizado = Convert.ToDouble(reader["VlValorIngredientePersonalizado"].ToString());


                        //----------------------- dados do lanche ----------------------//
                        if (!string.IsNullOrEmpty(reader["DsCardapio"].ToString()))
                            obj.DsCardapio = reader["DsCardapio"].ToString();

                        //----------------------- caso queira retornar mensagem de sucesso ou de erro da proc ----------------------//
                        if (!string.IsNullOrEmpty(reader["mensagem"].ToString()))
                            obj.MensagemRetorno = reader["mensagem"].ToString();

                        retorno.Add(obj);
                    }
                }
                reader.Close();

                return retorno;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }



    }
}
