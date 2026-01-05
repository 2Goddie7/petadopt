/// Excepciones personalizadas de la aplicación
/// Estas son lanzadas en la capa de datos (Data Sources)

/// Excepción base de la aplicación
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

// ============================================
// EXCEPCIONES DE RED Y SERVIDOR
// ============================================

/// Excepción de error de servidor (500, 502, etc.)
class ServerException extends AppException {
  const ServerException([String message = 'Error del servidor', String? code])
      : super(message, code);
}

/// Excepción de timeout/conexión
class NetworkException extends AppException {
  const NetworkException([String message = 'Error de conexión', String? code])
      : super(message, code);
}

/// Excepción de timeout
class TimeoutException extends AppException {
  const TimeoutException([String message = 'La solicitud tardó demasiado', String? code])
      : super(message, code);
}

// ============================================
// EXCEPCIONES DE AUTENTICACIÓN
// ============================================

/// Excepción de usuario no autenticado
class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'No autorizado', String? code])
      : super(message, code);
}

/// Excepción de credenciales inválidas
class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException([String message = 'Credenciales inválidas', String? code])
      : super(message, code);
}

/// Excepción de email ya registrado
class EmailAlreadyInUseException extends AppException {
  const EmailAlreadyInUseException([String message = 'Este email ya está registrado', String? code])
      : super(message, code);
}

/// Excepción de usuario no encontrado
class UserNotFoundException extends AppException {
  const UserNotFoundException([String message = 'Usuario no encontrado', String? code])
      : super(message, code);
}

/// Excepción de contraseña débil
class WeakPasswordException extends AppException {
  const WeakPasswordException([String message = 'La contraseña es muy débil', String? code])
      : super(message, code);
}

/// Excepción de sesión expirada
class SessionExpiredException extends AppException {
  const SessionExpiredException([String message = 'La sesión ha expirado', String? code])
      : super(message, code);
}

// ============================================
// EXCEPCIONES DE DATOS
// ============================================

/// Excepción de recurso no encontrado (404)
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Recurso no encontrado', String? code])
      : super(message, code);
}

/// Excepción de datos inválidos
class InvalidDataException extends AppException {
  const InvalidDataException([String message = 'Datos inválidos', String? code])
      : super(message, code);
}

/// Excepción de formato JSON inválido
class JsonParseException extends AppException {
  const JsonParseException([String message = 'Error al procesar datos', String? code])
      : super(message, code);
}

/// Excepción de duplicado (409)
class DuplicateException extends AppException {
  const DuplicateException([String message = 'El recurso ya existe', String? code])
      : super(message, code);
}

// ============================================
// EXCEPCIONES DE STORAGE
// ============================================

/// Excepción de error al subir archivo
class FileUploadException extends AppException {
  const FileUploadException([String message = 'Error al subir archivo', String? code])
      : super(message, code);
}

/// Excepción de archivo demasiado grande
class FileTooLargeException extends AppException {
  const FileTooLargeException([String message = 'El archivo es demasiado grande', String? code])
      : super(message, code);
}

/// Excepción de tipo de archivo no permitido
class InvalidFileTypeException extends AppException {
  const InvalidFileTypeException([String message = 'Tipo de archivo no permitido', String? code])
      : super(message, code);
}

// ============================================
// EXCEPCIONES DE PERMISOS
// ============================================

/// Excepción de permiso denegado (403)
class ForbiddenException extends AppException {
  const ForbiddenException([String message = 'No tienes permisos para esta acción', String? code])
      : super(message, code);
}

/// Excepción de permiso de ubicación denegado
class LocationPermissionException extends AppException {
  const LocationPermissionException([String message = 'Permiso de ubicación denegado', String? code])
      : super(message, code);
}

/// Excepción de permiso de cámara denegado
class CameraPermissionException extends AppException {
  const CameraPermissionException([String message = 'Permiso de cámara denegado', String? code])
      : super(message, code);
}

// ============================================
// EXCEPCIONES DE CACHE/LOCAL
// ============================================

/// Excepción de error de cache
class CacheException extends AppException {
  const CacheException([String message = 'Error al acceder al cache', String? code])
      : super(message, code);
}

/// Excepción de cache vacío
class EmptyCacheException extends AppException {
  const EmptyCacheException([String message = 'No hay datos en cache', String? code])
      : super(message, code);
}

// ============================================
// EXCEPCIONES DE VALIDACIÓN
// ============================================

/// Excepción de campos requeridos faltantes
class RequiredFieldException extends AppException {
  const RequiredFieldException([String message = 'Campos requeridos faltantes', String? code])
      : super(message, code);
}

/// Excepción de formato inválido
class InvalidFormatException extends AppException {
  const InvalidFormatException([String message = 'Formato inválido', String? code])
      : super(message, code);
}

/// Excepción de validación (por ejemplo, validación de campos del formulario o errores devueltos por API)
class ValidationException extends AppException {
  const ValidationException([String message = 'Datos inválidos', String? code]) : super(message, code);
}

// ============================================
// EXCEPCIONES DE LÓGICA DE NEGOCIO
// ============================================

/// Excepción de operación no permitida
class OperationNotAllowedException extends AppException {
  const OperationNotAllowedException([String message = 'Operación no permitida', String? code])
      : super(message, code);
}

/// Excepción de límite excedido
class LimitExceededException extends AppException {
  const LimitExceededException([String message = 'Límite excedido', String? code])
      : super(message, code);
}

// ============================================
// EXCEPCIÓN DESCONOCIDA
// ============================================

/// Excepción desconocida/no manejada
class UnknownException extends AppException {
  const UnknownException([String message = 'Ocurrió un error desconocido', String? code])
      : super(message, code);
}