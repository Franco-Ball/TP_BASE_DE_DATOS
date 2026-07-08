USE GD1C2026
GO

-- ========================================================================================
-- 1. FUNCIONES AUXILIARES
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
-- 2. CREACIÓN DE DIMENSIONES
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
-- 3. CREACIÓN DE TABLAS DE HECHOS
-- ========================================================================================

-- Hecho Venta: Registra los importes totales de las ventas asociándolas al tiempo, cliente, canal y servicio.
CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_venta(
    rango_etario_cliente bigint,
    canal_de_venta bigint,
    tiempo bigint,
    tipo_servicio bigint,
    importe_total decimal(18,2),
    cantidad_ventas int,
    PRIMARY KEY (rango_etario_cliente, canal_de_venta, tiempo, tipo_servicio)
);

-- Hecho Solicitud: Contabiliza los días de anticipación de una solicitud según la temporada y la edad del cliente.
CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_solicitud(
    tiempo bigint,
    temporada bigint,
    rango_etario_cliente bigint,
    total_dias_anticipacion int,
    cantidad_solicitudes int,
    PRIMARY KEY (tiempo, temporada, rango_etario_cliente)
);

-- Hecho Propuesta: Permite analizar la eficacia (tiempos de respuesta, desvíos monetarios) del trabajo de los agentes y los importes de propuestas.
CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_propuesta(
    estado_propuesta bigint,
    temporada_inicio_viaje bigint,
    tiempo_emision_propuesta bigint,
    tiempo_inicio_viaje bigint,
    tiempo_fecha_solicitud bigint,
    rango_etario_agente bigint,
    total_dias_entre_solicitud_y_propuesta int,
    importe_total decimal(18,2),
    total_desvio_presupuesto_importe decimal(18,2),
    cantidad_propuestas int,
    PRIMARY KEY (estado_propuesta, temporada_inicio_viaje, tiempo_emision_propuesta, tiempo_inicio_viaje, tiempo_fecha_solicitud, rango_etario_agente)
);

-- Hecho Aspecto: Almacena el puntaje directo de cada pregunta individual dentro de una encuesta.
CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_aspecto(
    tiempo bigint,
    detalle_aspecto bigint,
    total_puntaje int,
    cantidad_evaluaciones int,
    PRIMARY KEY (tiempo, detalle_aspecto)
);

-- Hecho Encuesta: Mide la satisfacción general (promediada) de cada atención brindada por un agente en un momento del tiempo.
CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_encuesta(
    rango_etario_agente bigint,
    tiempo bigint,
    total_puntaje decimal(18,2),
    cantidad_encuestas int,
    PRIMARY KEY (rango_etario_agente, tiempo)
);
GO

-- ========================================================================================
-- 4. PROCEDIMIENTOS DE MIGRACIÓN
-- ========================================================================================

-- Stored Procedure principal que poblará las tablas maestras de dimensiones estáticas e inferidas (catálogos)
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_dimensiones_bi
AS
BEGIN
    -- Carga de la dimensión Tiempo: Extraemos fechas directamente con múltiples SELECTs usando UNION
    INSERT INTO [BASADOS_DE_DATOS].BI_dimension_tiempo (anyo, cuatrimestre, mes)
    SELECT YEAR(vent_fecha), 
           CASE WHEN MONTH(vent_fecha) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(vent_fecha) BETWEEN 5 AND 8 THEN 2
                ELSE 3 END, 
           MONTH(vent_fecha)
    FROM [BASADOS_DE_DATOS].Venta WHERE vent_fecha IS NOT NULL
    UNION
    SELECT YEAR(soli_fecha), 
           CASE WHEN MONTH(soli_fecha) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(soli_fecha) BETWEEN 5 AND 8 THEN 2
                ELSE 3 END, 
           MONTH(soli_fecha)
    FROM [BASADOS_DE_DATOS].Solicitud WHERE soli_fecha IS NOT NULL
    UNION
    SELECT YEAR(soli_inicio_tentativa), 
           CASE WHEN MONTH(soli_inicio_tentativa) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(soli_inicio_tentativa) BETWEEN 5 AND 8 THEN 2
                ELSE 3 END, 
           MONTH(soli_inicio_tentativa)
    FROM [BASADOS_DE_DATOS].Solicitud WHERE soli_inicio_tentativa IS NOT NULL
    UNION
    SELECT YEAR(prop_fecha_emision), 
           CASE WHEN MONTH(prop_fecha_emision) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(prop_fecha_emision) BETWEEN 5 AND 8 THEN 2
                ELSE 3 END, 
           MONTH(prop_fecha_emision)
    FROM [BASADOS_DE_DATOS].Propuesta WHERE prop_fecha_emision IS NOT NULL
    UNION
    SELECT YEAR(prop_fecha_desde), 
           CASE WHEN MONTH(prop_fecha_desde) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(prop_fecha_desde) BETWEEN 5 AND 8 THEN 2
                ELSE 3 END, 
           MONTH(prop_fecha_desde)
    FROM [BASADOS_DE_DATOS].Propuesta WHERE prop_fecha_desde IS NOT NULL
    UNION
    SELECT YEAR(encu_fecha), 
           CASE WHEN MONTH(encu_fecha) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(encu_fecha) BETWEEN 5 AND 8 THEN 2
                ELSE 3 END, 
           MONTH(encu_fecha)
    FROM [BASADOS_DE_DATOS].Encuesta WHERE encu_fecha IS NOT NULL;

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
    INSERT INTO [BASADOS_DE_DATOS].BI_hecho_venta (rango_etario_cliente, canal_de_venta, tiempo, tipo_servicio, importe_total, cantidad_ventas)
    SELECT
        rc.id_rango_etario_cliente,
        cv.id_canal_de_venta,
        t.id_tiempo,
        ts.id_tipo_servicio,
        sum(v.vent_importe_total),
        COUNT(*)
    FROM [BASADOS_DE_DATOS].Venta v
    JOIN [BASADOS_DE_DATOS].Cliente c ON v.vent_cliente = c.clie_codigo
    JOIN [BASADOS_DE_DATOS].CanalVenta canal ON v.vent_canal_venta = canal.cana_codigo
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON YEAR(v.vent_fecha) = t.anyo AND MONTH(v.vent_fecha) = t.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rc ON rc.rango = [BASADOS_DE_DATOS].fn_rango_etario([BASADOS_DE_DATOS].fn_calcular_edad(c.clie_fecha_nacimiento, v.vent_fecha))
    JOIN [BASADOS_DE_DATOS].BI_dimension_canal_de_venta cv ON cv.canal = canal.cana_nombre
    JOIN [BASADOS_DE_DATOS].BI_dimension_tipo_servicio ts ON ts.tipo = CASE WHEN EXISTS (SELECT 1 FROM [BASADOS_DE_DATOS].Venta_Propuesta vp WHERE vp.vpro_venta = v.vent_codigo) THEN 'Propuesta a Medida' ELSE 'Venta Directa' END
    GROUP BY rc.id_rango_etario_cliente, cv.id_canal_de_venta, t.id_tiempo, ts.id_tipo_servicio

    -- Migración de la tabla Hechos de Solicitud: Calcula matemáticamente los días de anticipación de una solicitud respecto al inicio previsto
    INSERT INTO [BASADOS_DE_DATOS].BI_hecho_solicitud (tiempo, temporada, rango_etario_cliente, total_dias_anticipacion, cantidad_solicitudes)
    SELECT
        t.id_tiempo,
        temp.id_temporada,
        rc.id_rango_etario_cliente,
        sum(DATEDIFF(DAY, s.soli_fecha, s.soli_inicio_tentativa)) as dias_anticipacion,
        count(*)
    FROM [BASADOS_DE_DATOS].Solicitud s
    JOIN [BASADOS_DE_DATOS].Cliente c ON s.soli_cliente = c.clie_codigo
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON YEAR(s.soli_fecha) = t.anyo AND MONTH(s.soli_fecha) = t.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_temporada temp ON temp.temporada = [BASADOS_DE_DATOS].fn_temporada(s.soli_inicio_tentativa)
    JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rc ON rc.rango = [BASADOS_DE_DATOS].fn_rango_etario([BASADOS_DE_DATOS].fn_calcular_edad(c.clie_fecha_nacimiento, s.soli_fecha))
    GROUP BY t.id_tiempo, temp.id_temporada, rc.id_rango_etario_cliente

    -- Migración de la tabla Hechos de Propuestas: Resuelve los cruces temporales, el tiempo de respuesta del agente y el desvío monetario
    INSERT INTO [BASADOS_DE_DATOS].BI_hecho_propuesta (estado_propuesta, temporada_inicio_viaje, tiempo_emision_propuesta, tiempo_inicio_viaje, tiempo_fecha_solicitud, rango_etario_agente, total_dias_entre_solicitud_y_propuesta, importe_total, total_desvio_presupuesto_importe, cantidad_propuestas)
    SELECT
        ep.id_estado_propuesta,
        temp.id_temporada,
        t_emi.id_tiempo,
        t_ini.id_tiempo,
        t_sol.id_tiempo,
        ra.id_rango_etario_agente,
        sum(DATEDIFF(DAY, s.soli_fecha, p.prop_fecha_emision)),
        sum(p.prop_importe_total),
        sum((p.prop_importe_total - s.soli_presupuesto_estimado)) as desvio_presupuesto_importe,
        count(*)
    FROM [BASADOS_DE_DATOS].Propuesta p
    JOIN [BASADOS_DE_DATOS].Solicitud s ON p.prop_solicitud = s.soli_numero
    JOIN [BASADOS_DE_DATOS].EstadoPropuesta e ON p.prop_estado = e.esta_codigo
    JOIN [BASADOS_DE_DATOS].Agente a ON p.prop_agente = a.agen_legajo
    JOIN [BASADOS_DE_DATOS].BI_dimension_estado_propuesta ep ON ep.estado = e.esta_nombre
    JOIN [BASADOS_DE_DATOS].BI_dimension_temporada temp ON temp.temporada = [BASADOS_DE_DATOS].fn_temporada(p.prop_fecha_desde)
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_emi ON YEAR(p.prop_fecha_emision) = t_emi.anyo AND MONTH(p.prop_fecha_emision) = t_emi.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_ini ON YEAR(p.prop_fecha_desde) = t_ini.anyo AND MONTH(p.prop_fecha_desde) = t_ini.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_sol ON YEAR(s.soli_fecha) = t_sol.anyo AND MONTH(s.soli_fecha) = t_sol.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente ra ON ra.rango = [BASADOS_DE_DATOS].fn_rango_etario([BASADOS_DE_DATOS].fn_calcular_edad(a.agen_fecha_nacimiento, p.prop_fecha_emision))
    GROUP BY ep.id_estado_propuesta, temp.id_temporada, t_emi.id_tiempo, t_ini.id_tiempo, t_sol.id_tiempo, ra.id_rango_etario_agente

    -- Migración de la tabla Hechos Aspecto: Desdobla las respuestas individuales de las encuestas
    INSERT INTO [BASADOS_DE_DATOS].BI_hecho_aspecto (tiempo, detalle_aspecto, total_puntaje, cantidad_evaluaciones)
    SELECT
        t.id_tiempo,
        da.id_detalle_aspecto,
        sum(a.aspe_puntaje),
        COUNT(*)
    FROM [BASADOS_DE_DATOS].Aspecto a
    JOIN [BASADOS_DE_DATOS].Encuesta e ON a.aspe_encuesta = e.encu_codigo
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON YEAR(e.encu_fecha) = t.anyo AND MONTH(e.encu_fecha) = t.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto da ON da.detalle = a.aspe_detalle
    GROUP BY t.id_tiempo, da.id_detalle_aspecto;
      
    -- Migración de la tabla Hechos de Encuestas (Satisfacción Promedio): Genera una sola fila por encuesta con la media de sus preguntas
    with Encuesta_Puntaje as (
    select encu_codigo, encu_agente, encu_fecha, avg(aspe_puntaje * 1.0) as puntaje from [BASADOS_DE_DATOS].Aspecto join [BASADOS_DE_DATOS].Encuesta on encu_codigo = aspe_encuesta 
    group by encu_codigo, encu_agente, encu_fecha
    )
    INSERT INTO [BASADOS_DE_DATOS].BI_hecho_encuesta (rango_etario_agente, tiempo, total_puntaje, cantidad_encuestas)
    SELECT
        ra.id_rango_etario_agente,
        t.id_tiempo,
        sum(e.puntaje) as puntaje_total,
        count(*)
    FROM Encuesta_Puntaje e
    JOIN [BASADOS_DE_DATOS].Agente ag ON e.encu_agente = ag.agen_legajo
    JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON YEAR(e.encu_fecha) = t.anyo AND MONTH(e.encu_fecha) = t.mes
    JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente ra ON ra.rango = [BASADOS_DE_DATOS].fn_rango_etario([BASADOS_DE_DATOS].fn_calcular_edad(ag.agen_fecha_nacimiento, e.encu_fecha))
    GROUP BY ra.id_rango_etario_agente, t.id_tiempo;
END
GO

-- ========================================================================================
-- 5. EJECUCIÓN DE PROCEDIMIENTOS DE MIGRACIÓN
-- ========================================================================================
-- Se ejecutan en orden lógico: las dimensiones primero y luego las tablas de hechos que las consumen.
EXEC [BASADOS_DE_DATOS].sp_migrar_dimensiones_bi;
EXEC [BASADOS_DE_DATOS].sp_migrar_hechos_bi;
GO

-- ========================================================================================
-- 6. CREACIÓN DE VISTAS (TABLEROS DE CONTROL)
-- ========================================================================================

-- Vista 1. Ticket promedio: Valor promedio de venta mensual según rango etario de cliente y canal de venta.
-- Utiliza AVG sobre los importes agrupados por edad, canal, año y mes.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Ticket_Promedio AS
SELECT 
    t.anyo as Anio,
    t.mes as Mes,
    rc.rango as Rango_Etario_Cliente,
    cv.canal as Canal_Venta,
    SUM(hv.importe_total) / SUM(hv.cantidad_ventas) as Ticket_Promedio
FROM [BASADOS_DE_DATOS].BI_hecho_venta hv
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON hv.tiempo = t.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rc ON hv.rango_etario_cliente = rc.id_rango_etario_cliente
JOIN [BASADOS_DE_DATOS].BI_dimension_canal_de_venta cv ON hv.canal_de_venta = cv.id_canal_de_venta
GROUP BY t.anyo, t.mes, rc.rango, cv.canal;
GO

-- Vista 2. Distribución de Facturación: Porcentaje correspondiente a cada tipo de servicio por cuatrimestre y año.
-- Aplica una subconsulta escalar en el SELECT para obtener el total del cuatrimestre sin usar particiones.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Distribucion_Facturacion AS
SELECT 
    t.anyo as Anio,
    t.cuatrimestre as Cuatrimestre,
    ts.tipo as Tipo_Servicio,
    SUM(hv.importe_total) * 100.0 / (
        SELECT SUM(hv2.importe_total)
        FROM [BASADOS_DE_DATOS].BI_hecho_venta hv2
        JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t2 ON hv2.tiempo = t2.id_tiempo
        WHERE t2.anyo = t.anyo AND t2.cuatrimestre = t.cuatrimestre
    ) as Porcentaje_Facturacion
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
    SUM(hs.cantidad_solicitudes) as Cantidad_Solicitudes
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
    SUM(hs.total_dias_anticipacion) * 1.0 / SUM(hs.cantidad_solicitudes) as Anticipacion_Promedio_Dias
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
    CAST(SUM(CASE WHEN ep.estado LIKE '%ceptad%' THEN hp.cantidad_propuestas ELSE 0 END) AS DECIMAL) * 100.0 / nullif(SUM(hp.cantidad_propuestas), 0) as Tasa_Aceptacion_Porcentaje
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
    SUM(hp.importe_total) / SUM(hp.cantidad_propuestas) as Cotizacion_Promedio
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
    SUM(hp.total_dias_entre_solicitud_y_propuesta) * 1.0 / SUM(hp.cantidad_propuestas) as Tiempo_Respuesta_Dias
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
    SUM(hp.total_desvio_presupuesto_importe) / SUM(hp.cantidad_propuestas) as Desvio_Presupuesto_Promedio
FROM [BASADOS_DE_DATOS].BI_hecho_propuesta hp
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_emi ON hp.tiempo_emision_propuesta = t_emi.id_tiempo
GROUP BY t_emi.anyo, t_emi.mes;
GO

-- Vista 9. Ranking de aspectos mejor y peor valorados: Ordena el desempeño general de los atributos auditados.
-- Utiliza TOP y ORDER BY para dejar los resultados inherentemente ordenados y conformar el ranking directamente.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Ranking_Aspectos AS
SELECT TOP(100) PERCENT
    t.anyo as Anio,
    t.cuatrimestre as Cuatrimestre,
    da.detalle as Aspecto,
    SUM(ha.total_puntaje) * 1.0 / SUM(ha.cantidad_evaluaciones) as Puntaje_Promedio
FROM [BASADOS_DE_DATOS].BI_hecho_aspecto ha
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON ha.tiempo = t.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto da ON ha.detalle_aspecto = da.id_detalle_aspecto
GROUP BY t.anyo, t.cuatrimestre, da.detalle
ORDER BY t.anyo ASC, t.cuatrimestre ASC, Puntaje_Promedio DESC;
GO

-- Vista 10. Satisfacción promedio por agente: Consolida la métrica general ponderada de la experiencia comercial brindada.
CREATE VIEW [BASADOS_DE_DATOS].V_BI_Satisfaccion_Promedio_Agente AS
SELECT 
    t.anyo as Anio,
    t.mes as Mes,
    ra.rango as Rango_Etario_Agente,
    SUM(he.total_puntaje) / SUM(he.cantidad_encuestas) as Satisfaccion_Promedio
FROM [BASADOS_DE_DATOS].BI_hecho_encuesta he
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON he.tiempo = t.id_tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente ra ON he.rango_etario_agente = ra.id_rango_etario_agente
GROUP BY t.anyo, t.mes, ra.rango;
GO