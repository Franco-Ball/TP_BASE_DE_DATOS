-- AGENCIA
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
INSERT INTO [BASADOS_DE_DATOS].[Aerolinea]
SELECT DISTINCT
    [Aerolinea_Codigo]
    ,[Aerolinea_Nombre]
    ,[Aerolinea_Pais]
    ,[Aerolinea_Alianza]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Aerolinea_Codigo] IS NOT NULL;


-- VUELO
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
INSERT INTO [BASADOS_DE_DATOS].[Proveedor_Agente]
SELECT DISTINCT
    [Proveedor_Nombre]
    ,[Agente_Legajo]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Proveedor_Nombre] IS NOT NULL
  AND [Agente_Legajo]    IS NOT NULL;


-- ASPECTO
INSERT INTO [BASADOS_DE_DATOS].[Aspecto]
SELECT DISTINCT
    [Aspecto_Aspecto]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Aspecto_Aspecto] IS NOT NULL;


-- ENCUESTA
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
INSERT INTO [BASADOS_DE_DATOS].[Detalle_Encuesta]
SELECT DISTINCT
    [Encuesta_Codigo_Encuesta]
    ,[Aspecto_Aspecto]
    ,[Detalle_Encuesta_Puntaje]
FROM [GD1C2026].[gd_esquema].[Maestra]
WHERE [Encuesta_Codigo_Encuesta]    IS NOT NULL
  AND [Aspecto_Aspecto]             IS NOT NULL;


-- SOLICITUD
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
