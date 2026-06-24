# Estrategia de Resolución - Trabajo Práctico Base de Datos

## 1. Modelo Relacional y Migración Inicial

Para la etapa de migración del modelo transaccional se optó por un enfoque secuencial y de limpieza estructurada, garantizando la idempotencia del script `script_creación_inicial.sql`.

### 1.1 Limpieza y Preparación
Se definieron sentencias `DROP TABLE` y `DROP PROCEDURE` preventivas con chequeos de existencia (`IF OBJECT_ID...`), garantizando que la ejecución repetida del script no genere colisiones. Asimismo, se optó por limpiar el esquema `[BASADOS_DE_DATOS]` en lugar de recrearlo por completo, preservando la continuidad del entorno de desarrollo.

### 1.2 Decisiones de Diseño y Consistencia de Datos
Conforme a las restricciones indicadas por la cátedra, **no se modificaron, dedujeron ni alteraron los datos originales (strings)** provistos en la tabla maestra. 
- **Tratamiento de Acentos en Agrupaciones (Países):** En lugar de utilizar funciones destructivas como `REPLACE` para eliminar tildes, se decidió aprovechar la configuración de intercalación (`COLLATE Latin1_General_CI_AI`) del motor de SQL Server. Esto permitió unificar y agrupar correctamente registros lógicamente idénticos (ej. "Perú" y "Peru") a la hora de armar los catálogos y resolver las uniones (JOINs), manteniendo intacta la integridad del string original.
- **Normalización:** Se desglosaron entidades como *Cliente, Agente, Sucursal, Vuelo, Hospedaje y Facturación*, asignándoles claves primarias subrogadas (`IDENTITY(1,1)`) en los casos donde no existía una clave natural confiable en el origen.

## 2. Modelo de Inteligencia de Negocios (BI)

El objetivo central del modelo de Inteligencia de Negocios (`script_creación_BI.sql`) fue proveer una estructura desnormalizada (Modelo Estrella / Copo de Nieve) orientada íntegramente a satisfacer la lectura ágil de las 10 métricas gerenciales solicitadas.

### 2.1 Tablas de Dimensiones (Catálogos)
Se extrajeron los conceptos transversales en tablas dimensionales estáticas e inferidas:
- `BI_dimension_tiempo`: Dimensión jerárquica principal conformada por la disección de las fechas operativas (Año, Cuatrimestre, Mes).
- `BI_dimension_rango_etario_cliente` y `BI_dimension_rango_etario_agente`: Segmentaciones demográficas predefinidas.
- `BI_dimension_temporada`: Bucketización del tiempo según las 4 estaciones del año, implementado mediante una función escalar para facilitar el cálculo (Enero-Marzo: Verano, etc.).
- Se respetó la inclusión de todos los descriptores mínimos exigidos: Tipo de Servicio, Canal de Venta y Estado de Propuesta.

### 2.2 Tablas de Hechos (Facts)
Se implementaron 5 tablas de hechos granulares para aislar conceptualmente el comportamiento del negocio:
1. `BI_hecho_venta`
2. `BI_hecho_solicitud`
3. `BI_hecho_propuesta`
4. `BI_hecho_aspecto`
5. `BI_hecho_encuesta`

Cada tabla de hechos vincula, a través de Claves Foráneas (Foreign Keys), las dimensiones correspondientes al momento en que ocurrió el evento, calculando internamente métricas derivadas como los días de anticipación de una reserva o los desvíos financieros.

### 2.3 Creación de Vistas y Tableros
Como última etapa del pipeline analítico, se generaron las 10 vistas requeridas (Prefijo `V_BI_...`). Cada una de ellas realiza una agregación semántica (usando promedios `AVG`, conteos `COUNT` y métricas ponderadas como el porcentaje de facturación particionado `OVER(PARTITION BY)`). Estas vistas apuntan directamente al modelo de BI y no transitan por las tablas relacionales originales, asegurando extrema velocidad de respuesta en los tableros gerenciales.

---
*(Nota: Este documento debe ser exportado a PDF y se le debe agregar una carátula e índice formal según exigencias de cátedra).*
