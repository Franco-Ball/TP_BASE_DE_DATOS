USE GD1C2026;
GO

IF NOT EXISTS (
    SELECT *
    FROM sys.schemas
    WHERE name = 'BASADOS_DE_DATOS'
)
BEGIN
    EXEC('CREATE SCHEMA BASADOS_DE_DATOS');
END;
GO

/*
Para las tablas 
Primero creo la tabla maestras con pk con CREATE TABLE
Segundo creo tablas dependientes con pk y sin fk
Tercero hago un alter table de las tablas dependientes agregando las referencias de fk

*/
/*
migracion
Primero tablas maestras
Segundo tablas dependientes
Teercero tablas intermedias
*/

/*drop de las tablas para crear correctamente las PKs*/
--Tablas hijas--
DROP TABLE IF EXISTS BASADOS_DE_DATOS.Localidad;
DROP TABLE IF EXISTS BASADOS_DE_DATOS.Ciudad;
DROP TABLE IF EXISTS BASADOS_DE_DATOS.Agencia;
DROP TABLE IF EXISTS BASADOS_DE_DATOS.Agente;


--Tablas intermedias o dependientes--


--Tablas independientes--
DROP TABLE IF EXISTS BASADOS_DE_DATOS.Provincia;
DROP TABLE IF EXISTS BASADOS_DE_DATOS.Pais;
DROP TABLE IF EXISTS BASADOS_DE_DATOS.CanalVenta;
DROP TABLE IF EXISTS BASADOS_DE_DATOS.MedioPago;
DROP TABLE IF EXISTS BASADOS_DE_DATOS.EstadoPropuesta;
DROP TABLE IF EXISTS BASADOS_DE_DATOS.Aspecto;
DROP TABLE IF EXISTS BASADOS_DE_DATOS.Alianza;
DROP TABLE IF EXISTS BASADOS_DE_DATOS.Proveedor;

/*drop a todos los procedures para que no haya errores*/
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_provincia;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_pais;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_proveedor;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_canalVenta;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_medioPago;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_estadoPropuesta;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_aspecto;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_alianza;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_localidad;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_ciudad;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_agencia;
DROP PROCEDURE IF EXISTS BASADOS_DE_DATOS.migrar_agentes;
go

--TABLAS independientes --
--Provincia
CREATE TABLE [BASADOS_DE_DATOS].[Provincia] (
	[prov_codigo]		bigint IDENTITY(1,1) NOT NULL,
	[prov_nombre]		nvarchar(255),
	CONSTRAINT PK_Provincia primary key (prov_codigo)
);
--Pais--
CREATE TABLE [BASADOS_DE_DATOS].[Pais] (
	[pais_codigo]		bigint identity(1,1) NOT NULL,
	[pais_nombre]		nvarchar(255),
	CONSTRAINT PK_pais_codigo primary key (pais_codigo)
);

--Aspecto--
CREATE TABLE [BASADOS_DE_DATOS].[Aspecto] (
	[aspe_codigo]		bigint identity(1,1) NOT NULL,
	[aspe_detalle]		nvarchar(255),
	[aspe_puntaje]		int,
	CONSTRAINT PK_aspecto_codigo primary key (aspe_codigo)
);

--Canal de Venta--
CREATE TABLE [BASADOS_DE_DATOS].[CanalVenta] (
	[cana_codigo]		bigint identity(1,1) NOT NULL,
	[cana_nombre]		nvarchar(255),
	CONSTRAINT PK_canal_venta_codigo primary key (cana_codigo)
);

--Medio de pago--
CREATE TABLE [BASADOS_DE_DATOS].[MedioPago] (
	[medi_codigo]		bigint identity(1,1) NOT NULL,
	[medi_nombre]		nvarchar(255),
	CONSTRAINT PK_medio_pago_codigo primary key (medi_codigo)
);

--Estado propuesta--
CREATE TABLE [BASADOS_DE_DATOS].[EstadoPropuesta] (
	[esta_codigo]		bigint identity(1,1) NOT NULL,
	[esta_nombre]		nvarchar(255),
	CONSTRAINT PK_estado_propuesta_codigo primary key (esta_codigo)
);

--Alianza--
CREATE TABLE [BASADOS_DE_DATOS].[Alianza] (
	[alia_codigo]		bigint identity(1,1) NOT NULL,
	[alia_nombre]		nvarchar(255),
	CONSTRAINT PK_alianza_codigo primary key (alia_codigo)
);

--Proveedor--
CREATE TABLE [BASADOS_DE_DATOS].[Proveedor] (
	[prov_codigo]		bigint identity(1,1) NOT NULL,
	[prov_nombre]		nvarchar(255),
	[prov_mail]			nvarchar(255),
	[prov_telefono]		nvarchar(255)
	CONSTRAINT PK_proveedor_codigo primary key (prov_codigo)
);


--TABLAS dependientes --
--LOCALIDAD
CREATE TABLE [BASADOS_DE_DATOS].[Localidad] (
	[loca_codigo]		bigint identity(1,1) NOT NULL,
	[loca_nombre]		nvarchar(255),
	[loca_provincia]	bigint --FK a Provincia
	constraint PK_Localidad primary key (loca_codigo)
);

alter table [BASADOS_DE_DATOS].[Localidad]
add constraint FK_loca_provincia foreign key (loca_provincia)
references [BASADOS_DE_DATOS].[Provincia](prov_codigo);

--Ciudad
CREATE TABLE [BASADOS_DE_DATOS].[Ciudad] (
	[ciud_codigo]		bigint identity(1,1) NOT NULL,
	[ciud_nombre]		nvarchar(255),
	[ciud_pais]			bigint --FK a pais
	constraint PK_Ciudad primary key (ciud_codigo)
);

alter table [BASADOS_DE_DATOS].[Ciudad]
add constraint FK_ciud_pais foreign key (ciud_pais)
references [BASADOS_DE_DATOS].[Pais](pais_codigo);
go

-- AGENCIA
CREATE TABLE [BASADOS_DE_DATOS].[Agencia] (
    [Agencia_Nro_Agencia]   bigint NOT NULL,
    [Agencia_Direccion]     nvarchar(255),
    [Agencia_Telefono]      nvarchar(255),
    [Agencia_Mail]          nvarchar(255),
    [Agencia_Localidad]     bigint --FK a Localidad
	constraint PK_AgenciaNro primary key (Agencia_Nro_Agencia)   
);

alter table BASADOS_DE_DATOS.Agencia
add constraint FK_Agencia_Localidad foreign key (Agencia_Localidad) 
references BASADOS_DE_DATOS.Localidad(loca_codigo);
go



INSERT INTO [BASADOS_DE_DATOS].[Agencia]
SELECT DISTINCT
    [Agencia_Nro_Agencia]
    ,[Agencia_Direccion]
    ,[Agencia_Telefono]
    ,[Agencia_Mail]
    --,[Agencia_Localidad]
    --,[Agencia_Provincia]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Agencia_Nro_Agencia] IS NOT NULL;


-- AGENTE
CREATE TABLE [BASADOS_DE_DATOS].[Agente] (
    [Agente_Legajo]         bigint  NOT NULL,
    [Agente_Nro_Agencia]	bigint,
    [Agente_Nombre]         nvarchar(255),
    [Agente_Apellido]       nvarchar(255),
    [Agente_Dni]            nvarchar(255),
    [Agente_Fecha_Nac]      date,
    [Agente_Telefono]       nvarchar(255),
    [Agente_Mail]           nvarchar(255),
    [Agente_Direccion]      nvarchar(255),
    [Agente_Localidad]      bigint,
    constraint PK_AgenteLegajo PRIMARY KEY (Agente_Legajo)
);

alter table BASADOS_DE_DATOS.Agente
add constraint FK_Agente_Nro_Agencia 
foreign key (Agente_Nro_Agencia) 
references BASADOS_DE_DATOS.Agencia(Agencia_Nro_Agencia);
go

ALTER TABLE BASADOS_DE_DATOS.Agente
ADD CONSTRAINT FK_Agente_Localidad
FOREIGN KEY (Agente_Localidad)
REFERENCES BASADOS_DE_DATOS.Localidad(loca_codigo);
GO

--inicio de tablas a chequear con la ultima version de la tabla que mando Fran--
--estas tablas falta chequear fk con tablas maestras
--falta agregar constraint y referencias fk
-- CLIENTE
CREATE TABLE [BASADOS_DE_DATOS].[Cliente] (
    [Cliente_Dni]           nvarchar(255)   NOT NULL,
    [nro_Cliente]           int identity(1,1) NOT NULL,
    [Agente_Legajo]         bigint,
    [Cliente_Nombre]        nvarchar(255),
    [Cliente_Apellido]      nvarchar(255),
    [Cliente_Tel]           nvarchar(255),
    [Cliente_Mail]          nvarchar(255),
    [Cliente_Direccion]     nvarchar(255),
    [Cliente_Fecha_Nac]     date,
    [Cliente_Localidad]     bigint
    --[Cliente_Provincia]     nvarchar(255),
    --PRIMARY KEY ([Cliente_Dni], [nro_Cliente]),
    --FOREIGN KEY ([Agente_Legajo]) REFERENCES [BASADOS_DE_DATOS].[Agente]([Agente_Legajo])
);

-- AEROPUERTO
CREATE TABLE [BASADOS_DE_DATOS].[Aeropuerto] (
    [Aeropuerto_Codigo]         nvarchar(255)   NOT NULL,
    [Aeropuerto_Descripcion]    nvarchar(255),
    [Aeropuerto_Ciudad]         bigint,
    --[Aeropuerto_Pais]           bigint,
    PRIMARY KEY ([Aeropuerto_Codigo])
);

-- AEROLINEA
CREATE TABLE [BASADOS_DE_DATOS].[Aerolinea] (
    [Aerolinea_Codigo]      nvarchar(255)   NOT NULL,
    [Aerolinea_Nombre]      nvarchar(255),
    [Aerolinea_Pais]        bigint,
    [Aerolinea_Alianza]     bigint,
    PRIMARY KEY ([Aerolinea_Codigo])
);

-- VUELO
CREATE TABLE [BASADOS_DE_DATOS].[Vuelo] (
    [Vuelo_Fecha_Salida]            date            NOT NULL,
    [Vuelo_Horario_Salida]          nvarchar(255)   NOT NULL,
    [Aerolinea_Codigo]              nvarchar(255)   NOT NULL,
    [Aeropuerto_Salida_Codigo]      nvarchar(255),
    [Aeropuerto_Llegada_Codigo]     nvarchar(255),
    [Vuelo_Fecha_Llegada]           date,
    [Vuelo_Horario_Llegada]         nvarchar(255),
    [Vuelo_Duracion]                int,
    [Vuelo_Precio]                  decimal(18,2),
    [Vuelo_Incluye_Carry]           bit,
    [Vuelo_Incluye_Valija]          bit,
    PRIMARY KEY ([Vuelo_Fecha_Salida], [Vuelo_Horario_Salida], [Aerolinea_Codigo]),
    FOREIGN KEY ([Aerolinea_Codigo])            REFERENCES [BASADOS_DE_DATOS].[Aerolinea]([Aerolinea_Codigo]),
    FOREIGN KEY ([Aeropuerto_Salida_Codigo])    REFERENCES [BASADOS_DE_DATOS].[Aeropuerto]([Aeropuerto_Codigo]),
    FOREIGN KEY ([Aeropuerto_Llegada_Codigo])   REFERENCES [BASADOS_DE_DATOS].[Aeropuerto]([Aeropuerto_Codigo])
);

-- PASAJERO_VUELO  [TABLA NUEVA - intermedia N:M]
-- Permite que un vuelo tenga muchos clientes y un cliente haya tome muchos vuelos.
CREATE TABLE [BASADOS_DE_DATOS].[Pasajero_Vuelo] (
    [Cliente_Dni]           nvarchar(255)   NOT NULL,
    [nro_Cliente]           int             NOT NULL,
    [Vuelo_Fecha_Salida]    date            NOT NULL,
    [Vuelo_Horario_Salida]  nvarchar(255)   NOT NULL,
    [Aerolinea_Codigo]      nvarchar(255)   NOT NULL,
    PRIMARY KEY ([Cliente_Dni], [nro_Cliente], [Vuelo_Fecha_Salida], [Vuelo_Horario_Salida], [Aerolinea_Codigo]),
    FOREIGN KEY ([Cliente_Dni], [nro_Cliente])
        REFERENCES [BASADOS_DE_DATOS].[Cliente]([Cliente_Dni], [nro_Cliente]),
    FOREIGN KEY ([Vuelo_Fecha_Salida], [Vuelo_Horario_Salida], [Aerolinea_Codigo])
        REFERENCES [BASADOS_DE_DATOS].[Vuelo]([Vuelo_Fecha_Salida], [Vuelo_Horario_Salida], [Aerolinea_Codigo])
);

-- HOSPEDAJE
CREATE TABLE [BASADOS_DE_DATOS].[Hospedaje] (
    [Hospedaje_Nombre]              nvarchar(255)   NOT NULL,
    [Hospedaje_Ciudad]              nvarchar(255),
    [Hospedaje_Pais]                nvarchar(255),
    [Hospedaje_Direccion]           nvarchar(255),
    [Hospedaje_Incluye_Desayuno]    bit,
    [Hospedaje_Check_In]            nvarchar(255),
    [Hospedaje_Check_Out]           nvarchar(255),
    PRIMARY KEY ([Hospedaje_Nombre])
);

-- HABITACION
CREATE TABLE [BASADOS_DE_DATOS].[Habitacion] (
    [Habitacion_Nombre]         nvarchar(255)   NOT NULL,
    [Hospedaje_Nombre]          nvarchar(255)   NOT NULL,
    [Habitacion_Descripcion]    nvarchar(255),
    [Habitacion_Precio_Noche]   decimal(18,2),
    PRIMARY KEY ([Habitacion_Nombre], [Hospedaje_Nombre]),
    FOREIGN KEY ([Hospedaje_Nombre]) REFERENCES [BASADOS_DE_DATOS].[Hospedaje]([Hospedaje_Nombre])
);

-- EXCURSION
CREATE TABLE [BASADOS_DE_DATOS].[Excursion] (
    [Excursion_Nombre]          nvarchar(255)   NOT NULL,
    [Excursion_Descripcion]     nvarchar(255),
    [Excursion_Horario]         nvarchar(255),
    [Excursion_Duracion]        int,
    [Excursion_Precio]          decimal(18,2),
    PRIMARY KEY ([Excursion_Nombre])
);

CREATE TABLE [BASADOS_DE_DATOS].[Encuesta] (
    [Encuesta_Codigo_Encuesta]  bigint          NOT NULL,
    [Cliente_Dni]               nvarchar(255),
    [nro_Cliente]               int,
    [Agente_Legajo]             bigint,
    [Encuesta_Fecha_Encuesta]   date,
    [Encuesta_Comentarios]      nvarchar(255),
    PRIMARY KEY ([Encuesta_Codigo_Encuesta]),
    FOREIGN KEY ([Cliente_Dni], [nro_Cliente])  REFERENCES [BASADOS_DE_DATOS].[Cliente]([Cliente_Dni], [nro_Cliente]),
    FOREIGN KEY ([Agente_Legajo])               REFERENCES [BASADOS_DE_DATOS].[Agente]([Agente_Legajo])
);

-- DETALLE_ENCUESTA
CREATE TABLE [BASADOS_DE_DATOS].[Detalle_Encuesta] (
    [Encuesta_Codigo_Encuesta]  bigint          NOT NULL,
    [Aspecto_Aspecto]           nvarchar(255)   NOT NULL,
    [Detalle_Encuesta_Puntaje]  int,
    PRIMARY KEY ([Encuesta_Codigo_Encuesta], [Aspecto_Aspecto]),
    FOREIGN KEY ([Encuesta_Codigo_Encuesta]) REFERENCES [BASADOS_DE_DATOS].[Encuesta]([Encuesta_Codigo_Encuesta]),
    FOREIGN KEY ([Aspecto_Aspecto])          REFERENCES [BASADOS_DE_DATOS].[Aspecto]([Aspecto_Aspecto])
);

-- SOLICITUD
CREATE TABLE [BASADOS_DE_DATOS].[Solicitud] (
    [Solicitud_Nro_Solicitud]           bigint          NOT NULL,
    [Cliente_Dni]                       nvarchar(255),
    [nro_Cliente]                       int,
    [Agente_Legajo]                     bigint,
    [Solicitud_Fecha_Solicitud]         date,
    [Solicitud_Fecha_Inicio_Tentativa]  date,
    [Solicitud_Fecha_Fin_Tentativa]     date,
    [Solicitud_Cant_Pax]                int,
    [Solicitud_Observaciones]           nvarchar(255),
    [Solicitud_Presupuesto_Estimado]    decimal(18,2),
    PRIMARY KEY ([Solicitud_Nro_Solicitud]),
    FOREIGN KEY ([Cliente_Dni], [nro_Cliente])  REFERENCES [BASADOS_DE_DATOS].[Cliente]([Cliente_Dni], [nro_Cliente]),
    FOREIGN KEY ([Agente_Legajo])               REFERENCES [BASADOS_DE_DATOS].[Agente]([Agente_Legajo])
);

-- DETALLE_SOLICITUD
CREATE TABLE [BASADOS_DE_DATOS].[Detalle_Solicitud] (
    [Detalle_Solicitud_Id]              int             NOT NULL,
    [Solicitud_Nro_Solicitud]           bigint          NOT NULL,
    [Detalle_Solicitud_Ciudad]          nvarchar(255),
    [Detalle_Solicitud_Cant_Dias_Aprox] int,
    [Detalle_Solicitud_Observaciones]   nvarchar(255),
    PRIMARY KEY ([Detalle_Solicitud_Id], [Solicitud_Nro_Solicitud]),
    FOREIGN KEY ([Solicitud_Nro_Solicitud]) REFERENCES [BASADOS_DE_DATOS].[Solicitud]([Solicitud_Nro_Solicitud])
);

-- PROPUESTA
CREATE TABLE [BASADOS_DE_DATOS].[Propuesta] (
    [Propuesta_Nro_Propuesta]   bigint          NOT NULL,
    [Cliente_Dni]               nvarchar(255),
    [nro_Cliente]               int,
    [Propuesta_Fecha_Emision]   date,
    [Propuesta_Vigencia_Hasta]  date,
    [Propuesta_Fecha_Desde]     date,
    [Propuesta_Fecha_Hasta]     date,
    [Propuesta_Subtotal]        decimal(18,2),
    [Propuesta_Descuento]       decimal(18,2),
    [Propuesta_Importe_Total]   decimal(18,2),
    [Propuesta_Estado]          nvarchar(255),
    PRIMARY KEY ([Propuesta_Nro_Propuesta]),
    FOREIGN KEY ([Cliente_Dni], [nro_Cliente]) REFERENCES [BASADOS_DE_DATOS].[Cliente]([Cliente_Dni], [nro_Cliente])
);

-- DETALLE_PROPUESTA
CREATE TABLE [BASADOS_DE_DATOS].[Detalle_Propuesta] (
    [Detalle_Propuesta_Id]                      int             NOT NULL,
    [Propuesta_Nro_Propuesta]                   bigint          NOT NULL,
    [Detalle_Propuesta_Vuelo_Cant_Pasajes]      int,
    [Detalle_Propuesta_Vuelo_Precio]            decimal(18,2),
    [Detalle_Propuesta_Vuelo_Subtotal]          decimal(18,2),
    [Detalle_Propuesta_Hospedaje_Fecha_Desde]   date,
    [Detalle_Propuesta_Hospedaje_Fecha_Hasta]   date,
    [Detalle_Propuesta_Hospedaje_Cant]          int,
    [Detalle_Propuesta_Hospedaje_Precio]        decimal(18,2),
    [Detalle_Propuesta_Hospedaje_Subtotal]      decimal(18,2),
    PRIMARY KEY ([Detalle_Propuesta_Id], [Propuesta_Nro_Propuesta]),
    FOREIGN KEY ([Propuesta_Nro_Propuesta]) REFERENCES [BASADOS_DE_DATOS].[Propuesta]([Propuesta_Nro_Propuesta])
);

-- VENTA
CREATE TABLE [BASADOS_DE_DATOS].[Venta] (
    [Venta_Nro_Venta]       bigint          NOT NULL,
    [Cliente_Dni]           nvarchar(255),
    [nro_Cliente]           int,
    [Agente_Legajo]         bigint,
    [Venta_Fecha_Venta]     date,
    [Venta_Canal_Venta]     nvarchar(255),
    [Venta_Medio_Pago]      nvarchar(255),
    [Venta_Subtotal]        decimal(18,2),
    [Venta_Descuento]       decimal(18,2),
    [Venta_Importe_Total]   decimal(18,2),
    PRIMARY KEY ([Venta_Nro_Venta]),
    FOREIGN KEY ([Cliente_Dni], [nro_Cliente])  REFERENCES [BASADOS_DE_DATOS].[Cliente]([Cliente_Dni], [nro_Cliente]),
    FOREIGN KEY ([Agente_Legajo])               REFERENCES [BASADOS_DE_DATOS].[Agente]([Agente_Legajo])
);

-- DETALLE_VENTA
CREATE TABLE [BASADOS_DE_DATOS].[Detalle_Venta] (
    [Detalle_Venta_Id]                          int             NOT NULL,
    [Venta_Nro_Venta]                           bigint          NOT NULL,
    [Detalle_Venta_Vuelo_Cod_Reserva]           nvarchar(255),
    [Detalle_Venta_Vuelo_Cantidad_Pasajes]      int,
    [Detalle_Venta_Vuelo_Precio_Unitario]       decimal(18,2),
    [Detalle_Venta_Vuelo_Subtotal]              decimal(18,2),
    [Detalle_Venta_Hospedaje_Fecha_Desde]       date,
    [Detalle_Venta_Hospedaje_Fecha_Hasta]       date,
    [Detalle_Venta_Hospedaje_Cantidad]          int,
    [Detalle_Venta_Hospedaje_Precio_Unitario]   decimal(18,2),
    [Detalle_Venta_Hospedaje_Subtotal]          decimal(18,2),
    [Detalle_Venta_Hospedaje_Cod_Reserva]       nvarchar(255),
    [Detalle_Venta_Excursion_Fecha_Reserva]     date,
    [Detalle_Venta_Excursion_Cant]              int,
    [Detalle_Venta_Excursion_Precio_Unitario]   decimal(18,2),
    [Detalle_Venta_Excursion_Subtotal]          decimal(18,2),
    [Detalle_Venta_Excursion_Cod_Reserva]       nvarchar(255),
    PRIMARY KEY ([Detalle_Venta_Id], [Venta_Nro_Venta]),
    FOREIGN KEY ([Venta_Nro_Venta]) REFERENCES [BASADOS_DE_DATOS].[Venta]([Venta_Nro_Venta])
);

--fin de tablas a chequear con la ultima version de las tablas que mando Fran-- 

-------------- INICIO  MIGRACIONES   --------------
/*Insertar provincia de la tabla maestra a tabla provincia*/
CREATE OR ALTER PROCEDURE BASADOS_DE_DATOS.migrar_provincia
AS
BEGIN
INSERT INTO BASADOS_DE_DATOS.Provincia (prov_nombre)
SELECT DISTINCT LTRIM(RTRIM(provincia))
FROM (
    SELECT Agencia_Provincia AS provincia FROM gd_esquema.Maestra
    UNION
    SELECT Cliente_Provincia AS provincia FROM gd_esquema.Maestra
    UNION
    SELECT Agente_Provincia AS provincia FROM gd_esquema.Maestra
) AS provincias
WHERE provincia IS NOT NULL;
END;
GO

/*Insertar pais de la tabla maestra a tabla pais*/
CREATE OR ALTER PROCEDURE BASADOS_DE_DATOS.migrar_pais
AS
BEGIN
INSERT INTO BASADOS_DE_DATOS.Pais (pais_nombre)
SELECT DISTINCT LTRIM(RTRIM(pais)) COLLATE Latin1_General_CI_AI
FROM (
    SELECT Aerolinea_Pais AS pais FROM gd_esquema.Maestra
    UNION
    SELECT Aeropuerto_Llegada_Pais AS pais FROM gd_esquema.Maestra
    UNION
    SELECT Aeropuerto_Salida_Pais AS pais FROM gd_esquema.Maestra
	UNION
	SELECT Hospedaje_Pais AS pais FROM gd_esquema.Maestra
) AS paises
WHERE pais IS NOT NULL
AND NOT EXISTS (
        SELECT 1
        FROM BASADOS_DE_DATOS.Pais p
        WHERE p.pais_nombre COLLATE Latin1_General_CI_AI =
              LTRIM(RTRIM(pais)) COLLATE Latin1_General_CI_AI
    );
END;
GO

/*Migracion de Proveedor*/
create procedure BASADOS_DE_DATOS.migrar_proveedor
as
begin
insert into BASADOS_DE_DATOS.Proveedor(
	prov_nombre, prov_mail, prov_telefono
)
select distinct Proveedor_Nombre, Proveedor_Mail ,Proveedor_Telefono from gd_esquema.Maestra m
where m.Proveedor_Nombre is not null
AND NOT EXISTS (
        SELECT 1
        FROM BASADOS_DE_DATOS.Proveedor p
        WHERE p.prov_mail = LTRIM(RTRIM(m.Proveedor_Mail))
    )
end;
go

/*migracion de canal venta*/
create or alter procedure BASADOS_DE_DATOS.migrar_canalVenta
as
begin
	insert into BASADOS_DE_DATOS.CanalVenta (
		cana_nombre
	)
	select distinct 
		ltrim(rtrim(m.Venta_Canal_Venta))
	from gd_esquema.Maestra m

	where m.Venta_Canal_Venta is not null

	and not exists (
		select 1 from BASADOS_DE_DATOS.CanalVenta c
		where c.cana_nombre = ltrim(rtrim(m.Venta_Canal_Venta))
	);
end;
go

/*migracion de medio de pago*/
create or alter procedure BASADOS_DE_DATOS.migrar_medioPago
as
begin
	insert into BASADOS_DE_DATOS.MedioPago (
		medi_nombre
	)
	select distinct 
		ltrim(rtrim(m.Venta_Medio_Pago))
	from gd_esquema.Maestra m

	where m.Venta_Medio_Pago is not null

	and not exists (
		select 1 from BASADOS_DE_DATOS.MedioPago me
		where me.medi_nombre = ltrim(rtrim(m.Venta_Medio_Pago))
	);
end;
go

/*migracion de estado de propuesta*/
create or alter procedure BASADOS_DE_DATOS.migrar_estadoPropuesta
as
begin
	insert into BASADOS_DE_DATOS.EstadoPropuesta (
		esta_nombre
	)
	select distinct 
		ltrim(rtrim(m.Propuesta_Estado))
	from gd_esquema.Maestra m

	where m.Propuesta_Estado is not null

	and not exists (
		select 1 from BASADOS_DE_DATOS.EstadoPropuesta es
		where es.esta_nombre = ltrim(rtrim(m.Propuesta_Estado))
	);
end;
go

/*migracion aspecto*/
create or alter procedure BASADOS_DE_DATOS.migrar_aspecto
as
begin
	insert into BASADOS_DE_DATOS.Aspecto (
		aspe_detalle,
		aspe_puntaje
	)
	select distinct 
		ltrim(rtrim(m.Aspecto_Aspecto)),
		Detalle_Encuesta_Puntaje
	from gd_esquema.Maestra m

	where m.Aspecto_Aspecto is not null

	and not exists (
		select 1 from BASADOS_DE_DATOS.Aspecto a
		where a.aspe_detalle = ltrim(rtrim(m.Aspecto_Aspecto))
	);
end;
go

/*migracion alianza*/
create or alter procedure BASADOS_DE_DATOS.migrar_alianza
as
begin
	insert into BASADOS_DE_DATOS.Alianza (
		alia_nombre
	)
	select distinct 
		ltrim(rtrim(m.Aerolinea_Alianza))
	from gd_esquema.Maestra m

	where m.Aerolinea_Alianza is not null

	and not exists (
		select 1 from BASADOS_DE_DATOS.Alianza a
		where a.alia_nombre = ltrim(rtrim(m.Aerolinea_Alianza))
	);
end;
go

/*insertar localidades de agencia*/
create or alter procedure BASADOS_DE_DATOS.migrar_localidades_agencia
as
begin
	insert into BASADOS_DE_DATOS.Localidad (loca_nombre,loca_provincia)
	select distinct
		rtrim(ltrim(maestra.Agencia_Localidad)),
		prov.prov_codigo
	from gd_esquema.Maestra maestra
	join BASADOS_DE_DATOS.Provincia prov
		on rtrim(ltrim(prov.prov_nombre)) = rtrim(ltrim(maestra.Agencia_Provincia))
		where maestra.Agencia_Provincia is not null AND maestra.Agencia_Localidad is not null
		and not exists (
			select 1
			from BASADOS_DE_DATOS.Localidad loc
			where loc.loca_nombre = rtrim(ltrim(maestra.Agencia_Localidad))
			and loc.loca_provincia = prov.prov_codigo
		);
end;
go


/*insertar localidad de agentes*/
create or alter procedure BASADOS_DE_DATOS.migrar_localidades_agentes
as
begin
	insert into BASADOS_DE_DATOS.Localidad (loca_nombre,loca_provincia)
	select distinct
		rtrim(ltrim(maestra.Agente_Localidad)),
		prov.prov_codigo
	from gd_esquema.Maestra maestra
	join BASADOS_DE_DATOS.Provincia prov
		on rtrim(ltrim(prov.prov_nombre)) = rtrim(ltrim(maestra.Agente_Provincia))
		where maestra.Agente_Provincia is not null AND maestra.Agente_Localidad is not null
		and not exists (
			select 1
			from BASADOS_DE_DATOS.Localidad loc
			where loc.loca_nombre = rtrim(ltrim(maestra.Agente_Localidad))
			and loc.loca_provincia = prov.prov_codigo
		);
end;
go



/*insertar localidad de clientes*/
create or alter procedure BASADOS_DE_DATOS.migrar_localidades_clientes
as
begin
	insert into BASADOS_DE_DATOS.Localidad (loca_nombre,loca_provincia)
	select distinct
		rtrim(ltrim(maestra.Cliente_Localidad)),
		prov.prov_codigo
	from gd_esquema.Maestra maestra
	join BASADOS_DE_DATOS.Provincia prov
		on rtrim(ltrim(prov.prov_nombre)) = rtrim(ltrim(maestra.Cliente_Provincia))
		where maestra.Cliente_Provincia is not null AND maestra.Cliente_Localidad is not null
		and not exists (
			select 1
			from BASADOS_DE_DATOS.Localidad loc
			where loc.loca_nombre = rtrim(ltrim(maestra.Cliente_Localidad))
			and loc.loca_provincia = prov.prov_codigo
		);
end;
go

/*migracion completa de localidad*/
create procedure BASADOS_DE_DATOS.migrar_localidad
as
begin
	exec BASADOS_DE_DATOS.migrar_localidades_agencia;
	exec BASADOS_DE_DATOS.migrar_localidades_agentes;
	exec BASADOS_DE_DATOS.migrar_localidades_clientes;
end;
go


/*insertar ciudades de los hospedajes*/
create or alter procedure BASADOS_DE_DATOS.migrar_ciudad_hospedajes
as
begin
	insert into BASADOS_DE_DATOS.Ciudad (ciud_nombre,ciud_pais)
	select distinct
		rtrim(ltrim(maestra.Hospedaje_Ciudad)),
		pais.pais_codigo
	from gd_esquema.Maestra maestra
	join BASADOS_DE_DATOS.Pais pais
		on rtrim(ltrim(pais.pais_nombre)) = rtrim(ltrim(maestra.Hospedaje_Pais))
		where maestra.Hospedaje_Ciudad is not null AND maestra.Hospedaje_Pais is not null
		and not exists (
			select 1
			from BASADOS_DE_DATOS.Ciudad ciudad
			where ciudad.ciud_nombre = rtrim(ltrim(maestra.Hospedaje_Ciudad))
			and ciudad.ciud_pais = pais.pais_codigo
		);
end;
go

/*insertar ciudades de aeropuertos de llegadas*/
create or alter procedure BASADOS_DE_DATOS.migrar_ciudad_aerop_llegadas
as
begin
	insert into BASADOS_DE_DATOS.Ciudad (ciud_nombre,ciud_pais)
	select distinct
		rtrim(ltrim(maestra.Aeropuerto_Llegada_Ciudad)),
		pais.pais_codigo
	from gd_esquema.Maestra maestra
	join BASADOS_DE_DATOS.Pais pais
		on rtrim(ltrim(pais.pais_nombre)) = rtrim(ltrim(maestra.Aeropuerto_Llegada_Pais))
		where maestra.Aeropuerto_Llegada_Ciudad is not null AND maestra.Aeropuerto_Llegada_Pais is not null
		and not exists (
			select 1
			from BASADOS_DE_DATOS.Ciudad ciudad
			where ciudad.ciud_nombre = rtrim(ltrim(maestra.Aeropuerto_Llegada_Ciudad))
			and ciudad.ciud_pais = pais.pais_codigo
		);
end;
go

/*insertar ciudades de aeropuertos de salida*/
create or alter procedure BASADOS_DE_DATOS.migrar_ciudad_aerop_salidas
as
begin
	insert into BASADOS_DE_DATOS.Ciudad (ciud_nombre,ciud_pais)
	select distinct
		rtrim(ltrim(maestra.Aeropuerto_Salida_Ciudad)),
		pais.pais_codigo
	from gd_esquema.Maestra maestra
	join BASADOS_DE_DATOS.Pais pais
		on rtrim(ltrim(pais.pais_nombre)) = rtrim(ltrim(maestra.Aeropuerto_Salida_Pais))
		where maestra.Aeropuerto_Salida_Ciudad is not null AND maestra.Aeropuerto_Salida_Pais is not null
		and not exists (
			select 1
			from BASADOS_DE_DATOS.Ciudad ciudad
			where ciudad.ciud_nombre = rtrim(ltrim(maestra.Aeropuerto_Salida_Ciudad))
			and ciudad.ciud_pais = pais.pais_codigo
		);
end;
go


/*migracion de agencias*/
CREATE OR ALTER PROCEDURE BASADOS_DE_DATOS.migrar_agencia
AS
BEGIN

    INSERT INTO BASADOS_DE_DATOS.Agencia (
        Agencia_Nro_Agencia,
        Agencia_Direccion,
        Agencia_Telefono,
        Agencia_Mail,
        Agencia_Localidad
    )

    SELECT DISTINCT
        m.Agencia_Nro_Agencia,
        LTRIM(RTRIM(m.Agencia_Direccion)),
        LTRIM(RTRIM(m.Agencia_Telefono)),
        LTRIM(RTRIM(m.Agencia_Mail)),
        l.loca_codigo

    FROM gd_esquema.Maestra m

    JOIN BASADOS_DE_DATOS.Provincia p
        ON LTRIM(RTRIM(p.prov_nombre)) =
           LTRIM(RTRIM(m.Agencia_Provincia))

    JOIN BASADOS_DE_DATOS.Localidad l
        ON LTRIM(RTRIM(l.loca_nombre)) =
           LTRIM(RTRIM(m.Agencia_Localidad))
       AND l.loca_provincia = p.prov_codigo

    WHERE m.Agencia_Nro_Agencia IS NOT NULL
    AND m.Agencia_Localidad IS NOT NULL
    AND m.Agencia_Provincia IS NOT NULL

    AND NOT EXISTS (
        SELECT 1
        FROM BASADOS_DE_DATOS.Agencia a
        WHERE a.Agencia_Nro_Agencia = m.Agencia_Nro_Agencia
    );

END;
GO

create procedure basados_de_datos.migrar_ciudad
as
begin
	exec BASADOS_DE_DATOS.migrar_ciudad_hospedajes;
	exec BASADOS_DE_DATOS.migrar_ciudad_aerop_llegadas;
	exec BASADOS_DE_DATOS.migrar_ciudad_aerop_salidas;
end;
go


/*migracion de agentes*/
CREATE OR ALTER PROCEDURE BASADOS_DE_DATOS.migrar_agentes
AS
BEGIN

    INSERT INTO BASADOS_DE_DATOS.Agente(
		Agente_Legajo,
		Agente_Nro_Agencia,
		Agente_Nombre,
		Agente_Apellido,
		Agente_Dni,
		Agente_Fecha_Nac,
		Agente_Telefono,
		Agente_Mail,
		Agente_Direccion,
		Agente_Localidad
		)

    SELECT DISTINCT
		m.Agente_Legajo,
        m.Agencia_Nro_Agencia,
		ltrim(rtrim(m.Agente_Nombre)),
		ltrim(rtrim(m.Agente_Apellido)),
		ltrim(rtrim(m.Agente_Dni)),
		m.Agente_Fecha_Nac,
		LTRIM(RTRIM(m.Agente_Telefono)),
		LTRIM(RTRIM(m.Agente_Mail)),
        LTRIM(RTRIM(m.Agente_Direccion)),
        l.loca_codigo

    FROM gd_esquema.Maestra m

	JOIN BASADOS_DE_DATOS.Agencia ag
		on ag.Agencia_Nro_Agencia = m.Agencia_Nro_Agencia

    JOIN BASADOS_DE_DATOS.Provincia p
        ON LTRIM(RTRIM(p.prov_nombre)) =
           LTRIM(RTRIM(m.Agente_Provincia))

    JOIN BASADOS_DE_DATOS.Localidad l
        ON LTRIM(RTRIM(l.loca_nombre)) =
           LTRIM(RTRIM(m.Agente_Localidad))
       AND l.loca_provincia = p.prov_codigo

    WHERE m.Agencia_Nro_Agencia IS NOT NULL
    AND m.Agente_Localidad IS NOT NULL
    AND m.Agente_Provincia IS NOT NULL

    AND NOT EXISTS (
        SELECT 1
        FROM BASADOS_DE_DATOS.Agente a
        WHERE a.Agente_Legajo = m.Agente_Legajo
    );

END;
GO

------------   FIN MIGRACION   ---------------


/*Ejecucion de los procedures en orden correspondiente*/
exec BASADOS_DE_DATOS.migrar_provincia;
exec BASADOS_DE_DATOS.migrar_pais;
exec BASADOS_DE_DATOS.migrar_proveedor;
exec BASADOS_DE_DATOS.migrar_canalVenta;
exec BASADOS_DE_DATOS.migrar_medioPago;
exec BASADOS_DE_DATOS.migrar_estadoPropuesta;
exec BASADOS_DE_DATOS.migrar_aspecto;
exec BASADOS_DE_DATOS.migrar_alianza;
exec BASADOS_DE_DATOS.migrar_localidad;
exec BASADOS_DE_DATOS.migrar_ciudad;
exec BASADOS_DE_DATOS.migrar_agencia;
exec BASADOS_DE_DATOS.migrar_agentes;
