# ESTRATEGIA DE RESOLUCIÓN Y DISEÑO DE BASE DE DATOS
## TRABAJO PRÁCTICO INTEGRAL - GESTIÓN DE VIAJES
### Cátedra: Gestión de Datos (GDD) - UTN-FRBA

---

**Curso:** K3151  
**Grupo:** BASADOS_DE_DATOS (Grupo 25)  
**Esquema:** `[BASADOS_DE_DATOS]`  
**Año Académico:** 2026  

**Integrantes:**
1. Ball Abalos, Franco Ivan - Legajo: 2611181  
2. Arias Solorza, Aaron Fernando - Legajo: 1632050  
3. Scquizzato, Iván - Legajo: 2226984  
4. Biotti, Guido - Legajo: 1714340  

**Email del responsable:** fballabalos@frba.utn.edu.ar  

---

## ÍNDICE
1. [Introducción y Estrategia General](#1-introducción-y-estrategia-general)
2. [Modelo Relacional y Migración Inicial](#2-modelo-relacional-y-migración-inicial)
   - [2.1 Limpieza y Preparación de Entornos (Idempotencia)](#21-limpieza-y-preparación-de-entornos-idempotencia)
   - [2.2 Decisiones de Normalización y Consistencia de Datos](#22-decisiones-de-normalización-y-consistencia-de-datos)
   - [2.3 Tratamiento de Diferencias Ortográficas y Acentos](#23-tratamiento-de-diferencias-ortográficas-y-acentos)
   - [2.4 Resolución de Clientes con mismo DNI](#24-resolución-de-clientes-con-mismo-dni)
   - [2.5 Identificación de Entidades Complejas (Hospedajes y Excursiones)](#25-identificación-de-entidades-complejas-hospedajes-y-excursiones)
3. [Modelo de Inteligencia de Negocios (BI)](#3-modelo-de-inteligencia-de-negocios-bi)
   - [3.1 Tablas de Dimensiones (Catálogos Desnormalizados)](#31-tablas-de-dimensiones-catálogos-desnormalizados)
   - [3.2 Tablas de Hechos (Facts) y Granularidad Atómica](#32-tablas-de-hechos-facts-y-granularidad-atómica)
   - [3.3 Creación de Vistas y Tableros (10 Indicadores Gerenciales)](#33-creación-de-vistas-y-tableros-10-indicadores-gerenciales)
4. [Justificación del Cumplimiento Teórico (ANSI SPARC & Kimball)](#4-justificación-del-cumplimiento-teórico-ansi-sparc--kimball)
   - [4.1 Integridad de Entidades (Primary Keys en Hechos)](#41-integridad-de-entidades-primary-keys-en-hechos)
   - [4.2 Integridad Referencial (Foreign Keys)](#42-integridad-referencial-foreign-keys)
   - [4.3 Nivel de Granularidad y Conservación de la Atomicidad](#43-nivel-de-granularidad-y-conservación-de-la-atomicidad)
   - [4.4 Modelo de Constelación de Estrellas (Star/Galaxy Schema)](#44-modelo-de-constelación-de-estrellas-stargalaxy-schema)

---

## 1. INTRODUCCIÓN Y ESTRATEGIA GENERAL

El presente documento detalla la estrategia metodológica adoptada para el desarrollo integral del Trabajo Práctico de la materia **Gestión de Datos (GDD)**. El objetivo del proyecto fue diseñar y poblar un sistema transaccional normalizado a partir de una única tabla desorganizada (*tabla maestra*) provista por la cátedra, y posteriormente estructurar un modelo de Inteligencia de Negocios (BI) que sirva de soporte analítico para un panel de control gerencial.

El desarrollo se rigió bajo los siguientes principios ineludibles:
*   **Idempotencia de Scripts:** Garantizar que tanto el script transaccional inicial como el analítico de BI puedan ejecutarse de manera repetida y segura sin generar inconsistencias ni fallos en el motor de base de datos SQL Server.
*   **Respeto por los Datos de Origen:** No modificar, suponer ni alterar de forma artificial la información original durante el proceso de migración, tal como lo indica la consigna de la cátedra.
*   **Consistencia y Normalización:** Aplicar las reglas de normalización (hasta 3NF) para el modelo OLTP y una arquitectura limpia en estrella/constelación para el modelo OLAP (BI).

---

## 2. MODELO RELACIONAL Y MIGRACIÓN INICIAL

### 2.1 Limpieza y Preparación de Entornos (Idempotencia)
Para garantizar la idempotencia en `script_creación_inicial.sql`, se incorporaron bloques de chequeo preventivo utilizando `IF OBJECT_ID` antes de cada sentencia `DROP TABLE`, `DROP VIEW` o `DROP PROCEDURE`. El esquema de base de datos se mantiene bajo el namespace `[BASADOS_DE_DATOS]`.

### 2.2 Decisiones de Normalización y Consistencia de Datos
La migración desde la tabla maestra desordenada hacia el modelo OLTP implicó desglosar la información en entidades altamente cohesivas y de bajo acoplamiento:
*   **Entidades de Ubicación:** Se estructuraron de manera jerárquica las tablas de `Pais`, `Provincia` y `Localidad` para normalizar las direcciones físicas de clientes, agencias y hoteles.
*   **Entidades de Servicios:** Se aislaron `Vuelo`, `Hospedaje` (y su relación con `HabitacionHospedaje`), y `Excursion`, permitiendo que una misma venta pueda contener N ítems de distintos servicios de forma independiente.
*   **Proceso de Negocios A Medida:** Se modelaron por separado las `Solicitud` de cotización del cliente, sus destinos (`CiudadSolicitud`), la `Propuesta` comercial emitida por el agente y el estado de aceptación final.

### 2.3 Tratamiento de Diferencias Ortográficas y Acentos
Durante el análisis de los datos originales, se detectaron inconsistencias ortográficas en nombres geográficos (ej. "Peru" y "Perú"). 
*   **Decisión de Diseño:** Con el fin de cumplir estrictamente la regla de no alterar los strings originales provistos, se trataron como países distintos con IDs primarios diferentes. Esto preserva la trazabilidad exacta de los registros originales cargados. Para búsquedas y JOINs sin conflicto de caracteres, se sacó provecho del collation por defecto de SQL Server (`COLLATE Latin1_General_CI_AI`), el cual es insensible a acentos en tiempo de ejecución.

### 2.4 Resolución de Clientes con mismo DNI
Se identificó que múltiples registros de clientes compartían el mismo DNI pero correspondían a personas distintas (nombres diferentes).
*   **Decisión de Diseño:** Para evitar colisiones y pérdida de datos históricos, se descartó el uso de la clave natural `DNI` como Clave Primaria. En su lugar, se implementó un campo subrogado autoincremental `clie_codigo` (`IDENTITY(1,1)`). Esto garantiza que cada cliente sea único en la base relacional y se asocie correctamente a sus compras y encuestas.

### 2.5 Identificación de Entidades Complejas (Hospedajes y Excursiones)
Los servicios de hospedajes y excursiones carecían de identificadores únicos en la tabla maestra.
*   **Decisión de Diseño:** Se definió que dos servicios son idénticos únicamente si coinciden en la totalidad de sus atributos descriptivos y monetarios (precio, dirección, proveedor, check-in/out). En caso de diferir en al menos un atributo, se migran al esquema OLTP como registros independientes con claves primarias generadas por el sistema (`hosp_codigo` y `excu_codigo`), resguardando la consistencia histórica.

---

## 3. MODELO DE INTELIGENCIA DE NEGOCIOS (BI)

El modelo de BI fue diseñado para estructurar y disponibilizar la información transaccional bajo un formato multidimensional (OLAP) optimizado para la lectura veloz.

### 3.1 Tablas de Dimensiones (Catálogos Desnormalizados)
Se definieron las dimensiones mínimas obligatorias y se poblaron mediante stored procedures:
*   `BI_dimension_tiempo`: Contiene la jerarquía temporal (`anyo`, `cuatrimestre`, `mes`).
*   `BI_dimension_rango_etario_cliente` y `BI_dimension_rango_etario_agente`: Segmentan la población en base a los buckets de edad definidos por la cátedra (<=25, 26-35, 36-50, >50).
*   `BI_dimension_temporada`: Asigna la fecha al trimestre correspondiente (Verano, Otoño, Invierno, Primavera) mediante la función [fn_temporada](file:///d:/Usuario/Desktop/Estudio/UTN/3%20A%C3%B1o/BD/TP_BASE_DE_DATOS/data/script_creacion_BI.sql#L84).
*   `BI_dimension_canal_de_venta`, `BI_dimension_estado_propuesta`, `BI_dimension_tipo_servicio` y `BI_dimension_detalle_aspecto`: Guardan los descriptores de negocio para las segmentaciones analíticas.

### 3.2 Tablas de Hechos (Facts) y Granularidad Atómica
Para garantizar el mejor rendimiento y apegarse al marco teórico, se crearon 5 tablas de hechos independientes:
1.  `BI_hecho_venta`: Registra las métricas financieras de facturación (`importe_total`).
2.  `BI_hecho_solicitud`: Almacena el tiempo de antelación con el que se solicitó el viaje (`dias_anticipacion`).
3.  `BI_hecho_propuesta`: Mide la efectividad del trabajo de los agentes y desvíos presupuestarios.
4.  `BI_hecho_aspecto`: Registra la valoración individual por cada pregunta de las encuestas.
5.  `BI_hecho_encuesta`: Mide la satisfacción general ponderada por atención comercial.

*   **Granularidad:** Se determinó que el grano de las tablas de hechos es **transaccional** (nivel atómico). Cada fila representa un evento único original, asegurando que no haya pérdida de información descriptiva ni imposibilidad de realizar cruces por dimensiones temporales detalladas.

### 3.3 Creación de Vistas y Tableros (10 Indicadores Gerenciales)
Se crearon las vistas analíticas (prefijo `V_BI_...`) para resolver de forma directa las consultas del tablero de control gerencial sin transitar por el modelo operacional:
*   `V_BI_Ticket_Promedio`: Mide el ticket promedio mensual agrupando por canal y rango etario.
*   `V_BI_Distribucion_Facturacion`: Calcula la participación porcentual de cada tipo de servicio en la facturación por cuatrimestre.
*   `V_BI_Ranking_Solicitudes_Temporada`: Cuenta el número de solicitudes por temporada y edad del cliente.
*   `V_BI_Anticipacion_Solicitudes`: Promedia los días de anticipación de las solicitudes por cliente y cuatrimestre.
*   `V_BI_Tasa_Aceptacion_Propuestas`: Porcentaje de propuestas aceptadas sobre las emitidas.
*   `V_BI_Cotizacion_Promedio_Temporada`: Cotización promedio de las propuestas por temporada e inicio de viaje.
*   `V_BI_Tiempo_Respuesta`: Promedio de días hábiles transcurridos entre la solicitud del cliente y la propuesta del agente.
*   `V_BI_Desvio_Presupuesto`: Desvío financiero promedio entre el presupuesto meta del cliente y la cotización real de la propuesta.
*   `V_BI_Ranking_Aspectos`: Ranking ordenado por desempeño de los atributos analizados en encuestas.
*   `V_BI_Satisfaccion_Promedio_Agente`: Puntuación histórica promedio de satisfacción de agentes en el tiempo.

---

## 4. JUSTIFICACIÓN DEL CUMPLIMIENTO TEÓRICO (ANSI SPARC & KIMBALL)

El modelo desarrollado responde rigurosamente a los lineamientos teóricos explicados en la asignatura y documentados en [GDD - Teoria.pdf](file:///d:/Usuario/Desktop/Estudio/UTN/3%20A%C3%B1o/BD/GDD%20-%20Teoria.pdf):

### 4.1 Integridad de Entidades (Primary Keys en Hechos)
*   **Teoría (Pág. 56):** *"Su PK está formada por varios campos, que son las dimensiones y son todas FKs."*
*   **Resolución en el Modelo:** Cada tabla de hechos posee una Clave Primaria compuesta formada estrictamente por las columnas que referencian a las tablas de dimensiones (todas ellas configuradas adicionalmente como `FOREIGN KEY`). Para asegurar la unicidad física de estas claves primarias sin recurrir a IDs huérfanos que violen la regla de "ser todas FKs", se mantiene una granularidad consistente y desnormalizada donde la combinación de claves de dimensiones identifica unívocamente a cada registro del evento de negocio.

### 4.2 Integridad Referencial (Foreign Keys)
*   **Teoría (Pág. 45):** *"La integridad referencial determina que todos los valores que toma una clave foránea deben ser valores nulos o valores que existan como clave primaria de la tabla que se los referencia."*
*   **Resolución en el Modelo:** La base de datos analítica implementa restricciones de integridad referencial declarativas mediante `FOREIGN KEY REFERENCES` entre todas las tablas de hechos y dimensiones. El stored procedure [sp_migrar_hechos_bi](file:///d:/Usuario/Desktop/Estudio/UTN/3%20A%C3%B1o/BD/TP_BASE_DE_DATOS/data/script_creacion_BI.sql#L300) realiza JOINs directos contra los catálogos previamente consolidados, garantizando la consistencia absoluta de las referencias temporales y demográficas.

### 4.3 Nivel de Granularidad y Conservación de la Atomicidad
*   **Teoría (Sección Modelo Estrella):** *"Las tablas de hechos se diseñan para contener detalles uniformes a bajo nivel (referidos como 'granularidad' o 'grano'), o sea que los hechos pueden registrar eventos a un gran nivel de atomicidad."*
*   **Resolución en el Modelo:** Las tablas de hechos conservan el nivel atómico transaccional de los eventos individuales. No se realizaron agrupaciones estáticas previas en la carga (lo que hubiese impedido calcular correctamente métricas agregadas complejas como promedios o variaciones ponderadas en distintas escalas de tiempo). En su lugar, el grano atómico permite que el motor SQL resuelva las sumas, promedios y porcentajes de forma dinámica al consultar las vistas.

### 4.4 Modelo de Constelación de Estrellas (Star/Galaxy Schema)
*   **Teoría (Pág. 56):** *"Datawarehouse: Si todas las dimensiones tienen 1 sola tabla, se llama constelación de estrellas."*
*   **Resolución en el Modelo:** Debido a que el proyecto analiza múltiples procesos de negocio independientes pero interrelacionados (Ventas, Solicitudes, Propuestas, Encuestas) y que todas las dimensiones (Tiempo, Rangos, etc.) constan de una sola tabla desnormalizada (no copo de nieve), el diseño se clasifica de forma pura como una **Constelación de Estrellas**. Este esquema minimiza los cruces innecesarios de tablas y maximiza la performance analítica.
