Imports System.Drawing.Color


Public Class frmPedido

    Dim cronometro As New Stopwatch

    Dim IdPedido As Integer
    Dim VlPedido As Double

    Dim IdPedidoItem As Integer


    Private Sub frmPedido_Load(sender As Object, e As EventArgs) Handles MyBase.Load

        lblidPedido.Text = ""
        lblTimer.Text = ""
        lblValorPedido.Text = ""

        Dim botao As New DataGridViewButtonColumn()
        grdPedido.Columns.Add(botao)
        botao.HeaderText = ""
        botao.Text = "[ - ]"
        botao.Name = "btnExcluirItem"
        botao.UseColumnTextForButtonValue = True

        ConsultaCardapio()
        ConsultaIngredientes()

        pnlIngredientes.Visible = False

    End Sub


    Private Sub ConsultaCardapio()

        lblMensagem.Text = "Consultando dados"
        Try
            Dim consulta As List(Of CardapioClientModel) = AcessoWebApi.ConsultaCardapio()

            'cria um array de botões dinamicamente para joga dentro de um panel (um para cada lanche do menu)
            Dim objBotoes() As Button = Nothing
            Dim indice As Integer
            indice = 0
            Dim posicao As Integer
            posicao = 30

            ''limpa os botões já existentes neste panel, caso o cardápio seja recarregado
            'For x = 0 To pnlCardapio.Controls.Count - 1
            '    pnlCardapio.Controls.Remove(pnlCardapio.Controls(x))
            'Next

            For Each item In consulta

                '------------------------------------------------------------------------------------
                'captura dados da classe que recebeu o request WEB API (após decodificada do JSON)
                'e cria o objeto simples abaixo
                '------------------------------------------------------------------------------------
                Dim info(3) As Object
                info(0) = item.Codigo
                info(1) = item.Cardapio
                info(2) = item.Valor
                info(3) = item.Personalizavel.ToUpper()

                '------------------------------------------------------------------------------------
                'cria um aray de botões dinamicante e joga dentro de um panel
                'guarda na propriedade tag se é um lanche personalizável ou não
                '------------------------------------------------------------------------------------
                ReDim Preserve objBotoes(indice)
                objBotoes(indice) = New Button
                With objBotoes(indice)
                    .Name = "btnCardapio_" + info(0)
                    If info(3) <> "S" Then
                        .Text = info(1) + vbCr + vbCr + CDbl(info(2)).ToString("R$ #0.00")
                    Else
                        .Text = info(1) + vbCr + vbCr + "(monte o seu!)"
                    End If
                    .Tag = info(3)
                    .Location = New Point(30, posicao)
                    .Size() = New Size(100, 100)
                End With

                AddHandler objBotoes(indice).Click, AddressOf BotoesCardapio_Click
                AddHandler objBotoes(indice).MouseHover, AddressOf BotoesCardapio_MouseHover

                With pnlCardapio.Controls
                    .Add(objBotoes(indice))
                End With

                indice += 1
                posicao += 100

            Next

            lblMensagem.Text = ""

        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try

    End Sub

    Private Sub ConsultaIngredientes()

        lblMensagem.Text = "Consultando dados"
        Try
            Dim consulta As List(Of IngredienteClientModel) = AcessoWebApi.ConsultaIngredientes("")

            'cria um array de botões dinamicamente para joga dentro de um panel (um para cada ingrediente para ser escolhido para lanches personalizados)
            Dim objBotoes() As Button = Nothing
            Dim indice As Integer
            indice = 0
            Dim posicao As Integer
            posicao = 30

            For Each item In consulta

                '------------------------------------------------------------------------------------
                'captura dados da classe que recebeu o request WEB API (após decodificada do JSON)
                'e cria o objeto simples abaixo
                '------------------------------------------------------------------------------------
                Dim info(2) As Object
                info(0) = item.Codigo
                info(1) = item.Ingrediente
                info(2) = CDbl(item.Valor).ToString("R$ #0.00")

                '------------------------------------------------------------------------------------
                'cria um aray de botões dinamicante e joga dentro de um panel
                '------------------------------------------------------------------------------------
                ReDim Preserve objBotoes(indice)
                objBotoes(indice) = New Button
                With objBotoes(indice)
                    .Name = "btnIngrediente_" + info(0)
                    .Text = info(1) + vbCr + vbCr + CDbl(info(2)).ToString("R$ #0.00")
                    .Location = New Point(30, posicao)
                    .Size() = New Size(100, 100)
                End With

                AddHandler objBotoes(indice).Click, AddressOf BotoesIngredientes_Click

                With pnlIngredientes.Controls
                    .Add(objBotoes(indice))
                End With

                indice += 1
                posicao += 100

            Next

            lblMensagem.Text = ""

        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try

    End Sub


    Private Sub btnAbrePedido_Click(sender As Object, e As EventArgs) Handles btnAbrePedido.Click

        AbrePedido()

    End Sub

    Private Sub AbrePedido()

        lblMensagem.Text = "Consultando dados"
        Try
            cronometro.Reset()
            cronometro.Start()

            btnAbrePedido.Enabled = False
            btnFechaPedido.Enabled = True

            Dim consulta As String = AcessoWebApi.AbrePedido()
            lblidPedido.Text = "Seu pedido de número " + consulta + " está em andamento"
            lblValorPedido.Text = ""

            IdPedido = CInt(consulta)
            VlPedido = 0

            pnlCardapio.Enabled = True
            grdPedido.Visible = True
            grdIngredientes.Visible = True

            lblMensagem.Text = ""

        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try


    End Sub

    Private Sub timerPedido_Tick(sender As Object, e As EventArgs) Handles timerPedido.Tick

        If cronometro.IsRunning Then
            Dim ts As TimeSpan = cronometro.Elapsed

            lblTimer.Text = String.Format("{0:00}:{1:00}:{2:00}.{3:00}", ts.Hours, ts.Minutes, ts.Seconds, ts.Milliseconds / 10)
        End If

    End Sub


    Private Sub btnFechaPedido_Click(sender As Object, e As EventArgs) Handles btnFechaPedido.Click

        FechaPedido()

    End Sub

    Private Sub FechaPedido()

        lblMensagem.Text = "Consultando dados"
        Try
            Dim ts As TimeSpan = cronometro.Elapsed

            If cronometro.IsRunning Then
                cronometro.Stop()
                cronometro.Reset()
            End If

            btnAbrePedido.Enabled = True
            btnFechaPedido.Enabled = False
            pnlCardapio.Enabled = False

            lblMensagem.Text = ""

        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try

    End Sub

    Private Sub BotoesCardapio_Click(ByVal sender As Button, ByVal e As EventArgs)

        'botões criados dinamicamente - para selecionar lanches do menu

        Dim idCardapio As Integer
        idCardapio = CInt(Replace(sender.Name, "btnCardapio_", ""))

        Dim quantidade As Integer = 1
        NovoItemPedido(IdPedido, idCardapio, quantidade, sender.Tag)

    End Sub
    Private Sub BotoesCardapio_MouseHover(ByVal sender As Button, ByVal e As EventArgs)

        'botões criados dinamicamente - para selecionar lanches do menu

        Dim idCardapio As Integer
        idCardapio = CInt(Replace(sender.Name, "btnCardapio_", ""))

        ConsultaIngredientesCardapio(idCardapio, sender.Tag)

    End Sub

    Private Sub BotoesIngredientes_Click(ByVal sender As Button, ByVal e As EventArgs)

        'botões criados dinamicamente - para selecionar ingredientes para o lanche personalizado

        Dim idIngrediente As Integer
        idIngrediente = CInt(Replace(sender.Name, "btnIngrediente_", ""))

        Dim quantidade As Integer = 1
        NovoIngredientePersonalizado(IdPedido, IdPedidoItem, idIngrediente, quantidade)

    End Sub

    Public Sub ConsultaIngredientesCardapio(cardapio, personalizavel)

        'quando passa o mouse pelo botão
        lblMensagem.Text = "Consultando dados"
        Try

            Dim consulta As List(Of IngredienteClientModel)
            If personalizavel <> "S" Then
                'traz os dados da web api
                consulta = AcessoWebApi.ConsultaIngredientes(cardapio)
                CarregaGridIngredientes(consulta)
            Else
                'limpa a grid de ingredientes
                lblMensagem.Text = ""
                grdIngredientes.DataSource = Nothing
            End If


        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try

    End Sub

    Public Sub NovoItemPedido(pedido, cardapio, quant, personalizavel)

        lblMensagem.Text = "Consultando dados"
        IdPedidoItem = 0
        Try

            Dim consulta As List(Of PedidoClientModel) = AcessoWebApi.NovoItemPedido(pedido, cardapio, quant)
            CarregaGridPedido(consulta)

            'se retorno com sucesso e trata-se de lanche pernoalizável
            If consulta.Count > 0 And personalizavel = "S" Then

                'se retornou ID do item com sucesso, trabalha com ele 

                If Not String.IsNullOrEmpty(consulta(consulta.Count - 1).Item) Then
                    IdPedidoItem = CInt(consulta(consulta.Count - 1).Item)

                    'esconde painel de botões de lanches e traz panel de botões de ingredientes
                    pnlCardapio.Visible = False
                    grdPedido.Enabled = False

                    btnPersonalizacao.Visible = True
                    pnlIngredientes.Visible = True
                    pnlIngredientes.Enabled = True
                End If

            End If

        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try

    End Sub

    Public Sub NovoIngredientePersonalizado(pedido, item, ingrediente, quant)

        lblMensagem.Text = "Consultando dados"
        Try

            Dim consulta As List(Of IngredienteClientModel) = AcessoWebApi.NovoIngredientePersonalizado(pedido, item, ingrediente, quant)

            CarregaGridIngredientes(consulta, True)


        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try

    End Sub

    Private Sub CarregaGridPedido(consulta As List(Of PedidoClientModel))

        lblMensagem.Text = ""
        Try

            'verifica se retornaram dados
            If consulta.Count > 0 Then

                Dim dt As New DataTable()

                'verifica se retornaram dados válidos (ID do item válido) -- pois podem vir dados de um pedido sem itens, ou seja, um recordset com quase rodos valores vazios)
                If consulta(0).Item <> "0" Then

                    'cria colunas que vão alimentar o data grid
                    dt.Columns.Add("id", GetType(String))
                    dt.Columns.Add("Lanche", GetType(String))
                    dt.Columns.Add("Valor" + vbCr + " Unitário", GetType(String))
                    dt.Columns.Add("Qtde", GetType(String))
                    dt.Columns.Add("Valor", GetType(String))
                    dt.Columns.Add("Desconto" + vbCr + "Promocional", GetType(String))
                    dt.Columns.Add("Valor Final", GetType(String))
                    dt.Columns.Add("Promoção", GetType(String))

                    'consulta retorno da webapi
                    For Each item In consulta

                        'cria objeto para adicionar ao recordset que vai para o grid
                        Dim linha(7) As Object
                        linha(0) = item.Item
                        linha(1) = item.Descricao
                        linha(2) = CDbl(item.ValorUnitario).ToString("R$ #0.00")
                        linha(3) = item.Quantidade
                        linha(4) = CDbl(item.Valor).ToString("R$ #0.00")
                        linha(5) = CDbl(item.ValorPromocao).ToString("R$ #0.00")
                        linha(6) = CDbl(item.ValorFinal).ToString("R$ #0.00")
                        linha(7) = item.Promocao

                        dt.Rows.Add(linha)
                    Next

                    'atualizado valor do pedido na tela e na variável
                    lblValorPedido.Text = CDbl(consulta(0).ValorPedido).ToString("R$ #0.00")
                    VlPedido = CDbl(consulta(0).ValorPedido)

                    'traz mensagem de sucesso ou erro
                    lblMensagem.Text = consulta(0).Mensagem

                End If

                'atualiza grid com recordset
                grdPedido.DataSource = dt

                If consulta(0).Item <> "0" Then
                    'ajusta o tamanho do coluna que tem botão
                    grdPedido.Columns(0).Width = 30
                    'esconde a coluna de ID
                    grdPedido.Columns(1).Visible = False
                End If

            End If

        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try

    End Sub

    Private Sub CarregaGridIngredientes(consulta As List(Of IngredienteClientModel), Optional personalizacao As Boolean = False)

        lblMensagem.Text = ""
        Try

            'verifica se retornaram dados (se não, limpa o grid, deve ser "limpeza" vindo dos "mouse hover"
            If consulta.Count = 0 Then
                grdIngredientes.DataSource = Nothing

            Else

                Dim dt As New DataTable()

                'verifica se retornaram dados válidos (ID do ingrediente válido)
                If consulta(0).Codigo <> "0" Then

                    'cria colunas que vão alimentar o data grid
                    dt.Columns.Add("id", GetType(String))
                    dt.Columns.Add("Ingrediente", GetType(String))
                    dt.Columns.Add("Qtde", GetType(String))

                    If Not personalizacao Then
                        dt.Columns.Add("Valor", GetType(String))
                    Else

                    End If



                    'consulta retorno da webapi
                    For Each item In consulta

                        'cria objeto para adicionar ao recordset que vai para o grid
                        Dim linha(IIf(Not personalizacao, 3, 7)) As Object
                        linha(0) = item.Codigo
                        linha(1) = item.Ingrediente
                        linha(2) = item.Quantidade
                        If Not personalizacao Then
                            linha(3) = CDbl(item.Valor).ToString("R$ #0.00")
                        Else

                        End If

                        dt.Rows.Add(linha)
                    Next

                    'traz mensagem de sucesso ou erro
                    'lblMensagem.Text = consulta(0).Mensagem

                End If

                'atualiza grid com recordset
                grdIngredientes.DataSource = dt
                'esconde a coluna de ID e aumenta a do nome do ingrediente
                grdIngredientes.Columns(0).Visible = False
                grdIngredientes.Columns(1).Width = 200

            End If

        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try
    End Sub


    Private Sub grdCardapio_CellClick(sender As Object, e As DataGridViewCellEventArgs) Handles grdPedido.CellClick

        lblMensagem.Text = ""
        Try
            If e.ColumnIndex = 0 And grdPedido.Columns.Count > 1 Then
                If e.RowIndex + 1 < grdPedido.Rows.Count Then

                    Dim item As String = grdPedido.Rows(e.RowIndex).Cells(1).Value
                    ApagaItemPedido(IdPedido, item)

                End If
            End If

        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try

    End Sub

    Public Sub ApagaItemPedido(pedido, item)

        lblMensagem.Text = "Consultando dados"
        Try

            Dim consulta As List(Of PedidoClientModel) = AcessoWebApi.ApagaItemPedido(pedido, item)
            CarregaGridPedido(consulta)

        Catch ex As Exception
            lblMensagem.Text = ex.Message
        End Try

    End Sub


    Private Sub pnlCardapio_MouseHover(sender As Object, e As EventArgs) Handles pnlCardapio.MouseHover

        'quando passa o mouse pelo panel (ou seja, saiu do botão)

        'limpa a grid de ingredientes
        grdIngredientes.DataSource = Nothing

    End Sub

    Private Sub frmPedido_MouseHover(sender As Object, e As EventArgs) Handles Me.MouseHover

        'quando passa o mouse pelo form (ou seja, saiu do botão)

        'limpa a grid de ingredientes
        grdIngredientes.DataSource = Nothing
    End Sub

    Private Sub grdCardapio_MouseHover(sender As Object, e As EventArgs) Handles grdPedido.MouseHover

        'quando passa o mouse pel agrid (ou seja, saiu do botão)

        'limpa a grid de ingredientes
        grdIngredientes.DataSource = Nothing

    End Sub


    Private Sub btnPersonalizacao_Click_1(sender As Object, e As EventArgs) Handles btnPersonalizacao.Click

        IdPedidoItem = 0

        btnPersonalizacao.Visible = False
        pnlIngredientes.Enabled = False
        pnlIngredientes.Visible = False

        pnlCardapio.Visible = True
        grdPedido.Enabled = True


    End Sub
End Class





