USE GD1C2026
GO

-- Creacion del esquema propio del grupo solo si no existe (permite re-ejecutar).
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'BASADOS_DE_DATOS')
    EXEC (N'CREATE SCHEMA [BASADOS_DE_DATOS]');
GO

/* ===========================================================================
   0) LIMPIEZA - DROP de objetos previos para poder re-ejecutar el script.
      Primero los SP de migracion; luego las tablas en orden inverso al de
      creacion (por las claves foraneas).
   =========================================================================== */

-- Stored procedures de migracion.
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_ItemPropuestaHospedaje;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_ItemPropuestaVuelo;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_ItemVentaExcursion;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_ItemVentaHospedaje;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_ItemVentaVuelo;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Venta_Propuesta;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Aspecto;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Propuesta;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_CiudadSolicitud;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Encuesta;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Venta;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Solicitud;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Cliente;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Agente;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Vuelo;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_HabitacionHospedaje;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Agencia;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Excursion;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Hospedaje;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Aeropuerto;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Localidad;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Aerolinea;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Ciudad;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Provincia;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_EstadoPropuesta;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Proveedor;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Alianza;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_MedioPago;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_CanalVenta;
DROP PROCEDURE IF EXISTS [BASADOS_DE_DATOS].Migrar_Pais;

-- Tablas (orden inverso al de creacion).
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].ItemPropuestaHospedaje;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].ItemPropuestaVuelo;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].ItemVentaExcursion;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].ItemVentaHospedaje;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].ItemVentaVuelo;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Venta_Propuesta;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Aspecto;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Propuesta;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].CiudadSolicitud;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Encuesta;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Venta;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Solicitud;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Cliente;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Agente;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Vuelo;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].HabitacionHospedaje;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Agencia;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Excursion;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Hospedaje;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Aeropuerto;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Localidad;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Aerolinea;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Ciudad;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Provincia;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].EstadoPropuesta;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Proveedor;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Alianza;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].MedioPago;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].CanalVenta;
DROP TABLE IF EXISTS [BASADOS_DE_DATOS].Pais;
GO

/* ===========================================================================
   1) DDL - TABLAS DE CATALOGO / DIMENSIONALES SIMPLES
   =========================================================================== */

-- Pais: catalogo de paises (clave subrogada; agrupa variantes con/sin tilde).
CREATE TABLE [BASADOS_DE_DATOS].Pais (
    pais_codigo bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    pais_nombre NVARCHAR(255)
);

-- CanalVenta: canales por los que se concreta una venta (mail, telefono, etc.).
CREATE TABLE [BASADOS_DE_DATOS].CanalVenta (
    cana_codigo bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    cana_nombre NVARCHAR(255)
);

-- MedioPago: medios de pago utilizados por el cliente.
CREATE TABLE [BASADOS_DE_DATOS].MedioPago (
    medi_codigo bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    medi_nombre NVARCHAR(255)
);

-- Alianza: alianzas comerciales de aerolineas.
CREATE TABLE [BASADOS_DE_DATOS].Alianza (
    alia_codigo bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    alia_nombre NVARCHAR(255)
);

-- Proveedor: proveedores de excursiones.
CREATE TABLE [BASADOS_DE_DATOS].Proveedor (
    prov_codigo  bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    prov_nombre NVARCHAR(255),
    prov_mail NVARCHAR(255),
    prov_telefono NVARCHAR(255)
);

-- EstadoPropuesta: estados posibles de una propuesta (aceptada/rechazada/etc.).
CREATE TABLE [BASADOS_DE_DATOS].EstadoPropuesta (
    esta_codigo bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    esta_nombre NVARCHAR(255)
);

-- Provincia: provincias de agencias/agentes/clientes (match exacto por nombre).
CREATE TABLE [BASADOS_DE_DATOS].Provincia (
    prov_codigo bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    prov_nombre NVARCHAR(255)
);

-- Ciudad: ciudades (de aeropuertos y hospedajes), asociadas a un pais.
CREATE TABLE [BASADOS_DE_DATOS].Ciudad (
    ciud_codigo bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ciud_nombre NVARCHAR(255),
    ciud_pais bigint,
    FOREIGN KEY (ciud_pais) REFERENCES [BASADOS_DE_DATOS].Pais(pais_codigo)
);

-- Aerolinea: clave natural = codigo IATA/propio de la aerolinea.
CREATE TABLE [BASADOS_DE_DATOS].Aerolinea (
    aero_codigo NVARCHAR(255) PRIMARY KEY,
    aero_nombre NVARCHAR(255),
    aero_pais bigint,
    aero_alianza bigint,
    FOREIGN KEY (aero_pais) REFERENCES [BASADOS_DE_DATOS].Pais(pais_codigo),
    FOREIGN KEY (aero_alianza) REFERENCES [BASADOS_DE_DATOS].Alianza(alia_codigo)
);

-- Localidad: localidades pertenecientes a una provincia.
CREATE TABLE [BASADOS_DE_DATOS].Localidad (
    loca_codigo bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    loca_nombre NVARCHAR(255),
    loca_provincia bigint,
    FOREIGN KEY (loca_provincia) REFERENCES [BASADOS_DE_DATOS].Provincia(prov_codigo)
);

-- Aeropuerto: clave natural = codigo de aeropuerto; pertenece a una ciudad.
CREATE TABLE [BASADOS_DE_DATOS].Aeropuerto (
    aero_codigo NVARCHAR(10) PRIMARY KEY,
    aero_descripcion NVARCHAR(200),
    aero_ciudad bigint,
    FOREIGN KEY (aero_ciudad) REFERENCES [BASADOS_DE_DATOS].Ciudad(ciud_codigo)
);

-- Hospedaje: alojamientos; clave subrogada (no hay id propio en la maestra).
CREATE TABLE [BASADOS_DE_DATOS].Hospedaje (
    hosp_codigo bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    hosp_ciudad bigint,
    hosp_nombre NVARCHAR(255),
    hosp_direccion NVARCHAR(255),
    hosp_incluye_desayuno BIT,
    hosp_hora_check_in NVARCHAR(50),
    hosp_hora_check_out NVARCHAR(50),
    FOREIGN KEY (hosp_ciudad) REFERENCES [BASADOS_DE_DATOS].Ciudad(ciud_codigo)
);

-- Excursion: excursiones ofrecidas por un proveedor; clave subrogada.
CREATE TABLE [BASADOS_DE_DATOS].Excursion (
    excu_codigo BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    excu_nombre NVARCHAR(255),
    excu_descripcion NVARCHAR(MAX),
    excu_horario NVARCHAR(50),
    excu_duracion INT,
    excu_precio DECIMAL(18,2),
    excu_proveedor BIGINT,
    FOREIGN KEY (excu_proveedor) REFERENCES [BASADOS_DE_DATOS].Proveedor(prov_codigo)
);

-- Agencia: clave natural = numero de agencia provisto por la maestra.
CREATE TABLE [BASADOS_DE_DATOS].Agencia (
    agen_numero BIGINT PRIMARY KEY,
    agen_direccion NVARCHAR(255),
    agen_telefono NVARCHAR(255),
    agen_mail NVARCHAR(255),
    agen_localidad bigint,
    FOREIGN KEY (agen_localidad) REFERENCES [BASADOS_DE_DATOS].Localidad(loca_codigo)
);

-- HabitacionHospedaje: tipos de habitacion de cada hospedaje; clave subrogada.
CREATE TABLE [BASADOS_DE_DATOS].HabitacionHospedaje (
    habi_codigo_habitacion BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    habi_hospedaje BIGINT,
    habi_nombre NVARCHAR(255),
    habi_descripcion NVARCHAR(MAX),
    habi_precio_noche DECIMAL(18,2),
    FOREIGN KEY (habi_hospedaje) REFERENCES [BASADOS_DE_DATOS].Hospedaje(hosp_codigo)
);

-- Vuelo: clave subrogada; se recupera vuel_duracion (presente en la maestra).
CREATE TABLE [BASADOS_DE_DATOS].Vuelo (
    vuel_codigo BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    vuel_precio DECIMAL(18,2),
    vuel_aeropuerto_salida NVARCHAR(10),
    vuel_aeropuerto_llegada NVARCHAR(10),
    vuel_fecha_salida DATE,
    vuel_horario_salida NVARCHAR(50),
    vuel_fecha_llegada DATE,
    vuel_horario_llegada NVARCHAR(50),
    vuel_duracion INT,
    vuel_aerolinea NVARCHAR(255),
    vuel_incluye_carry BIT,
    vuel_incluye_valija BIT,
    FOREIGN KEY (vuel_aeropuerto_salida) REFERENCES [BASADOS_DE_DATOS].Aeropuerto(aero_codigo),
    FOREIGN KEY (vuel_aeropuerto_llegada) REFERENCES [BASADOS_DE_DATOS].Aeropuerto(aero_codigo),
    FOREIGN KEY (vuel_aerolinea) REFERENCES [BASADOS_DE_DATOS].Aerolinea(aero_codigo)
);

-- Agente: clave natural = legajo; pertenece a una agencia y una localidad.
CREATE TABLE [BASADOS_DE_DATOS].Agente (
    agen_legajo BIGINT PRIMARY KEY,
    agen_agencia BIGINT,
    agen_nombre NVARCHAR(255),
    agen_apellido NVARCHAR(255),
    agen_dni NVARCHAR(255),
    agen_fecha_nacimiento DATE,
    agen_telefono NVARCHAR(255),
    agen_mail NVARCHAR(255),
    agen_direccion NVARCHAR(255),
    agen_localidad bigint,
    FOREIGN KEY (agen_agencia) REFERENCES [BASADOS_DE_DATOS].Agencia(agen_numero),
    FOREIGN KEY (agen_localidad) REFERENCES [BASADOS_DE_DATOS].Localidad(loca_codigo)
);

-- Cliente: clave subrogada (mismo DNI puede tener distintos titulares).
CREATE TABLE [BASADOS_DE_DATOS].Cliente (
    clie_codigo bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    clie_dni NVARCHAR(255),
    clie_nombre NVARCHAR(255),
    clie_apellido NVARCHAR(255),
    clie_telefono NVARCHAR(255),
    clie_mail NVARCHAR(255),
    clie_direccion NVARCHAR(255),
    clie_fecha_nacimiento DATE,
    clie_localidad bigint,
    FOREIGN KEY (clie_localidad) REFERENCES [BASADOS_DE_DATOS].Localidad(loca_codigo)
);

/* ===========================================================================
   1b) DDL - TABLAS TRANSACCIONALES Y DE DETALLE
   =========================================================================== */

-- Solicitud: pedido de cotizacion de un cliente gestionado por un agente.
CREATE TABLE [BASADOS_DE_DATOS].Solicitud (
    soli_numero BIGINT PRIMARY KEY,
    soli_cliente bigint,
    soli_fecha DATE,
    soli_inicio_tentativa DATE,
    soli_fin_tentativa DATE,
    soli_cant_pas INT,
    soli_observaciones NVARCHAR(MAX),
    soli_presupuesto_estimado DECIMAL(18,2),
    soli_agente BIGINT,
    FOREIGN KEY (soli_cliente) REFERENCES [BASADOS_DE_DATOS].Cliente(clie_codigo),
    FOREIGN KEY (soli_agente) REFERENCES [BASADOS_DE_DATOS].Agente(agen_legajo)
);

-- Venta: venta de productos turisticos a un cliente, por un agente y canal.
CREATE TABLE [BASADOS_DE_DATOS].Venta (
    vent_codigo BIGINT PRIMARY KEY,
    vent_cliente bigint,
    vent_agente BIGINT,
    vent_fecha DATE,
    vent_canal_venta bigint,
    vent_subtotal DECIMAL(18,2),
    vent_descuento DECIMAL(18,2),
    vent_importe_total DECIMAL(18,2),
    vent_medio_pago bigint,
    FOREIGN KEY (vent_cliente) REFERENCES [BASADOS_DE_DATOS].Cliente(clie_codigo),
    FOREIGN KEY (vent_agente) REFERENCES [BASADOS_DE_DATOS].Agente(agen_legajo),
    FOREIGN KEY (vent_canal_venta) REFERENCES [BASADOS_DE_DATOS].CanalVenta(cana_codigo),
    FOREIGN KEY (vent_medio_pago) REFERENCES [BASADOS_DE_DATOS].MedioPago(medi_codigo)
);

-- Encuesta: encuesta de satisfaccion respondida por el cliente.
CREATE TABLE [BASADOS_DE_DATOS].Encuesta (
    encu_codigo BIGINT PRIMARY KEY,
    encu_fecha DATE,
    encu_cliente bigint,
    encu_agente BIGINT,
    encu_comentario NVARCHAR(MAX),
    FOREIGN KEY (encu_cliente) REFERENCES [BASADOS_DE_DATOS].Cliente(clie_codigo),
    FOREIGN KEY (encu_agente) REFERENCES [BASADOS_DE_DATOS].Agente(agen_legajo)
);

-- CiudadSolicitud: ciudades incluidas en una solicitud (PK subrogada).
CREATE TABLE [BASADOS_DE_DATOS].CiudadSolicitud (
    ciud_codigo BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ciud_numero BIGINT,
    ciud_detalle NVARCHAR(255),
    ciud_cant_dias INT,
    ciud_observaciones NVARCHAR(MAX),
    FOREIGN KEY (ciud_numero) REFERENCES [BASADOS_DE_DATOS].Solicitud(soli_numero)
);

-- Propuesta: propuesta personalizada que un agente arma para una solicitud.
CREATE TABLE [BASADOS_DE_DATOS].Propuesta (
    prop_codigo BIGINT PRIMARY KEY,
    prop_solicitud BIGINT,
    prop_agente BIGINT,
    prop_fecha_emision DATE,
    prop_vigencia DATE,
    prop_fecha_desde DATE,
    prop_fecha_hasta DATE,
    prop_subtotal DECIMAL(18,2),
    prop_descuento DECIMAL(18,2),
    prop_importe_total DECIMAL(18,2),
    prop_estado bigint,
    FOREIGN KEY (prop_solicitud) REFERENCES [BASADOS_DE_DATOS].Solicitud(soli_numero),
    FOREIGN KEY (prop_agente) REFERENCES [BASADOS_DE_DATOS].Agente(agen_legajo),
    FOREIGN KEY (prop_estado) REFERENCES [BASADOS_DE_DATOS].EstadoPropuesta(esta_codigo)
);

-- Aspecto: valoraciones por aspecto dentro de una encuesta (PK subrogada).
CREATE TABLE [BASADOS_DE_DATOS].Aspecto (
    aspe_codigo BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    aspe_encuesta BIGINT,
    aspe_detalle NVARCHAR(255),
    aspe_puntaje INT,
    FOREIGN KEY (aspe_encuesta) REFERENCES [BASADOS_DE_DATOS].Encuesta(encu_codigo)
);

-- Venta_Propuesta: vincula una venta con la propuesta que la origino (PK subrogada).
CREATE TABLE [BASADOS_DE_DATOS].Venta_Propuesta (
    vpro_codigo BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    vpro_venta BIGINT,
    vpro_propuesta BIGINT,
    FOREIGN KEY (vpro_venta) REFERENCES [BASADOS_DE_DATOS].Venta(vent_codigo),
    FOREIGN KEY (vpro_propuesta) REFERENCES [BASADOS_DE_DATOS].Propuesta(prop_codigo)
);

-- ItemVentaVuelo: renglon de vuelo dentro de una venta (PK subrogada).
CREATE TABLE [BASADOS_DE_DATOS].ItemVentaVuelo (
    item_codigo BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    item_venta BIGINT,
    item_vuelo BIGINT,
    item_precio_unitario DECIMAL(18,2),
    vuel_cant_pasajes INT,
    item_cod_reserva NVARCHAR(255),
    item_subtotal DECIMAL(18,2),
    FOREIGN KEY (item_venta) REFERENCES [BASADOS_DE_DATOS].Venta(vent_codigo),
    FOREIGN KEY (item_vuelo) REFERENCES [BASADOS_DE_DATOS].Vuelo(vuel_codigo)
);

-- ItemVentaHospedaje: renglon de hospedaje/habitacion dentro de una venta.
CREATE TABLE [BASADOS_DE_DATOS].ItemVentaHospedaje (
    item_codigo BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    item_venta BIGINT,
    item_hospedaje BIGINT,
    item_habitacion BIGINT,
    item_desde DATE,
    item_hasta DATE,
    item_hospedaje_cantidad INT,
    item_precio_unitario DECIMAL(18,2),
    item_subtotal DECIMAL(18,2),
    item_cod_reserva NVARCHAR(255),
    FOREIGN KEY (item_venta) REFERENCES [BASADOS_DE_DATOS].Venta(vent_codigo),
    FOREIGN KEY (item_hospedaje) REFERENCES [BASADOS_DE_DATOS].Hospedaje(hosp_codigo),
    FOREIGN KEY (item_habitacion) REFERENCES [BASADOS_DE_DATOS].HabitacionHospedaje(habi_codigo_habitacion)
);

-- ItemVentaExcursion: renglon de excursion dentro de una venta.
CREATE TABLE [BASADOS_DE_DATOS].ItemVentaExcursion (
    item_codigo BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    item_venta BIGINT,
    item_excursion BIGINT,
    item_fecha DATE,
    item_cant INT,
    item_precio_unitario DECIMAL(18,2),
    item_subtotal decimal(18,2),
    item_cod_reserva NVARCHAR(255),
    FOREIGN KEY (item_venta) REFERENCES [BASADOS_DE_DATOS].Venta(vent_codigo),
    FOREIGN KEY (item_excursion) REFERENCES [BASADOS_DE_DATOS].Excursion(excu_codigo)
);

-- ItemPropuestaVuelo: renglon de vuelo dentro de una propuesta.
CREATE TABLE [BASADOS_DE_DATOS].ItemPropuestaVuelo (
    item_codigo BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    item_propuesta BIGINT,
    item_vuelo BIGINT,
    item_cant_pasajes INT,
    item_precio_unitario DECIMAL(18,2),
    item_subtotal DECIMAL(18,2),
    FOREIGN KEY (item_propuesta) REFERENCES [BASADOS_DE_DATOS].Propuesta(prop_codigo),
    FOREIGN KEY (item_vuelo) REFERENCES [BASADOS_DE_DATOS].Vuelo(vuel_codigo)
);

-- ItemPropuestaHospedaje: renglon de hospedaje dentro de una propuesta.
CREATE TABLE [BASADOS_DE_DATOS].ItemPropuestaHospedaje (
    item_codigo BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    item_propuesta BIGINT,
    item_hospedaje BIGINT,
    item_habitacion BIGINT,
    item_ingreso DATE,
    item_egreso DATE,
    item_cant_habitaciones INT,
    item_precio_unitario decimal(18,2),
    item_subtotal DECIMAL(18,2),
    FOREIGN KEY (item_propuesta) REFERENCES [BASADOS_DE_DATOS].Propuesta(prop_codigo),
    FOREIGN KEY (item_hospedaje) REFERENCES [BASADOS_DE_DATOS].Hospedaje(hosp_codigo),
    FOREIGN KEY (item_habitacion) REFERENCES [BASADOS_DE_DATOS].HabitacionHospedaje(habi_codigo_habitacion)
);
GO

/* ===========================================================================
   2) INDICES
   - Sobre claves naturales usadas en los JOIN de la migracion (aceleran la carga).
   - Sobre claves foraneas (mejoran el rendimiento de consultas y del modelo BI).
   =========================================================================== */

-- Indices de apoyo a la migracion (resolucion de FK por clave natural).
CREATE INDEX IX_Cliente_Natural    ON [BASADOS_DE_DATOS].Cliente (clie_dni, clie_nombre, clie_apellido, clie_direccion);
CREATE INDEX IX_Hospedaje_Natural  ON [BASADOS_DE_DATOS].Hospedaje (hosp_nombre, hosp_direccion);
CREATE INDEX IX_Habitacion_Natural ON [BASADOS_DE_DATOS].HabitacionHospedaje (habi_hospedaje, habi_nombre);
CREATE INDEX IX_Vuelo_Natural      ON [BASADOS_DE_DATOS].Vuelo (vuel_aeropuerto_salida, vuel_aeropuerto_llegada, vuel_aerolinea);
CREATE INDEX IX_Excursion_Natural  ON [BASADOS_DE_DATOS].Excursion (excu_nombre);

-- Indices sobre FKs de las tablas de catalogo geografico.
CREATE INDEX IX_Ciudad_Pais        ON [BASADOS_DE_DATOS].Ciudad (ciud_pais);
CREATE INDEX IX_Localidad_Prov     ON [BASADOS_DE_DATOS].Localidad (loca_provincia);
CREATE INDEX IX_Aeropuerto_Ciudad  ON [BASADOS_DE_DATOS].Aeropuerto (aero_ciudad);
CREATE INDEX IX_Hospedaje_Ciudad   ON [BASADOS_DE_DATOS].Hospedaje (hosp_ciudad);
CREATE INDEX IX_Aerolinea_Pais     ON [BASADOS_DE_DATOS].Aerolinea (aero_pais);

-- Indices sobre FKs de tablas transaccionales.
CREATE INDEX IX_Solicitud_Cliente  ON [BASADOS_DE_DATOS].Solicitud (soli_cliente);
CREATE INDEX IX_Solicitud_Agente   ON [BASADOS_DE_DATOS].Solicitud (soli_agente);
CREATE INDEX IX_Venta_Cliente      ON [BASADOS_DE_DATOS].Venta (vent_cliente);
CREATE INDEX IX_Venta_Agente       ON [BASADOS_DE_DATOS].Venta (vent_agente);
CREATE INDEX IX_Propuesta_Soli     ON [BASADOS_DE_DATOS].Propuesta (prop_solicitud);
CREATE INDEX IX_Propuesta_Agente   ON [BASADOS_DE_DATOS].Propuesta (prop_agente);
CREATE INDEX IX_Encuesta_Cliente   ON [BASADOS_DE_DATOS].Encuesta (encu_cliente);
CREATE INDEX IX_Encuesta_Agente    ON [BASADOS_DE_DATOS].Encuesta (encu_agente);

-- Indices sobre FKs de tablas de detalle / cruce.
CREATE INDEX IX_IVV_Venta          ON [BASADOS_DE_DATOS].ItemVentaVuelo (item_venta);
CREATE INDEX IX_IVH_Venta          ON [BASADOS_DE_DATOS].ItemVentaHospedaje (item_venta);
CREATE INDEX IX_IVE_Venta          ON [BASADOS_DE_DATOS].ItemVentaExcursion (item_venta);
CREATE INDEX IX_IPV_Propuesta      ON [BASADOS_DE_DATOS].ItemPropuestaVuelo (item_propuesta);
CREATE INDEX IX_IPH_Propuesta      ON [BASADOS_DE_DATOS].ItemPropuestaHospedaje (item_propuesta);
CREATE INDEX IX_Aspecto_Encuesta   ON [BASADOS_DE_DATOS].Aspecto (aspe_encuesta);
CREATE INDEX IX_CiudadSoli_Soli    ON [BASADOS_DE_DATOS].CiudadSolicitud (ciud_numero);
CREATE INDEX IX_VentaProp_Venta    ON [BASADOS_DE_DATOS].Venta_Propuesta (vpro_venta);
CREATE INDEX IX_VentaProp_Prop     ON [BASADOS_DE_DATOS].Venta_Propuesta (vpro_propuesta);
GO

/* ===========================================================================
   3) STORED PROCEDURES DE MIGRACION (uno por tabla)
      El enunciado exige que la migracion se realice mediante Stored Procedures.
   =========================================================================== */

-- Migra Pais: reune los paises de aeropuertos, aerolineas y hospedajes.
-- Cada variante literal (con o sin tilde) se conserva como un pais distinto.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Pais AS
BEGIN
    SET NOCOUNT ON;
    WITH PaisesUnificados AS (
        SELECT Aeropuerto_Salida_Pais  AS Nombre_Pais FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Pais  IS NOT NULL
        UNION SELECT Aeropuerto_Llegada_Pais FROM gd_esquema.Maestra WHERE Aeropuerto_Llegada_Pais IS NOT NULL
        UNION SELECT Aerolinea_Pais          FROM gd_esquema.Maestra WHERE Aerolinea_Pais          IS NOT NULL
        UNION SELECT Hospedaje_Pais          FROM gd_esquema.Maestra WHERE Hospedaje_Pais          IS NOT NULL
    )
    INSERT INTO [BASADOS_DE_DATOS].Pais (pais_nombre)
    SELECT DISTINCT Nombre_Pais FROM PaisesUnificados;
END
GO

-- Migra CanalVenta: canales distintos presentes en las ventas.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_CanalVenta AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].CanalVenta (cana_nombre)
    SELECT DISTINCT Venta_Canal_Venta FROM gd_esquema.Maestra WHERE Venta_Canal_Venta IS NOT NULL;
END
GO

-- Migra MedioPago: medios de pago distintos presentes en las ventas.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_MedioPago AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].MedioPago (medi_nombre)
    SELECT DISTINCT Venta_Medio_Pago FROM gd_esquema.Maestra WHERE Venta_Medio_Pago IS NOT NULL;
END
GO

-- Migra Alianza: alianzas de aerolineas distintas.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Alianza AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Alianza (alia_nombre)
    SELECT DISTINCT Aerolinea_Alianza FROM gd_esquema.Maestra WHERE Aerolinea_Alianza IS NOT NULL;
END
GO

-- Migra Proveedor: proveedores de excursiones distintos.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Proveedor AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Proveedor (prov_nombre, prov_mail, prov_telefono)
    SELECT DISTINCT Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono
    FROM gd_esquema.Maestra WHERE Proveedor_Nombre IS NOT NULL;
END
GO

-- Migra EstadoPropuesta: estados distintos de propuesta.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_EstadoPropuesta AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].EstadoPropuesta (esta_nombre)
    SELECT DISTINCT Propuesta_Estado FROM gd_esquema.Maestra WHERE Propuesta_Estado IS NOT NULL;
END
GO

-- Migra Provincia: provincias de agencias, agentes y clientes (match exacto).
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Provincia AS
BEGIN
    SET NOCOUNT ON;
    WITH ProvinciasUnificadas AS (
        SELECT Agencia_Provincia AS Nombre_Provincia FROM gd_esquema.Maestra WHERE Agencia_Provincia IS NOT NULL
        UNION SELECT Agente_Provincia  FROM gd_esquema.Maestra WHERE Agente_Provincia  IS NOT NULL
        UNION SELECT Cliente_Provincia FROM gd_esquema.Maestra WHERE Cliente_Provincia IS NOT NULL
    )
    INSERT INTO [BASADOS_DE_DATOS].Provincia (prov_nombre)
    SELECT DISTINCT Nombre_Provincia FROM ProvinciasUnificadas;
END
GO

-- Migra Ciudad: ciudades de aeropuertos y hospedajes, asociadas a su pais
-- (resuelto por nombre de pais insensible a acentos).
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Ciudad AS
BEGIN
    SET NOCOUNT ON;
    WITH Ciudad_Pais AS (
        SELECT DISTINCT Aeropuerto_Salida_Ciudad  AS ciudad, Aeropuerto_Salida_Pais  AS pais FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Ciudad  IS NOT NULL AND Aeropuerto_Salida_Pais  IS NOT NULL
        UNION SELECT Aeropuerto_Llegada_Ciudad, Aeropuerto_Llegada_Pais FROM gd_esquema.Maestra WHERE Aeropuerto_Llegada_Ciudad IS NOT NULL AND Aeropuerto_Llegada_Pais IS NOT NULL
        UNION SELECT Hospedaje_Ciudad, Hospedaje_Pais FROM gd_esquema.Maestra WHERE Hospedaje_Ciudad IS NOT NULL AND Hospedaje_Pais IS NOT NULL
    )
    INSERT INTO [BASADOS_DE_DATOS].Ciudad (ciud_nombre, ciud_pais)
    SELECT cp.ciudad, p.pais_codigo
    FROM Ciudad_Pais cp
    LEFT JOIN [BASADOS_DE_DATOS].Pais p ON cp.pais = p.pais_nombre
    WHERE p.pais_codigo IS NOT NULL;
END
GO

-- Migra Aerolinea: una fila por codigo de aerolinea (GROUP BY sobre la clave
-- para evitar violacion de PK si un mismo codigo trae datos distintos).
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Aerolinea AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Aerolinea (aero_codigo, aero_nombre, aero_pais, aero_alianza)
    SELECT  m.Aerolinea_Codigo,
            MAX(m.Aerolinea_Nombre),
            MAX(p.pais_codigo),
            MAX(a.alia_codigo)
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Pais    p ON m.Aerolinea_Pais = p.pais_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Alianza a ON m.Aerolinea_Alianza = a.alia_nombre
    WHERE m.Aerolinea_Codigo IS NOT NULL
    GROUP BY m.Aerolinea_Codigo;
END
GO

-- Migra Localidad: localidades asociadas a su provincia (match exacto de nombres).
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Localidad AS
BEGIN
    SET NOCOUNT ON;
    WITH Provincia_Localidad AS (
        SELECT DISTINCT Agencia_Provincia AS provincia, Agencia_Localidad AS localidad FROM gd_esquema.Maestra WHERE Agencia_Provincia IS NOT NULL AND Agencia_Localidad IS NOT NULL
        UNION SELECT Agente_Provincia,  Agente_Localidad  FROM gd_esquema.Maestra WHERE Agente_Provincia  IS NOT NULL AND Agente_Localidad  IS NOT NULL
        UNION SELECT Cliente_Provincia, Cliente_Localidad FROM gd_esquema.Maestra WHERE Cliente_Provincia IS NOT NULL AND Cliente_Localidad IS NOT NULL
    )
    INSERT INTO [BASADOS_DE_DATOS].Localidad (loca_nombre, loca_provincia)
    SELECT DISTINCT pl.localidad, pr.prov_codigo
    FROM Provincia_Localidad pl
    LEFT JOIN [BASADOS_DE_DATOS].Provincia pr ON pl.provincia = pr.prov_nombre;
END
GO

-- Migra Aeropuerto: una fila por codigo de aeropuerto (GROUP BY sobre la clave).
-- El filtro de pais se aplica en el JOIN (no en WHERE) para NO descartar codigos
-- que luego son referenciados por Vuelo (evita violacion de FK).
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Aeropuerto AS
BEGIN
    SET NOCOUNT ON;
    WITH AeropuertosUnificados AS (
        SELECT Aeropuerto_Llegada_Codigo AS codigo, Aeropuerto_Llegada_Descripcion AS descripcion,
               Aeropuerto_Llegada_Ciudad AS ciudad, Aeropuerto_Llegada_Pais AS pais
        FROM gd_esquema.Maestra WHERE Aeropuerto_Llegada_Codigo IS NOT NULL
        UNION
        SELECT Aeropuerto_Salida_Codigo, Aeropuerto_Salida_Descripcion,
               Aeropuerto_Salida_Ciudad, Aeropuerto_Salida_Pais
        FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Codigo IS NOT NULL
    )
    INSERT INTO [BASADOS_DE_DATOS].Aeropuerto (aero_codigo, aero_descripcion, aero_ciudad)
    SELECT  au.codigo,
            MAX(au.descripcion),
            MAX(c.ciud_codigo)
    FROM AeropuertosUnificados au
    LEFT JOIN [BASADOS_DE_DATOS].Pais   p ON au.pais = p.pais_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Ciudad c ON c.ciud_nombre = au.ciudad AND c.ciud_pais = p.pais_codigo
    GROUP BY au.codigo;
END
GO

-- Migra Hospedaje: un alojamiento es unico por la combinacion de sus atributos.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Hospedaje AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Hospedaje (hosp_ciudad, hosp_nombre, hosp_direccion, hosp_incluye_desayuno, hosp_hora_check_in, hosp_hora_check_out)
    SELECT DISTINCT c.ciud_codigo, m.Hospedaje_Nombre, m.Hospedaje_Direccion,
           m.Hospedaje_Incluye_Desayuno, m.Hospedaje_Check_In, m.Hospedaje_Check_Out
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Pais   p ON m.Hospedaje_Pais = p.pais_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Ciudad c ON m.Hospedaje_Ciudad = c.ciud_nombre AND c.ciud_pais = p.pais_codigo
    WHERE m.Hospedaje_Nombre IS NOT NULL;
END
GO

-- Migra Excursion: una excursion es unica por la combinacion de sus atributos.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Excursion AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Excursion (excu_nombre, excu_descripcion, excu_horario, excu_duracion, excu_precio, excu_proveedor)
    SELECT DISTINCT m.Excursion_Nombre, m.Excursion_Descripcion, m.Excursion_Horario,
           m.Excursion_Duracion, m.Excursion_Precio, pr.prov_codigo
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Proveedor pr ON m.Proveedor_Nombre = pr.prov_nombre
    WHERE m.Excursion_Nombre IS NOT NULL;
END
GO

-- Migra Agencia: una fila por numero de agencia (GROUP BY sobre la clave; el
-- filtro de provincia va en el JOIN para no descartar agencias referenciadas).
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Agencia AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Agencia (agen_numero, agen_direccion, agen_telefono, agen_mail, agen_localidad)
    SELECT  m.Agencia_Nro_Agencia,
            MAX(m.Agencia_Direccion),
            MAX(m.Agencia_Telefono),
            MAX(m.Agencia_Mail),
            MAX(l.loca_codigo)
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Provincia pr ON m.Agencia_Provincia = pr.prov_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Localidad l  ON m.Agencia_Localidad = l.loca_nombre AND l.loca_provincia = pr.prov_codigo
    WHERE m.Agencia_Nro_Agencia IS NOT NULL
    GROUP BY m.Agencia_Nro_Agencia;
END
GO

-- Migra HabitacionHospedaje: tipos de habitacion vinculados a su hospedaje.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_HabitacionHospedaje AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].HabitacionHospedaje (habi_hospedaje, habi_nombre, habi_descripcion, habi_precio_noche)
    SELECT DISTINCT h.hosp_codigo, m.Habitacion_Nombre, m.Habitacion_Descripcion, m.Habitacion_Precio_Noche
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Pais   p ON m.Hospedaje_Pais = p.pais_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Ciudad c ON m.Hospedaje_Ciudad = c.ciud_nombre AND c.ciud_pais = p.pais_codigo
    LEFT JOIN [BASADOS_DE_DATOS].Hospedaje h
           ON m.Hospedaje_Nombre = h.hosp_nombre AND m.Hospedaje_Direccion = h.hosp_direccion
          AND m.Hospedaje_Check_In = h.hosp_hora_check_in AND m.Hospedaje_Check_Out = h.hosp_hora_check_out
          AND m.Hospedaje_Incluye_Desayuno = h.hosp_incluye_desayuno AND c.ciud_codigo = h.hosp_ciudad
    WHERE m.Habitacion_Nombre IS NOT NULL AND h.hosp_codigo IS NOT NULL;
END
GO

-- Migra Vuelo: vuelo unico por la combinacion de atributos (incluye duracion).
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Vuelo AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Vuelo (vuel_precio, vuel_aeropuerto_salida, vuel_aeropuerto_llegada,
        vuel_fecha_salida, vuel_horario_salida, vuel_fecha_llegada, vuel_horario_llegada,
        vuel_duracion, vuel_aerolinea, vuel_incluye_carry, vuel_incluye_valija)
    SELECT DISTINCT Vuelo_Precio, Aeropuerto_Salida_Codigo, Aeropuerto_Llegada_Codigo,
           Vuelo_Fecha_Salida, Vuelo_Horario_Salida, Vuelo_Fecha_Llegada, Vuelo_Horario_Llegada,
           Vuelo_Duracion, Aerolinea_Codigo, Vuelo_Incluye_Carry, Vuelo_Incluye_Valija
    FROM gd_esquema.Maestra
    WHERE Vuelo_Precio IS NOT NULL;
END
GO

-- Migra Agente: una fila por legajo (GROUP BY sobre la clave; filtro de
-- provincia en el JOIN para no descartar agentes referenciados por ventas).
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Agente AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Agente (agen_legajo, agen_agencia, agen_nombre, agen_apellido,
        agen_dni, agen_fecha_nacimiento, agen_telefono, agen_mail, agen_direccion, agen_localidad)
    SELECT  m.Agente_Legajo,
            MAX(m.Agencia_Nro_Agencia),
            MAX(m.Agente_Nombre),
            MAX(m.Agente_Apellido),
            MAX(m.Agente_Dni),
            MAX(m.Agente_Fecha_Nac),
            MAX(m.Agente_Telefono),
            MAX(m.Agente_Mail),
            MAX(m.Agente_Direccion),
            MAX(l.loca_codigo)
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Provincia pr ON m.Agente_Provincia = pr.prov_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Localidad l  ON m.Agente_Localidad = l.loca_nombre AND l.loca_provincia = pr.prov_codigo
    WHERE m.Agente_Legajo IS NOT NULL
    GROUP BY m.Agente_Legajo;
END
GO

-- Migra Cliente: clave subrogada; se deduplica por (dni, nombre, apellido,
-- direccion) para que la resolucion de FK desde las transacciones sea 1:1.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Cliente AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Cliente (clie_dni, clie_nombre, clie_apellido, clie_telefono,
        clie_mail, clie_direccion, clie_fecha_nacimiento, clie_localidad)
    SELECT  m.Cliente_Dni, m.Cliente_Nombre, m.Cliente_Apellido,
            MAX(m.Cliente_Tel), MAX(m.Cliente_Mail), m.Cliente_Direccion,
            MAX(m.Cliente_Fecha_Nac), MAX(l.loca_codigo)
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Provincia pr ON m.Cliente_Provincia = pr.prov_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Localidad l  ON m.Cliente_Localidad = l.loca_nombre AND l.loca_provincia = pr.prov_codigo
    WHERE m.Cliente_Dni IS NOT NULL
    GROUP BY m.Cliente_Dni, m.Cliente_Nombre, m.Cliente_Apellido, m.Cliente_Direccion;
END
GO

-- Migra Solicitud: pedido de cotizacion; resuelve cliente por su clave natural.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Solicitud AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Solicitud (soli_numero, soli_cliente, soli_fecha, soli_inicio_tentativa,
        soli_fin_tentativa, soli_cant_pas, soli_observaciones, soli_presupuesto_estimado, soli_agente)
    SELECT DISTINCT m.Solicitud_Nro_Solicitud, c.clie_codigo, m.Solicitud_Fecha_Solicitud,
           m.Solicitud_Fecha_Inicio_Tentativa, m.Solicitud_Fecha_Fin_Tentativa, m.Solicitud_Cant_Pax,
           m.Solicitud_Observaciones, m.Solicitud_Presupuesto_Estimado, m.Agente_Legajo
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Cliente c
           ON m.Cliente_Dni = c.clie_dni AND m.Cliente_Nombre = c.clie_nombre
          AND m.Cliente_Apellido = c.clie_apellido AND m.Cliente_Direccion = c.clie_direccion
    WHERE m.Solicitud_Nro_Solicitud IS NOT NULL;
END
GO

-- Migra Venta: resuelve cliente, canal y medio de pago por sus claves naturales.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Venta AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Venta (vent_codigo, vent_cliente, vent_agente, vent_fecha,
        vent_canal_venta, vent_subtotal, vent_descuento, vent_importe_total, vent_medio_pago)
    SELECT DISTINCT m.Venta_Nro_Venta, c.clie_codigo, m.Agente_Legajo, m.Venta_Fecha_Venta,
           cv.cana_codigo, m.Venta_Subtotal, m.Venta_Descuento, m.Venta_Importe_Total, mp.medi_codigo
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Cliente c
           ON m.Cliente_Dni = c.clie_dni AND m.Cliente_Nombre = c.clie_nombre
          AND m.Cliente_Apellido = c.clie_apellido AND m.Cliente_Direccion = c.clie_direccion
    LEFT JOIN [BASADOS_DE_DATOS].CanalVenta cv ON m.Venta_Canal_Venta = cv.cana_nombre
    LEFT JOIN [BASADOS_DE_DATOS].MedioPago  mp ON m.Venta_Medio_Pago  = mp.medi_nombre
    WHERE m.Venta_Nro_Venta IS NOT NULL;
END
GO

-- Migra Encuesta: encuesta de satisfaccion; resuelve cliente por clave natural.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Encuesta AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Encuesta (encu_codigo, encu_fecha, encu_cliente, encu_agente, encu_comentario)
    SELECT DISTINCT m.Encuesta_Codigo_Encuesta, m.Encuesta_Fecha_Encuesta, c.clie_codigo, m.Agente_Legajo, m.Encuesta_Comentarios
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Cliente c
           ON m.Cliente_Dni = c.clie_dni AND m.Cliente_Nombre = c.clie_nombre
          AND m.Cliente_Apellido = c.clie_apellido AND m.Cliente_Direccion = c.clie_direccion
    WHERE m.Encuesta_Codigo_Encuesta IS NOT NULL;
END
GO

-- Migra CiudadSolicitud: ciudades incluidas en cada solicitud.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_CiudadSolicitud AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].CiudadSolicitud (ciud_numero, ciud_detalle, ciud_cant_dias, ciud_observaciones)
    SELECT DISTINCT Solicitud_Nro_Solicitud, Detalle_Solicitud_Ciudad, Detalle_Solicitud_Cant_Dias_Aprox, Detalle_Solicitud_Observaciones
    FROM gd_esquema.Maestra
    WHERE Detalle_Solicitud_Ciudad IS NOT NULL;
END
GO

-- Migra Propuesta: propuesta de un agente a una solicitud; resuelve estado.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Propuesta AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Propuesta (prop_codigo, prop_solicitud, prop_agente, prop_fecha_emision,
        prop_vigencia, prop_fecha_desde, prop_fecha_hasta, prop_subtotal, prop_descuento, prop_importe_total, prop_estado)
    SELECT DISTINCT m.Propuesta_Nro_Propuesta, m.Solicitud_Nro_Solicitud, m.Agente_Legajo,
           m.Propuesta_Fecha_Emision, m.Propuesta_Vigencia_Hasta, m.Propuesta_Fecha_Desde,
           m.Propuesta_Fecha_Hasta, m.Propuesta_Subtotal, m.Propuesta_Descuento,
           m.Propuesta_Importe_Total, ep.esta_codigo
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].EstadoPropuesta ep ON m.Propuesta_Estado = ep.esta_nombre
    WHERE m.Propuesta_Nro_Propuesta IS NOT NULL;
END
GO

-- Migra Aspecto: valoraciones por aspecto de cada encuesta.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Aspecto AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Aspecto (aspe_encuesta, aspe_detalle, aspe_puntaje)
    SELECT DISTINCT Encuesta_Codigo_Encuesta, Aspecto_Aspecto, Detalle_Encuesta_Puntaje
    FROM gd_esquema.Maestra
    WHERE Aspecto_Aspecto IS NOT NULL;
END
GO

-- Migra Venta_Propuesta: vincula venta con la propuesta que la origino.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_Venta_Propuesta AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].Venta_Propuesta (vpro_venta, vpro_propuesta)
    SELECT DISTINCT Venta_Nro_Venta, Propuesta_Nro_Propuesta
    FROM gd_esquema.Maestra
    WHERE Venta_Nro_Venta IS NOT NULL AND Propuesta_Nro_Propuesta IS NOT NULL;
END
GO

-- Migra ItemVentaVuelo: renglones de vuelo de cada venta (resuelve el vuelo
-- por TODOS sus atributos, incluida la duracion, para mantener la cardinalidad 1:1).
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_ItemVentaVuelo AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].ItemVentaVuelo (item_venta, item_vuelo, item_precio_unitario,
        vuel_cant_pasajes, item_cod_reserva, item_subtotal)
    SELECT DISTINCT m.Venta_Nro_Venta, v.vuel_codigo, m.Detalle_Venta_Vuelo_Precio_Unitario,
           m.Detalle_Venta_Vuelo_Cantidad_Pasajes, m.Detalle_Venta_Vuelo_Cod_Reserva, m.Detalle_Venta_Vuelo_Subtotal
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Vuelo v
           ON m.Aeropuerto_Salida_Codigo = v.vuel_aeropuerto_salida AND m.Aeropuerto_Llegada_Codigo = v.vuel_aeropuerto_llegada
          AND m.Aerolinea_Codigo = v.vuel_aerolinea AND m.Vuelo_Precio = v.vuel_precio
          AND m.Vuelo_Fecha_Salida = v.vuel_fecha_salida AND m.Vuelo_Fecha_Llegada = v.vuel_fecha_llegada
          AND m.Vuelo_Horario_Salida = v.vuel_horario_salida AND m.Vuelo_Horario_Llegada = v.vuel_horario_llegada
          AND m.Vuelo_Duracion = v.vuel_duracion
          AND m.Vuelo_Incluye_Carry = v.vuel_incluye_carry AND m.Vuelo_Incluye_Valija = v.vuel_incluye_valija
    WHERE m.Venta_Nro_Venta IS NOT NULL AND v.vuel_codigo IS NOT NULL;
END
GO

-- Migra ItemVentaHospedaje: renglones de hospedaje/habitacion de cada venta.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_ItemVentaHospedaje AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].ItemVentaHospedaje (item_venta, item_hospedaje, item_habitacion,
        item_desde, item_hasta, item_hospedaje_cantidad, item_precio_unitario, item_subtotal, item_cod_reserva)
    SELECT DISTINCT m.Venta_Nro_Venta, h.hosp_codigo, hh.habi_codigo_habitacion, m.Detalle_Venta_Hospedaje_Fecha_Desde,
           m.Detalle_Venta_Hospedaje_Fecha_Hasta, m.Detalle_Venta_Hospedaje_Cantidad,
           m.Detalle_Venta_Hospedaje_Precio_Unitario, m.Detalle_Venta_Hospedaje_Subtotal, m.Detalle_Venta_Hospedaje_Cod_Reserva
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Pais   p ON m.Hospedaje_Pais = p.pais_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Ciudad c ON m.Hospedaje_Ciudad = c.ciud_nombre AND c.ciud_pais = p.pais_codigo
    LEFT JOIN [BASADOS_DE_DATOS].Hospedaje h
           ON m.Hospedaje_Nombre = h.hosp_nombre AND m.Hospedaje_Direccion = h.hosp_direccion
          AND m.Hospedaje_Check_In = h.hosp_hora_check_in AND m.Hospedaje_Check_Out = h.hosp_hora_check_out
          AND m.Hospedaje_Incluye_Desayuno = h.hosp_incluye_desayuno AND c.ciud_codigo = h.hosp_ciudad
    LEFT JOIN [BASADOS_DE_DATOS].HabitacionHospedaje hh
           ON h.hosp_codigo = hh.habi_hospedaje AND m.Habitacion_Nombre = hh.habi_nombre
          AND m.Habitacion_Descripcion = hh.habi_descripcion AND m.Habitacion_Precio_Noche = hh.habi_precio_noche
    WHERE m.Venta_Nro_Venta IS NOT NULL AND h.hosp_codigo IS NOT NULL;
END
GO

-- Migra ItemVentaExcursion: renglones de excursion de cada venta.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_ItemVentaExcursion AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].ItemVentaExcursion (item_venta, item_excursion, item_fecha,
        item_cant, item_precio_unitario, item_subtotal, item_cod_reserva)
    SELECT DISTINCT m.Venta_Nro_Venta, e.excu_codigo, m.Detalle_Venta_Excursion_Fecha_Reserva,
           m.Detalle_Venta_Excursion_Cant, m.Detalle_Venta_Excursion_Precio_Unitario,
           m.Detalle_Venta_Excursion_Subtotal, m.Detalle_Venta_Excursion_Cod_Reserva
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Excursion e
           ON m.Excursion_Nombre = e.excu_nombre AND m.Excursion_Descripcion = e.excu_descripcion
          AND m.Excursion_Horario = e.excu_horario AND m.Excursion_Duracion = e.excu_duracion AND m.Excursion_Precio = e.excu_precio
    WHERE m.Venta_Nro_Venta IS NOT NULL AND e.excu_codigo IS NOT NULL;
END
GO

-- Migra ItemPropuestaVuelo: renglones de vuelo de cada propuesta.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_ItemPropuestaVuelo AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].ItemPropuestaVuelo (item_propuesta, item_vuelo, item_cant_pasajes,
        item_precio_unitario, item_subtotal)
    SELECT DISTINCT m.Propuesta_Nro_Propuesta, v.vuel_codigo, m.Detalle_Propuesta_Vuelo_Cant_Pasajes,
           m.Detalle_Propuesta_Vuelo_Precio, m.Detalle_Propuesta_Vuelo_Subtotal
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Vuelo v
           ON m.Aeropuerto_Salida_Codigo = v.vuel_aeropuerto_salida AND m.Aeropuerto_Llegada_Codigo = v.vuel_aeropuerto_llegada
          AND m.Aerolinea_Codigo = v.vuel_aerolinea AND m.Vuelo_Precio = v.vuel_precio
          AND m.Vuelo_Fecha_Salida = v.vuel_fecha_salida AND m.Vuelo_Fecha_Llegada = v.vuel_fecha_llegada
          AND m.Vuelo_Horario_Salida = v.vuel_horario_salida AND m.Vuelo_Horario_Llegada = v.vuel_horario_llegada
          AND m.Vuelo_Duracion = v.vuel_duracion
          AND m.Vuelo_Incluye_Carry = v.vuel_incluye_carry AND m.Vuelo_Incluye_Valija = v.vuel_incluye_valija
    WHERE m.Propuesta_Nro_Propuesta IS NOT NULL AND v.vuel_codigo IS NOT NULL AND m.Detalle_Propuesta_Vuelo_Precio IS NOT NULL;
END
GO

-- Migra ItemPropuestaHospedaje: renglones de hospedaje de cada propuesta.
CREATE PROCEDURE [BASADOS_DE_DATOS].Migrar_ItemPropuestaHospedaje AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [BASADOS_DE_DATOS].ItemPropuestaHospedaje (item_propuesta, item_hospedaje, item_habitacion,
        item_ingreso, item_egreso, item_cant_habitaciones, item_precio_unitario, item_subtotal)
    SELECT DISTINCT m.Propuesta_Nro_Propuesta, h.hosp_codigo, hh.habi_codigo_habitacion,
           m.Detalle_Propuesta_Hospedaje_Fecha_Desde, m.Detalle_Propuesta_Hospedaje_Fecha_Hasta,
           m.Detalle_Propuesta_Hospedaje_Cant, m.Detalle_Propuesta_Hospedaje_Precio, m.Detalle_Propuesta_Hospedaje_Subtotal
    FROM gd_esquema.Maestra m
    LEFT JOIN [BASADOS_DE_DATOS].Pais   p ON m.Hospedaje_Pais = p.pais_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Ciudad c ON m.Hospedaje_Ciudad = c.ciud_nombre AND c.ciud_pais = p.pais_codigo
    LEFT JOIN [BASADOS_DE_DATOS].Hospedaje h
           ON m.Hospedaje_Nombre = h.hosp_nombre AND m.Hospedaje_Direccion = h.hosp_direccion
          AND m.Hospedaje_Check_In = h.hosp_hora_check_in AND m.Hospedaje_Check_Out = h.hosp_hora_check_out
          AND m.Hospedaje_Incluye_Desayuno = h.hosp_incluye_desayuno AND c.ciud_codigo = h.hosp_ciudad
    LEFT JOIN [BASADOS_DE_DATOS].HabitacionHospedaje hh
           ON h.hosp_codigo = hh.habi_hospedaje AND m.Habitacion_Nombre = hh.habi_nombre
          AND m.Habitacion_Descripcion = hh.habi_descripcion AND m.Habitacion_Precio_Noche = hh.habi_precio_noche
    WHERE m.Propuesta_Nro_Propuesta IS NOT NULL AND h.hosp_codigo IS NOT NULL AND m.Detalle_Propuesta_Hospedaje_Precio IS NOT NULL;
END
GO

/* ===========================================================================
   4) EJECUCION DE LA MIGRACION (en orden de dependencias)
   =========================================================================== */

-- Catalogos base (sin dependencias).
EXEC [BASADOS_DE_DATOS].Migrar_Pais;
EXEC [BASADOS_DE_DATOS].Migrar_CanalVenta;
EXEC [BASADOS_DE_DATOS].Migrar_MedioPago;
EXEC [BASADOS_DE_DATOS].Migrar_Alianza;
EXEC [BASADOS_DE_DATOS].Migrar_Proveedor;
EXEC [BASADOS_DE_DATOS].Migrar_EstadoPropuesta;
EXEC [BASADOS_DE_DATOS].Migrar_Provincia;
-- Catalogos que dependen de los anteriores.
EXEC [BASADOS_DE_DATOS].Migrar_Ciudad;
EXEC [BASADOS_DE_DATOS].Migrar_Aerolinea;
EXEC [BASADOS_DE_DATOS].Migrar_Localidad;
EXEC [BASADOS_DE_DATOS].Migrar_Aeropuerto;
EXEC [BASADOS_DE_DATOS].Migrar_Hospedaje;
EXEC [BASADOS_DE_DATOS].Migrar_Excursion;
EXEC [BASADOS_DE_DATOS].Migrar_Agencia;
EXEC [BASADOS_DE_DATOS].Migrar_HabitacionHospedaje;
EXEC [BASADOS_DE_DATOS].Migrar_Vuelo;
EXEC [BASADOS_DE_DATOS].Migrar_Agente;
EXEC [BASADOS_DE_DATOS].Migrar_Cliente;
-- Transaccionales y detalle.
EXEC [BASADOS_DE_DATOS].Migrar_Solicitud;
EXEC [BASADOS_DE_DATOS].Migrar_Venta;
EXEC [BASADOS_DE_DATOS].Migrar_Encuesta;
EXEC [BASADOS_DE_DATOS].Migrar_CiudadSolicitud;
EXEC [BASADOS_DE_DATOS].Migrar_Propuesta;
EXEC [BASADOS_DE_DATOS].Migrar_Aspecto;
EXEC [BASADOS_DE_DATOS].Migrar_Venta_Propuesta;
EXEC [BASADOS_DE_DATOS].Migrar_ItemVentaVuelo;
EXEC [BASADOS_DE_DATOS].Migrar_ItemVentaHospedaje;
EXEC [BASADOS_DE_DATOS].Migrar_ItemVentaExcursion;
EXEC [BASADOS_DE_DATOS].Migrar_ItemPropuestaVuelo;
EXEC [BASADOS_DE_DATOS].Migrar_ItemPropuestaHospedaje;
GO
