# Correcciones para los documentos de estrategia (Entrega 2)

> Notas de texto para actualizar `Estrategia.pdf` y `justificacion_diseno_bd.pdf`.
> No se regeneraron los PDF; copiar/pegar estos párrafos y volver a exportar.

---

## 1. Países con/sin tilde — documento y código alineados

El `Estrategia.pdf` y la `justificacion_diseno_bd.pdf` (sección 2.1) dicen que los países con y
sin tilde (ej. "Perú" vs "Peru") se tratan como **países DISTINTOS**, con un ID único por
variación. **El código se ajustó para respetar exactamente eso:** se quitó el `COLLATE` insensible
a acentos de las comparaciones de país; ahora usan la collation por defecto (sensible a acentos),
de modo que cada variante literal genera su propio `pais_codigo`. **No hay que corregir el texto de
los PDF en este punto** — ya coincide con el código.

---

## 2. Decisiones nuevas a documentar (Entrega 2)

Agregar al documento de estrategia estas decisiones aplicadas en `script_creacion_inicial.sql`:

- **Migración mediante Stored Procedures.** Toda la carga se encapsula en un SP por tabla
  (`[BASADOS_DE_DATOS].Migrar_<Tabla>`), ejecutados en orden de dependencias al final del
  script, según exige el enunciado.
- **Índices.** Se crean índices sobre las claves naturales usadas en los JOIN de migración
  (Cliente, Hospedaje, Habitación, Vuelo, Excursión) y sobre las claves foráneas de las tablas
  transaccionales y de detalle, por criterios de performance.
- **Claves subrogadas en tablas de detalle/cruce.** `ItemVentaVuelo`, `ItemVentaHospedaje`,
  `ItemVentaExcursion`, `ItemPropuestaVuelo`, `ItemPropuestaHospedaje`, `CiudadSolicitud`,
  `Aspecto` y `Venta_Propuesta` reciben PK subrogada `IDENTITY` (`item_codigo`, etc.).
- **Recuperación de `vuel_duracion`.** La columna `Vuelo_Duracion` de la maestra, antes
  descartada, ahora se migra a `Vuelo.vuel_duracion` (no se pierde información).
- **Consolidación de claves naturales "sucias".** `Aerolinea`, `Aeropuerto`, `Agencia` y
  `Agente` se cargan con `GROUP BY` sobre su clave natural tomando `MAX()` del resto de los
  atributos. Esto evita violaciones de PK (una misma clave con datos distintos en la maestra)
  y de FK (esas claves se insertan crudas en tablas hijas, por lo que deben existir todas). El
  filtro geográfico (provincia/ciudad) se movió del `WHERE` al `JOIN` para no descartar claves
  referenciadas por otras tablas.
- **Deduplicación de Cliente.** `Cliente` usa clave subrogada `clie_codigo` y se deduplica por
  `(clie_dni, clie_nombre, clie_apellido, clie_direccion)`, que es exactamente la clave usada
  para resolver el cliente desde Venta/Solicitud/Encuesta. Garantiza relación 1:1 y evita
  duplicar transacciones.

---

## 3. Recordatorios de formato (requisitos del enunciado)

- El `Estrategia.pdf` debe **incluir el DER embebido** (modelo relacional) y, en la entrega de
  BI, también el DER de BI. Hoy el índice del PDF llega solo hasta el punto 2.3 y no incluye
  los diagramas; completarlo.
- Debe tener **carátula e índice** (ya tiene carátula; completar el índice).
- Exportar el DER a imagen `DER.jpg` legible (desde `EntregaDER/DER segunda entrega.mmd`).

---

## 3b. Entrega 3 — BI (a documentar en Estrategia.pdf)

- **Las 10 vistas de indicadores** están implementadas en `script_creacion_BI.sql` (sección 5),
  una por indicador del enunciado.
- **Indicador #8 (Desvío de presupuesto):** el enunciado no fija segmentación; el grupo decidió
  segmentar por **año/cuatrimestre de emisión** de la propuesta.
- **Indicador #5 (Tasa de aceptación):** el filtro de propuesta aceptada compara contra el
  literal `'Aceptada'` con `COLLATE Latin1_General_CI_AI`. Verificar el valor real con
  `SELECT DISTINCT estado FROM [BASADOS_DE_DATOS].BI_dimension_estado_propuesta` y ajustar si
  difiere.
- **Pendientes de formato:** exportar `DER_BI.jpg` (desde `EntregaDER/DER Segunda Entrega
  Completo.mmd`) y agregar la sección de BI al `Estrategia.pdf`.

---

## 4. Criterio de nombres geográficos (uniforme)

Todas las entidades geográficas (países, provincias, localidades y ciudades) se resuelven por
**coincidencia exacta de nombre** con la collation por defecto (sensible a acentos). Es decir,
no se unifican variantes con/sin tilde en ninguna de ellas: el criterio es uniforme y no se
altera ni se infiere sobre el dato original.
