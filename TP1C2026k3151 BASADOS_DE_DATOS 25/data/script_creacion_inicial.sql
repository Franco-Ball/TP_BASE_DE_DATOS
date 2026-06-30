USE GD1C2026
go
CREATE SCHEMA [BASADOS_DE_DATOS]
GO

CREATE TABLE [BASADOS_DE_DATOS].Pais (
    pais_codigo bigint IDENTITY(1,1) not null primary key,
    pais_nombre NVARCHAR(255) 
);

CREATE TABLE [BASADOS_DE_DATOS].CanalVenta (
    cana_codigo bigint IDENTITY(1,1) not null primary key,
    cana_nombre NVARCHAR(255)
);

CREATE TABLE [BASADOS_DE_DATOS].MedioPago (
    medi_codigo bigint IDENTITY(1,1) not null primary key,
    medi_nombre NVARCHAR(255) 
);

CREATE TABLE [BASADOS_DE_DATOS].Alianza (
    alia_codigo bigint IDENTITY(1,1) not null primary key,
    alia_nombre NVARCHAR(255) 
);

CREATE TABLE [BASADOS_DE_DATOS].Proveedor (
    prov_codigo  bigint IDENTITY(1,1) not null primary key,
    prov_nombre NVARCHAR(255),
    prov_mail NVARCHAR(255),
    prov_telefono NVARCHAR(255)
);

CREATE TABLE [BASADOS_DE_DATOS].EstadoPropuesta (
    esta_codigo bigint IDENTITY(1,1) not null primary key,
    esta_nombre NVARCHAR(255) 
)


CREATE TABLE [BASADOS_DE_DATOS].Provincia (
    prov_codigo bigint IDENTITY(1,1) not null primary key,
    prov_nombre NVARCHAR(255),
);

CREATE TABLE [BASADOS_DE_DATOS].Ciudad (
    ciud_codigo bigint IDENTITY(1,1) not null primary key,
    ciud_nombre NVARCHAR(255),
    ciud_pais bigint,
    FOREIGN KEY (ciud_pais) REFERENCES [BASADOS_DE_DATOS].Pais(pais_codigo)
);

CREATE TABLE [BASADOS_DE_DATOS].Aerolinea (
    aero_codigo NVARCHAR(255) PRIMARY KEY,
    aero_nombre NVARCHAR(255),
    aero_pais bigint,
    aero_alianza bigint,
    FOREIGN KEY (aero_pais) REFERENCES [BASADOS_DE_DATOS].Pais(pais_codigo),
    FOREIGN KEY (aero_alianza) REFERENCES [BASADOS_DE_DATOS].Alianza(alia_codigo)
);



CREATE TABLE [BASADOS_DE_DATOS].Localidad (
    loca_codigo bigint IDENTITY(1,1) not null primary key,
    loca_nombre NVARCHAR(255),
    loca_provincia bigint,
    FOREIGN KEY (loca_provincia) REFERENCES [BASADOS_DE_DATOS].Provincia(prov_codigo)
);

CREATE TABLE [BASADOS_DE_DATOS].Aeropuerto (
    aero_codigo NVARCHAR(10) PRIMARY KEY,
    aero_descripcion NVARCHAR(200),
    aero_ciudad bigint,
    FOREIGN KEY (aero_ciudad) REFERENCES [BASADOS_DE_DATOS].Ciudad(ciud_codigo)
);

CREATE TABLE [BASADOS_DE_DATOS].Hospedaje (
    hosp_codigo bigint IDENTITY(1,1) not null primary key,
    hosp_ciudad bigint,
    hosp_nombre NVARCHAR(255),
    hosp_direccion NVARCHAR(255),
    hosp_incluye_desayuno BIT,
    hosp_hora_check_in NVARCHAR(50),
    hosp_hora_check_out NVARCHAR(50),
    FOREIGN KEY (hosp_ciudad) REFERENCES [BASADOS_DE_DATOS].Ciudad(ciud_codigo)
);

CREATE TABLE [BASADOS_DE_DATOS].Excursion (
    excu_codigo BIGINT IDENTITY(1,1) not null PRIMARY KEY,
    excu_nombre NVARCHAR(255),
    excu_descripcion NVARCHAR(MAX),
    excu_horario NVARCHAR(50),
    excu_duracion INT,
    excu_precio DECIMAL(18,2),
    excu_proveedor BIGINT,
    FOREIGN KEY (excu_proveedor) REFERENCES [BASADOS_DE_DATOS].Proveedor(prov_codigo)
);


CREATE TABLE [BASADOS_DE_DATOS].Agencia (
    agen_numero BIGINT primary key,
    agen_direccion NVARCHAR(255),
    agen_telefono NVARCHAR(255),
    agen_mail NVARCHAR(255),
    agen_localidad bigint,
    FOREIGN KEY (agen_localidad) REFERENCES [BASADOS_DE_DATOS].Localidad(loca_codigo)
);

CREATE TABLE [BASADOS_DE_DATOS].HabitacionHospedaje (
    habi_codigo_habitacion BIGINT IDENTITY(1,1) not null PRIMARY KEY,
    habi_hospedaje BIGINT,
    habi_nombre NVARCHAR(255),
    habi_descripcion NVARCHAR(MAX),
    habi_precio_noche DECIMAL(18,2),
    FOREIGN KEY (habi_hospedaje) REFERENCES [BASADOS_DE_DATOS].Hospedaje(hosp_codigo)
);

CREATE TABLE [BASADOS_DE_DATOS].Vuelo (
    vuel_codigo BIGINT identity(1,1) not null PRIMARY KEY,
    vuel_precio DECIMAL(18,2),
    vuel_aeropuerto_salida NVARCHAR(10),
    vuel_aeropuerto_llegada NVARCHAR(10),
    vuel_fecha_salida DATE,
    vuel_horario_salida NVARCHAR(50),
    vuel_fecha_llegada DATE,
    vuel_horario_llegada NVARCHAR(50),
    vuel_aerolinea NVARCHAR(255),
    vuel_incluye_carry BIT,
    vuel_incluye_valija BIT,
    FOREIGN KEY (vuel_aeropuerto_salida) REFERENCES [BASADOS_DE_DATOS].Aeropuerto(aero_codigo),
    FOREIGN KEY (vuel_aeropuerto_llegada) REFERENCES [BASADOS_DE_DATOS].Aeropuerto(aero_codigo),
    FOREIGN KEY (vuel_aerolinea) REFERENCES [BASADOS_DE_DATOS].Aerolinea(aero_codigo)
);


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

CREATE TABLE [BASADOS_DE_DATOS].Cliente (
    clie_codigo bigint identity(1,1) not null primary key,
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

CREATE TABLE [BASADOS_DE_DATOS].Encuesta (
    encu_codigo BIGINT PRIMARY KEY,
    encu_fecha DATE,
    encu_cliente bigint,
    encu_agente BIGINT,
    encu_comentario NVARCHAR(MAX),
    FOREIGN KEY (encu_cliente) REFERENCES [BASADOS_DE_DATOS].Cliente(clie_codigo),
    FOREIGN KEY (encu_agente) REFERENCES [BASADOS_DE_DATOS].Agente(agen_legajo)
);


CREATE TABLE [BASADOS_DE_DATOS].CiudadSolicitud (
    ciud_numero BIGINT,
    ciud_detalle NVARCHAR(255),
    ciud_cant_dias INT,
    ciud_observaciones NVARCHAR(MAX),
    FOREIGN KEY (ciud_numero) REFERENCES [BASADOS_DE_DATOS].Solicitud(soli_numero)
);

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

CREATE TABLE [BASADOS_DE_DATOS].Aspecto (
    aspe_encuesta BIGINT,
    aspe_detalle NVARCHAR(255),
    aspe_puntaje INT,
    FOREIGN KEY (aspe_encuesta) REFERENCES [BASADOS_DE_DATOS].Encuesta(encu_codigo)
);


CREATE TABLE [BASADOS_DE_DATOS].Venta_Propuesta (
    vpro_venta BIGINT,
    vpro_propuesta BIGINT,
    FOREIGN KEY (vpro_venta) REFERENCES [BASADOS_DE_DATOS].Venta(vent_codigo),
    FOREIGN KEY (vpro_propuesta) REFERENCES [BASADOS_DE_DATOS].Propuesta(prop_codigo)
);

CREATE TABLE [BASADOS_DE_DATOS].ItemVentaVuelo (
    item_venta BIGINT,
    item_vuelo BIGINT,
    item_precio_unitario DECIMAL(18,2),
    vuel_cant_pasajes INT,
    item_cod_reserva NVARCHAR(255),
    item_subtotal DECIMAL(18,2),
    FOREIGN KEY (item_venta) REFERENCES [BASADOS_DE_DATOS].Venta(vent_codigo),
    FOREIGN KEY (item_vuelo) REFERENCES [BASADOS_DE_DATOS].Vuelo(vuel_codigo)
);

CREATE TABLE [BASADOS_DE_DATOS].ItemVentaHospedaje (
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

CREATE TABLE [BASADOS_DE_DATOS].ItemVentaExcursion (
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

CREATE TABLE [BASADOS_DE_DATOS].ItemPropuestaVuelo (
    item_propuesta BIGINT,
    item_vuelo BIGINT,
    item_cant_pasajes INT,
    item_precio_unitario DECIMAL(18,2),
    item_subtotal DECIMAL(18,2),
    FOREIGN KEY (item_propuesta) REFERENCES [BASADOS_DE_DATOS].Propuesta(prop_codigo),
    FOREIGN KEY (item_vuelo) REFERENCES [BASADOS_DE_DATOS].Vuelo(vuel_codigo)
);

CREATE TABLE [BASADOS_DE_DATOS].ItemPropuestaHospedaje (
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

go

/* ===========================================================================
   INDICES
   Se crean antes de la migracion: aceleran tanto los JOIN por clave natural
   que usa la carga como las consultas posteriores (incluido el modelo de BI).
   =========================================================================== */

-- Indices sobre claves naturales usadas en los JOIN de la migracion
CREATE INDEX IX_Pais_nombre              ON [BASADOS_DE_DATOS].Pais(pais_nombre);
CREATE INDEX IX_Provincia_nombre         ON [BASADOS_DE_DATOS].Provincia(prov_nombre);
CREATE INDEX IX_Localidad_nombre         ON [BASADOS_DE_DATOS].Localidad(loca_nombre);
CREATE INDEX IX_Ciudad_nombre            ON [BASADOS_DE_DATOS].Ciudad(ciud_nombre);
CREATE INDEX IX_Alianza_nombre           ON [BASADOS_DE_DATOS].Alianza(alia_nombre);
CREATE INDEX IX_CanalVenta_nombre        ON [BASADOS_DE_DATOS].CanalVenta(cana_nombre);
CREATE INDEX IX_MedioPago_nombre         ON [BASADOS_DE_DATOS].MedioPago(medi_nombre);
CREATE INDEX IX_EstadoPropuesta_nombre   ON [BASADOS_DE_DATOS].EstadoPropuesta(esta_nombre);
CREATE INDEX IX_Proveedor_nombre         ON [BASADOS_DE_DATOS].Proveedor(prov_nombre);
CREATE INDEX IX_Hospedaje_natural        ON [BASADOS_DE_DATOS].Hospedaje(hosp_direccion, hosp_nombre);
CREATE INDEX IX_Habitacion_natural       ON [BASADOS_DE_DATOS].HabitacionHospedaje(habi_hospedaje, habi_nombre);
CREATE INDEX IX_Vuelo_natural            ON [BASADOS_DE_DATOS].Vuelo(vuel_aeropuerto_salida, vuel_aeropuerto_llegada, vuel_aerolinea);
CREATE INDEX IX_Excursion_nombre         ON [BASADOS_DE_DATOS].Excursion(excu_nombre);
CREATE INDEX IX_Cliente_natural          ON [BASADOS_DE_DATOS].Cliente(clie_dni, clie_nombre, clie_apellido, clie_direccion);

-- Indices sobre claves foraneas de las tablas transaccionales y de detalle
CREATE INDEX IX_Venta_cliente            ON [BASADOS_DE_DATOS].Venta(vent_cliente);
CREATE INDEX IX_Venta_agente             ON [BASADOS_DE_DATOS].Venta(vent_agente);
CREATE INDEX IX_Venta_canal              ON [BASADOS_DE_DATOS].Venta(vent_canal_venta);
CREATE INDEX IX_Solicitud_cliente        ON [BASADOS_DE_DATOS].Solicitud(soli_cliente);
CREATE INDEX IX_Solicitud_agente         ON [BASADOS_DE_DATOS].Solicitud(soli_agente);
CREATE INDEX IX_Propuesta_solicitud      ON [BASADOS_DE_DATOS].Propuesta(prop_solicitud);
CREATE INDEX IX_Propuesta_agente         ON [BASADOS_DE_DATOS].Propuesta(prop_agente);
CREATE INDEX IX_Propuesta_estado         ON [BASADOS_DE_DATOS].Propuesta(prop_estado);
CREATE INDEX IX_Encuesta_agente          ON [BASADOS_DE_DATOS].Encuesta(encu_agente);
CREATE INDEX IX_Aspecto_encuesta         ON [BASADOS_DE_DATOS].Aspecto(aspe_encuesta);
CREATE INDEX IX_VentaPropuesta_venta     ON [BASADOS_DE_DATOS].Venta_Propuesta(vpro_venta);
CREATE INDEX IX_ItemVentaVuelo_venta     ON [BASADOS_DE_DATOS].ItemVentaVuelo(item_venta);
CREATE INDEX IX_ItemVentaHosp_venta      ON [BASADOS_DE_DATOS].ItemVentaHospedaje(item_venta);
CREATE INDEX IX_ItemVentaExc_venta       ON [BASADOS_DE_DATOS].ItemVentaExcursion(item_venta);
CREATE INDEX IX_ItemPropVuelo_propuesta  ON [BASADOS_DE_DATOS].ItemPropuestaVuelo(item_propuesta);
CREATE INDEX IX_ItemPropHosp_propuesta   ON [BASADOS_DE_DATOS].ItemPropuestaHospedaje(item_propuesta);
GO

/* ===========================================================================
   STORED PROCEDURES DE MIGRACION (uno por tabla)
   La migracion de datos desde gd_esquema.Maestra se encapsula en un SP por
   tabla. Se ejecutan al final, en orden de dependencias, mediante EXEC.
   =========================================================================== */

-- Migra Pais: unifica los nombres de pais de aeropuertos, aerolineas y hospedajes
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Pais AS
BEGIN
    WITH PaisesUnificados AS (
        SELECT Aeropuerto_Salida_Pais AS Nombre_Pais
        FROM gd_esquema.Maestra
        WHERE Aeropuerto_Salida_Pais IS NOT NULL
        UNION
        SELECT Aeropuerto_Llegada_Pais AS Nombre_Pais
        FROM gd_esquema.Maestra
        WHERE Aeropuerto_Llegada_Pais IS NOT NULL
        UNION
        SELECT Aerolinea_Pais AS Nombre_Pais
        FROM gd_esquema.Maestra
        WHERE Aerolinea_Pais IS NOT NULL
        UNION
        SELECT Hospedaje_Pais AS Nombre_Pais
        FROM gd_esquema.Maestra
        WHERE Hospedaje_Pais IS NOT NULL
    )
    INSERT INTO [BASADOS_DE_DATOS].Pais (pais_nombre)
    SELECT DISTINCT Nombre_Pais COLLATE Latin1_General_CI_AI FROM PaisesUnificados;
END
GO

-- Migra CanalVenta
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_CanalVenta AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].CanalVenta (cana_nombre)
    SELECT DISTINCT Venta_Canal_Venta FROM gd_esquema.Maestra
    WHERE Venta_Canal_Venta IS NOT NULL;
END
GO

-- Migra MedioPago
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_MedioPago AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].MedioPago (medi_nombre)
    SELECT DISTINCT Venta_Medio_Pago FROM gd_esquema.Maestra
    WHERE Venta_Medio_Pago IS NOT NULL;
END
GO

-- Migra Alianza
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Alianza AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Alianza (alia_nombre)
    SELECT DISTINCT Aerolinea_Alianza FROM gd_esquema.Maestra
    WHERE Aerolinea_Alianza IS NOT NULL;
END
GO

-- Migra EstadoPropuesta
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_EstadoPropuesta AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].EstadoPropuesta (esta_nombre)
    SELECT DISTINCT Propuesta_Estado FROM gd_esquema.Maestra
    WHERE Propuesta_Estado IS NOT NULL;
END
GO

-- Migra Ciudad: relaciona cada ciudad con su pais
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Ciudad AS
BEGIN
    WITH Ciudad_Pais AS (
        SELECT DISTINCT Aeropuerto_Salida_Ciudad AS ciudad, Aeropuerto_Salida_Pais AS pais FROM gd_esquema.Maestra
        WHERE Aeropuerto_Salida_Ciudad IS NOT NULL AND Aeropuerto_Salida_Pais IS NOT NULL
        UNION
        SELECT DISTINCT Aeropuerto_Llegada_Ciudad AS ciudad, Aeropuerto_Llegada_Pais AS pais FROM gd_esquema.Maestra
        WHERE Aeropuerto_Llegada_Ciudad IS NOT NULL AND Aeropuerto_Llegada_Pais IS NOT NULL
        UNION
        SELECT DISTINCT Hospedaje_Ciudad AS ciudad, Hospedaje_Pais AS pais FROM gd_esquema.Maestra
        WHERE Hospedaje_Ciudad IS NOT NULL AND Hospedaje_Pais IS NOT NULL
    )
    INSERT INTO [BASADOS_DE_DATOS].Ciudad
    SELECT ciudad, pais_codigo FROM Ciudad_Pais
    LEFT JOIN [BASADOS_DE_DATOS].Pais ON pais COLLATE Latin1_General_CI_AI = pais_nombre COLLATE Latin1_General_CI_AI
    WHERE pais_codigo IS NOT NULL;
END
GO

-- Migra Proveedor
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Proveedor AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Proveedor
    SELECT DISTINCT Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono FROM gd_esquema.Maestra
    WHERE Proveedor_Nombre IS NOT NULL;
END
GO

-- Migra Provincia: unifica las provincias de agencias, agentes y clientes
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Provincia AS
BEGIN
    WITH ProvinciasUnificadas AS (
        SELECT Agencia_Provincia AS Nombre_Provincia
        FROM gd_esquema.Maestra
        WHERE Agencia_Provincia IS NOT NULL
        UNION
        SELECT Agente_Provincia AS Nombre_Provincia
        FROM gd_esquema.Maestra
        WHERE Agente_Provincia IS NOT NULL
        UNION
        SELECT Cliente_Provincia AS Nombre_Provincia
        FROM gd_esquema.Maestra
        WHERE Cliente_Provincia IS NOT NULL
    )
    INSERT INTO [BASADOS_DE_DATOS].Provincia
    SELECT DISTINCT Nombre_Provincia FROM ProvinciasUnificadas;
END
GO

-- Migra Localidad: relaciona cada localidad con su provincia
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Localidad AS
BEGIN
    WITH Provincia_Localidad AS (
        SELECT DISTINCT Agencia_Provincia AS provincia, Agencia_Localidad AS localidad FROM gd_esquema.Maestra
        WHERE Agencia_Provincia IS NOT NULL AND Agencia_Localidad IS NOT NULL
        UNION
        SELECT DISTINCT Agente_Provincia AS provincia, Agente_Localidad AS localidad FROM gd_esquema.Maestra
        WHERE Agente_Provincia IS NOT NULL AND Agente_Localidad IS NOT NULL
        UNION
        SELECT DISTINCT Cliente_Provincia AS provincia, Cliente_Localidad AS localidad FROM gd_esquema.Maestra
        WHERE Cliente_Provincia IS NOT NULL AND Cliente_Localidad IS NOT NULL
    )
    INSERT INTO [BASADOS_DE_DATOS].Localidad
    SELECT DISTINCT localidad, prov_codigo FROM Provincia_Localidad
    LEFT JOIN [BASADOS_DE_DATOS].Provincia ON provincia = prov_nombre;
END
GO

-- Migra Aerolinea
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Aerolinea AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Aerolinea
    SELECT DISTINCT Aerolinea_Codigo, Aerolinea_Nombre, pais_codigo, alia_codigo FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Pais ON Aerolinea_Pais COLLATE Latin1_General_CI_AI = pais_nombre COLLATE Latin1_General_CI_AI
    LEFT JOIN [BASADOS_DE_DATOS].Alianza ON Aerolinea_Alianza = alia_nombre
    WHERE Aerolinea_Codigo IS NOT NULL;
END
GO

-- Migra Aeropuerto: unifica aeropuertos de salida y llegada
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Aeropuerto AS
BEGIN
    WITH AeropuertosUnificados AS (
        SELECT Aeropuerto_Llegada_Codigo AS aeropuerto_codigo,
            Aeropuerto_Llegada_Descripcion AS aeropuerto_descripcion,
            Aeropuerto_Llegada_Ciudad AS aeropuerto_ciudad,
            Aeropuerto_Llegada_Pais AS aeropuerto_pais
        FROM gd_esquema.Maestra
        WHERE Aeropuerto_Llegada_Codigo IS NOT NULL
        UNION
        SELECT Aeropuerto_Salida_Codigo AS aeropuerto_codigo,
            Aeropuerto_Salida_Descripcion AS aeropuerto_descripcion,
            Aeropuerto_Salida_Ciudad AS aeropuerto_ciudad,
            Aeropuerto_Salida_Pais AS aeropuerto_pais
        FROM gd_esquema.Maestra
        WHERE Aeropuerto_Salida_Codigo IS NOT NULL
    )
    INSERT INTO [BASADOS_DE_DATOS].Aeropuerto
    SELECT DISTINCT aeropuerto_codigo, aeropuerto_descripcion, ciud_codigo FROM AeropuertosUnificados
    LEFT JOIN [BASADOS_DE_DATOS].Ciudad ON aeropuerto_ciudad = ciud_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Pais ON ciud_pais = pais_codigo
    WHERE pais_nombre COLLATE Latin1_General_CI_AI = aeropuerto_pais COLLATE Latin1_General_CI_AI;
END
GO

-- Migra Hospedaje
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Hospedaje AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Hospedaje(
        hosp_ciudad,
        hosp_nombre,
        hosp_direccion,
        hosp_incluye_desayuno,
        hosp_hora_check_in,
        hosp_hora_check_out
    )
    SELECT DISTINCT ciud_codigo, Hospedaje_Nombre, Hospedaje_Direccion, Hospedaje_Incluye_Desayuno, Hospedaje_Check_In, Hospedaje_Check_Out
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Ciudad ON Hospedaje_Ciudad = ciud_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Pais ON ciud_pais = pais_codigo
    WHERE Hospedaje_Nombre IS NOT NULL AND Hospedaje_Pais COLLATE Latin1_General_CI_AI = pais_nombre COLLATE Latin1_General_CI_AI;
END
GO

-- Migra Excursion
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Excursion AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Excursion(
        excu_nombre,
        excu_descripcion,
        excu_horario,
        excu_duracion,
        excu_precio,
        excu_proveedor
    )
    SELECT DISTINCT Excursion_Nombre, Excursion_Descripcion, Excursion_Horario, Excursion_Duracion, Excursion_Precio, prov_codigo
    FROM gd_esquema.Maestra LEFT JOIN [BASADOS_DE_DATOS].Proveedor ON Proveedor_Nombre = prov_nombre
    WHERE Excursion_Nombre IS NOT NULL;
END
GO

-- Migra Agencia
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Agencia AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Agencia
    SELECT DISTINCT Agencia_Nro_Agencia, Agencia_Direccion, Agencia_Telefono, Agencia_Mail, loca_codigo
    FROM gd_esquema.Maestra LEFT JOIN [BASADOS_DE_DATOS].Localidad ON Agencia_Localidad = loca_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Provincia ON loca_provincia = prov_codigo
    WHERE Agencia_Nro_Agencia IS NOT NULL AND prov_nombre = Agencia_Provincia;
END
GO

-- Migra HabitacionHospedaje
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_HabitacionHospedaje AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].HabitacionHospedaje
    (habi_hospedaje,
    habi_nombre,
    habi_descripcion,
    habi_precio_noche
    )
    SELECT DISTINCT hosp_codigo, Habitacion_Nombre, Habitacion_Descripcion, Habitacion_Precio_Noche
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Ciudad ON Hospedaje_Ciudad = ciud_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Pais ON Hospedaje_Pais COLLATE Latin1_General_CI_AI = pais_nombre COLLATE Latin1_General_CI_AI
    LEFT JOIN [BASADOS_DE_DATOS].Hospedaje
    ON Hospedaje_Nombre = hosp_nombre AND Hospedaje_Direccion = hosp_direccion
    AND Hospedaje_Check_In = hosp_hora_check_in AND Hospedaje_Check_Out = hosp_hora_check_out
    AND Hospedaje_Incluye_Desayuno = hosp_incluye_desayuno
    AND ciud_codigo = hosp_ciudad
    WHERE ciud_pais = pais_codigo AND Habitacion_Nombre IS NOT NULL;
END
GO

-- Migra Vuelo
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Vuelo AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Vuelo(
        vuel_precio,
        vuel_aeropuerto_salida,
        vuel_aeropuerto_llegada,
        vuel_fecha_salida,
        vuel_horario_salida,
        vuel_fecha_llegada,
        vuel_horario_llegada,
        vuel_aerolinea,
        vuel_incluye_carry,
        vuel_incluye_valija
    )
    SELECT DISTINCT Vuelo_Precio, Aeropuerto_Salida_Codigo, Aeropuerto_Llegada_Codigo,
    Vuelo_Fecha_Salida, Vuelo_Horario_Salida, Vuelo_Fecha_Llegada, Vuelo_Horario_Llegada,
    Aerolinea_Codigo, Vuelo_Incluye_Carry, Vuelo_Incluye_Valija
    FROM gd_esquema.Maestra
    WHERE Vuelo_Precio IS NOT NULL;
END
GO

-- Migra Agente
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Agente AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Agente
        (agen_legajo,
        agen_agencia,
        agen_nombre,
        agen_apellido,
        agen_dni,
        agen_fecha_nacimiento,
        agen_telefono,
        agen_mail,
        agen_direccion,
        agen_localidad)
    SELECT DISTINCT Agente_Legajo, Agencia_Nro_Agencia, Agente_Nombre, Agente_Apellido, Agente_Dni,
    Agente_Fecha_Nac, Agente_Telefono, Agente_Mail, Agente_Direccion, loca_codigo
    FROM gd_esquema.Maestra LEFT JOIN [BASADOS_DE_DATOS].Localidad ON Agente_Localidad = loca_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Provincia ON loca_provincia = prov_codigo
    WHERE Agente_Legajo IS NOT NULL AND Agente_Provincia = prov_nombre;
END
GO

-- Migra Cliente
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Cliente AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Cliente(
        clie_dni,
        clie_nombre,
        clie_apellido,
        clie_telefono,
        clie_mail,
        clie_direccion,
        clie_fecha_nacimiento,
        clie_localidad)
    SELECT DISTINCT Cliente_Dni, Cliente_Nombre, Cliente_Apellido,
    Cliente_Tel, Cliente_Mail, Cliente_Direccion, Cliente_Fecha_Nac, loca_codigo
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Localidad ON Cliente_Localidad = loca_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Provincia ON loca_provincia = prov_codigo
    WHERE Cliente_Dni IS NOT NULL AND Cliente_Provincia = prov_nombre;
END
GO

-- Migra Solicitud
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Solicitud AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Solicitud(
        soli_numero,
        soli_cliente,
        soli_fecha,
        soli_inicio_tentativa,
        soli_fin_tentativa,
        soli_cant_pas,
        soli_observaciones,
        soli_presupuesto_estimado,
        soli_agente
    )
    SELECT DISTINCT Solicitud_Nro_Solicitud, clie_codigo, Solicitud_Fecha_Solicitud,
    Solicitud_Fecha_Inicio_Tentativa, Solicitud_Fecha_Fin_Tentativa, Solicitud_Cant_Pax,
    Solicitud_Observaciones, Solicitud_Presupuesto_Estimado, Agente_Legajo
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Cliente ON Cliente_Dni = clie_dni
    AND Cliente_Nombre = clie_nombre
    AND Cliente_Apellido = clie_apellido
    AND Cliente_Direccion = clie_direccion
    WHERE Solicitud_Nro_Solicitud IS NOT NULL;
END
GO

-- Migra Venta
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Venta AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Venta(
        vent_codigo,
        vent_cliente,
        vent_agente,
        vent_fecha,
        vent_canal_venta,
        vent_subtotal,
        vent_descuento,
        vent_importe_total,
        vent_medio_pago
    )
    SELECT DISTINCT Venta_Nro_Venta, clie_codigo, Agente_Legajo,
    Venta_Fecha_Venta, cana_codigo, Venta_Subtotal, Venta_Descuento,
    Venta_Importe_Total, medi_codigo
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Cliente ON Cliente_Dni = clie_dni
    AND Cliente_Nombre = clie_nombre
    AND Cliente_Apellido = clie_apellido
    AND Cliente_Direccion = clie_direccion
    LEFT JOIN [BASADOS_DE_DATOS].CanalVenta ON Venta_Canal_Venta = cana_nombre
    LEFT JOIN [BASADOS_DE_DATOS].MedioPago ON Venta_Medio_Pago = medi_nombre
    WHERE Venta_Nro_Venta IS NOT NULL;
END
GO

-- Migra Encuesta
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Encuesta AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Encuesta
    SELECT DISTINCT Encuesta_Codigo_Encuesta, Encuesta_Fecha_Encuesta, clie_codigo, Agente_Legajo, Encuesta_Comentarios
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Cliente ON Cliente_Dni = clie_dni
    AND Cliente_Nombre = clie_nombre
    AND Cliente_Apellido = clie_apellido
    AND Cliente_Direccion = clie_direccion
    WHERE Encuesta_Codigo_Encuesta IS NOT NULL;
END
GO

-- Migra CiudadSolicitud
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_CiudadSolicitud AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].CiudadSolicitud
    SELECT DISTINCT Solicitud_Nro_Solicitud, Detalle_Solicitud_Ciudad, Detalle_Solicitud_Cant_Dias_Aprox, Detalle_Solicitud_Observaciones
    FROM gd_esquema.Maestra
    WHERE Detalle_Solicitud_Ciudad IS NOT NULL;
END
GO

-- Migra Propuesta
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Propuesta AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Propuesta(
        prop_codigo,
        prop_solicitud,
        prop_agente,
        prop_fecha_emision,
        prop_vigencia,
        prop_fecha_desde,
        prop_fecha_hasta,
        prop_subtotal,
        prop_descuento,
        prop_importe_total,
        prop_estado
    )
    SELECT DISTINCT Propuesta_Nro_Propuesta, Solicitud_Nro_Solicitud, Agente_Legajo,
    Propuesta_Fecha_Emision, Propuesta_Vigencia_Hasta, Propuesta_Fecha_Desde,
    Propuesta_Fecha_Hasta, Propuesta_Subtotal, Propuesta_Descuento,
    Propuesta_Importe_Total, esta_codigo
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].EstadoPropuesta ON Propuesta_Estado = esta_nombre
    WHERE Propuesta_Nro_Propuesta IS NOT NULL;
END
GO

-- Migra Aspecto
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Aspecto AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Aspecto
    SELECT DISTINCT Encuesta_Codigo_Encuesta, Aspecto_Aspecto, Detalle_Encuesta_Puntaje
    FROM gd_esquema.Maestra
    WHERE Aspecto_Aspecto IS NOT NULL;
END
GO

-- Migra Venta_Propuesta (relacion venta <-> propuesta)
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_Venta_Propuesta AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].Venta_Propuesta
    SELECT DISTINCT Venta_Nro_Venta, Propuesta_Nro_Propuesta
    FROM gd_esquema.Maestra
    WHERE Venta_Nro_Venta IS NOT NULL AND Propuesta_Nro_Propuesta IS NOT NULL;
END
GO

-- Migra ItemVentaVuelo
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_ItemVentaVuelo AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].ItemVentaVuelo(
        item_venta,
        item_vuelo,
        item_precio_unitario,
        vuel_cant_pasajes,
        item_cod_reserva,
        item_subtotal
    )
    SELECT DISTINCT Venta_Nro_Venta, vuel_codigo, Detalle_Venta_Vuelo_Precio_Unitario, Detalle_Venta_Vuelo_Cantidad_Pasajes,
    Detalle_Venta_Vuelo_Cod_Reserva, Detalle_Venta_Vuelo_Subtotal
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Vuelo ON Aeropuerto_Salida_Codigo = vuel_aeropuerto_salida
    AND Aeropuerto_Llegada_Codigo = vuel_aeropuerto_llegada AND Aerolinea_Codigo = vuel_aerolinea
    AND Vuelo_Precio = vuel_precio AND Vuelo_Fecha_Salida = vuel_fecha_salida AND Vuelo_Fecha_Llegada = vuel_fecha_llegada
    AND Vuelo_Horario_Salida = vuel_horario_salida
    AND Vuelo_Horario_Llegada = vuel_horario_llegada
    AND Vuelo_Incluye_Carry = vuel_incluye_carry AND Vuelo_Incluye_Valija = vuel_incluye_valija
    WHERE Venta_Nro_Venta IS NOT NULL AND vuel_codigo IS NOT NULL;
END
GO

-- Migra ItemVentaHospedaje
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_ItemVentaHospedaje AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].ItemVentaHospedaje(
        item_venta,
        item_hospedaje,
        item_habitacion,
        item_desde,
        item_hasta,
        item_hospedaje_cantidad,
        item_precio_unitario,
        item_subtotal,
        item_cod_reserva
    )
    SELECT DISTINCT Venta_Nro_Venta, hosp_codigo, habi_codigo_habitacion, Detalle_Venta_Hospedaje_Fecha_Desde,
    Detalle_Venta_Hospedaje_Fecha_Hasta, Detalle_Venta_Hospedaje_Cantidad,
    Detalle_Venta_Hospedaje_Precio_Unitario, Detalle_Venta_Hospedaje_Subtotal,
    Detalle_Venta_Hospedaje_Cod_Reserva
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Hospedaje ON Hospedaje_Direccion = hosp_direccion
    LEFT JOIN [BASADOS_DE_DATOS].Ciudad ON Hospedaje_Ciudad = ciud_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Pais ON Hospedaje_Pais COLLATE Latin1_General_CI_AI = pais_nombre COLLATE Latin1_General_CI_AI AND pais_codigo = ciud_pais
    LEFT JOIN [BASADOS_DE_DATOS].HabitacionHospedaje ON hosp_codigo = habi_hospedaje AND Habitacion_Nombre = habi_nombre
    AND Habitacion_Descripcion = habi_descripcion AND Habitacion_Precio_Noche = habi_precio_noche
    WHERE ciud_codigo = hosp_ciudad AND Venta_Nro_Venta IS NOT NULL AND hosp_codigo IS NOT NULL
    AND Hospedaje_Nombre = hosp_nombre AND Hospedaje_Check_In = hosp_hora_check_in
    AND Hospedaje_Check_Out = hosp_hora_check_out AND Hospedaje_Incluye_Desayuno = hosp_incluye_desayuno;
END
GO

-- Migra ItemVentaExcursion
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_ItemVentaExcursion AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].ItemVentaExcursion(
        item_venta,
        item_excursion,
        item_fecha,
        item_cant,
        item_precio_unitario,
        item_subtotal,
        item_cod_reserva
    )
    SELECT DISTINCT Venta_Nro_Venta, excu_codigo, Detalle_Venta_Excursion_Fecha_Reserva,
    Detalle_Venta_Excursion_Cant, Detalle_Venta_Excursion_Precio_Unitario, Detalle_Venta_Excursion_Subtotal,
    Detalle_Venta_Excursion_Cod_Reserva
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Excursion ON Excursion_Nombre = excu_nombre
    AND Excursion_Descripcion = excu_descripcion AND Excursion_Horario = excu_horario
    AND Excursion_Duracion = excu_duracion AND Excursion_Precio = excu_precio
    WHERE Venta_Nro_Venta IS NOT NULL AND excu_codigo IS NOT NULL;
END
GO

-- Migra ItemPropuestaVuelo
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_ItemPropuestaVuelo AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].ItemPropuestaVuelo
    SELECT DISTINCT Propuesta_Nro_Propuesta, vuel_codigo, Detalle_Propuesta_Vuelo_Cant_Pasajes,
    Detalle_Propuesta_Vuelo_Precio, Detalle_Propuesta_Vuelo_Subtotal
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Vuelo ON Aeropuerto_Salida_Codigo = vuel_aeropuerto_salida AND Aeropuerto_Llegada_Codigo = vuel_aeropuerto_llegada
    AND Aerolinea_Codigo = vuel_aerolinea
    WHERE Vuelo_Precio = vuel_precio AND Vuelo_Fecha_Salida = vuel_fecha_salida AND Vuelo_Fecha_Llegada = vuel_fecha_llegada
    AND Vuelo_Horario_Salida = vuel_horario_salida AND Vuelo_Horario_Llegada = vuel_horario_llegada
    AND Vuelo_Incluye_Carry = vuel_incluye_carry AND Vuelo_Incluye_Valija = vuel_incluye_valija
    AND Propuesta_Nro_Propuesta IS NOT NULL AND vuel_codigo IS NOT NULL AND Detalle_Propuesta_Vuelo_Precio IS NOT NULL;
END
GO

-- Migra ItemPropuestaHospedaje
CREATE PROCEDURE [BASADOS_DE_DATOS].sp_migrar_ItemPropuestaHospedaje AS
BEGIN
    INSERT INTO [BASADOS_DE_DATOS].ItemPropuestaHospedaje(
        item_propuesta,
        item_hospedaje,
        item_habitacion,
        item_ingreso,
        item_egreso,
        item_cant_habitaciones,
        item_precio_unitario,
        item_subtotal
    )
    SELECT DISTINCT Propuesta_Nro_Propuesta, hosp_codigo, habi_codigo_habitacion,
    Detalle_Propuesta_Hospedaje_Fecha_Desde, Detalle_Propuesta_Hospedaje_Fecha_Hasta,
    Detalle_Propuesta_Hospedaje_Cant, Detalle_Propuesta_Hospedaje_Precio,
    Detalle_Propuesta_Hospedaje_Subtotal
    FROM gd_esquema.Maestra
    LEFT JOIN [BASADOS_DE_DATOS].Hospedaje ON Hospedaje_Direccion = hosp_direccion
    LEFT JOIN [BASADOS_DE_DATOS].Ciudad ON Hospedaje_Ciudad = ciud_nombre
    LEFT JOIN [BASADOS_DE_DATOS].Pais ON Hospedaje_Pais COLLATE Latin1_General_CI_AI = pais_nombre COLLATE Latin1_General_CI_AI AND pais_codigo = ciud_pais
    LEFT JOIN [BASADOS_DE_DATOS].HabitacionHospedaje ON hosp_codigo = habi_hospedaje AND Habitacion_Nombre = habi_nombre
    AND Habitacion_Descripcion = habi_descripcion AND Habitacion_Precio_Noche = habi_precio_noche
    WHERE ciud_codigo = hosp_ciudad AND Propuesta_Nro_Propuesta IS NOT NULL AND hosp_codigo IS NOT NULL
    AND Detalle_Propuesta_Hospedaje_Precio IS NOT NULL
    AND Hospedaje_Nombre = hosp_nombre AND Hospedaje_Check_In = hosp_hora_check_in
    AND Hospedaje_Check_Out = hosp_hora_check_out AND Hospedaje_Incluye_Desayuno = hosp_incluye_desayuno;
END
GO

/* ===========================================================================
   EJECUCION DE LA MIGRACION
   Se ejecutan los SP en orden de dependencias (primero tablas maestras,
   luego transaccionales, y por ultimo las tablas de detalle/cruce).
   =========================================================================== */

EXEC [BASADOS_DE_DATOS].sp_migrar_Pais;
EXEC [BASADOS_DE_DATOS].sp_migrar_CanalVenta;
EXEC [BASADOS_DE_DATOS].sp_migrar_MedioPago;
EXEC [BASADOS_DE_DATOS].sp_migrar_Alianza;
EXEC [BASADOS_DE_DATOS].sp_migrar_EstadoPropuesta;
EXEC [BASADOS_DE_DATOS].sp_migrar_Ciudad;
EXEC [BASADOS_DE_DATOS].sp_migrar_Proveedor;
EXEC [BASADOS_DE_DATOS].sp_migrar_Provincia;
EXEC [BASADOS_DE_DATOS].sp_migrar_Localidad;
EXEC [BASADOS_DE_DATOS].sp_migrar_Aerolinea;
EXEC [BASADOS_DE_DATOS].sp_migrar_Aeropuerto;
EXEC [BASADOS_DE_DATOS].sp_migrar_Hospedaje;
EXEC [BASADOS_DE_DATOS].sp_migrar_Excursion;
EXEC [BASADOS_DE_DATOS].sp_migrar_Agencia;
EXEC [BASADOS_DE_DATOS].sp_migrar_HabitacionHospedaje;
EXEC [BASADOS_DE_DATOS].sp_migrar_Vuelo;
EXEC [BASADOS_DE_DATOS].sp_migrar_Agente;
EXEC [BASADOS_DE_DATOS].sp_migrar_Cliente;
EXEC [BASADOS_DE_DATOS].sp_migrar_Solicitud;
EXEC [BASADOS_DE_DATOS].sp_migrar_Venta;
EXEC [BASADOS_DE_DATOS].sp_migrar_Encuesta;
EXEC [BASADOS_DE_DATOS].sp_migrar_CiudadSolicitud;
EXEC [BASADOS_DE_DATOS].sp_migrar_Propuesta;
EXEC [BASADOS_DE_DATOS].sp_migrar_Aspecto;
EXEC [BASADOS_DE_DATOS].sp_migrar_Venta_Propuesta;
EXEC [BASADOS_DE_DATOS].sp_migrar_ItemVentaVuelo;
EXEC [BASADOS_DE_DATOS].sp_migrar_ItemVentaHospedaje;
EXEC [BASADOS_DE_DATOS].sp_migrar_ItemVentaExcursion;
EXEC [BASADOS_DE_DATOS].sp_migrar_ItemPropuestaVuelo;
EXEC [BASADOS_DE_DATOS].sp_migrar_ItemPropuestaHospedaje;
GO
