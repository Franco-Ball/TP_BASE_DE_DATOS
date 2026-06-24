USE GD1C2026
GO

-- ========================================================================================
-- 1. DROP DE VISTAS
-- ========================================================================================
-- Las siguientes sentencias eliminan las vistas de indicadores si ya existen en la base, 
-- para permitir que el script se pueda ejecutar múltiples veces sin arrojar errores de duplicidad.
IF OBJECT_ID('[BASADOS_DE_DATOS].V_BI_Ticket_Promedio', 'V') IS NOT NULL DROP VIEW [BASADOS_DE_DATOS].V_BI_Ticket_Promedio;
IF OBJECT_ID('[BASADOS_DE_DATOS].V_BI_Distribucion_Facturacion', 'V') IS NOT NULL DROP VIEW [BASADOS_DE_DATOS].V_BI_Distribucion_Facturacion;
IF OBJECT_ID('[BASADOS_DE_DATOS].V_BI_Ranking_Solicitudes_Temporada', 'V') IS NOT NULL DROP VIEW [BASADOS_DE_DATOS].V_BI_Ranking_Solicitudes_Temporada;
IF OBJECT_ID('[BASADOS_DE_DATOS].V_BI_Anticipacion_Solicitudes', 'V') IS NOT NULL DROP VIEW [BASADOS_DE_DATOS].V_BI_Anticipacion_Solicitudes;
IF OBJECT_ID('[BASADOS_DE_DATOS].V_BI_Tasa_Aceptacion_Propuestas', 'V') IS NOT NULL DROP VIEW [BASADOS_DE_DATOS].V_BI_Tasa_Aceptacion_Propuestas;
IF OBJECT_ID('[BASADOS_DE_DATOS].V_BI_Cotizacion_Promedio_Temporada', 'V') IS NOT NULL DROP VIEW [BASADOS_DE_DATOS].V_BI_Cotizacion_Promedio_Temporada;
IF OBJECT_ID('[BASADOS_DE_DATOS].V_BI_Tiempo_Respuesta', 'V') IS NOT NULL DROP VIEW [BASADOS_DE_DATOS].V_BI_Tiempo_Respuesta;
IF OBJECT_ID('[BASADOS_DE_DATOS].V_BI_Desvio_Presupuesto', 'V') IS NOT NULL DROP VIEW [BASADOS_DE_DATOS].V_BI_Desvio_Presupuesto;
IF OBJECT_ID('[BASADOS_DE_DATOS].V_BI_Ranking_Aspectos', 'V') IS NOT NULL DROP VIEW [BASADOS_DE_DATOS].V_BI_Ranking_Aspectos;
IF OBJECT_ID('[BASADOS_DE_DATOS].V_BI_Satisfaccion_Promedio_Agente', 'V') IS NOT NULL DROP VIEW [BASADOS_DE_DATOS].V_BI_Satisfaccion_Promedio_Agente;
GO

-- ========================================================================================
-- 2. DROP DE TABLAS DE HECHOS
-- ========================================================================================
-- Se eliminan las tablas de hechos en caso de existir, respetando el orden de dependencias 
-- (primero las tablas que contienen Foreign Keys antes que las dimensiones).
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_hecho_venta', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_hecho_venta;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_hecho_solicitud', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_hecho_solicitud;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_hecho_propuesta', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_hecho_propuesta;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_hecho_aspecto', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_hecho_aspecto;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_hecho_encuesta', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_hecho_encuesta;
GO

-- ========================================================================================
-- 3. DROP DE DIMENSIONES
-- ========================================================================================
-- Se eliminan las tablas de dimensiones luego de haber eliminado las tablas de hechos que las referencian.
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_dimension_tiempo', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_dimension_tiempo;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_dimension_rango_etario_agente', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_dimension_temporada', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_dimension_temporada;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_dimension_tipo_servicio', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_dimension_tipo_servicio;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_dimension_canal_de_venta', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_dimension_canal_de_venta;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_dimension_estado_propuesta', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_dimension_estado_propuesta;
IF OBJECT_ID('[BASADOS_DE_DATOS].BI_dimension_detalle_aspecto', 'U') IS NOT NULL DROP TABLE [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto;
GO

-- ========================================================================================
-- 4. DROP DE PROCEDURES Y FUNCIONES
-- ========================================================================================
-- Se eliminan los stored procedures y funciones auxiliares generados para la carga de datos.
IF OBJECT_ID('[BASADOS_DE_DATOS].sp_migrar_dimensiones_bi', 'P') IS NOT NULL DROP PROCEDURE [BASADOS_DE_DATOS].sp_migrar_dimensiones_bi;
IF OBJECT_ID('[BASADOS_DE_DATOS].sp_migrar_hechos_bi', 'P') IS NOT NULL DROP PROCEDURE [BASADOS_DE_DATOS].sp_migrar_hechos_bi;
IF OBJECT_ID('[BASADOS_DE_DATOS].fn_calcular_edad', 'FN') IS NOT NULL DROP FUNCTION [BASADOS_DE_DATOS].fn_calcular_edad;
IF OBJECT_ID('[BASADOS_DE_DATOS].fn_rango_etario', 'FN') IS NOT NULL DROP FUNCTION [BASADOS_DE_DATOS].fn_rango_etario;
IF OBJECT_ID('[BASADOS_DE_DATOS].fn_temporada', 'FN') IS NOT NULL DROP FUNCTION [BASADOS_DE_DATOS].fn_temporada;
GO

-- ========================================================================================
-- 5. FUNCIONES AUXILIARES
-- ========================================================================================

-- Función para calcular la edad exacta de una persona en base a su fecha de nacimiento y la fecha del evento.
CREATE FUNCTION [BASADOS_DE_DATOS].fn_calcular_edad(@fecha_nac DATE, @fecha_evento DATE)
RETURNS INT AS
BEGIN
    RETURN DATEDIFF(YEAR, @fecha_nac, @fecha_evento) - CASE WHEN (MONTH(@fecha_nac) > MONTH(@fecha_evento)) OR (MONTH(@fecha_nac) = MONTH(@fecha_evento) AND DAY(@fecha_nac) > DAY(@fecha_evento)) THEN 1 ELSE 0 END
END
GO

-- Función para categorizar la edad numérica en los rangos etarios solicitados por el negocio.
CREATE FUNCTION [BASADOS_DE_DATOS].fn_rango_etario(@edad INT)
RETURNS NVARCHAR(50) AS
BEGIN
    RETURN CASE
        WHEN @edad <= 25 THEN 'Menores de 25 años inclusive'
        WHEN @edad > 25 AND @edad <= 35 THEN 'Entre 25 y 35 años inclusive'
        WHEN @edad > 35 AND @edad <= 50 THEN 'Entre 35 y 50 años inclusive'
        ELSE 'Mayores de 50 años'
    END
END
GO

-- Función para determinar la temporada (Verano, Otoño, Invierno, Primavera) en base a un mes.
CREATE FUNCTION [BASADOS_DE_DATOS].fn_temporada(@fecha DATE)
RETURNS NVARCHAR(50) AS
BEGIN
    RETURN CASE
        WHEN MONTH(@fecha) IN (1, 2, 3) THEN 'Verano (Enero - Marzo)'
        WHEN MONTH(@fecha) IN (4, 5, 6) THEN 'Otoño (Abril - Junio)'
        WHEN MONTH(@fecha) IN (7, 8, 9) THEN 'Invierno (Julio - Septiembre)'
        WHEN MONTH(@fecha) IN (10, 11, 12) THEN 'Primavera (Octubre - Diciembre)'
    END
END
GO

-- ========================================================================================
-- 6. CREACIÓN DE DIMENSIONES
-- ========================================================================================

-- Dimensión Tiempo: Agrupa y clasifica las fechas en años, cuatrimestres y meses.
CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_tiempo(
    id_tiempo bigint IDENTITY(1,1) PRIMARY KEY,
    anyo int,
    cuatrimestre int,
    mes int
);

-- Dimensión Rango Etario Cliente: Define los buckets de edad de los clientes.
CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente(
    id_rango_etario_cliente bigint IDENTITY(1,1) PRIMARY KEY,
    rango nvarchar(50)
);

-- Dimensión Rango Etario Agente: Define los buckets de edad de los agentes.
CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente(
    id_rango_etario_agente bigint IDENTITY(1,1) PRIMARY KEY,
    rango nvarchar(50)
);

-- Dimensión Temporada: Almacena las 4 estaciones o temporadas del año.
CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_temporada(
    id_temporada bigint IDENTITY(1,1) PRIMARY KEY,
    temporada nvarchar(50)
);

-- Dimensión Tipo Servicio: Identifica si un servicio proviene de venta directa o de propuesta a medida.
CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_tipo_servicio(
    id_tipo_servicio bigint IDENTITY(1,1) PRIMARY KEY,
    tipo nvarchar(50)
);

-- Dimensión Canal de Venta: Registra los distintos canales por donde ingresa la venta.
CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_canal_de_venta(
    id_canal_de_venta bigint IDENTITY(1,1) PRIMARY KEY,
    canal nvarchar(255)
);

-- Dimensión Estado Propuesta: Muestra los estados finales de una propuesta (ej. Aceptada, Rechazada).
CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_estado_propuesta(
    id_estado_propuesta bigint IDENTITY(1,1) PRIMARY KEY,
    estado nvarchar(255)
);

-- Dimensión Detalle Aspecto: Contiene los nombres de los atributos valorados en las encuestas.
CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto(
    id_detalle_aspecto bigint IDENTITY(1,1) PRIMARY KEY,
    detalle nvarchar(255)
);
GO

-- ========================================================================================
-- 7. CREACIÓN DE TABLAS DE HECHOS
-- ========================================================================================

-- Hecho Venta: Registra los importes totales de las ventas asociándolas al tiempo, cliente, canal y servicio.
CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_venta(
    rango_etario_cliente bigint,
    canal_de_venta bigint,
    tiempo bigint,
    tipo_servicio bigint,
    importe_total decimal(18,2),
    FOREIGN KEY (rango_etario_cliente) REFERENCES [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente(id_rango_etario_cliente),
    FOREIGN KEY (canal_de_venta) REFERENCES [BASADOS_DE_DATOS].BI_dimension_canal_de_venta(id_canal_de_venta),
    FOREIGN KEY (tiempo) REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (tipo_servicio) REFERENCES [BASADOS_DE_DATOS].BI_dimension_tipo_servicio(id_tipo_servicio)
);

-- Hecho Solicitud: Contabiliza los días de anticipación de una solicitud según la temporada y la edad del cliente.
CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_solicitud(
    tiempo bigint,
    temporada bigint,
    rango_etario_cliente bigint,
    dias_anticipacion int,
    FOREIGN KEY (tiempo) REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (temporada) REFERENCES [BASADOS_DE_DATOS].BI_dimension_temporada(id_temporada),
    FOREIGN KEY (rango_etario_cliente) REFERENCES [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente(id_rango_etario_cliente)
);

-- Hecho Propuesta: Permite analizar la eficacia (tiempos de respuesta, desvíos monetarios) del trabajo de los agentes y los importes de propuestas.
CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_propuesta(
    estado_propuesta bigint,
    temporada_inicio_viaje bigint,
    tiempo_emision_propuesta bigint,
    tiempo_inicio_viaje bigint,
    tiempo_fecha_solicitud bigint,
    rango_etario_agente bigint,
    dias_entre_solicitud_y_propuesta int,
    importe_total decimal(18,2),
    desvio_presupuesto_importe decimal(18,2),
    FOREIGN KEY (estado_propuesta) REFERENCES [BASADOS_DE_DATOS].BI_dimension_estado_propuesta(id_estado_propuesta),
    FOREIGN KEY (temporada_inicio_viaje) REFERENCES [BASADOS_DE_DATOS].BI_dimension_temporada(id_temporada),
    FOREIGN KEY (tiempo_emision_propuesta) REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (tiempo_inicio_viaje) REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (tiempo_fecha_solicitud) REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (rango_etario_agente) REFERENCES [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente(id_rango_etario_agente)
);

-- Hecho Aspecto: Almacena el puntaje directo de cada pregunta individual dentro de una encuesta.
CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_aspecto(
    tiempo bigint,
    detalle_aspecto bigint,
    puntaje int,
    FOREIGN KEY (tiempo) REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (detalle_aspecto) REFERENCES [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto(id_detalle_aspecto)
);

-- Hecho Encuesta: Mide la satisfacción general (promediada) de cada atención brindada por un agente en un momento del tiempo.
CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_encuesta(
    rango_etario_agente bigint,
    tiempo bigint,
    puntaje decimal(18,2), 
    FOREIGN KEY (rango_etario_agente) REFERENCES [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente(id_rango_etario_agente),
    FOREIGN KEY (tiempo) REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo)
);
GO

-- ========================================================================================
-- 8. PROCEDIMIENTOS DE MIGRACIÓN
-- ========================================================================================

-- Stored Procedure principal que poblará las tablas maestras de dimensiones estáticas e inferidas (catálogos)
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_dimensiones_bi
AS
BEGIN
    -- Carga de la dimensión Tiempo: Unificamos todas las fechas registradas en el sistema para tener un catálogo maestro
    INSERT INTO [BASADOS_DE_DATOS].BI_dimension_tiempo (anyo, cuatrimestre, mes)
    SELECT DISTINCT YEAR(fecha), 
           CASE WHEN MONTH(fecha) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(fecha) BETWEEN 5 AND 8 THEN 2
                ELSE 3 END, 
           MONTH(fecha)
    FROM (
        SELECT vent_fecha as fecha FROM [BASADOS_DE_DATOS].Venta WHERE vent_fecha IS NOT NULL
        UNION
        SELECT soli_fecha FROM [BASADOS_DE_DATOS].Solicitud WHERE soli_fecha IS NOT NULL
        UNION
        SELECT soli_inicio_tentativa FROM [BASADOS_DE_DATOS].Solicitud WHERE soli_inicio_tentativa IS NOT NULL
        UNION
        SELECT prop_fecha_emision FROM [BASADOS_DE_DATOS].Propuesta WHERE prop_fecha_emision IS NOT NULL
        UNION
        SELECT prop_fecha_desde FROM [BASADOS_DE_DATOS].Propuesta WHERE prop_fecha_desde IS NOT NULL
        UNION
        SELECT encu_fecha FROM [BASADOS_DE_DATOS].Encuesta WHERE encu_fecha IS NOT NULL
    ) as Fechas;

    -- Inserción explícita de los 4 rangos etarios solicitados para clientes
    INSERT INTO [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente (rango)
    VALUES ('Menores de 25 años inclusive'), ('Entre 25 y 35 años inclusive'), ('Entre 35 y 50 años inclusive'), ('Mayores de 50 años');

    -- Inserción explícita de los 4 rangos etarios solicitados para agentes
    INSERT INTO [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente (rango)
    VALUES ('Menores de 25 años inclusive'), ('Entre 25 y 35 años inclusive'), ('Entre 35 y 50 años inclusive'), ('Mayores de 50 años');

    -- Inserción explícita de las 4 temporadas requeridas en las métricas
    INSERT INTO [BASADOS_DE_DATOS].BI_dimension_temporada (temporada)
    VALUES ('Verano (Enero - Marzo)'), ('Otoño (Abril - Junio)'), ('Invierno (Julio - Septiembre)'), ('Primavera (Octubre - Diciembre)');

    -- Inserción explícita de la clasificación de servicio (Directa o Personalizada)
    INSERT INTO [BASADOS_DE_DATOS].BI_dimension_tipo_servicio (tipo)
    VALUES ('Venta Directa'), ('Propuesta a Medida');

    -- Se copian los catálogos del sistema transaccional referidos a Canales de Venta
    INSERT INTO [BASADOS_DE_DATOS].BI_dimension_canal_de_venta (canal)
    SELECT cana_nombre FROM [BASADOS_DE_DATOS].CanalVenta;

    -- Se copian los catálogos del sistema transaccional referidos a Estados de Propuestas
    INSERT INTO [BASADOS_DE_DATOS].BI_dimension_estado_propuesta (estado)
    SELECT esta_nombre FROM [BASADOS_DE_DATOS].EstadoPropuesta;

    -- Se extraen y unifican todos los aspectos evaluables presentes en las encuestas
    INSERT INTO [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto (detalle)
    SELECT DISTINCT aspe_detalle FROM [BASADOS_DE_DATOS].Aspecto WHERE aspe_detalle IS NOT NULL;
END
GO

-- Stored Procedure principal que extrae la volumetría del sistema e inserta las tablas de hechos mediante cruces con dimensiones
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_hechos_bi
AS
BEGIN
    -- Migración de la tabla Hechos de Venta: Determina el tipo de servicio mediante un LEFT JOIN contra las ventas originadas en propuestas
    INSERT INTO [BASADOS_DE_DATOS].BI_hecho_venta (rango_etario_cliente, canal_de_venta, tiempo, tipo_servicio, importe_total)
    SELECT 
        rc.id_rango_etario_cliente,
        cv.id_canal_de_venta,
        t.id_tiempo,
        ts.id_tipo_servicio,
        v.vent_importe_total
    FROM [BASADOS_DE_DATOS].Venta v
    JOIN [BASADOS_DE_DATOS].Cliente c ON v.vent_cliente = c.clie_codigo
    JOIN [BASADOS_DE_DATOS].CanalVenta canal ON v.vent_canal_venta = canal.cana_codigo
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON YEAR(v.vent_fecha) = t.anyo AND MONTH(v.vent_fecha) = t.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rc ON rc.rango = [BASADOS_DE_DATOS].fn_rango_etario([BASADOS_DE_DATOS].fn_calcular_edad(c.clie_fecha_nacimiento, v.vent_fecha))
    JOIN [BASADOS_DE_DATOS].BI_dimension_canal_de_venta cv ON cv.canal = canal.cana_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Venta_Propuesta vp ON vp.vpro_venta = v.vent_codigo
    JOIN [BASADOS_DE_DATOS].BI_dimension_tipo_servicio ts ON ts.tipo = CASE WHEN vp.vpro_propuesta IS NULL THEN 'Venta Directa' ELSE 'Propuesta a Medida' END;

    -- Migración de la tabla Hechos de Solicitud: Calcula matemáticamente los días de anticipación de una solicitud respecto al inicio previsto
    INSERT INTO [BASADOS_DE_DATOS].BI_hecho_solicitud (tiempo, temporada, rango_etario_cliente, dias_anticipacion)
    SELECT 
        t.id_tiempo,
        temp.id_temporada,
        rc.id_rango_etario_cliente,
        DATEDIFF(DAY, s.soli_fecha, s.soli_inicio_tentativa) as dias_anticipacion
    FROM [BASADOS_DE_DATOS].Solicitud s
    JOIN [BASADOS_DE_DATOS].Cliente c ON s.soli_cliente = c.clie_codigo
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON YEAR(s.soli_fecha) = t.anyo AND MONTH(s.soli_fecha) = t.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_temporada temp ON temp.temporada = [BASADOS_DE_DATOS].fn_temporada(s.soli_inicio_tentativa)
    JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rc ON rc.rango = [BASADOS_DE_DATOS].fn_rango_etario([BASADOS_DE_DATOS].fn_calcular_edad(c.clie_fecha_nacimiento, s.soli_fecha));

    -- Migración de la tabla Hechos de Propuestas: Resuelve los cruces temporales, el tiempo de respuesta del agente y el desvío monetario
    INSERT INTO [BASADOS_DE_DATOS].BI_hecho_propuesta (estado_propuesta, temporada_inicio_viaje, tiempo_emision_propuesta, tiempo_inicio_viaje, tiempo_fecha_solicitud, rango_etario_agente, dias_entre_solicitud_y_propuesta, importe_total, desvio_presupuesto_importe)
    SELECT 
        ep.id_estado_propuesta,
        temp.id_temporada,
        t_emi.id_tiempo,
        t_ini.id_tiempo,
        t_sol.id_tiempo,
        ra.id_rango_etario_agente,
        DATEDIFF(DAY, s.soli_fecha, p.prop_fecha_emision),
        p.prop_importe_total,
        (p.prop_importe_total - s.soli_presupuesto_estimado) as desvio_presupuesto_importe
    FROM [BASADOS_DE_DATOS].Propuesta p
    JOIN [BASADOS_DE_DATOS].Solicitud s ON p.prop_solicitud = s.soli_numero
    JOIN [BASADOS_DE_DATOS].EstadoPropuesta e ON p.prop_estado = e.esta_codigo
    JOIN [BASADOS_DE_DATOS].Agente a ON p.prop_agente = a.agen_legajo
    JOIN [BASADOS_DE_DATOS].BI_dimension_estado_propuesta ep ON ep.estado = e.esta_nombre
    JOIN [BASADOS_DE_DATOS].BI_dimension_temporada temp ON temp.temporada = [BASADOS_DE_DATOS].fn_temporada(p.prop_fecha_desde)
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_emi ON YEAR(p.prop_fecha_emision) = t_emi.anyo AND MONTH(p.prop_fecha_emision) = t_emi.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_ini ON YEAR(p.prop_fecha_desde) = t_ini.anyo AND MONTH(p.prop_fecha_desde) = t_ini.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_sol ON YEAR(s.soli_fecha) = t_sol.anyo AND MONTH(s.soli_fecha) = t_sol.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente ra ON ra.rango = [BASADOS_DE_DATOS].fn_rango_etario([BASADOS_DE_DATOS].fn_calcular_edad(a.agen_fecha_nacimiento, p.prop_fecha_emision));

    -- Migración de la tabla Hechos Aspecto: Desdobla las respuestas individuales de las encuestas
    INSERT INTO [BASADOS_DE_DATOS].BI_hecho_aspecto (tiempo, detalle_aspecto, puntaje)
    SELECT 
        t.id_tiempo,
        da.id_detalle_aspecto,
        a.aspe_puntaje
    FROM [BASADOS_DE_DATOS].Aspecto a
    JOIN [BASADOS_DE_DATOS].Encuesta e ON a.aspe_encuesta = e.encu_codigo
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON YEAR(e.encu_fecha) = t.anyo AND MONTH(e.encu_fecha) = t.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto da ON da.detalle = a.aspe_detalle;

    -- Migración de la tabla Hechos de Encuestas (Satisfacción Promedio): Genera una sola fila por encuesta con la media de sus preguntas
    INSERT INTO [BASADOS_DE_DATOS].BI_hecho_encuesta (rango_etario_agente, tiempo, puntaje)
    SELECT 
        ra.id_rango_etario_agente,
        t.id_tiempo,
        AVG(CAST(asp.aspe_puntaje AS DECIMAL(18,2))) as puntaje_promedio
    FROM [BASADOS_DE_DATOS].Encuesta e
    JOIN [BASADOS_DE_DATOS].Aspecto asp ON e.encu_codigo = asp.aspe_encuesta
    JOIN [BASADOS_DE_DATOS].Agente ag ON e.encu_agente = ag.agen_legajo
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON YEAR(e.encu_fecha) = t.anyo AND MONTH(e.encu_fecha) = t.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente ra ON ra.rango = [BASADOS_DE_DATOS].fn_rango_etario([BASADOS_DE_DATOS].fn_calcular_edad(ag.agen_fecha_nacimiento, e.encu_fecha))
    GROUP BY ra.id_rango_etario_agente, t.id_tiempo, e.encu_codigo;
END
GO

-- ========================================================================================
-- 9. EJECUCIÓN DE PROCEDIMIENTOS DE MIGRACIÓN
-- ========================================================================================
-- Se ejecutan en orden lógico: las dimensiones primero y luego las tablas de hechos que las consumen.
EXEC [BASADOS_DE_DATOS].sp_migrar_dimensiones_bi;
EXEC [BASADOS_DE_DATOS].sp_migrar_hechos_bi;
GO

-- ========================================================================================
-- 10. CREACIÓN DE VISTAS (TABLEROS DE CONTROL)
-- ========================================================================================

-- Vista 1. Ticket promedio: Valor promedio de venta mensual según rango etario de cliente y canal de venta.
-- Utiliza AVG sobre los importes agrupados por edad, canal, año y mes.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Ticket_Promedio AS
SELECT 
    t.anyo as Anio,
    t.mes as Mes,
    rc.rango as Rango_Etario_Cliente,
    cv.canal as Canal_Venta,
    AVG(hv.importe_total) as Ticket_Promedio
FROM [BASADOS_DE_DATOS].BI_hecho_venta hv
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON hv.tiempo = t.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rc ON hv.rango_etario_cliente = rc.id_rango_etario_cliente
JOIN [BASADOS_DE_DATOS].BI_dimension_canal_de_venta cv ON hv.canal_de_venta = cv.id_canal_de_venta
GROUP BY t.anyo, t.mes, rc.rango, cv.canal;
GO

-- Vista 2. Distribución de Facturación: Porcentaje correspondiente a cada tipo de servicio por cuatrimestre y año.
-- Aplica particiones analíticas (OVER PARTITION) para calcular el 100% de la facturación del período y obtener el margen parcial.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Distribucion_Facturacion AS
SELECT 
    t.anyo as Anio,
    t.cuatrimestre as Cuatrimestre,
    ts.tipo as Tipo_Servicio,
    SUM(hv.importe_total) * 100.0 / SUM(SUM(hv.importe_total)) OVER (PARTITION BY t.anyo, t.cuatrimestre) as Porcentaje_Facturacion
FROM [BASADOS_DE_DATOS].BI_hecho_venta hv
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON hv.tiempo = t.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_tipo_servicio ts ON hv.tipo_servicio = ts.id_tipo_servicio
GROUP BY t.anyo, t.cuatrimestre, ts.tipo;
GO

-- Vista 3. Ranking de solicitudes por temporadas: Cantidad realizadas por temporada y rango etario.
-- Cuenta el número absoluto de filas de solicitudes agrupando por las dimensiones descritas.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Ranking_Solicitudes_Temporada AS
SELECT 
    t.anyo as Anio,
    temp.temporada as Temporada,
    rc.rango as Rango_Etario_Cliente,
    COUNT(*) as Cantidad_Solicitudes
FROM [BASADOS_DE_DATOS].BI_hecho_solicitud hs
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON hs.tiempo = t.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_temporada temp ON hs.temporada = temp.id_temporada
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rc ON hs.rango_etario_cliente = rc.id_rango_etario_cliente
GROUP BY t.anyo, temp.temporada, rc.rango;
GO

-- Vista 4. Anticipación promedio de solicitudes: Promedio de días calculados en la migración por rango etario y cuatrimestre.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Anticipacion_Solicitudes AS
SELECT 
    t.anyo as Anio,
    t.cuatrimestre as Cuatrimestre,
    rc.rango as Rango_Etario_Cliente,
    AVG(CAST(hs.dias_anticipacion as decimal(18,2))) as Anticipacion_Promedio_Dias
FROM [BASADOS_DE_DATOS].BI_hecho_solicitud hs
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON hs.tiempo = t.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rc ON hs.rango_etario_cliente = rc.id_rango_etario_cliente
GROUP BY t.anyo, t.cuatrimestre, rc.rango;
GO

-- Vista 5. Tasa de aceptación de propuestas: Porcentaje aceptado respecto del total emitido en un cuatrimestre.
-- Se vale de la expresión lógica CASE para contar las favorables sobre la población total.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Tasa_Aceptacion_Propuestas AS
SELECT 
    t.anyo as Anio,
    t.cuatrimestre as Cuatrimestre,
    CAST(SUM(CASE WHEN ep.estado LIKE '%ceptad%' THEN 1 ELSE 0 END) AS DECIMAL) * 100.0 / COUNT(*) as Tasa_Aceptacion_Porcentaje
FROM [BASADOS_DE_DATOS].BI_hecho_propuesta hp
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON hp.tiempo_emision_propuesta = t.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_estado_propuesta ep ON hp.estado_propuesta = ep.id_estado_propuesta
GROUP BY t.anyo, t.cuatrimestre;
GO

-- Vista 6. Cotización promedio por temporada: Referencia tomada directamente de la fecha inicial planificada para el viaje.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Cotizacion_Promedio_Temporada AS
SELECT 
    t_ini.anyo as Anio_Inicio_Viaje,
    temp.temporada as Temporada_Inicio_Viaje,
    AVG(hp.importe_total) as Cotizacion_Promedio
FROM [BASADOS_DE_DATOS].BI_hecho_propuesta hp
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_ini ON hp.tiempo_inicio_viaje = t_ini.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_temporada temp ON hp.temporada_inicio_viaje = temp.id_temporada
GROUP BY t_ini.anyo, temp.temporada;
GO

-- Vista 7. Tiempo promedio de respuesta: Calcula la brecha temporal promedio en que tarda un agente en enviar una cotización.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Tiempo_Respuesta AS
SELECT 
    t_sol.anyo as Anio_Solicitud,
    t_sol.mes as Mes_Solicitud,
    ra.rango as Rango_Etario_Agente,
    AVG(CAST(hp.dias_entre_solicitud_y_propuesta as decimal(18,2))) as Tiempo_Respuesta_Dias
FROM [BASADOS_DE_DATOS].BI_hecho_propuesta hp
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_sol ON hp.tiempo_fecha_solicitud = t_sol.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente ra ON hp.rango_etario_agente = ra.id_rango_etario_agente
GROUP BY t_sol.anyo, t_sol.mes, ra.rango;
GO

-- Vista 8. Desvío de presupuesto: Indica cuánto se apartan las propuestas financieras generadas del presupuesto meta del cliente.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Desvio_Presupuesto AS
SELECT 
    t_emi.anyo as Anio_Emision,
    t_emi.mes as Mes_Emision,
    AVG(hp.desvio_presupuesto_importe) as Desvio_Presupuesto_Promedio
FROM [BASADOS_DE_DATOS].BI_hecho_propuesta hp
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_emi ON hp.tiempo_emision_propuesta = t_emi.id_tiempo
GROUP BY t_emi.anyo, t_emi.mes;
GO

-- Vista 9. Ranking de aspectos mejor y peor valorados: Ordena el desempeño general de los atributos auditados.
-- Utiliza funciones de partición RANK() y ordenamientos ascendentes/descendentes para determinar posiciones del ranking.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Ranking_Aspectos AS
SELECT 
    t.anyo as Anio,
    t.cuatrimestre as Cuatrimestre,
    da.detalle as Aspecto,
    AVG(CAST(ha.puntaje as decimal(18,2))) as Puntaje_Promedio,
    RANK() OVER (PARTITION BY t.anyo, t.cuatrimestre ORDER BY AVG(CAST(ha.puntaje as decimal(18,2))) DESC) as Ranking_Mejor_Valorado,
    RANK() OVER (PARTITION BY t.anyo, t.cuatrimestre ORDER BY AVG(CAST(ha.puntaje as decimal(18,2))) ASC) as Ranking_Peor_Valorado
FROM [BASADOS_DE_DATOS].BI_hecho_aspecto ha
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON ha.tiempo = t.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto da ON ha.detalle_aspecto = da.id_detalle_aspecto
GROUP BY t.anyo, t.cuatrimestre, da.detalle;
GO

-- Vista 10. Satisfacción promedio por agente: Consolida la métrica general ponderada de la experiencia comercial brindada.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Satisfaccion_Promedio_Agente AS
SELECT 
    t.anyo as Anio,
    t.mes as Mes,
    ra.rango as Rango_Etario_Agente,
    AVG(he.puntaje) as Satisfaccion_Promedio
FROM [BASADOS_DE_DATOS].BI_hecho_encuesta he
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON he.tiempo = t.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente ra ON he.rango_etario_agente = ra.id_rango_etario_agente
GROUP BY t.anyo, t.mes, ra.rango;
GO
