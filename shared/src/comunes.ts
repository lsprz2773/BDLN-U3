/**
 * Objetos que se repiten en la API (docs/api/contrato-v0.md §2) y formatos generales
 * (context/convenciones.md §5). Los esquemas propios de cada endpoint los agrega su dueño
 * en un archivo de esta carpeta al implementarlo.
 */
import { z } from 'zod';
import {
  Dificultad,
  EstadoIntento,
  EstadoSimulacion,
  EstadoUsuario,
  NombreBase,
  Rol,
  Severidad,
} from './catalogos.js';

export const Uuid = z.uuid();
/** ISO-8601 en UTC con Z: 2026-11-18T21:30:00.000Z */
export const FechaIso = z.iso.datetime();
/** Puntuaciones y niveles: 0 a 100, máximo 2 decimales. */
export const Nivel = z.number().min(0).max(100);

// ---- Error y sincronización -------------------------------------------------

export const ErrorRespuesta = z.object({
  error: z.object({
    codigo: z.string().regex(/^[A-Z][A-Z0-9_]*$/),
    mensaje: z.string(),
    detalles: z.record(z.string(), z.unknown()).optional(),
  }),
});
export type ErrorRespuesta = z.infer<typeof ErrorRespuesta>;

export const Sincronizacion = z.object({
  grafo: z.enum(['APLICADO', 'PENDIENTE']),
  eventos: z.array(Uuid),
});
export type Sincronizacion = z.infer<typeof Sincronizacion>;

/** Respuesta de una lista paginada: { datos, total }. */
export const lista = <T extends z.ZodType>(elemento: T) =>
  z.object({ datos: z.array(elemento), total: z.number().int().min(0) });

export const Paginacion = z.object({
  limite: z.coerce.number().int().min(1).max(100).default(20),
  desplazamiento: z.coerce.number().int().min(0).default(0),
});
export type Paginacion = z.infer<typeof Paginacion>;

// ---- Salud (GET /api/health) -------------------------------------------------

export const EstadoBase = z.object({
  ok: z.boolean(),
  latencia_ms: z.number().int().min(0),
  /** Solo si ok = false. Código genérico; el detalle va al log, no a la respuesta pública. */
  error: z.enum(['SIN_CONEXION', 'TIEMPO_AGOTADO']).optional(),
});
export type EstadoBase = z.infer<typeof EstadoBase>;

export const Salud = z.object({
  estado: z.enum(['OK', 'DEGRADADO']),
  version: z.string(),
  bases: z.record(NombreBase, EstadoBase),
});
export type Salud = z.infer<typeof Salud>;

// ---- Entidades comunes --------------------------------------------------------

export const Usuario = z.object({
  id_usuario: Uuid,
  nombre: z.string().min(1).max(100),
  correo: z.email().max(150),
  rol: Rol,
  estado: EstadoUsuario,
  fecha_registro: FechaIso,
});
export type Usuario = z.infer<typeof Usuario>;

export const Habilidad = z.object({
  id_habilidad: Uuid,
  nombre: z.string().min(1).max(100),
  descripcion: z.string(),
  categoria: z.string().max(50),
  nivel_objetivo: Nivel.nullable(),
});
export type Habilidad = z.infer<typeof Habilidad>;

export const HabilidadDeSimulacion = z.object({
  id_habilidad: Uuid,
  nombre: z.string(),
  peso: z.number().gt(0).max(1),
  nivel_esperado: Nivel,
});

export const SimulacionResumen = z.object({
  id_simulacion: Uuid,
  titulo: z.string().min(1).max(150),
  descripcion: z.string(),
  dificultad: Dificultad,
  duracion_estimada: z.number().int().positive().nullable(),
  estado: EstadoSimulacion,
  habilidades: z.array(HabilidadDeSimulacion),
});
export type SimulacionResumen = z.infer<typeof SimulacionResumen>;

export const Intento = z.object({
  id_intento: Uuid,
  id_simulacion: Uuid,
  estado: EstadoIntento,
  fecha_inicio: FechaIso,
  fecha_fin: FechaIso.nullable(),
  puntuacion: Nivel.nullable(),
});
export type Intento = z.infer<typeof Intento>;

// ---- Paso tal como lo ve quien juega (sin valoración ni consecuencias) --------

/** Forma del contexto según el tipo de paso (convenciones §4, matriz §3). */
export const ContextoCorreo = z.object({
  remitente: z.string(),
  asunto: z.string(),
  cuerpo: z.string(),
});
export const ContextoReunion = z.object({
  participantes: z.array(z.string()).min(1),
  agenda: z.array(z.string()).min(1),
});
export const ContextoConversacion = z.object({
  interlocutor: z.string(),
  lineas: z.array(z.object({ quien: z.string(), texto: z.string() })).min(1),
});
export const ContextoTarea = z.object({
  entregables: z.array(z.string()).min(1),
  plazo_horas: z.number().positive(),
});
export const ContextoIncidente = z.object({
  cronologia: z.array(z.object({ momento: z.string(), hecho: z.string() })).min(1),
  severidad: Severidad,
});

export const OpcionVista = z.object({ id_opcion: Uuid, descripcion: z.string() });

const pasoBase = {
  id_paso: Uuid,
  orden: z.number().int().positive(),
  titulo: z.string().max(150),
  descripcion: z.string(),
  opciones: z.array(OpcionVista).min(1),
};

export const PasoVista = z.discriminatedUnion('tipo', [
  z.object({ ...pasoBase, tipo: z.literal('CORREO'), contexto: ContextoCorreo }),
  z.object({ ...pasoBase, tipo: z.literal('REUNION'), contexto: ContextoReunion }),
  z.object({ ...pasoBase, tipo: z.literal('CONVERSACION'), contexto: ContextoConversacion }),
  z.object({ ...pasoBase, tipo: z.literal('TAREA'), contexto: ContextoTarea }),
  z.object({ ...pasoBase, tipo: z.literal('INCIDENTE'), contexto: ContextoIncidente }),
]);
export type PasoVista = z.infer<typeof PasoVista>;
