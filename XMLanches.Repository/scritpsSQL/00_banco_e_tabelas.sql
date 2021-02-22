USE [master]
GO

/****** Object:  Database [dbProvaMutant2014]    Script Date: 20/02/2021 10:07:08 ******/
CREATE DATABASE [dbProvaMutant2014]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'dbProvaMutant2014', FILENAME = N'D:\SQLServer2017Dev\MSSQL14.SQLSERVER2017\MSSQL\DATA\dbProvaMutant2014.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'dbProvaMutant2014_log', FILENAME = N'D:\SQLServer2017Dev\MSSQL14.SQLSERVER2017\MSSQL\DATA\dbProvaMutant2014_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [dbProvaMutant2014] SET COMPATIBILITY_LEVEL = 120
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [dbProvaMutant2014].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [dbProvaMutant2014] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET ARITHABORT OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [dbProvaMutant2014] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [dbProvaMutant2014] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET  DISABLE_BROKER 
GO

ALTER DATABASE [dbProvaMutant2014] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [dbProvaMutant2014] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET RECOVERY FULL 
GO

ALTER DATABASE [dbProvaMutant2014] SET  MULTI_USER 
GO

ALTER DATABASE [dbProvaMutant2014] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [dbProvaMutant2014] SET DB_CHAINING OFF 
GO

ALTER DATABASE [dbProvaMutant2014] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [dbProvaMutant2014] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [dbProvaMutant2014] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [dbProvaMutant2014] SET QUERY_STORE = OFF
GO

ALTER DATABASE [dbProvaMutant2014] SET  READ_WRITE 
GO

USE [dbProvaMutant2014]
GO


/****** Object:  Table [dbo].[tbIngrediente]    Script Date: 20/02/2021 12:27:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbIngrediente](
	[idIngrediente] [int] IDENTITY(1,1) NOT NULL,
	[dsIngrediente] [varchar](50) NOT NULL,
	[flAtivo] [bit] NOT NULL,
 CONSTRAINT [PK_tbIngrediente] PRIMARY KEY CLUSTERED 
(
	[idIngrediente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tbIngrediente] ADD  DEFAULT ((1)) FOR [flAtivo]
GO


GO

/****** Object:  Table [dbo].[tbIngredienteValor]    Script Date: 20/02/2021 12:19:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbIngredienteValor](
	[idIngredienteValor] [bigint] IDENTITY(1,1) NOT NULL,
	[idIngrediente] [int] NOT NULL,
	[dtValor] [date] NOT NULL,
	[vlValor] [numeric](10, 2) NOT NULL,
 CONSTRAINT [PK_tbIngredienteValor] PRIMARY KEY CLUSTERED 
(
	[idIngredienteValor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tbIngredienteValor]  WITH CHECK ADD  CONSTRAINT [FK_tbIngredienteValor_tbIngrediente] FOREIGN KEY([idIngrediente])
REFERENCES [dbo].[tbIngrediente] ([idIngrediente])
GO

ALTER TABLE [dbo].[tbIngredienteValor] CHECK CONSTRAINT [FK_tbIngredienteValor_tbIngrediente]
GO


GO

/****** Object:  Table [dbo].[tbCardapio]    Script Date: 20/02/2021 12:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbCardapio](
	[idCardapio] [int] IDENTITY(1,1) NOT NULL,
	[dsCardapio] [varchar](50) NOT NULL,
	[flAtivo] [bit] NOT NULL,
	[flPersonalizado] [bit] NOT NULL,
 CONSTRAINT [PK_tbCardapio] PRIMARY KEY CLUSTERED 
(
	[idCardapio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tbCardapio] ADD  DEFAULT ((1)) FOR [flAtivo]
GO

ALTER TABLE [dbo].[tbCardapio] ADD  DEFAULT ((0)) FOR [flPersonalizado]
GO



GO

/****** Object:  Table [dbo].[tbCardapioIngrediente]    Script Date: 20/02/2021 12:20:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbCardapioIngrediente](
	[idCardapioIngrediente] [int] IDENTITY(1,1) NOT NULL,
	[idCardapio] [int] NOT NULL,
	[idIngrediente] [int] NOT NULL,
	[qtQuantidade] [int] NOT NULL,
	[flAtivo] [bit] NOT NULL,
 CONSTRAINT [PK_tbCardapioIngrediente] PRIMARY KEY CLUSTERED 
(
	[idCardapioIngrediente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tbCardapioIngrediente] ADD  DEFAULT ((1)) FOR [flAtivo]
GO

ALTER TABLE [dbo].[tbCardapioIngrediente]  WITH CHECK ADD  CONSTRAINT [FK_tbCardapioIngrediente_tbCardapio] FOREIGN KEY([idCardapio])
REFERENCES [dbo].[tbCardapio] ([idCardapio])
GO

ALTER TABLE [dbo].[tbCardapioIngrediente] CHECK CONSTRAINT [FK_tbCardapioIngrediente_tbCardapio]
GO

ALTER TABLE [dbo].[tbCardapioIngrediente]  WITH CHECK ADD  CONSTRAINT [FK_tbCardapioIngrediente_tbIngrediente] FOREIGN KEY([idIngrediente])
REFERENCES [dbo].[tbIngrediente] ([idIngrediente])
GO

ALTER TABLE [dbo].[tbCardapioIngrediente] CHECK CONSTRAINT [FK_tbCardapioIngrediente_tbIngrediente]
GO



GO

/****** Object:  Table [dbo].[tbPedido]    Script Date: 20/02/2021 12:20:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbPedido](
	[idPedido] [bigint] IDENTITY(1,1) NOT NULL,
	[dtInicioPedido] [datetime] NOT NULL,
	[dtConclusaoPedido] [datetime] NULL,
	[dsNomeChamada] [varchar](50) NULL,
	[nuCPF] [varchar](14) NULL,
	[vlPedido] [numeric](10, 2) NULL,
 CONSTRAINT [PK_tbPedido] PRIMARY KEY CLUSTERED 
(
	[idPedido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


GO

/****** Object:  Table [dbo].[tbPedidoCardapio]    Script Date: 20/02/2021 12:20:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Table [dbo].[tbPedidoCardapio]    Script Date: 20/02/2021 12:31:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbPedidoCardapio](
	[idPedidoCardapio] [bigint] IDENTITY(1,1) NOT NULL,
	[idPedido] [bigint] NOT NULL,
	[idCardapio] [int] NOT NULL,
	[qtQuantidade] [int] NOT NULL,
	[vlValor] [numeric](10, 2) NOT NULL,
	[vlPromocao] [numeric](10, 2) NULL,
	[vlValorFinal] [numeric](10, 2) NOT NULL,
	[obsPromocao] [varchar](1024) NULL,

 CONSTRAINT [PK_tbPedidoCardapio] PRIMARY KEY CLUSTERED 
(
	[idPedidoCardapio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


ALTER TABLE [dbo].[tbPedidoCardapio]  WITH CHECK ADD  CONSTRAINT [FK_tbPedidoCardapio_tbCardapio] FOREIGN KEY([idCardapio])
REFERENCES [dbo].[tbCardapio] ([idCardapio])
GO

ALTER TABLE [dbo].[tbPedidoCardapio] CHECK CONSTRAINT [FK_tbPedidoCardapio_tbCardapio]
GO

ALTER TABLE [dbo].[tbPedidoCardapio]  WITH CHECK ADD  CONSTRAINT [FK_tbPedidoCardapio_tbPedido] FOREIGN KEY([idPedido])
REFERENCES [dbo].[tbPedido] ([idPedido])
GO

ALTER TABLE [dbo].[tbPedidoCardapio] CHECK CONSTRAINT [FK_tbPedidoCardapio_tbPedido]
GO





SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbPedidoCardapioIngrediente](
	[idPedidoCardapioIngrediente] [bigint] IDENTITY(1,1) NOT NULL,
	[idPedidoCardapio] [bigint] NOT NULL,
	[idIngrediente] [int] NOT NULL,
	[qtQuantidade] [int] NOT NULL,
	[vlValor] [numeric](10, 2) NOT NULL,
 CONSTRAINT [PK_tbPedidoCardapioIngrediente] PRIMARY KEY CLUSTERED 
(
	[idPedidoCardapioIngrediente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO





ALTER TABLE [dbo].[tbPedidoCardapioIngrediente]  WITH CHECK ADD  CONSTRAINT [FK_tbPedidoCardapioIngrediente_tbIngrediente] FOREIGN KEY([idIngrediente])
REFERENCES [dbo].[tbIngrediente] ([idIngrediente])
GO

ALTER TABLE [dbo].[tbPedidoCardapioIngrediente] CHECK CONSTRAINT [FK_tbPedidoCardapioIngrediente_tbIngrediente]
GO

ALTER TABLE [dbo].[tbPedidoCardapioIngrediente]  WITH CHECK ADD  CONSTRAINT [FK_tbPedidoCardapioIngrediente_tbPedidoCardapio] FOREIGN KEY([idPedidoCardapio])
REFERENCES [dbo].[tbPedidoCardapio] ([idPedidoCardapio])
GO

ALTER TABLE [dbo].[tbPedidoCardapioIngrediente] CHECK CONSTRAINT [FK_tbPedidoCardapioIngrediente_tbPedidoCardapio]
GO



/****** Object:  Table [dbo].[tbPromocao]    Script Date: 20/02/2021 23:05:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbPromocao](
	[idPromocao] [int] IDENTITY(1,1) NOT NULL,
	[dsPromocao] [varchar](50) NOT NULL,
	[dsRegra] [varchar](256) NOT NULL,
	[flAtivo] [bit] NOT NULL DEFAULT (1) ,
 CONSTRAINT [PK_tbPromocao] PRIMARY KEY CLUSTERED 
(
	[idPromocao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



/****** Object:  Table [dbo].[tbPromocaoParametroIngrediente]    Script Date: 21/02/2021 01:38:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbPromocaoParametroIngrediente](
	[idPromocaoParametroIngrediente] [int] IDENTITY(1,1) NOT NULL,
	[idPromocao] [int] NOT NULL,
	[idIngrediente] [int] NOT NULL,
	
	[flTemNoPacote] [bit] NULL,
	[flNaoTemNoPacote] [bit] NULL,
	[qtDescontoPacote] [numeric](5, 2) NULL,

	[qtLeveX] [int] NULL,
	[qtPagueY] [int] NULL,
 CONSTRAINT [PK_tbPromocaoParametroIngrediente] PRIMARY KEY CLUSTERED 
(
	[idPromocaoParametroIngrediente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tbPromocaoParametroIngrediente]  WITH CHECK ADD  CONSTRAINT [FK_tbPromocaoParametroIngrediente_tbIngrediente] FOREIGN KEY([idIngrediente])
REFERENCES [dbo].[tbIngrediente] ([idIngrediente])
GO

ALTER TABLE [dbo].[tbPromocaoParametroIngrediente] CHECK CONSTRAINT [FK_tbPromocaoParametroIngrediente_tbIngrediente]
GO

ALTER TABLE [dbo].[tbPromocaoParametroIngrediente]  WITH CHECK ADD  CONSTRAINT [FK_tbPromocaoParametroIngrediente_tbPromocao] FOREIGN KEY([idPromocao])
REFERENCES [dbo].[tbPromocao] ([idPromocao])
GO

ALTER TABLE [dbo].[tbPromocaoParametroIngrediente] CHECK CONSTRAINT [FK_tbPromocaoParametroIngrediente_tbPromocao]
GO




USE [master]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [xmlanches]    Script Date: 21/02/2021 14:43:07 ******/
CREATE LOGIN [xmlanches] WITH PASSWORD=N'iNtuKTFuz7JJT1wJYCJ9lo0+BD3JPnePI9dks1tOwsI=', DEFAULT_DATABASE=[dbProvaMutant2014], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER LOGIN [xmlanches] DISABLE
GO

ALTER SERVER ROLE [dbcreator] ADD MEMBER [xmlanches]
GO


