<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class frmPedido
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container()
        Me.lblMensagem = New System.Windows.Forms.Label()
        Me.pnlCardapio = New System.Windows.Forms.Panel()
        Me.lblidPedido = New System.Windows.Forms.Label()
        Me.btnAbrePedido = New System.Windows.Forms.Button()
        Me.timerPedido = New System.Windows.Forms.Timer(Me.components)
        Me.lblTimer = New System.Windows.Forms.Label()
        Me.btnFechaPedido = New System.Windows.Forms.Button()
        Me.grdPedido = New System.Windows.Forms.DataGridView()
        Me.lblValorPedido = New System.Windows.Forms.Label()
        Me.grdIngredientes = New System.Windows.Forms.DataGridView()
        Me.pnlIngredientes = New System.Windows.Forms.Panel()
        Me.btnPersonalizacao = New System.Windows.Forms.Button()
        CType(Me.grdPedido, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.grdIngredientes, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'lblMensagem
        '
        Me.lblMensagem.AutoSize = True
        Me.lblMensagem.Location = New System.Drawing.Point(166, 554)
        Me.lblMensagem.Name = "lblMensagem"
        Me.lblMensagem.Size = New System.Drawing.Size(71, 13)
        Me.lblMensagem.TabIndex = 2
        Me.lblMensagem.Text = "Carregando..."
        '
        'pnlCardapio
        '
        Me.pnlCardapio.AutoScroll = True
        Me.pnlCardapio.Dock = System.Windows.Forms.DockStyle.Left
        Me.pnlCardapio.Enabled = False
        Me.pnlCardapio.Location = New System.Drawing.Point(164, 0)
        Me.pnlCardapio.Name = "pnlCardapio"
        Me.pnlCardapio.Size = New System.Drawing.Size(164, 607)
        Me.pnlCardapio.TabIndex = 3
        '
        'lblidPedido
        '
        Me.lblidPedido.AutoSize = True
        Me.lblidPedido.Location = New System.Drawing.Point(178, 50)
        Me.lblidPedido.Name = "lblidPedido"
        Me.lblidPedido.Size = New System.Drawing.Size(59, 13)
        Me.lblidPedido.TabIndex = 4
        Me.lblidPedido.Text = "seu pedido"
        '
        'btnAbrePedido
        '
        Me.btnAbrePedido.Location = New System.Drawing.Point(170, 12)
        Me.btnAbrePedido.Name = "btnAbrePedido"
        Me.btnAbrePedido.Size = New System.Drawing.Size(131, 25)
        Me.btnAbrePedido.TabIndex = 5
        Me.btnAbrePedido.Text = "Novo Pedido"
        Me.btnAbrePedido.UseVisualStyleBackColor = True
        '
        'timerPedido
        '
        Me.timerPedido.Enabled = True
        Me.timerPedido.Interval = 1000
        '
        'lblTimer
        '
        Me.lblTimer.AutoSize = True
        Me.lblTimer.Location = New System.Drawing.Point(178, 72)
        Me.lblTimer.Name = "lblTimer"
        Me.lblTimer.Size = New System.Drawing.Size(49, 13)
        Me.lblTimer.TabIndex = 6
        Me.lblTimer.Text = "00:00:00"
        '
        'btnFechaPedido
        '
        Me.btnFechaPedido.Enabled = False
        Me.btnFechaPedido.Location = New System.Drawing.Point(572, 528)
        Me.btnFechaPedido.Name = "btnFechaPedido"
        Me.btnFechaPedido.Size = New System.Drawing.Size(130, 23)
        Me.btnFechaPedido.TabIndex = 7
        Me.btnFechaPedido.Text = "Concluir Pedido"
        Me.btnFechaPedido.UseVisualStyleBackColor = True
        '
        'grdPedido
        '
        Me.grdPedido.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.grdPedido.EditMode = System.Windows.Forms.DataGridViewEditMode.EditProgrammatically
        Me.grdPedido.Location = New System.Drawing.Point(160, 106)
        Me.grdPedido.Name = "grdPedido"
        Me.grdPedido.Size = New System.Drawing.Size(545, 229)
        Me.grdPedido.TabIndex = 8
        Me.grdPedido.Visible = False
        '
        'lblValorPedido
        '
        Me.lblValorPedido.AutoSize = True
        Me.lblValorPedido.Location = New System.Drawing.Point(300, 72)
        Me.lblValorPedido.Name = "lblValorPedido"
        Me.lblValorPedido.Size = New System.Drawing.Size(45, 13)
        Me.lblValorPedido.TabIndex = 9
        Me.lblValorPedido.Text = "R$ 0,00"
        '
        'grdIngredientes
        '
        Me.grdIngredientes.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.grdIngredientes.EditMode = System.Windows.Forms.DataGridViewEditMode.EditProgrammatically
        Me.grdIngredientes.Location = New System.Drawing.Point(160, 344)
        Me.grdIngredientes.Name = "grdIngredientes"
        Me.grdIngredientes.Size = New System.Drawing.Size(542, 166)
        Me.grdIngredientes.TabIndex = 10
        Me.grdIngredientes.Visible = False
        '
        'pnlIngredientes
        '
        Me.pnlIngredientes.AutoScroll = True
        Me.pnlIngredientes.Dock = System.Windows.Forms.DockStyle.Left
        Me.pnlIngredientes.Enabled = False
        Me.pnlIngredientes.Location = New System.Drawing.Point(0, 0)
        Me.pnlIngredientes.Name = "pnlIngredientes"
        Me.pnlIngredientes.Size = New System.Drawing.Size(164, 607)
        Me.pnlIngredientes.TabIndex = 11
        '
        'btnPersonalizacao
        '
        Me.btnPersonalizacao.Location = New System.Drawing.Point(170, 528)
        Me.btnPersonalizacao.Name = "btnPersonalizacao"
        Me.btnPersonalizacao.Size = New System.Drawing.Size(130, 23)
        Me.btnPersonalizacao.TabIndex = 14
        Me.btnPersonalizacao.Text = "Concluir Personalização"
        Me.btnPersonalizacao.UseVisualStyleBackColor = True
        Me.btnPersonalizacao.Visible = False
        '
        'frmPedido
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(730, 607)
        Me.Controls.Add(Me.btnPersonalizacao)
        Me.Controls.Add(Me.grdIngredientes)
        Me.Controls.Add(Me.lblValorPedido)
        Me.Controls.Add(Me.grdPedido)
        Me.Controls.Add(Me.btnFechaPedido)
        Me.Controls.Add(Me.lblTimer)
        Me.Controls.Add(Me.btnAbrePedido)
        Me.Controls.Add(Me.lblidPedido)
        Me.Controls.Add(Me.pnlCardapio)
        Me.Controls.Add(Me.lblMensagem)
        Me.Controls.Add(Me.pnlIngredientes)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D
        Me.Name = "frmPedido"
        Me.Text = "Pedidos de lanches - XM Lanches"
        CType(Me.grdPedido, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.grdIngredientes, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents lblMensagem As Label
    Friend WithEvents pnlCardapio As Panel
    Friend WithEvents lblidPedido As Label
    Friend WithEvents btnAbrePedido As Button
    Friend WithEvents timerPedido As Timer
    Friend WithEvents lblTimer As Label
    Friend WithEvents btnFechaPedido As Button
    Friend WithEvents grdPedido As DataGridView
    Friend WithEvents lblValorPedido As Label
    Friend WithEvents grdIngredientes As DataGridView
    Friend WithEvents pnlIngredientes As Panel
    Friend WithEvents btnPersonalizacao As Button
End Class
