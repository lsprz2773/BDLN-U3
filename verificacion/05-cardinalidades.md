# Verificación — Entregable 5: Tabla de cardinalidades

Archivo: `entregables/05-cardinalidades.md` · Fuente: KG v1.1 · Herramienta: `scripts/verificar.py 5`

## Ronda 1 (creación, v1)

### ToT
| Decisión | Ramas | Elegida | Motivo |
|---|---|---|---|
| Presentación | A. una tabla ancha con todo · B. tres tablas (cardinalidades, preguntas del enunciado, existencia por entidad) + condiciones · C. una sección por relación | **B** | A no cabe en una página .docx; C es repetitiva. B responde cada pregunta del enunciado en su propia tabla |
| Notación | A. crow's foot (ER) · B. `mín..máx` en ambos sentidos con la convención explícita | **B** | Es la del KG (DEC-07) y es independiente del diagrama |
| Casos dudosos | R06 0..N/1..N; R05 pasos finales; R03 BORRADOR | R06 1..N (DEC-02); R05 1..N (DEC-03); R03 0..N con mínimo condicionado (RI-17) | Resueltos en `docs/decisiones-modelado.md` |
| Reglas que cambian con el estado | A. ignorarlas · B. sección de cardinalidades condicionadas | **B** | RI-17 hace que un mínimo dependa del estado de la simulación |

### CoVe
| Pregunta de verificación | Resultado |
|---|---|
| ¿17 filas con cardinalidades iguales al KG v1.1? | ✔ (script) |
| ¿Las 3 preguntas respondidas en las 17 relaciones? | ✔ (script) |
| ¿Coherencia con el diccionario (E2): FK no nula ↔ 1..1 y FK nula ↔ 0..1 en el lado que tiene la FK? | ✔ 15/15, comprobado de forma independiente (`Opcion.id_paso_siguiente` nula ↔ R07 0..1) |
| ¿La tabla de existencia por entidad coincide con las cardinalidades? | ✔ Derivada por separado: las entidades sin ningún lado con mínimo 1 son exactamente Usuario, Simulacion y Habilidad. Se añadió la comprobación al script |
| ¿R07 "ninguna opción llega al paso inicial" está respaldado? | ✘ No es una regla del modelo (los ciclos están pendientes, P-04) → **corregido**: "un paso (por ejemplo, el inicial) puede no ser destino de ninguna" |
| ¿R05/R06 "No puede existir sin la relación" es coherente con la autoría en BORRADOR? | ✘ Faltaba aclarar que el mínimo se exige al publicar, como en R03 → **corregido** |
| ¿La cita de R15 es precisa? | ✘ Citaba RI-14 para "un único intento" (RI-14 trata de que sea el mismo usuario) → **corregido** |

### Self-consistency (cardinalidad de cada relación)
| Relación | Ruta 1: KG v1.1 | Ruta 2: OBS | Ruta 3: reglas, consultas y estados | Resultado |
|---|---|---|---|---|
| R03 | 0..N | OBS-11 (BORRADOR sin pasos) | RI-17 (≥1 si está PUBLICADA) | 0..N con mínimo condicionado (3/3) |
| R05 | 1..N | OBS-02 (múltiples, sin mínimo) | DEC-03 (sin pasos finales) | 1..N (3/3 compatibles) |
| R06 | 1..N | OBS-03 (una o más) | RF-04 / D-04 | 1..N (3/3) |
| R07 | 0..1 / 0..N | OBS-04 (puede terminar) | RI-23 | 3/3 |
| R11 | 0..N | OBS-07 ("puede generar") | RF-05 sin mínimo explícito | 3/3 |
| R16 | 1..N | OBS-09 (una o varias) | RI-20 (límite superior) | 3/3 |
| Las 11 restantes | KG | OBS-05, OBS-06, OBS-08, OBS-10 | RI-09, RI-13, RI-14 | 3/3 |

**Cambios en la ronda 1:** 3 redacciones + nueva comprobación en el script. → Nueva ronda.

## Ronda 2 (v2)
- **ToT:** sin decisiones nuevas.
- **CoVe:** coherencia con E3 (R07 "varias opciones pueden conducir al mismo paso") ✔ y con E4 (RI-17 "se exige al publicar") ✔. `verificar.py` (E1–E5) → **0 fallos**.
- **SC:** sin cambios.
- **Resultado:** **ronda limpia → entregable cerrado.**
