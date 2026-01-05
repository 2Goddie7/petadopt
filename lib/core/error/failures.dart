import 'package:equatable/equatable.dart';

/// Failures representan errores en la capa de dominio
/// Son el resultado de mapear Exceptions de la capa de datos
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure: $message${code != null ? ' (code: $code)' : ''}';
}

// ============================================
// FAILURES DE RED Y SERVIDOR
// ============================================

/// Failure de error de servidor
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Error del servidor. Intenta más tarde.', String? code])
      : super(message, code);
}

/// Failure de error de conexión
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Error de conexión. Verifica tu internet.', String? code])
      : super(message, code);
}

/// Failure de timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'La solicitud tardó demasiado. Intenta nuevamente.', String? code])
      : super(message, code);
}

// ============================================
// FAILURES DE AUTENTICACIÓN
// ============================================

/// Failure de usuario no autenticado
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'No autorizado. Inicia sesión nuevamente.', String? code])
      : super(message, code);
}

/// Failure de credenciales inválidas
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([String message = 'Email o contraseña incorrectos.', String? code])
      : super(message, code);
}

/// Failure de email ya registrado
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([String message = 'Este email ya está registrado.', String? code])
      : super(message, code);
}

/// Failure de usuario no encontrado
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([String message = 'Usuario no encontrado.', String? code])
      : super(message, code);
}

/// Failure de contraseña débil
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([String message = 'La contraseña es muy débil. Usa al menos 8 caracteres.', String? code])
      : super(message, code);
}

/// Failure de sesión expirada
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([String message = 'Tu sesión ha expirado. Inicia sesión nuevamente.', String? code])
      : super(message, code);
}

// ============================================
// FAILURES DE DATOS
// ============================================

/// Failure de recurso no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Recurso no encontrado.', String? code])
      : super(message, code);
}

/// Failure de datos inválidos
class InvalidDataFailure extends Failure {
  const InvalidDataFailure([String message = 'Los datos proporcionados son inválidos.', String? code])
      : super(message, code);
}

/// Failure de formato JSON inválido
class JsonParseFailure extends Failure {
  const JsonParseFailure([String message = 'Error al procesar los datos.', String? code])
      : super(message, code);
}

/// Failure de duplicado
class DuplicateFailure extends Failure {
  const DuplicateFailure([String message = 'El recurso ya existe.', String? code])
      : super(message, code);
}

// ============================================
// FAILURES DE STORAGE
// ============================================

/// Failure de error al subir archivo
class FileUploadFailure extends Failure {
  const FileUploadFailure([String message = 'Error al subir archivo. Intenta nuevamente.', String? code])
      : super(message, code);
}

/// Failure de archivo demasiado grande
class FileTooLargeFailure extends Failure {
  const FileTooLargeFailure([String message = 'El archivo es demasiado grande. Máximo 5MB.', String? code])
      : super(message, code);
}

/// Failure de tipo de archivo no permitido
class InvalidFileTypeFailure extends Failure {
  const InvalidFileTypeFailure([String message = 'Tipo de archivo no permitido. Solo JPG, PNG, WEBP.', String? code])
      : super(message, code);
}

// ============================================
// FAILURES DE PERMISOS
// ============================================

/// Failure de permiso denegado
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([String message = 'No tienes permisos para esta acción.', String? code])
      : super(message, code);
}

/// Failure de permiso de ubicación denegado
class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure([String message = 'Necesitamos acceso a tu ubicación.', String? code])
      : super(message, code);
}

/// Failure de permiso de cámara denegado
class CameraPermissionFailure extends Failure {
  const CameraPermissionFailure([String message = 'Necesitamos acceso a tu cámara.', String? code])
      : super(message, code);
}

// ============================================
// FAILURES DE CACHE/LOCAL
// ============================================

/// Failure de error de cache
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Error al acceder a los datos locales.', String? code])
      : super(message, code);
}

/// Failure de cache vacío
class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure([String message = 'No hay datos disponibles sin conexión.', String? code])
      : super(message, code);
}

// ============================================
// FAILURES DE VALIDACIÓN
// ============================================

/// Failure de campos requeridos faltantes
class RequiredFieldFailure extends Failure {
  const RequiredFieldFailure([String message = 'Completa todos los campos requeridos.', String? code])
      : super(message, code);
}

/// Failure de formato inválido
class InvalidFormatFailure extends Failure {
  const InvalidFormatFailure([String message = 'El formato es inválido.', String? code])
      : super(message, code);
}

/// Failure de validación (campos/errores devueltos por la API)
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Datos inválidos', String? code]) : super(message, code);
}

// ============================================
// FAILURES DE LÓGICA DE NEGOCIO
// ============================================

/// Failure de operación no permitida
class OperationNotAllowedFailure extends Failure {
  const OperationNotAllowedFailure([String message = 'Esta operación no está permitida.', String? code])
      : super(message, code);
}

/// Failure de límite excedido
class LimitExceededFailure extends Failure {
  const LimitExceededFailure([String message = 'Has excedido el límite permitido.', String? code])
      : super(message, code);
}

// ============================================
// FAILURE DESCONOCIDO
// ============================================

/// Failure desconocido/no manejado
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Ocurrió un error inesperado.', String? code])
      : super(message, code);
}