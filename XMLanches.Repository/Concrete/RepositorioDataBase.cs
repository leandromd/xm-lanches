using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;


namespace XMLanches.Repository.Concrete
{
    public class RepositorioDataBase
    {
        #region "SQL Server"

        private static string stringDeConexaoSQL = "";

        public RepositorioDataBase()
        {
            stringDeConexaoSQL = ConfigurationManager.ConnectionStrings["XMLanchesConnection"].ToString();
            //stringDeConexaoSQL = "Data Source = 172.16.2.223; Initial Catalog = SisunColegio; Persist Security Info = True; User ID = sa; Password = Banco$teste2019; Application Name = Conexao Sisun Colégio;";
            //stringDeConexaoSQL = ConexaoBase.ObterConexao();
            //stringDeConexaoSQL = "Data Source=172.16.2.12; Initial Catalog=ColegioCursoObjetivo;Persist Security Info=True;User ID=UserUnip;Password=delstv$2014@psw;Application Name=Conexao Sisun Colégio;";
        }

        public static void ExecutaStoredProcedureNonQuery(string sql, params SqlParameter[] param)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            cmd.CommandType = CommandType.StoredProcedure;

            //SqlParameter parameter;

            foreach (var p in param)
                cmd.Parameters.Add(p);
            SqlParameter pRet = new SqlParameter("@RETURN_VALUE", SqlDbType.Int, 0);
            pRet.Value = 0;
            pRet.Direction = ParameterDirection.ReturnValue;
            cmd.Parameters.Add(pRet);

            try
            {
                cn.Open();
                cmd.ExecuteNonQuery();
                if (!pRet.Value.Equals(0))
                    throw new Exception("Execução do objeto " + sql);
            }
            catch (SqlException sqlErro)
            {
                throw new Exception(sqlErro.Message);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }
        }

        public static void ExecutaStoredProcedureNonQuery(string sql)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            cmd.CommandType = CommandType.StoredProcedure;

            try
            {
                cn.Open();
                SqlParameter pRet = new SqlParameter("@RETURN_VALUE", SqlDbType.Int, 0);
                pRet.Direction = ParameterDirection.ReturnValue;
                pRet.Value = 0;
                cmd.Parameters.Add(pRet);
                cmd.ExecuteNonQuery();
                if (!pRet.Value.Equals(0))
                    throw new Exception("Execução do objeto " + sql);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }
        }

        public static SqlDataReader ExecutaStoredProcedureDataReader(string sql, params SqlParameter[] param)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);

            //TODO - voltar essa variável no parâmetro abaixo. Está fixada a string de conexão pois estava vindo a string do banco 12
            //SqlConnection cn = new SqlConnection("Data Source=172.16.2.223; Initial Catalog=SisunColegio;Persist Security Info=True;User ID=sa;Password=banco$teste2019;Application Name=Conexao Sisun Colégio;");

            SqlCommand cmd = new SqlCommand(sql, cn);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlDataReader dr;

            //SqlParameter p;
            foreach (var p in param)
                cmd.Parameters.Add(p);
            SqlParameter pRet = new SqlParameter("@RETURN_VALUE", 0);
            pRet.Direction = ParameterDirection.ReturnValue;
            pRet.Value = 0;
            cmd.Parameters.Add(pRet);
            cmd.CommandTimeout = 720;
            try
            {
                cn.Open();
                dr = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!pRet.Value.Equals(0))
                    throw new Exception("Execução do objeto " + sql);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dr;
        }

        public static SqlDataReader ExecutaStoredProcedureDataReaderRetornaRaiserror(string sql, params SqlParameter[] param)
        { //leandromd 13abr20 - criado para receber o RAISERROR que a proceure retorna com classe 16 - exemplo: RAISERROR ('(01) - parcela não pode ser impressa. Por favor, dirija-se à tesouraria da sua unidade.',16,1) 
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlDataReader dr;

            //SqlParameter p;
            foreach (var p in param)
                cmd.Parameters.Add(p);
            SqlParameter pRet = new SqlParameter("@RETURN_VALUE", 0);
            pRet.Direction = ParameterDirection.ReturnValue;
            pRet.Value = 0;
            cmd.Parameters.Add(pRet);
            cmd.CommandTimeout = 720;
            try
            {
                cn.Open();
                dr = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!pRet.Value.Equals(0))
                    throw new Exception("Execução do objeto " + sql);
            }
            catch (SqlException ex)
            {
                string mensagemErro = ex.Message;
                if (ex.Class == 16) mensagemErro = "class=" + ex.Class.ToString() + "/" + mensagemErro;
                throw new Exception(mensagemErro);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dr;
        }


        public static SqlDataReader ExecutaStoredProcedureDataReader(string sql)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlDataReader dr;

            try
            {
                cn.Open();
                SqlParameter pRet = new SqlParameter("@RETURN_VALUE", SqlDbType.Int, 0);
                pRet.Direction = ParameterDirection.ReturnValue;
                pRet.Value = 0;
                cmd.Parameters.Add(pRet);
                dr = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!pRet.Value.Equals(0))
                    throw new Exception("Erro na execução do objeto " + sql);
            }
            catch (Exception ex)
            {
                throw new Exception("Erro na execução do objeto " + sql + ". " + ex.Message);
            }
            return dr;
        }

        public static DataTable ExecutaStoredProcedureDataTable(string sql, params SqlParameter[] param)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dtb = new DataTable();

            //SqlParameter p;
            foreach (var p in param)
                cmd.Parameters.Add(p);
            SqlParameter pRet = new SqlParameter("@RETURN_VALUE", SqlDbType.Int, 0);
            pRet.Direction = ParameterDirection.ReturnValue;
            pRet.Value = 0;
            cmd.Parameters.Add(pRet);
            cmd.CommandTimeout = 70;
            try
            {
                cn.Open();
                dtb.Load(cmd.ExecuteReader(CommandBehavior.CloseConnection));
                if (!pRet.Value.Equals(0))
                    throw new Exception("Execução do objeto " + sql);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dtb;
        }

        public static DataTable ExecutaStoredProcedureDataTable(string sql)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dtb = new DataTable();

            SqlParameter pRet = new SqlParameter("@RETURN_VALUE", SqlDbType.Int, 0);
            pRet.Direction = ParameterDirection.ReturnValue;
            pRet.Value = 0;
            cmd.Parameters.Add(pRet);

            try
            {
                cn.Open();
                dtb.Load(cmd.ExecuteReader(CommandBehavior.CloseConnection));
                if (!pRet.Value.Equals(0))
                    throw new Exception("Execução do objeto " + sql);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dtb;
        }

        public static object ExecutaStoredProcedureSQLScalar(string sql)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            cmd.CommandType = CommandType.StoredProcedure;

            object result;
            try
            {
                cn.Open();
                SqlParameter pRet = new SqlParameter("@RETURN_VALUE", SqlDbType.Int, 0);
                pRet.Direction = ParameterDirection.ReturnValue;
                pRet.Value = 0;
                cmd.Parameters.Add(pRet);
                result = cmd.ExecuteScalar();
                if (!pRet.Value.Equals(0))
                    throw new Exception("Erro na execução do objeto " + sql);
            }
            catch (Exception ex)
            {
                throw new Exception("Erro na execução do objeto " + sql + ". " + ex.Message);
            }
            finally
            {
                cn.Close();
            }
            return result;
        }

        public static object ExecutaStoredProcedureSQLScalar(string sql, params SqlParameter[] param)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            object result;
            //SqlParameter p;

            cmd.CommandType = CommandType.StoredProcedure;

            foreach (var p in param)
                cmd.Parameters.Add(p);
            SqlParameter pRet = new SqlParameter("@RETURN_VALUE", SqlDbType.Int, 0);
            pRet.Direction = ParameterDirection.ReturnValue;
            pRet.Value = 0;
            cmd.Parameters.Add(pRet);

            try
            {
                cn.Open();
                result = cmd.ExecuteScalar();
                if (!pRet.Value.Equals(0))
                    throw new Exception("Execução do objeto " + sql);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }
            return result;
        }

        public static DataSet ExecutaSQLDataSet(string sql)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlDataAdapter da = new SqlDataAdapter(sql, cn);
            DataSet ds = new DataSet();
            try
            {
                cn.Open();
                da.Fill(ds);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }
            return ds;
        }

        public static DataSet ExecutaSQLDataSet(string sql, params SqlParameter[] param)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlDataAdapter da = new SqlDataAdapter(sql, cn);

            //SqlParameter p;
            foreach (var p in param)
                da.SelectCommand.Parameters.Add(p);

            DataSet ds = new DataSet();
            try
            {
                cn.Open();
                da.Fill(ds);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }

            return ds;
        }

        public static DataTable ExecutaSQLDataTable(string sql)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlDataAdapter da = new SqlDataAdapter(sql, cn);
            DataTable dt = new DataTable();
            try
            {
                cn.Open();
                da.Fill(dt);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }
            return dt;
        }

        public static DataTable ExecutaSQLDataTable(string sql, params SqlParameter[] param)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlDataAdapter da = new SqlDataAdapter(sql, cn);

            //SqlParameter p;
            foreach (var p in param)
                da.SelectCommand.Parameters.Add(p);

            DataTable dt = new DataTable();
            try
            {
                cn.Open();
                da.Fill(dt);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }
            return dt;
        }

        public static object ExecutaSQLScalar(string sql)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            object result;
            try
            {
                cn.Open();
                result = cmd.ExecuteScalar();
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }
            return result;
        }

        public static object ExecutaSQLScalar(string sql, params SqlParameter[] param)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            object result;

            //SqlParameter p;
            foreach (var p in param)
                cmd.Parameters.Add(p);

            try
            {
                cn.Open();
                result = cmd.ExecuteScalar();
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }
            return result;
        }

        public static SqlDataReader ExecutaSQLReader(string sql)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            SqlDataReader dr;
            try
            {
                cn.Open();
                cmd.CommandTimeout = 600;
                dr = cmd.ExecuteReader(CommandBehavior.CloseConnection);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dr;
        }

        public static SqlDataReader ExecutaSQLReader(string sql, params SqlParameter[] param)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            SqlDataReader dr;

            //SqlParameter p;
            foreach (var p in param)
                cmd.Parameters.Add(p);

            try
            {
                cn.Open();
                dr = cmd.ExecuteReader(CommandBehavior.CloseConnection);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dr;
        }

        public static void ExecutaSQLNonQuery(string sql, params SqlParameter[] param)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);

            //SqlParameter p;
            foreach (var p in param)
                cmd.Parameters.Add(p);

            try
            {
                cn.Open();
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }
        }

        public static void ExecutaSQLNonQuery(string sql)
        {
            SqlConnection cn = new SqlConnection(stringDeConexaoSQL);
            SqlCommand cmd = new SqlCommand(sql, cn);
            try
            {
                cn.Open();
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cn.Close();
            }
        }

        #endregion

        public void Dispose()
        {
            throw new NotImplementedException();
        }

    }
}
