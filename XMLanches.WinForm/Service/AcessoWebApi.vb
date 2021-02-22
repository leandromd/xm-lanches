Imports System.IO
Imports System.Net
Imports System.Runtime.Serialization.Json
Imports System.Text
Imports Newtonsoft.Json
Imports XMLanches.WinForm

Public Class AcessoWebApi

    Shared baseUrl As String = "https://localhost:44391/api/xmenlanches/"

    Public Shared Function ConsultaCardapio() As List(Of CardapioClientModel)

        Dim client = New WebClient()
        client.Headers.Add("User-Agent", "Nobody")

        Dim url As String = baseUrl + "GetCardapio"

        Try
            Dim consulta = client.DownloadString(New Uri(url))

            'Dim retorno As CardapioClientModel = JsonConvert.DeserializeObject(Of CardapioClientModel)(consulta)
            Dim serializer As New DataContractJsonSerializer(GetType(List(Of CardapioClientModel)))
            Using ms = New MemoryStream(Encoding.Unicode.GetBytes(consulta))
                Dim retorno = DirectCast(serializer.ReadObject(ms), List(Of CardapioClientModel))
                Return retorno
            End Using

        Catch ex As Exception
            Throw ex
        End Try

    End Function

    Public Shared Function ConsultaIngredientes(idCardapio) As List(Of IngredienteClientModel)

        Dim client = New WebClient()
        client.Headers.Add("User-Agent", "Nobody")

        Dim url As String = baseUrl + "GetIngredientes"

        Try
            Dim requisicao As Specialized.NameValueCollection = New Specialized.NameValueCollection()
            requisicao.Add("Cardapio", idCardapio.ToString())

            Dim consulta = client.UploadValues(New Uri(url), "POST", requisicao)

            Dim serializer As New DataContractJsonSerializer(GetType(List(Of IngredienteClientModel)))
            Using ms = New MemoryStream(consulta)
                Dim retorno = DirectCast(serializer.ReadObject(ms), List(Of IngredienteClientModel))
                Return retorno
            End Using

        Catch ex As Exception
            Throw ex
        End Try

    End Function


    Public Shared Function AbrePedido() As String

        Dim client = New WebClient()
        client.Headers.Add("User-Agent", "Nobody")

        Dim url As String = baseUrl + "AddPedido"

        Try
            Dim requisicao As Specialized.NameValueCollection = New Specialized.NameValueCollection()
            requisicao.Add("NomeChamada", "")
            requisicao.Add("CPF", "")
            requisicao.Add("DataInicio", Now.ToString("yyyy-MM-dd HH:mm:ss"))

            Dim consulta = client.UploadValues(New Uri(url), "POST", requisicao)
            Dim retorno = Replace((New Text.UTF8Encoding).GetString(consulta), """", "")
            Return retorno

        Catch ex As Exception
            Throw ex
        End Try

    End Function


    Public Shared Function NovoItemPedido(idPedido As String, idCardapio As String, quantidade As String) As List(Of PedidoClientModel)

        Dim client = New WebClient()
        client.Headers.Add("User-Agent", "Nobody")

        Dim url As String = baseUrl + "AddItemPedido"

        Try
            Dim requisicao As Specialized.NameValueCollection = New Specialized.NameValueCollection()
            requisicao.Add("Pedido", idPedido.ToString())
            requisicao.Add("Cardapio", idCardapio.ToString())
            requisicao.Add("Quantidade", quantidade.ToString())

            Dim consulta = client.UploadValues(New Uri(url), "POST", requisicao)

            Dim serializer As New DataContractJsonSerializer(GetType(List(Of PedidoClientModel)))
            Using ms = New MemoryStream(consulta)
                Dim retorno = DirectCast(serializer.ReadObject(ms), List(Of PedidoClientModel))
                Return retorno
            End Using


        Catch ex As Exception
            Throw ex
        End Try

    End Function


    Public Shared Function ApagaItemPedido(idPedido As String, idItem As String) As List(Of PedidoClientModel)

        Dim client = New WebClient()
        client.Headers.Add("User-Agent", "Nobody")

        Dim url As String = baseUrl + "DelItemPedido"

        Try
            Dim requisicao As Specialized.NameValueCollection = New Specialized.NameValueCollection()
            requisicao.Add("Pedido", idPedido.ToString())
            requisicao.Add("Item", idItem.ToString())

            Dim consulta = client.UploadValues(New Uri(url), "POST", requisicao)

            Dim serializer As New DataContractJsonSerializer(GetType(List(Of PedidoClientModel)))
            Using ms = New MemoryStream(consulta)
                Dim retorno = DirectCast(serializer.ReadObject(ms), List(Of PedidoClientModel))
                Return retorno
            End Using


        Catch ex As Exception
            Throw ex
        End Try

    End Function

    Public Shared Function NovoIngredientePersonalizado(idPedido As String, idItem As String, idIngrediente As String, quantidade As String) As List(Of IngredienteClientModel)

        Dim client = New WebClient()
        client.Headers.Add("User-Agent", "Nobody")

        Dim url As String = baseUrl + "AddIngredientePersonalizado"

        Try
            Dim requisicao As Specialized.NameValueCollection = New Specialized.NameValueCollection()
            requisicao.Add("Pedido", idPedido.ToString())
            requisicao.Add("Item", idItem.ToString())
            requisicao.Add("Ingrediente", idIngrediente.ToString())
            requisicao.Add("Quantidade", quantidade.ToString())

            Dim consulta = client.UploadValues(New Uri(url), "POST", requisicao)

            Dim serializer As New DataContractJsonSerializer(GetType(List(Of IngredienteClientModel)))
            Using ms = New MemoryStream(consulta)
                Dim retorno = DirectCast(serializer.ReadObject(ms), List(Of IngredienteClientModel))
                Return retorno
            End Using


        Catch ex As Exception
            Throw ex
        End Try

    End Function

End Class
