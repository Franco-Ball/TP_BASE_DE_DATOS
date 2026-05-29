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

WITH PaisesUnificados AS (

    SELECT Aeropuerto_Salida_Pais  AS Nombre_Pais 
    FROM gd_esquema.Maestra 
    WHERE Aeropuerto_Salida_Pais IS NOT NULL
    UNION 
    SELECT Aeropuerto_Llegada_Pais  AS Nombre_Pais 
    FROM gd_esquema.Maestra 
    WHERE Aeropuerto_Llegada_Pais IS NOT NULL
    union 
    SELECT Aerolinea_Pais  AS  Nombre_Pais 
    FROM gd_esquema.Maestra 
    WHERE Aerolinea_Pais IS NOT NULL
    union
    SELECT Hospedaje_Pais  AS Nombre_Pais 
    FROM gd_esquema.Maestra 
    WHERE Hospedaje_Pais IS NOT NULL

)

insert into [BASADOS_DE_DATOS].Pais (pais_nombre)
select distinct Nombre_Pais from PaisesUnificados

insert into [BASADOS_DE_DATOS].CanalVenta (cana_nombre)
select distinct Venta_Canal_Venta from gd_esquema.Maestra
where Venta_Canal_Venta is not null

insert into [BASADOS_DE_DATOS].MedioPago (medi_nombre)
select distinct Venta_Medio_Pago from gd_esquema.Maestra
where Venta_Medio_Pago is not null

insert into [BASADOS_DE_DATOS].Alianza (alia_nombre)
select distinct Aerolinea_Alianza from gd_esquema.Maestra
where Aerolinea_Alianza is not null

insert into [BASADOS_DE_DATOS].EstadoPropuesta (esta_nombre)
select distinct Propuesta_Estado from gd_esquema.Maestra
where Propuesta_Estado is not null;

with Ciudad_Pais AS (
    select distinct Aeropuerto_Salida_Ciudad as ciudad, Aeropuerto_Salida_Pais as pais from gd_esquema.Maestra
    where Aeropuerto_Salida_Ciudad is not null and Aeropuerto_Salida_Pais is not null
    union 
    select distinct Aeropuerto_Llegada_Ciudad as ciudad, Aeropuerto_Llegada_Pais as pais from gd_esquema.Maestra
    where Aeropuerto_Llegada_Ciudad is not null and Aeropuerto_Llegada_Pais is not null
    union
    select distinct Hospedaje_Ciudad as ciudad, Hospedaje_Pais as pais from gd_esquema.Maestra
    where Hospedaje_Ciudad is not null and Hospedaje_Pais is not null
)

insert into [BASADOS_DE_DATOS].Ciudad
select ciudad, pais_codigo from Ciudad_Pais left join [BASADOS_DE_DATOS].Pais on pais=pais_nombre
where pais_codigo is not null

insert into [BASADOS_DE_DATOS].Proveedor
select distinct Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono from gd_esquema.Maestra
where Proveedor_Nombre is not null;


WITH ProvinciasUnificadas AS (

    SELECT Agencia_Provincia AS Nombre_Provincia
    FROM gd_esquema.Maestra 
    WHERE Agencia_Provincia IS NOT NULL
    UNION 
    SELECT Agente_Provincia AS Nombre_Provincia 
    FROM gd_esquema.Maestra 
    WHERE Agente_Provincia IS NOT NULL
    union 
    SELECT Cliente_Provincia AS  Nombre_Provincia 
    FROM gd_esquema.Maestra 
    WHERE Cliente_Provincia IS NOT NULL
)
insert into [BASADOS_DE_DATOS].Provincia
select distinct Nombre_Provincia from ProvinciasUnificadas;

with Provincia_Localidad as (
    select distinct Agencia_Provincia as provincia, Agencia_Localidad as localidad from gd_esquema.Maestra
    where Agencia_Provincia is not null and Agencia_Localidad is not null
    union 
    select distinct Agente_Provincia as provincia, Agente_Localidad as localidad from gd_esquema.Maestra
    where Agente_Provincia is not null and Agente_Localidad is not null
    union
    select distinct Cliente_Provincia as provincia, Cliente_Localidad as localidad from gd_esquema.Maestra
    where Cliente_Provincia is not null and Cliente_Localidad is not null
)

insert into [BASADOS_DE_DATOS].Localidad
select distinct localidad, prov_codigo from Provincia_Localidad left join [BASADOS_DE_DATOS].Provincia on provincia = prov_nombre

insert into [BASADOS_DE_DATOS].Aerolinea
select distinct Aerolinea_Codigo, Aerolinea_Nombre, pais_codigo, alia_codigo from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].Pais on Aerolinea_Pais=pais_nombre
left join [BASADOS_DE_DATOS].Alianza on Aerolinea_Alianza = alia_nombre
where Aerolinea_Codigo is not null;

with AeropuertosUnificados as (
    SELECT Aeropuerto_Llegada_Codigo as aeropuerto_codigo,
        Aeropuerto_Llegada_Descripcion as aeropuerto_descripcion,
        Aeropuerto_Llegada_Ciudad as aeropuerto_ciudad,
        Aeropuerto_Llegada_Pais as aeropuerto_pais
    FROM gd_esquema.Maestra 
    WHERE Aeropuerto_Llegada_Codigo IS NOT NULL
    UNION 
    SELECT Aeropuerto_Salida_Codigo as aeropuerto_codigo,
        Aeropuerto_Salida_Descripcion as aeropuerto_descripcion,
        Aeropuerto_Salida_Ciudad as aeropuerto_ciudad,
        Aeropuerto_Salida_Pais as aeropuerto_pais
    FROM gd_esquema.Maestra 
    WHERE Aeropuerto_Salida_Codigo IS NOT NULL
)

insert into [BASADOS_DE_DATOS].Aeropuerto
select distinct aeropuerto_codigo, aeropuerto_descripcion, ciud_codigo from AeropuertosUnificados
left join [BASADOS_DE_DATOS].Ciudad on aeropuerto_ciudad=ciud_nombre
left join [BASADOS_DE_DATOS].Pais on ciud_pais = pais_codigo
where pais_nombre=aeropuerto_pais

insert into [BASADOS_DE_DATOS].Hospedaje(
    hosp_ciudad, 
    hosp_nombre, 
    hosp_direccion, 
    hosp_incluye_desayuno, 
    hosp_hora_check_in, 
    hosp_hora_check_out
)
select distinct ciud_codigo, Hospedaje_Nombre, Hospedaje_Direccion, Hospedaje_Incluye_Desayuno, Hospedaje_Check_In, Hospedaje_Check_Out 
from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].Ciudad on Hospedaje_Ciudad=ciud_nombre
left join [BASADOS_DE_DATOS].Pais on ciud_pais = pais_codigo
where Hospedaje_Nombre is not null and Hospedaje_Pais = pais_nombre


insert into [BASADOS_DE_DATOS].Excursion(
    excu_nombre,
    excu_descripcion,
    excu_horario,
    excu_duracion,
    excu_precio,
    excu_proveedor
)
select distinct Excursion_Nombre, Excursion_Descripcion, Excursion_Horario, Excursion_Duracion, Excursion_Precio, prov_codigo
from gd_esquema.Maestra left join [BASADOS_DE_DATOS].Proveedor on Proveedor_Nombre = prov_nombre
where Excursion_Nombre is not null

insert into [BASADOS_DE_DATOS].Agencia
select distinct Agencia_Nro_Agencia, Agencia_Direccion, Agencia_Telefono, Agencia_Mail, loca_codigo
from gd_esquema.Maestra left join [BASADOS_DE_DATOS].Localidad on Agencia_Localidad=loca_nombre
left join [BASADOS_DE_DATOS].Provincia on loca_provincia = prov_codigo
where Agencia_Nro_Agencia is not null and prov_nombre = Agencia_Provincia

insert into [BASADOS_DE_DATOS].HabitacionHospedaje
(habi_hospedaje,
habi_nombre,
habi_descripcion,
habi_precio_noche
)
select distinct hosp_codigo, Habitacion_Nombre, Habitacion_Descripcion, Habitacion_Precio_Noche
from gd_esquema.Maestra 
left join [BASADOS_DE_DATOS].Ciudad on Hospedaje_Ciudad=ciud_nombre
left join [BASADOS_DE_DATOS].Pais on Hospedaje_Pais=pais_nombre
left join [BASADOS_DE_DATOS].Hospedaje 
on Hospedaje_Nombre = hosp_nombre and Hospedaje_Direccion = hosp_direccion
and Hospedaje_Check_In = hosp_hora_check_in and Hospedaje_Check_Out = hosp_hora_check_out
and Hospedaje_Incluye_Desayuno = hosp_incluye_desayuno
and ciud_codigo = hosp_ciudad
where ciud_pais=pais_codigo and Habitacion_Nombre is not null

insert into [BASADOS_DE_DATOS].Vuelo(
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
select distinct Vuelo_Precio, Aeropuerto_Salida_Codigo, Aeropuerto_Llegada_Codigo,
Vuelo_Fecha_Salida, Vuelo_Horario_Salida, Vuelo_Fecha_Llegada, Vuelo_Horario_Llegada,
Aerolinea_Codigo, Vuelo_Incluye_Carry, Vuelo_Incluye_Valija
from gd_esquema.Maestra
where Vuelo_Precio is not null

insert into [BASADOS_DE_DATOS].Agente
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
select distinct Agente_Legajo, Agencia_Nro_Agencia, Agente_Nombre, Agente_Apellido, Agente_Dni,
Agente_Fecha_Nac, Agente_Telefono, Agente_Mail, Agente_Direccion, loca_codigo
from gd_esquema.Maestra left join [BASADOS_DE_DATOS].Localidad on Agente_Localidad = loca_nombre
left join [BASADOS_DE_DATOS].Provincia on loca_provincia = prov_codigo
where Agente_Legajo is not null and Agente_Provincia = prov_nombre

insert into [BASADOS_DE_DATOS].Cliente(
    clie_dni,
    clie_nombre,
    clie_apellido,
    clie_telefono,
    clie_mail,
    clie_direccion,
    clie_fecha_nacimiento,
    clie_localidad)
select distinct Cliente_Dni, Cliente_Nombre, Cliente_Apellido,
Cliente_Tel, Cliente_Mail, Cliente_Direccion, Cliente_Fecha_Nac, loca_codigo
from gd_esquema.Maestra 
left join [BASADOS_DE_DATOS].Localidad on Cliente_Localidad = loca_nombre
left join [BASADOS_DE_DATOS].Provincia on loca_provincia = prov_codigo
where Cliente_Dni is not null and Cliente_Provincia = prov_nombre


insert into [BASADOS_DE_DATOS].Solicitud(
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
select distinct Solicitud_Nro_Solicitud, clie_codigo, Solicitud_Fecha_Solicitud,
Solicitud_Fecha_Inicio_Tentativa, Solicitud_Fecha_Fin_Tentativa, Solicitud_Cant_Pax,
Solicitud_Observaciones, Solicitud_Presupuesto_Estimado, Agente_Legajo
from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].Cliente on Cliente_Dni = clie_dni
and Cliente_Nombre = clie_nombre
and Cliente_Apellido = clie_apellido
and Cliente_Direccion = clie_direccion
where Solicitud_Nro_Solicitud is not null

insert into [BASADOS_DE_DATOS].Venta(
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
select distinct Venta_Nro_Venta, clie_codigo, Agente_Legajo,
Venta_Fecha_Venta, cana_codigo, Venta_Subtotal, Venta_Descuento,
Venta_Importe_Total, medi_codigo
from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].Cliente on Cliente_Dni = clie_dni
and Cliente_Nombre = clie_nombre
and Cliente_Apellido = clie_apellido
and Cliente_Direccion = clie_direccion 
left join [BASADOS_DE_DATOS].CanalVenta on Venta_Canal_Venta=cana_nombre
left join [BASADOS_DE_DATOS].MedioPago on Venta_Medio_Pago=medi_nombre
where Venta_Nro_Venta is not null

insert into [BASADOS_DE_DATOS].Encuesta
select distinct Encuesta_Codigo_Encuesta, Encuesta_Fecha_Encuesta, clie_codigo, Agente_Legajo, Encuesta_Comentarios
from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].Cliente on Cliente_Dni = clie_dni
and Cliente_Nombre = clie_nombre
and Cliente_Apellido = clie_apellido
and Cliente_Direccion = clie_direccion
where Encuesta_Codigo_Encuesta is not null

insert into [BASADOS_DE_DATOS].CiudadSolicitud
select distinct Solicitud_Nro_Solicitud, Detalle_Solicitud_Ciudad, Detalle_Solicitud_Cant_Dias_Aprox, Detalle_Solicitud_Observaciones
from gd_esquema.Maestra
where Detalle_Solicitud_Ciudad is not null

insert into [BASADOS_DE_DATOS].Propuesta(
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
select distinct Propuesta_Nro_Propuesta, Solicitud_Nro_Solicitud, Agente_Legajo,
Propuesta_Fecha_Emision, Propuesta_Vigencia_Hasta, Propuesta_Fecha_Desde,
Propuesta_Fecha_Hasta, Propuesta_Subtotal, Propuesta_Descuento,
Propuesta_Importe_Total, esta_codigo
from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].EstadoPropuesta on Propuesta_Estado=esta_nombre
where Propuesta_Nro_Propuesta is not null

insert into [BASADOS_DE_DATOS].Aspecto
select distinct Encuesta_Codigo_Encuesta, Aspecto_Aspecto, Detalle_Encuesta_Puntaje
from gd_esquema.Maestra
where Aspecto_Aspecto is not null

insert into [BASADOS_DE_DATOS].Venta_Propuesta
select distinct Venta_Nro_Venta, Propuesta_Nro_Propuesta
from gd_esquema.Maestra 
where Venta_Nro_Venta is not null and Propuesta_Nro_Propuesta is not null

insert into [BASADOS_DE_DATOS].ItemVentaVuelo(
    item_venta,
    item_vuelo,
    item_precio_unitario,
    vuel_cant_pasajes,
    item_cod_reserva,
    item_subtotal
)
select distinct Venta_Nro_Venta, vuel_codigo, Detalle_Venta_Vuelo_Precio_Unitario, Detalle_Venta_Vuelo_Cantidad_Pasajes,
Detalle_Venta_Vuelo_Cod_Reserva, Detalle_Venta_Vuelo_Subtotal
from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].Vuelo on Aeropuerto_Salida_Codigo = vuel_aeropuerto_salida
and Aeropuerto_Llegada_Codigo = vuel_aeropuerto_llegada and Aerolinea_Codigo=vuel_aerolinea
and Vuelo_Precio = vuel_precio and Vuelo_Fecha_Salida = vuel_fecha_salida and Vuelo_Fecha_Llegada = vuel_fecha_llegada
and Vuelo_Horario_Salida=vuel_horario_salida
and Vuelo_Horario_Llegada =  vuel_horario_llegada
and Vuelo_Incluye_Carry=vuel_incluye_carry and Vuelo_Incluye_Valija=vuel_incluye_valija
and Venta_Nro_Venta is not null and vuel_codigo is not null

insert into [BASADOS_DE_DATOS].ItemVentaHospedaje(
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
select distinct Venta_Nro_Venta, hosp_codigo, habi_codigo_habitacion, Detalle_Venta_Hospedaje_Fecha_Desde,
Detalle_Venta_Hospedaje_Fecha_Hasta, Detalle_Venta_Hospedaje_Cantidad,
Detalle_Venta_Hospedaje_Precio_Unitario, Detalle_Venta_Hospedaje_Subtotal,
Detalle_Venta_Hospedaje_Cod_Reserva
from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].Hospedaje on Hospedaje_Direccion=hosp_direccion
left join [BASADOS_DE_DATOS].Ciudad on Hospedaje_Ciudad=ciud_nombre
left join [BASADOS_DE_DATOS].Pais on Hospedaje_Pais=pais_nombre and pais_codigo=ciud_pais
left join [BASADOS_DE_DATOS].HabitacionHospedaje on hosp_codigo = habi_hospedaje and Habitacion_Nombre = habi_nombre 
and Habitacion_Descripcion = habi_descripcion and Habitacion_Precio_Noche = habi_precio_noche
where ciud_codigo = hosp_ciudad and Venta_Nro_Venta is not null and hosp_codigo is not null
and Hospedaje_Nombre = hosp_nombre and Hospedaje_Check_In = hosp_hora_check_in
and Hospedaje_Check_Out = hosp_hora_check_out and Hospedaje_Incluye_Desayuno = hosp_incluye_desayuno

insert into [BASADOS_DE_DATOS].ItemVentaExcursion(
    item_venta,
    item_excursion,
    item_fecha,
    item_cant,
    item_precio_unitario,
    item_subtotal,
    item_cod_reserva 
)
select distinct Venta_Nro_Venta, excu_codigo, Detalle_Venta_Excursion_Fecha_Reserva,
Detalle_Venta_Excursion_Cant, Detalle_Venta_Excursion_Precio_Unitario, Detalle_Venta_Excursion_Subtotal,
Detalle_Venta_Excursion_Cod_Reserva
from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].Excursion on Excursion_Nombre=excu_nombre
and Excursion_Descripcion = excu_descripcion and Excursion_Horario = excu_horario
and Excursion_Duracion=excu_duracion and Excursion_Precio=excu_precio
where Venta_Nro_Venta is not null and excu_codigo is not null

insert into [BASADOS_DE_DATOS].ItemPropuestaVuelo 
select distinct Propuesta_Nro_Propuesta, vuel_codigo, Detalle_Propuesta_Vuelo_Cant_Pasajes,
Detalle_Propuesta_Vuelo_Precio, Detalle_Propuesta_Vuelo_Subtotal
from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].Vuelo on Aeropuerto_Salida_Codigo = vuel_aeropuerto_salida and Aeropuerto_Llegada_Codigo = vuel_aeropuerto_llegada
and Aerolinea_Codigo = vuel_aerolinea
where Vuelo_Precio = vuel_precio and Vuelo_Fecha_Salida = vuel_fecha_salida and Vuelo_Fecha_Llegada = vuel_fecha_llegada
and Vuelo_Horario_Salida=vuel_horario_salida and Vuelo_Horario_Llegada=vuel_horario_llegada
and Vuelo_Incluye_Carry=vuel_incluye_carry and Vuelo_Incluye_Valija=vuel_incluye_valija
and Propuesta_Nro_Propuesta is not null and vuel_codigo is not null and Detalle_Propuesta_Vuelo_Precio is not null

insert into [BASADOS_DE_DATOS].ItemPropuestaHospedaje(
    item_propuesta,
    item_hospedaje,
    item_habitacion,
    item_ingreso,
    item_egreso,
    item_cant_habitaciones,
    item_precio_unitario,
    item_subtotal
)
select distinct Propuesta_Nro_Propuesta, hosp_codigo, habi_codigo_habitacion,
Detalle_Propuesta_Hospedaje_Fecha_Desde, Detalle_Propuesta_Hospedaje_Fecha_Hasta,
Detalle_Propuesta_Hospedaje_Cant, Detalle_Propuesta_Hospedaje_Precio,
Detalle_Propuesta_Hospedaje_Subtotal
from gd_esquema.Maestra
left join [BASADOS_DE_DATOS].Hospedaje on Hospedaje_Direccion=hosp_direccion
left join [BASADOS_DE_DATOS].Ciudad on Hospedaje_Ciudad=ciud_nombre
left join [BASADOS_DE_DATOS].Pais on Hospedaje_Pais=pais_nombre and pais_codigo=ciud_pais
left join [BASADOS_DE_DATOS].HabitacionHospedaje on hosp_codigo = habi_hospedaje and Habitacion_Nombre = habi_nombre
and Habitacion_Descripcion = habi_descripcion and Habitacion_Precio_Noche = habi_precio_noche
where ciud_codigo = hosp_ciudad and Propuesta_Nro_Propuesta is not null and hosp_codigo is not null 
and Detalle_Propuesta_Hospedaje_Precio is not null
and Hospedaje_Nombre = hosp_nombre and Hospedaje_Check_In = hosp_hora_check_in
and Hospedaje_Check_Out = hosp_hora_check_out and Hospedaje_Incluye_Desayuno = hosp_incluye_desayuno
go