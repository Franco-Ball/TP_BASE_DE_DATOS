/* ============================================================================
   SCRIPT DE CREACION Y CARGA DEL MODELO DE BI  (esquema estrella)
   ----------------------------------------------------------------------------
   Basado en:
     - EntregaDER/"DER Segunda Entrega Completo.mmd"
     - Enunciado.md (Especificacion del Modelo de BI, indicadores 1 a 10)

   IMPORTANTE: este script se ejecuta DESPUES de script_creacion_inicial.sql.
   La carga del modelo dimensional se realiza leyendo del MODELO TRANSACCIONAL
   ya migrado en el esquema [BASADOS_DE_DATOS] (no de gd_esquema.Maestra),
   tal como lo exige el enunciado.

   Incluye al final (seccion 5) las 10 vistas de indicadores de negocio que
   pide el enunciado, una por indicador.

   Decisiones tomadas (documentar tambien en Estrategia.pdf):
     - Tiempo: anyo / cuatrimestre / mes. cuatrimestre = ((mes-1)/4)+1
       (1: meses 1-4, 2: 5-8, 3: 9-12).
     - Rango etario CLIENTE (enunciado): cortes con limite superior inclusive
         <= 25            -> 'Menores de 25'
         26-35 (35 incl)  -> 'Entre 25 y 35'
         36-50 (50 incl)  -> 'Entre 35 y 50'
         > 50             -> 'Mayores de 50'
     - Rango etario AGENTE (enunciado): define EXACTAMENTE 3 rangos que arrancan
       en 25 (no existe 'Menores de 25' como en cliente), porque se asume que no
       hay agentes menores de 25 anios. Las etiquetas se respetan tal cual:
         25-35  -> 'Entre 25 y 35'
         36-50  -> 'Entre 35 y 50'
         > 50   -> 'Mayores de 50'
     - Edad: anios cumplidos calculados contra la fecha actual (GETDATE()).
     - Temporada (enunciado, trimestres calendario):
         Verano (Ene-Mar) / Otono (Abr-Jun) / Invierno (Jul-Sep) / Primavera (Oct-Dic)
     - Tipo de servicio (enunciado): 'Venta Directa' / 'Propuesta a Medida'.
       Una venta es 'Propuesta a Medida' si esta asociada a una propuesta
       (tabla Venta_Propuesta); en caso contrario es 'Venta Directa'.
     - BI_hecho_venta tiene grano = venta; la medida es vent_importe_total.
     - BI_hecho_encuesta.puntaje = promedio (redondeado) de los puntajes de
       los aspectos de la encuesta.
   ============================================================================ */

USE GD1C2026
GO

/* ===========================================================================
   0) LIMPIEZA - DROP de vistas y tablas de BI previas (para re-ejecutar).
      Primero las vistas, luego los hechos, luego las dimensiones (por las FKs).
   =========================================================================== */

-- Vistas de indicadores.
DROP VIEW IF EXISTS [BASADOS_DE_DATOS].BI_vista_ticket_promedio;
DROP VIEW IF EXISTS [BASADOS_DE_DATOS].BI_vista_distribucion_facturacion;
DROP VIEW IF EXISTS [BASADOS_DE_DATOS].BI_vista_ranking_solicitudes_temporada;
DROP VIEW IF EXISTS [BASADOS_DE_DATOS].BI_vista_anticipacion_promedio;
DROP VIEW IF EXISTS [BASADOS_DE_DATOS].BI_vista_tasa_aceptacion_propuestas;
DROP VIEW IF EXISTS [BASADOS_DE_DATOS].BI_vista_cotizacion_promedio_temporada;
DROP VIEW IF EXISTS [BASADOS_DE_DATOS].BI_vista_tiempo_promedio_respuesta;
DROP VIEW IF EXISTS [BASADOS_DE_DATOS].BI_vista_desvio_presupuesto;
DROP VIEW IF EXISTS [BASADOS_DE_DATOS].BI_vista_ranking_aspectos;
DROP VIEW IF EXISTS [BASADOS_DE_DATOS].BI_vista_satisfaccion_promedio_agente;

-- Tablas de hechos.
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_hecho_encuesta;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_hecho_aspecto;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_hecho_propuesta;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_hecho_solicitud;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_hecho_venta;

-- Tablas de dimensiones.
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_dimension_estado_propuesta;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_dimension_canal_de_venta;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_dimension_tipo_servicio;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_dimension_temporada;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].BI_dimension_tiempo;
GO

/* ===========================================================================
   1) DDL - DIMENSIONES
   =========================================================================== */

CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_tiempo (
    id_tiempo       bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    anyo            int,
    cuatrimestre    int,
    mes             int
);

CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente (
    id_rango_etario_cliente bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    rango                   nvarchar(30)
);

CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente (
    id_rango_etario_agente  bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    rango                   nvarchar(30)
);

CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_temporada (
    id_temporada    bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    temporada       nvarchar(30)
);

CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_tipo_servicio (
    id_tipo_servicio    bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    tipo                nvarchar(30)
);

CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_canal_de_venta (
    id_canal_de_venta   bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    canal               nvarchar(255)
);

CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_estado_propuesta (
    id_estado_propuesta bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    estado              nvarchar(255)
);

CREATE TABLE [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto (
    id_detalle_aspecto  bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    detalle             nvarchar(255)
);

/* ===========================================================================
   2) DDL - HECHOS
   (id surrogado por hecho; las FK pueden quedar NULL si el atributo de origen
    no esta presente)
   =========================================================================== */

CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_venta (
    id_hecho_venta          bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    rango_etario_cliente    bigint,
    canal_de_venta          bigint,
    tiempo                  bigint,
    tipo_servicio           bigint,
    importe_total           decimal(18,2),
    FOREIGN KEY (rango_etario_cliente) REFERENCES [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente(id_rango_etario_cliente),
    FOREIGN KEY (canal_de_venta)       REFERENCES [BASADOS_DE_DATOS].BI_dimension_canal_de_venta(id_canal_de_venta),
    FOREIGN KEY (tiempo)               REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (tipo_servicio)        REFERENCES [BASADOS_DE_DATOS].BI_dimension_tipo_servicio(id_tipo_servicio)
);

CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_solicitud (
    id_hecho_solicitud      bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    tiempo                  bigint,
    temporada               bigint,
    rango_etario_cliente    bigint,
    dias_anticipacion       int,
    FOREIGN KEY (tiempo)               REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (temporada)            REFERENCES [BASADOS_DE_DATOS].BI_dimension_temporada(id_temporada),
    FOREIGN KEY (rango_etario_cliente) REFERENCES [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente(id_rango_etario_cliente)
);

CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_propuesta (
    id_hecho_propuesta                  bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    estado_propuesta                    bigint,
    temporada_inicio_viaje              bigint,
    tiempo_emision_propuesta            bigint,
    tiempo_inicio_viaje                 bigint,
    tiempo_fecha_solicitud              bigint,
    rango_etario_agente                 bigint,
    dias_entre_solicitud_y_propuesta    int,
    importe_total                       decimal(18,2),
    desvio_presupuesto_importe          decimal(18,2),
    FOREIGN KEY (estado_propuesta)         REFERENCES [BASADOS_DE_DATOS].BI_dimension_estado_propuesta(id_estado_propuesta),
    FOREIGN KEY (temporada_inicio_viaje)   REFERENCES [BASADOS_DE_DATOS].BI_dimension_temporada(id_temporada),
    FOREIGN KEY (tiempo_emision_propuesta) REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (tiempo_inicio_viaje)      REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (tiempo_fecha_solicitud)   REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (rango_etario_agente)      REFERENCES [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente(id_rango_etario_agente)
);

CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_aspecto (
    id_hecho_aspecto    bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    tiempo              bigint,
    detalle_aspecto     bigint,
    puntaje             int,
    FOREIGN KEY (tiempo)          REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo),
    FOREIGN KEY (detalle_aspecto) REFERENCES [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto(id_detalle_aspecto)
);

CREATE TABLE [BASADOS_DE_DATOS].BI_hecho_encuesta (
    id_hecho_encuesta       bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    rango_etario_agente     bigint,
    tiempo                  bigint,
    puntaje                 int,
    FOREIGN KEY (rango_etario_agente) REFERENCES [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente(id_rango_etario_agente),
    FOREIGN KEY (tiempo)              REFERENCES [BASADOS_DE_DATOS].BI_dimension_tiempo(id_tiempo)
);

GO

/* ===========================================================================
   3) DML - CARGA DE DIMENSIONES (desde el modelo transaccional)
   =========================================================================== */

-- TIEMPO: todas las combinaciones (anyo, mes) presentes en las fechas del modelo.
-- Reunimos todas las fechas en una tabla temporal para no usar una subconsulta en el FROM.
SELECT CAST(vent_fecha AS date) AS fecha
INTO #fechas_tiempo
FROM [BASADOS_DE_DATOS].Venta
WHERE vent_fecha IS NOT NULL;

INSERT INTO #fechas_tiempo (fecha) SELECT soli_fecha            FROM [BASADOS_DE_DATOS].Solicitud WHERE soli_fecha IS NOT NULL;
INSERT INTO #fechas_tiempo (fecha) SELECT soli_inicio_tentativa FROM [BASADOS_DE_DATOS].Solicitud WHERE soli_inicio_tentativa IS NOT NULL;
INSERT INTO #fechas_tiempo (fecha) SELECT prop_fecha_emision    FROM [BASADOS_DE_DATOS].Propuesta WHERE prop_fecha_emision IS NOT NULL;
INSERT INTO #fechas_tiempo (fecha) SELECT prop_fecha_desde      FROM [BASADOS_DE_DATOS].Propuesta WHERE prop_fecha_desde IS NOT NULL;
INSERT INTO #fechas_tiempo (fecha) SELECT encu_fecha            FROM [BASADOS_DE_DATOS].Encuesta  WHERE encu_fecha IS NOT NULL;

INSERT INTO [BASADOS_DE_DATOS].BI_dimension_tiempo (anyo, cuatrimestre, mes)
SELECT DISTINCT
    YEAR(fecha)                  AS anyo,
    ((MONTH(fecha) - 1) / 4) + 1 AS cuatrimestre,
    MONTH(fecha)                 AS mes
FROM #fechas_tiempo;

DROP TABLE #fechas_tiempo;

-- RANGO ETARIO CLIENTE (4 rangos segun enunciado)
INSERT INTO [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente (rango)
VALUES ('Menores de 25'), ('Entre 25 y 35'), ('Entre 35 y 50'), ('Mayores de 50');

-- RANGO ETARIO AGENTE (3 rangos segun enunciado)
INSERT INTO [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente (rango)
VALUES ('Entre 25 y 35'), ('Entre 35 y 50'), ('Mayores de 50');

-- TEMPORADA (trimestres calendario segun enunciado)
INSERT INTO [BASADOS_DE_DATOS].BI_dimension_temporada (temporada)
VALUES ('Verano'), ('Otoño'), ('Invierno'), ('Primavera');

-- TIPO DE SERVICIO
INSERT INTO [BASADOS_DE_DATOS].BI_dimension_tipo_servicio (tipo)
VALUES ('Venta Directa'), ('Propuesta a Medida');

-- CANAL DE VENTA
INSERT INTO [BASADOS_DE_DATOS].BI_dimension_canal_de_venta (canal)
SELECT DISTINCT cana_nombre
FROM [BASADOS_DE_DATOS].CanalVenta
WHERE cana_nombre IS NOT NULL;

-- ESTADO DE PROPUESTA
INSERT INTO [BASADOS_DE_DATOS].BI_dimension_estado_propuesta (estado)
SELECT DISTINCT esta_nombre
FROM [BASADOS_DE_DATOS].EstadoPropuesta
WHERE esta_nombre IS NOT NULL;

-- DETALLE DE ASPECTO
INSERT INTO [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto (detalle)
SELECT DISTINCT aspe_detalle
FROM [BASADOS_DE_DATOS].Aspecto
WHERE aspe_detalle IS NOT NULL;

GO

/* ===========================================================================
   4) DML - CARGA DE HECHOS (desde el modelo transaccional)
   =========================================================================== */

-- HECHO VENTA: una fila por venta.
-- Staging con los atributos calculados (edad del cliente, tipo de servicio).
SELECT
    ven.vent_codigo,
    ven.vent_fecha,
    ven.vent_importe_total,
    cv.cana_nombre,
    -- edad del cliente (anios cumplidos a la fecha actual)
    DATEDIFF(YEAR, cli.clie_fecha_nacimiento, GETDATE())
        - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, cli.clie_fecha_nacimiento, GETDATE()), cli.clie_fecha_nacimiento) > GETDATE()
               THEN 1 ELSE 0 END AS edad_cliente,
    -- tipo de servicio: si la venta esta ligada a una propuesta -> a medida
    CASE WHEN EXISTS (
            SELECT 1 FROM [BASADOS_DE_DATOS].Venta_Propuesta vp
            WHERE vp.vpro_venta = ven.vent_codigo
         ) THEN 'Propuesta a Medida' ELSE 'Venta Directa' END AS tipo
INTO #stg_venta
FROM [BASADOS_DE_DATOS].Venta ven
LEFT JOIN [BASADOS_DE_DATOS].Cliente    cli ON cli.clie_codigo = ven.vent_cliente
LEFT JOIN [BASADOS_DE_DATOS].CanalVenta cv  ON cv.cana_codigo  = ven.vent_canal_venta;

INSERT INTO [BASADOS_DE_DATOS].BI_hecho_venta
    (rango_etario_cliente, canal_de_venta, tiempo, tipo_servicio, importe_total)
SELECT
    rec.id_rango_etario_cliente,
    cdv.id_canal_de_venta,
    t.id_tiempo,
    ts.id_tipo_servicio,
    v.vent_importe_total
FROM #stg_venta v
JOIN [BASADOS_DE_DATOS].BI_dimension_tipo_servicio ts
    ON ts.tipo = v.tipo
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_canal_de_venta cdv
    ON cdv.canal = v.cana_nombre
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t
    ON t.anyo = YEAR(v.vent_fecha) AND t.mes = MONTH(v.vent_fecha)
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rec
    ON rec.rango = CASE
        WHEN v.edad_cliente <= 25 THEN 'Menores de 25'
        WHEN v.edad_cliente <= 35 THEN 'Entre 25 y 35'
        WHEN v.edad_cliente <= 50 THEN 'Entre 35 y 50'
        ELSE 'Mayores de 50'
    END;

DROP TABLE #stg_venta;


-- HECHO SOLICITUD: una fila por solicitud.
-- Staging con la edad del cliente calculada.
SELECT
    sol.soli_numero,
    sol.soli_fecha,
    sol.soli_inicio_tentativa,
    DATEDIFF(YEAR, cli.clie_fecha_nacimiento, GETDATE())
        - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, cli.clie_fecha_nacimiento, GETDATE()), cli.clie_fecha_nacimiento) > GETDATE()
               THEN 1 ELSE 0 END AS edad_cliente
INTO #stg_solicitud
FROM [BASADOS_DE_DATOS].Solicitud sol
LEFT JOIN [BASADOS_DE_DATOS].Cliente cli ON cli.clie_codigo = sol.soli_cliente;

INSERT INTO [BASADOS_DE_DATOS].BI_hecho_solicitud
    (tiempo, temporada, rango_etario_cliente, dias_anticipacion)
SELECT
    t.id_tiempo,
    temp.id_temporada,
    rec.id_rango_etario_cliente,
    DATEDIFF(DAY, s.soli_fecha, s.soli_inicio_tentativa) AS dias_anticipacion
FROM #stg_solicitud s
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t
    ON t.anyo = YEAR(s.soli_fecha) AND t.mes = MONTH(s.soli_fecha)
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_temporada temp
    ON temp.temporada = CASE
        WHEN MONTH(s.soli_inicio_tentativa) IN (1, 2, 3)   THEN 'Verano'
        WHEN MONTH(s.soli_inicio_tentativa) IN (4, 5, 6)   THEN 'Otoño'
        WHEN MONTH(s.soli_inicio_tentativa) IN (7, 8, 9)   THEN 'Invierno'
        WHEN MONTH(s.soli_inicio_tentativa) IN (10, 11, 12) THEN 'Primavera'
    END
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rec
    ON rec.rango = CASE
        WHEN s.edad_cliente <= 25 THEN 'Menores de 25'
        WHEN s.edad_cliente <= 35 THEN 'Entre 25 y 35'
        WHEN s.edad_cliente <= 50 THEN 'Entre 35 y 50'
        ELSE 'Mayores de 50'
    END;

DROP TABLE #stg_solicitud;


-- HECHO PROPUESTA: una fila por propuesta.
-- Staging con la edad del agente y los datos de la solicitud asociada.
SELECT
    pro.prop_codigo,
    pro.prop_fecha_emision,
    pro.prop_fecha_desde,
    pro.prop_importe_total,
    ep2.esta_nombre,
    sol.soli_fecha,
    sol.soli_presupuesto_estimado,
    DATEDIFF(YEAR, age.agen_fecha_nacimiento, GETDATE())
        - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, age.agen_fecha_nacimiento, GETDATE()), age.agen_fecha_nacimiento) > GETDATE()
               THEN 1 ELSE 0 END AS edad_agente
INTO #stg_propuesta
FROM [BASADOS_DE_DATOS].Propuesta pro
LEFT JOIN [BASADOS_DE_DATOS].Solicitud       sol ON sol.soli_numero  = pro.prop_solicitud
LEFT JOIN [BASADOS_DE_DATOS].Agente          age ON age.agen_legajo  = pro.prop_agente
LEFT JOIN [BASADOS_DE_DATOS].EstadoPropuesta ep2 ON ep2.esta_codigo  = pro.prop_estado;

INSERT INTO [BASADOS_DE_DATOS].BI_hecho_propuesta
    (estado_propuesta, temporada_inicio_viaje, tiempo_emision_propuesta,
     tiempo_inicio_viaje, tiempo_fecha_solicitud, rango_etario_agente,
     dias_entre_solicitud_y_propuesta, importe_total, desvio_presupuesto_importe)
SELECT
    ep.id_estado_propuesta,
    temp.id_temporada,
    t_emi.id_tiempo,
    t_ini.id_tiempo,
    t_sol.id_tiempo,
    rea.id_rango_etario_agente,
    DATEDIFF(DAY, p.soli_fecha, p.prop_fecha_emision)   AS dias_entre_solicitud_y_propuesta,
    p.prop_importe_total,
    p.prop_importe_total - p.soli_presupuesto_estimado  AS desvio_presupuesto_importe
FROM #stg_propuesta p
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_estado_propuesta ep
    ON ep.estado = p.esta_nombre
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_temporada temp
    ON temp.temporada = CASE
        WHEN MONTH(p.prop_fecha_desde) IN (1, 2, 3)    THEN 'Verano'
        WHEN MONTH(p.prop_fecha_desde) IN (4, 5, 6)    THEN 'Otoño'
        WHEN MONTH(p.prop_fecha_desde) IN (7, 8, 9)    THEN 'Invierno'
        WHEN MONTH(p.prop_fecha_desde) IN (10, 11, 12) THEN 'Primavera'
    END
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_emi
    ON t_emi.anyo = YEAR(p.prop_fecha_emision) AND t_emi.mes = MONTH(p.prop_fecha_emision)
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_ini
    ON t_ini.anyo = YEAR(p.prop_fecha_desde) AND t_ini.mes = MONTH(p.prop_fecha_desde)
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t_sol
    ON t_sol.anyo = YEAR(p.soli_fecha) AND t_sol.mes = MONTH(p.soli_fecha)
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente rea
    ON rea.rango = CASE
        WHEN p.edad_agente <= 35 THEN 'Entre 25 y 35'
        WHEN p.edad_agente <= 50 THEN 'Entre 35 y 50'
        ELSE 'Mayores de 50'
    END;

DROP TABLE #stg_propuesta;


-- HECHO ASPECTO: una fila por aspecto puntuado en una encuesta.
-- Staging con el aspecto y la fecha de la encuesta a la que pertenece.
SELECT
    asp.aspe_detalle,
    asp.aspe_puntaje,
    enc.encu_fecha
INTO #stg_aspecto
FROM [BASADOS_DE_DATOS].Aspecto asp
LEFT JOIN [BASADOS_DE_DATOS].Encuesta enc ON enc.encu_codigo = asp.aspe_encuesta;

INSERT INTO [BASADOS_DE_DATOS].BI_hecho_aspecto
    (tiempo, detalle_aspecto, puntaje)
SELECT
    t.id_tiempo,
    da.id_detalle_aspecto,
    a.aspe_puntaje
FROM #stg_aspecto a
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto da
    ON da.detalle = a.aspe_detalle
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t
    ON t.anyo = YEAR(a.encu_fecha) AND t.mes = MONTH(a.encu_fecha);

DROP TABLE #stg_aspecto;


-- HECHO ENCUESTA: una fila por encuesta (puntaje = promedio de sus aspectos).
-- Primero pre-agregamos el promedio de puntaje por encuesta en una temporal
-- (evita una subconsulta escalar correlacionada fila por fila).
SELECT
    asp.aspe_encuesta,
    AVG(CAST(asp.aspe_puntaje AS float)) AS puntaje_promedio
INTO #prom_encuesta
FROM [BASADOS_DE_DATOS].Aspecto asp
WHERE asp.aspe_encuesta IS NOT NULL
GROUP BY asp.aspe_encuesta;

-- Staging de encuestas con la edad del agente y el promedio ya calculado.
SELECT
    enc.encu_codigo,
    enc.encu_fecha,
    DATEDIFF(YEAR, age.agen_fecha_nacimiento, GETDATE())
        - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, age.agen_fecha_nacimiento, GETDATE()), age.agen_fecha_nacimiento) > GETDATE()
               THEN 1 ELSE 0 END AS edad_agente,
    pe.puntaje_promedio
INTO #stg_encuesta
FROM [BASADOS_DE_DATOS].Encuesta enc
LEFT JOIN [BASADOS_DE_DATOS].Agente age ON age.agen_legajo = enc.encu_agente
LEFT JOIN #prom_encuesta pe ON pe.aspe_encuesta = enc.encu_codigo;

INSERT INTO [BASADOS_DE_DATOS].BI_hecho_encuesta
    (rango_etario_agente, tiempo, puntaje)
SELECT
    rea.id_rango_etario_agente,
    t.id_tiempo,
    CAST(ROUND(e.puntaje_promedio, 0) AS int) AS puntaje
FROM #stg_encuesta e
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t
    ON t.anyo = YEAR(e.encu_fecha) AND t.mes = MONTH(e.encu_fecha)
LEFT JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente rea
    ON rea.rango = CASE
        WHEN e.edad_agente <= 35 THEN 'Entre 25 y 35'
        WHEN e.edad_agente <= 50 THEN 'Entre 35 y 50'
        ELSE 'Mayores de 50'
    END;

DROP TABLE #stg_encuesta;
DROP TABLE #prom_encuesta;

GO

/* ===========================================================================
   5) VISTAS DE INDICADORES DE NEGOCIO (1 a 10 del enunciado)
   Cada vista consulta directamente el modelo estrella ya cargado.
   =========================================================================== */

-- 1) Ticket promedio: valor promedio de venta MENSUAL segun rango etario de
--    cliente y canal de venta.
CREATE VIEW [BASADOS_DE_DATOS].BI_vista_ticket_promedio AS
SELECT
    t.anyo,
    t.mes,
    rec.rango AS rango_etario_cliente,
    cdv.canal AS canal_venta,
    AVG(hv.importe_total) AS ticket_promedio
FROM [BASADOS_DE_DATOS].BI_hecho_venta hv
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo               t   ON t.id_tiempo  = hv.tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rec ON rec.id_rango_etario_cliente = hv.rango_etario_cliente
JOIN [BASADOS_DE_DATOS].BI_dimension_canal_de_venta       cdv ON cdv.id_canal_de_venta = hv.canal_de_venta
GROUP BY t.anyo, t.mes, rec.rango, cdv.canal;
GO

-- 2) Distribucion de facturacion: porcentaje de facturacion de cada tipo de
--    servicio (Venta Directa / Propuesta a Medida) por cuatrimestre de cada anyo.
--    El total del cuatrimestre se obtiene con una subconsulta correlacionada
--    (sin funciones de ventana / PARTITION BY).
CREATE VIEW [BASADOS_DE_DATOS].BI_vista_distribucion_facturacion AS
SELECT
    t.anyo,
    t.cuatrimestre,
    ts.tipo AS tipo_servicio,
    SUM(hv.importe_total) AS facturacion_tipo,
    CAST(100.0 * SUM(hv.importe_total)
         / (SELECT SUM(hv2.importe_total)
            FROM [BASADOS_DE_DATOS].BI_hecho_venta hv2
            JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t2 ON t2.id_tiempo = hv2.tiempo
            WHERE t2.anyo = t.anyo AND t2.cuatrimestre = t.cuatrimestre)
         AS DECIMAL(18,2)) AS porcentaje_facturacion
FROM [BASADOS_DE_DATOS].BI_hecho_venta hv
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo        t  ON t.id_tiempo         = hv.tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_tipo_servicio ts ON ts.id_tipo_servicio = hv.tipo_servicio
GROUP BY t.anyo, t.cuatrimestre, ts.tipo;
GO

-- 3) Ranking de solicitudes por temporada: cantidad de solicitudes por
--    temporada de cada anyo y rango etario del cliente.
--    El "ranking" se obtiene ordenando por cantidad_solicitudes DESC al consultar
--    la vista (sin funciones de ventana / PARTITION BY).
CREATE VIEW [BASADOS_DE_DATOS].BI_vista_ranking_solicitudes_temporada AS
SELECT
    t.anyo,
    temp.temporada,
    rec.rango AS rango_etario_cliente,
    COUNT(*) AS cantidad_solicitudes
FROM [BASADOS_DE_DATOS].BI_hecho_solicitud hs
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo               t    ON t.id_tiempo       = hs.tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_temporada            temp ON temp.id_temporada = hs.temporada
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rec  ON rec.id_rango_etario_cliente = hs.rango_etario_cliente
GROUP BY t.anyo, temp.temporada, rec.rango;
GO

-- 4) Anticipacion promedio de solicitudes: promedio de dias entre la fecha de
--    solicitud y la fecha de inicio tentativa, por rango etario cliente y cuatrimestre.
CREATE VIEW [BASADOS_DE_DATOS].BI_vista_anticipacion_promedio AS
SELECT
    t.anyo,
    t.cuatrimestre,
    rec.rango AS rango_etario_cliente,
    AVG(CAST(hs.dias_anticipacion AS DECIMAL(18,2))) AS dias_anticipacion_promedio
FROM [BASADOS_DE_DATOS].BI_hecho_solicitud hs
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo               t   ON t.id_tiempo  = hs.tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_cliente rec ON rec.id_rango_etario_cliente = hs.rango_etario_cliente
GROUP BY t.anyo, t.cuatrimestre, rec.rango;
GO

-- 5) Tasa de aceptacion de propuestas: porcentaje de propuestas aceptadas sobre
--    el total emitidas, por cuatrimestre (referencia: fecha de emision).
--    NOTA: verificar el literal del estado contra BI_dimension_estado_propuesta.
CREATE VIEW [BASADOS_DE_DATOS].BI_vista_tasa_aceptacion_propuestas AS
SELECT
    t.anyo,
    t.cuatrimestre,
    COUNT(*) AS total_propuestas,
    SUM(CASE WHEN ep.estado COLLATE Latin1_General_CI_AI = 'Aceptada' THEN 1 ELSE 0 END) AS propuestas_aceptadas,
    CAST(100.0 * SUM(CASE WHEN ep.estado COLLATE Latin1_General_CI_AI = 'Aceptada' THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(18,2)) AS tasa_aceptacion
FROM [BASADOS_DE_DATOS].BI_hecho_propuesta hp
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo           t  ON t.id_tiempo           = hp.tiempo_emision_propuesta
JOIN [BASADOS_DE_DATOS].BI_dimension_estado_propuesta ep ON ep.id_estado_propuesta = hp.estado_propuesta
GROUP BY t.anyo, t.cuatrimestre;
GO

-- 6) Cotizacion promedio por temporada: importe promedio de las propuestas
--    emitidas por temporada/anyo (referencia: fecha de inicio del viaje).
CREATE VIEW [BASADOS_DE_DATOS].BI_vista_cotizacion_promedio_temporada AS
SELECT
    t.anyo,
    temp.temporada,
    AVG(hp.importe_total) AS cotizacion_promedio
FROM [BASADOS_DE_DATOS].BI_hecho_propuesta hp
JOIN [BASADOS_DE_DATOS].BI_dimension_temporada temp ON temp.id_temporada = hp.temporada_inicio_viaje
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo    t    ON t.id_tiempo       = hp.tiempo_inicio_viaje
GROUP BY t.anyo, temp.temporada;
GO

-- 7) Tiempo promedio de respuesta: dias promedio entre la fecha de solicitud y
--    la de emision de la propuesta, por rango etario agente y mes
--    (referencia temporal: fecha de solicitud).
CREATE VIEW [BASADOS_DE_DATOS].BI_vista_tiempo_promedio_respuesta AS
SELECT
    t.anyo,
    t.mes,
    rea.rango AS rango_etario_agente,
    AVG(CAST(hp.dias_entre_solicitud_y_propuesta AS DECIMAL(18,2))) AS dias_respuesta_promedio
FROM [BASADOS_DE_DATOS].BI_hecho_propuesta hp
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo              t   ON t.id_tiempo  = hp.tiempo_fecha_solicitud
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente rea ON rea.id_rango_etario_agente = hp.rango_etario_agente
GROUP BY t.anyo, t.mes, rea.rango;
GO

-- 8) Desvio de presupuesto: desvio promedio entre el importe de la propuesta y
--    el presupuesto estimado de la solicitud, por anyo/cuatrimestre de emision
--    (segmentacion definida por el grupo; el enunciado no la fija).
CREATE VIEW [BASADOS_DE_DATOS].BI_vista_desvio_presupuesto AS
SELECT
    t.anyo,
    t.cuatrimestre,
    AVG(hp.desvio_presupuesto_importe) AS desvio_promedio
FROM [BASADOS_DE_DATOS].BI_hecho_propuesta hp
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo t ON t.id_tiempo = hp.tiempo_emision_propuesta
GROUP BY t.anyo, t.cuatrimestre;
GO

-- 9) Ranking de aspectos mejor y peor valorados: puntaje promedio por aspecto y
--    cuatrimestre. Ordenando por puntaje_promedio DESC se obtiene el mejor valorado
--    y ASC el peor, dentro de cada anyo/cuatrimestre (sin funciones de ventana).
CREATE VIEW [BASADOS_DE_DATOS].BI_vista_ranking_aspectos AS
SELECT
    t.anyo,
    t.cuatrimestre,
    da.detalle AS aspecto,
    AVG(CAST(ha.puntaje AS DECIMAL(18,2))) AS puntaje_promedio
FROM [BASADOS_DE_DATOS].BI_hecho_aspecto ha
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo          t  ON t.id_tiempo          = ha.tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_detalle_aspecto da ON da.id_detalle_aspecto = ha.detalle_aspecto
GROUP BY t.anyo, t.cuatrimestre, da.detalle;
GO

-- 10) Satisfaccion promedio por agente: puntaje promedio de las encuestas por
--     rango etario del agente y mes.
CREATE VIEW [BASADOS_DE_DATOS].BI_vista_satisfaccion_promedio_agente AS
SELECT
    t.anyo,
    t.mes,
    rea.rango AS rango_etario_agente,
    AVG(CAST(he.puntaje AS DECIMAL(18,2))) AS satisfaccion_promedio
FROM [BASADOS_DE_DATOS].BI_hecho_encuesta he
JOIN [BASADOS_DE_DATOS].BI_dimension_tiempo              t   ON t.id_tiempo  = he.tiempo
JOIN [BASADOS_DE_DATOS].BI_dimension_rango_etario_agente rea ON rea.id_rango_etario_agente = he.rango_etario_agente
GROUP BY t.anyo, t.mes, rea.rango;
GO
