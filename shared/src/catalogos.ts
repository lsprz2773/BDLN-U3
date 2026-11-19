/**
 * Catálogos de valores (context/convenciones.md §4). Fuente única: backend, frontend,
 * validadores de MongoDB y CHECK de PostgreSQL deben coincidir con estas listas.
 */
import { z } from 'zod';

export const EstadoUsuario = z.enum(['ACTIVO', 'INACTIVO', 'SUSPENDIDO']);
export type EstadoUsuario = z.infer<typeof EstadoUsuario>;

export const Rol = z.enum(['ESTUDIANTE', 'ADMIN']);
export type Rol = z.infer<typeof Rol>;

export const Dificultad = z.enum(['BASICA', 'INTERMEDIA', 'AVANZADA']);
export type Dificultad = z.infer<typeof Dificultad>;

export const EstadoSimulacion = z.enum(['BORRADOR', 'PUBLICADA', 'INACTIVA']);
export type EstadoSimulacion = z.infer<typeof EstadoSimulacion>;

export const EstadoIntento = z.enum(['EN_CURSO', 'COMPLETADO', 'ABANDONADO']);
export type EstadoIntento = z.infer<typeof EstadoIntento>;

export const Visibilidad = z.enum(['PRIVADA', 'PUBLICA']);
export type Visibilidad = z.infer<typeof Visibilidad>;

export const EstadoComparticion = z.enum(['ACTIVA', 'REVOCADA']);
export type EstadoComparticion = z.infer<typeof EstadoComparticion>;

export const TipoPaso = z.enum(['CORREO', 'REUNION', 'CONVERSACION', 'TAREA', 'INCIDENTE']);
export type TipoPaso = z.infer<typeof TipoPaso>;

export const Impacto = z.enum(['POSITIVO', 'NEUTRO', 'NEGATIVO']);
export type Impacto = z.infer<typeof Impacto>;

export const TipoConsecuencia = z.enum(['RELACIONAL', 'TIEMPO', 'CALIDAD', 'REPUTACION']);
export type TipoConsecuencia = z.infer<typeof TipoConsecuencia>;

export const TipoRetroalimentacion = z.enum(['ACIERTO', 'PARCIAL', 'ERROR']);
export type TipoRetroalimentacion = z.infer<typeof TipoRetroalimentacion>;

export const Severidad = z.enum(['BAJA', 'MEDIA', 'ALTA']);
export type Severidad = z.infer<typeof Severidad>;

/** Sincronización hacia Neo4j (docs/modelos/matriz-propiedad.md §5). */
export const EstadoEvento = z.enum(['PENDIENTE', 'APLICADO', 'FALLIDO']);
export type EstadoEvento = z.infer<typeof EstadoEvento>;

export const TipoEvento = z.enum([
  'USUARIO_CREADO',
  'USUARIO_ELIMINADO',
  'HABILIDAD_GUARDADA',
  'HABILIDAD_ELIMINADA',
  'SIMULACION_PUBLICADA',
  'SIMULACION_ESTADO_CAMBIADO',
  'INTENTO_INICIADO',
  'RESPUESTA_REGISTRADA',
  'INTENTO_FINALIZADO',
  'EVIDENCIA_GENERADA',
  'EVIDENCIA_ELIMINADA',
]);
export type TipoEvento = z.infer<typeof TipoEvento>;

/** Nombres de las 3 bases tal como aparecen en /api/health y en los errores 503. */
export const NombreBase = z.enum(['relacional', 'documental', 'grafo']);
export type NombreBase = z.infer<typeof NombreBase>;
