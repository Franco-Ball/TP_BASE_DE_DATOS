-- AGENCIA
CREATE TABLE [BASADOS_DE_DATOS].[Agencia] (
    [Agencia_Nro_Agencia]   bigint          NOT NULL,
    [Agencia_Direccion]     nvarchar(255),
    [Agencia_Telefono]      nvarchar(255),
    [Agencia_Mail]          nvarchar(255),
    [Agencia_Localidad]     nvarchar(255),
    [Agencia_Provincia]     nvarchar(255),
    PRIMARY KEY ([Agencia_Nro_Agencia])
);
INSERT INTO [BASADOS_DE_DATOS].[Agencia]
SELECT DISTINCT
    [Agencia_Nro_Agencia]
    ,[Agencia_Direccion]
    ,[Agencia_Telefono]
    ,[Agencia_Mail]
    ,[Agencia_Localidad]
    ,[Agencia_Provincia]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Agencia_Nro_Agencia] IS NOT NULL;


-- AGENTE
CREATE TABLE [BASADOS_DE_DATOS].[Agente] (
    [Agente_Legajo]         bigint          NOT NULL,
    [Agencia_Nro_Agencia]   bigint,
    [Agente_Nombre]         nvarchar(255),
    [Agente_Apellido]       nvarchar(255),
    [Agente_Dni]            nvarchar(255),
    [Agente_Fecha_Nac]      date,
    [Agente_Telefono]       nvarchar(255),
    [Agente_Mail]           nvarchar(255),
    [Agente_Direccion]      nvarchar(255),
    [Agente_Localidad]      nvarchar(255),
    [Agente_Provincia]      nvarchar(255),
    PRIMARY KEY ([Agente_Legajo]),
    FOREIGN KEY ([Agencia_Nro_Agencia]) REFERENCES [BASADOS_DE_DATOS].[Agencia]([Agencia_Nro_Agencia])
);
INSERT INTO [BASADOS_DE_DATOS].[Agente]
SELECT DISTINCT
    [Agente_Legajo]
    ,[Agencia_Nro_Agencia]
    ,[Agente_Nombre]
    ,[Agente_Apellido]
    ,[Agente_Dni]
    ,[Agente_Fecha_Nac]
    ,[Agente_Telefono]
    ,[Agente_Mail]
    ,[Agente_Direccion]
    ,[Agente_Localidad]
    ,[Agente_Provincia]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Agente_Legajo] IS NOT NULL;


-- CLIENTE
CREATE TABLE [BASADOS_DE_DATOS].[Cliente] (
    [Cliente_Dni]           nvarchar(255)   NOT NULL,
    [nro_Cliente]           int             NOT NULL,
    [Agente_Legajo]         bigint,
    [Cliente_Nombre]        nvarchar(255),
    [Cliente_Apellido]      nvarchar(255),
    [Cliente_Tel]           nvarchar(255),
    [Cliente_Mail]          nvarchar(255),
    [Cliente_Direccion]     nvarchar(255),
    [Cliente_Fecha_Nac]     date,
    [Cliente_Localidad]     nvarchar(255),
    [Cliente_Provincia]     nvarchar(255),
    PRIMARY KEY ([Cliente_Dni], [nro_Cliente]),
    FOREIGN KEY ([Agente_Legajo]) REFERENCES [BASADOS_DE_DATOS].[Agente]([Agente_Legajo])
);
INSERT INTO [BASADOS_DE_DATOS].[Cliente]
SELECT
    [Cliente_Dni]
    ,ROW_NUMBER() OVER (PARTITION BY [Cliente_Dni] ORDER BY [Cliente_Dni]) AS [nro_Cliente]
    ,[Agente_Legajo]
    ,[Cliente_Nombre]
    ,[Cliente_Apellido]
    ,[Cliente_Tel]
    ,[Cliente_Mail]
    ,[Cliente_Direccion]
    ,[Cliente_Fecha_Nac]
    ,[Cliente_Localidad]
    ,[Cliente_Provincia]
FROM (
    SELECT DISTINCT
        [Cliente_Dni]
        ,[Agente_Legajo]
        ,[Cliente_Nombre]
        ,[Cliente_Apellido]
        ,[Cliente_Tel]
        ,[Cliente_Mail]
        ,[Cliente_Direccion]
        ,[Cliente_Fecha_Nac]
        ,[Cliente_Localidad]
        ,[Cliente_Provincia]
    FROM [GD1C2026].[gd_esquema].[Maestra]
    WHERE [Cliente_Dni] IS NOT NULL
) t;


-- AEROPUERTO
CREATE TABLE [BASADOS_DE_DATOS].[Aeropuerto] (
    [Aeropuerto_Codigo]         nvarchar(255)   NOT NULL,
    [Aeropuerto_Descripcion]    nvarchar(255),
    [Aeropuerto_Ciudad]         nvarchar(255),
    [Aeropuerto_Pais]           nvarchar(255),
    PRIMARY KEY ([Aeropuerto_Codigo])
);
INSERT INTO [BASADOS_DE_DATOS].[Aeropuerto]
SELECT DISTINCT
    [Aeropuerto_Salida_Codigo]          AS [Aeropuerto_Codigo]
    ,[Aeropuerto_Salida_Descripcion]    AS [Aeropuerto_Descripcion]
    ,[Aeropuerto_Salida_Ciudad]         AS [Aeropuerto_Ciudad]
    ,[Aeropuerto_Salida_Pais]           AS [Aeropuerto_Pais]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Aeropuerto_Salida_Codigo] IS NOT NULL
UNION
SELECT DISTINCT
    [Aeropuerto_Llegada_Codigo]
    ,[Aeropuerto_Llegada_Descripcion]
    ,[Aeropuerto_Llegada_Ciudad]
    ,[Aeropuerto_Llegada_Pais]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Aeropuerto_Llegada_Codigo] IS NOT NULL;


-- AEROLINEA
CREATE TABLE [BASADOS_DE_DATOS].[Aerolinea] (
    [Aerolinea_Codigo]      nvarchar(255)   NOT NULL,
    [Aerolinea_Nombre]      nvarchar(255),
    [Aerolinea_Pais]        nvarchar(255),
    [Aerolinea_Alianza]     nvarchar(255),
    PRIMARY KEY ([Aerolinea_Codigo])
);
INSERT INTO [BASADOS_DE_DATOS].[Aerolinea]
SELECT DISTINCT
    [Aerolinea_Codigo]
    ,[Aerolinea_Nombre]
    ,[Aerolinea_Pais]
    ,[Aerolinea_Alianza]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Aerolinea_Codigo] IS NOT NULL;


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
INSERT INTO [BASADOS_DE_DATOS].[Vuelo]
SELECT
    [Vuelo_Fecha_Salida]
    ,[Vuelo_Horario_Salida]
    ,[Aerolinea_Codigo]
    ,[Aeropuerto_Salida_Codigo]
    ,[Aeropuerto_Llegada_Codigo]
    ,[Vuelo_Fecha_Llegada]
    ,[Vuelo_Horario_Llegada]
    ,[Vuelo_Duracion]
    ,[Vuelo_Precio]
    ,[Vuelo_Incluye_Carry]
    ,[Vuelo_Incluye_Valija]
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY [Vuelo_Fecha_Salida], [Vuelo_Horario_Salida], [Aerolinea_Codigo] ORDER BY (SELECT NULL)) AS rn
    FROM [GD1C2026].[gd_esquema].[Maestra]
    WHERE [Vuelo_Fecha_Salida]   IS NOT NULL
      AND [Vuelo_Horario_Salida] IS NOT NULL
      AND [Aerolinea_Codigo]     IS NOT NULL
) t
WHERE rn = 1;


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
INSERT INTO [BASADOS_DE_DATOS].[Pasajero_Vuelo]
SELECT DISTINCT
    [Cliente_Dni]
    ,1 AS [nro_Cliente]
    ,[Vuelo_Fecha_Salida]
    ,[Vuelo_Horario_Salida]
    ,[Aerolinea_Codigo]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Cliente_Dni]         IS NOT NULL
  AND [Vuelo_Fecha_Salida]  IS NOT NULL
  AND [Vuelo_Horario_Salida] IS NOT NULL
  AND [Aerolinea_Codigo]    IS NOT NULL;


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
INSERT INTO [BASADOS_DE_DATOS].[Hospedaje]
SELECT
    [Hospedaje_Nombre]
    ,[Hospedaje_Ciudad]
    ,[Hospedaje_Pais]
    ,[Hospedaje_Direccion]
    ,[Hospedaje_Incluye_Desayuno]
    ,[Hospedaje_Check_In]
    ,[Hospedaje_Check_Out]
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY [Hospedaje_Nombre] ORDER BY (SELECT NULL)) AS rn
    FROM [GD1C2026].[gd_esquema].[Maestra]
    WHERE [Hospedaje_Nombre] IS NOT NULL
) t
WHERE rn = 1;


-- HABITACION
CREATE TABLE [BASADOS_DE_DATOS].[Habitacion] (
    [Habitacion_Nombre]         nvarchar(255)   NOT NULL,
    [Hospedaje_Nombre]          nvarchar(255)   NOT NULL,
    [Habitacion_Descripcion]    nvarchar(255),
    [Habitacion_Precio_Noche]   decimal(18,2),
    PRIMARY KEY ([Habitacion_Nombre], [Hospedaje_Nombre]),
    FOREIGN KEY ([Hospedaje_Nombre]) REFERENCES [BASADOS_DE_DATOS].[Hospedaje]([Hospedaje_Nombre])
);
INSERT INTO [BASADOS_DE_DATOS].[Habitacion]
SELECT DISTINCT
    [Habitacion_Nombre]
    ,[Hospedaje_Nombre]
    ,[Habitacion_Descripcion]
    ,[Habitacion_Precio_Noche]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Habitacion_Nombre]   IS NOT NULL
  AND [Hospedaje_Nombre]    IS NOT NULL;


-- EXCURSION
CREATE TABLE [BASADOS_DE_DATOS].[Excursion] (
    [Excursion_Nombre]          nvarchar(255)   NOT NULL,
    [Excursion_Descripcion]     nvarchar(255),
    [Excursion_Horario]         nvarchar(255),
    [Excursion_Duracion]        int,
    [Excursion_Precio]          decimal(18,2),
    PRIMARY KEY ([Excursion_Nombre])
);
INSERT INTO [BASADOS_DE_DATOS].[Excursion]
SELECT
    [Excursion_Nombre]
    ,[Excursion_Descripcion]
    ,[Excursion_Horario]
    ,[Excursion_Duracion]
    ,[Excursion_Precio]
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY [Excursion_Nombre] ORDER BY (SELECT NULL)) AS rn
    FROM [GD1C2026].[gd_esquema].[Maestra]
    WHERE [Excursion_Nombre] IS NOT NULL
) t
WHERE rn = 1;


-- PROVEEDOR
CREATE TABLE [BASADOS_DE_DATOS].[Proveedor] (
    [Proveedor_Nombre]      nvarchar(255)   NOT NULL,
    [Proveedor_Mail]        nvarchar(255),
    [Proveedor_Telefono]    nvarchar(255),
    PRIMARY KEY ([Proveedor_Nombre])
);
INSERT INTO [BASADOS_DE_DATOS].[Proveedor]
SELECT
    [Proveedor_Nombre]
    ,[Proveedor_Mail]
    ,[Proveedor_Telefono]
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY [Proveedor_Nombre] ORDER BY (SELECT NULL)) AS rn
    FROM [GD1C2026].[gd_esquema].[Maestra]
    WHERE [Proveedor_Nombre] IS NOT NULL
) t
WHERE rn = 1;


-- PROVEEDOR_AGENTE
-- Un proveedor puede trabajar con muchos agentes y viceversa.
CREATE TABLE [BASADOS_DE_DATOS].[Proveedor_Agente] (
    [Proveedor_Nombre]  nvarchar(255)   NOT NULL,
    [Agente_Legajo]     bigint          NOT NULL,
    PRIMARY KEY ([Proveedor_Nombre], [Agente_Legajo]),
    FOREIGN KEY ([Proveedor_Nombre]) REFERENCES [BASADOS_DE_DATOS].[Proveedor]([Proveedor_Nombre]),
    FOREIGN KEY ([Agente_Legajo])    REFERENCES [BASADOS_DE_DATOS].[Agente]([Agente_Legajo])
);
INSERT INTO [BASADOS_DE_DATOS].[Proveedor_Agente]
SELECT DISTINCT
    [Proveedor_Nombre]
    ,[Agente_Legajo]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Proveedor_Nombre] IS NOT NULL
  AND [Agente_Legajo]    IS NOT NULL;


-- ASPECTO
CREATE TABLE [BASADOS_DE_DATOS].[Aspecto] (
    [Aspecto_Aspecto]   nvarchar(255)   NOT NULL,
    PRIMARY KEY ([Aspecto_Aspecto])
);
INSERT INTO [BASADOS_DE_DATOS].[Aspecto]
SELECT DISTINCT
    [Aspecto_Aspecto]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Aspecto_Aspecto] IS NOT NULL;


-- ENCUESTA
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
INSERT INTO [BASADOS_DE_DATOS].[Encuesta]
SELECT DISTINCT
    [Encuesta_Codigo_Encuesta]
    ,[Cliente_Dni]
    ,1 AS [nro_Cliente]
    ,[Agente_Legajo]
    ,[Encuesta_Fecha_Encuesta]
    ,[Encuesta_Comentarios]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Encuesta_Codigo_Encuesta] IS NOT NULL;


-- DETALLE_ENCUESTA
CREATE TABLE [BASADOS_DE_DATOS].[Detalle_Encuesta] (
    [Encuesta_Codigo_Encuesta]  bigint          NOT NULL,
    [Aspecto_Aspecto]           nvarchar(255)   NOT NULL,
    [Detalle_Encuesta_Puntaje]  int,
    PRIMARY KEY ([Encuesta_Codigo_Encuesta], [Aspecto_Aspecto]),
    FOREIGN KEY ([Encuesta_Codigo_Encuesta]) REFERENCES [BASADOS_DE_DATOS].[Encuesta]([Encuesta_Codigo_Encuesta]),
    FOREIGN KEY ([Aspecto_Aspecto])          REFERENCES [BASADOS_DE_DATOS].[Aspecto]([Aspecto_Aspecto])
);
INSERT INTO [BASADOS_DE_DATOS].[Detalle_Encuesta]
SELECT DISTINCT
    [Encuesta_Codigo_Encuesta]
    ,[Aspecto_Aspecto]
    ,[Detalle_Encuesta_Puntaje]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Encuesta_Codigo_Encuesta]    IS NOT NULL
  AND [Aspecto_Aspecto]             IS NOT NULL;


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
INSERT INTO [BASADOS_DE_DATOS].[Solicitud]
SELECT DISTINCT
    [Solicitud_Nro_Solicitud]
    ,[Cliente_Dni]
    ,1 AS [nro_Cliente]
    ,[Agente_Legajo]
    ,[Solicitud_Fecha_Solicitud]
    ,[Solicitud_Fecha_Inicio_Tentativa]
    ,[Solicitud_Fecha_Fin_Tentativa]
    ,[Solicitud_Cant_Pax]
    ,[Solicitud_Observaciones]
    ,[Solicitud_Presupuesto_Estimado]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Solicitud_Nro_Solicitud] IS NOT NULL;


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
INSERT INTO [BASADOS_DE_DATOS].[Detalle_Solicitud]
SELECT
    ROW_NUMBER() OVER (ORDER BY [Solicitud_Nro_Solicitud]) AS [Detalle_Solicitud_Id]
    ,[Solicitud_Nro_Solicitud]
    ,[Detalle_Solicitud_Ciudad]
    ,[Detalle_Solicitud_Cant_Dias_Aprox]
    ,[Detalle_Solicitud_Observaciones]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Solicitud_Nro_Solicitud] IS NOT NULL;


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
INSERT INTO [BASADOS_DE_DATOS].[Propuesta]
SELECT DISTINCT
    [Propuesta_Nro_Propuesta]
    ,[Cliente_Dni]
    ,1 AS [nro_Cliente]
    ,[Propuesta_Fecha_Emision]
    ,[Propuesta_Vigencia_Hasta]
    ,[Propuesta_Fecha_Desde]
    ,[Propuesta_Fecha_Hasta]
    ,[Propuesta_Subtotal]
    ,[Propuesta_Descuento]
    ,[Propuesta_Importe_Total]
    ,[Propuesta_Estado]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Propuesta_Nro_Propuesta] IS NOT NULL;


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
INSERT INTO [BASADOS_DE_DATOS].[Detalle_Propuesta]
SELECT
    ROW_NUMBER() OVER (ORDER BY [Propuesta_Nro_Propuesta]) AS [Detalle_Propuesta_Id]
    ,[Propuesta_Nro_Propuesta]
    ,[Detalle_Propuesta_Vuelo_Cant_Pasajes]
    ,[Detalle_Propuesta_Vuelo_Precio]
    ,[Detalle_Propuesta_Vuelo_Subtotal]
    ,[Detalle_Propuesta_Hospedaje_Fecha_Desde]
    ,[Detalle_Propuesta_Hospedaje_Fecha_Hasta]
    ,[Detalle_Propuesta_Hospedaje_Cant]
    ,[Detalle_Propuesta_Hospedaje_Precio]
    ,[Detalle_Propuesta_Hospedaje_Subtotal]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Propuesta_Nro_Propuesta] IS NOT NULL;


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
INSERT INTO [BASADOS_DE_DATOS].[Venta]
SELECT DISTINCT
    [Venta_Nro_Venta]
    ,[Cliente_Dni]
    ,1 AS [nro_Cliente]
    ,[Agente_Legajo]
    ,[Venta_Fecha_Venta]
    ,[Venta_Canal_Venta]
    ,[Venta_Medio_Pago]
    ,[Venta_Subtotal]
    ,[Venta_Descuento]
    ,[Venta_Importe_Total]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Venta_Nro_Venta] IS NOT NULL;


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
INSERT INTO [BASADOS_DE_DATOS].[Detalle_Venta]
SELECT
    ROW_NUMBER() OVER (ORDER BY [Venta_Nro_Venta]) AS [Detalle_Venta_Id]
    ,[Venta_Nro_Venta]
    ,[Detalle_Venta_Vuelo_Cod_Reserva]
    ,[Detalle_Venta_Vuelo_Cantidad_Pasajes]
    ,[Detalle_Venta_Vuelo_Precio_Unitario]
    ,[Detalle_Venta_Vuelo_Subtotal]
    ,[Detalle_Venta_Hospedaje_Fecha_Desde]
    ,[Detalle_Venta_Hospedaje_Fecha_Hasta]
    ,[Detalle_Venta_Hospedaje_Cantidad]
    ,[Detalle_Venta_Hospedaje_Precio_Unitario]
    ,[Detalle_Venta_Hospedaje_Subtotal]
    ,[Detalle_Venta_Hospedaje_Cod_Reserva]
    ,[Detalle_Venta_Excursion_Fecha_Reserva]
    ,[Detalle_Venta_Excursion_Cant]
    ,[Detalle_Venta_Excursion_Precio_Unitario]
    ,[Detalle_Venta_Excursion_Subtotal]
    ,[Detalle_Venta_Excursion_Cod_Reserva]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Venta_Nro_Venta] IS NOT NULL;