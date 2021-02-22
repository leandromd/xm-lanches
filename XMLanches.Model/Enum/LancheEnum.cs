using System;
using System.ComponentModel;
using System.Reflection;

namespace XMLanches.Model.Enum
{
    public static class LancheEnumExtensions
    {
        public enum LancheEnum
        {

            [Description("Pedido criado com com sucesso.")]
            MsgPedidoCriado = 1,

            [Description("Erro: um erro ocorreu ao abrir o pedido. Favor entrar em contato com o suporte.")]
            ErroExcAddPedido = 2,

            [Description("Erro: um erro ocorreu ao consultar os lanches do cardápio. Favor entrar em contato com o suporte.")]
            ErroExcGetCardapio = 3,
            
            [Description("Erro: um erro ocorreu ao consultar os ingredientes. Favor entrar em contato com o suporte.")]
            ErroExcGetIngredientes = 4,

            [Description("Erro: um erro ocorreu ao inserir o item ao pedido. Favor entrar em contato com o suporte.")]
            ErroExcAddItemPedido = 5,

            [Description("Erro: um erro ocorreu ao excluir o item do pedido. Favor entrar em contato com o suporte.")]
            ErroExcDelItemPedido = 6,

            [Description("Erro: um erro ocorreu ao inserir o ingreente ao lanche. Favor entrar em contato com o suporte.")]
            ErroExcAddIngredientePersonalizado = 7,
        }


        public static string Descricao(this LancheEnum valor)
        {
            FieldInfo field = valor.GetType().GetField(valor.ToString());

            DescriptionAttribute attribute
                    = Attribute.GetCustomAttribute(field, typeof(DescriptionAttribute))
                        as DescriptionAttribute;

            return attribute == null ? valor.ToString() : attribute.Description;
        }
    }
}
