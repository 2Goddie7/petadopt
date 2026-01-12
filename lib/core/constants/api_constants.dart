import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

/// Constantes de API y configuración de la aplicación PetAdopt
class ApiConstants {
  // Prevenir instanciación
  ApiConstants._();

  // URL del servicio de configuración remoto
  static const String configServiceUrl =
      'https://auth-pet-three.vercel.app/api/config';

  // Cache de configuración remota
  static Map<String, dynamic>? _remoteConfig;

  static Future<void> loadConfig() async {
    try {
      // Intentar cargar desde .env local primero
      await dotenv.load(fileName: 'assets/.env');
      print('✅ Configuración cargada desde assets/.env');
    } catch (e) {
      print('⚠️ No se pudo cargar .env local: $e');
      print('🌐 Intentando cargar configuración desde servicio remoto...');

      try {
        // Intentar obtener configuración desde el servicio remoto
        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        final response = await dio.get(configServiceUrl);

        if (response.statusCode == 200 && response.data != null) {
          _remoteConfig = Map<String, dynamic>.from(response.data);
          print('✅ Configuración cargada desde servicio remoto');
          print('🔑 Config: ${_remoteConfig!.keys.join(", ")}');
        } else {
          throw Exception('Respuesta inválida del servicio de configuración');
        }
      } catch (remoteError) {
        print('❌ Error cargando configuración remota: $remoteError');
        throw Exception(
            'No se pudo cargar la configuración desde .env ni desde el servicio remoto. '
            'Asegúrate de tener conexión a internet o incluir assets/.env en pubspec.yaml. '
            'Error local: $e | Error remoto: $remoteError');
      }
    }
  }

  // Helper para obtener valores de configuración
  static String _getConfigValue(String key, String envKey) {
    // Prioridad: remoteConfig > dotenv
    if (_remoteConfig != null && _remoteConfig!.containsKey(key)) {
      return _remoteConfig![key]?.toString() ?? '';
    }
    return dotenv.env[envKey] ?? '';
  }

  // ============================================
  // SUPABASE CONFIGURATION
  // ============================================

  /// URL del proyecto Supabase
  /// IMPORTANTE: Reemplazar con tu URL real
  static String get supabaseUrl =>
      _getConfigValue('supabaseUrl', 'SUPABASE_URL');

  /// Anon Key de Supabase
  /// IMPORTANTE: Reemplazar con tu anon key real
  static String get supabaseAnonKey =>
      _getConfigValue('supabaseAnonKey', 'SUPABASE_ANON_KEY');

  // ============================================
  // SUPABASE TABLES
  // ============================================
  static const String profilesTable = 'profiles';
  static const String sheltersTable = 'shelters';
  static const String petsTable = 'pets';
  static const String adoptionRequestsTable = 'adoption_requests';
  static const String chatHistoryTable = 'chat_history';
  static const String favoritesTable = 'favorites';

  // ============================================
  // SUPABASE VIEWS
  // ============================================
  static const String petsWithShelterInfoView = 'pets_with_shelter_info';
  static const String adoptionRequestsWithDetailsView =
      'adoption_requests_with_details';

  // ============================================
  // SUPABASE STORAGE BUCKETS
  // ============================================
  static const String petImagesBucket = 'pet-images';
  static const String profileAvatarsBucket = 'avatars';

  // ============================================
  // GEMINI AI CONFIGURATION
  // ============================================

  /// API Key de Gemini
  /// IMPORTANTE: Reemplazar con tu API key real
  /// Obtener en: https://makersuite.google.com/app/apikey
  static String get geminiApiKey =>
      _getConfigValue('geminiApiKey', 'GEMINI_API_KEY');

  /// Modelo de Gemini a usar
  /// Actualizado a gemini-1.5-flash (más rápido y eficiente)
  static const String geminiModel = 'gemini-1.5-flash';

  /// Endpoint base de Gemini
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // ============================================
  // GOOGLE OAUTH (OPCIONAL - Para +2 puntos)
  // ============================================

  /// Client ID de Google OAuth
  /// Obtener en Google Cloud Console
  static String get googleClientId =>
      _getConfigValue('googleClientId', 'GOOGLE_CLIENT_ID');

  /// Redirect URL para Google OAuth
  static String get googleRedirectUrl => '$supabaseUrl/auth/v1/callback';

  // ============================================
  // OPENSTREETMAP / NOMINATIM
  // ============================================

  /// Base URL para Nominatim (geocoding)
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// URL de tiles de OpenStreetMap
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// User-Agent para requests a OSM
  static const String osmUserAgent = 'PetAdopt/1.0.0';

  // ============================================
  // LÍMITES Y CONFIGURACIÓN
  // ============================================

  /// Máximo de fotos por mascota
  static const int maxPetImages = 5;

  /// Tamaño máximo de imagen en bytes (5MB)
  static const int maxImageSizeBytes = 5 * 1024 * 1024;

  /// Tamaño máximo de avatar en bytes (2MB)
  static const int maxAvatarSizeBytes = 2 * 1024 * 1024;

  /// Timeout para requests HTTP (30 segundos)
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Distancia máxima para refugios cercanos (km)
  static const double maxShelterDistance = 50.0;

  /// Número de items por página en paginación
  static const int itemsPerPage = 20;

  /// Máximo de caracteres en descripción de mascota
  static const int maxPetDescriptionLength = 500;

  /// Máximo de mensajes en el historial de chat
  static const int maxChatHistory = 50;

  // ============================================
  // FORMATO DE IMÁGENES
  // ============================================

  /// Formatos de imagen permitidos
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  /// MIME types permitidos
  static const List<String> allowedImageMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  // ============================================
  // ENUMS COMO STRINGS (para Supabase)
  // ============================================

  /// Tipos de usuario
  static const String userTypeAdopter = 'adopter';
  static const String userTypeShelter = 'shelter';

  /// Tipos de mascota
  static const String petTypeDog = 'dog';
  static const String petTypeCat = 'cat';
  static const String petTypeOther = 'other';

  /// Tamaños de mascota
  static const String petSizeSmall = 'small';
  static const String petSizeMedium = 'medium';
  static const String petSizeLarge = 'large';

  /// Géneros de mascota
  static const String petGenderMale = 'male';
  static const String petGenderFemale = 'female';

  /// Estados de adopción
  static const String adoptionStatusAvailable = 'available';
  static const String adoptionStatusPending = 'pending';
  static const String adoptionStatusAdopted = 'adopted';

  /// Estados de solicitud
  static const String requestStatusPending = 'pending';
  static const String requestStatusApproved = 'approved';
  static const String requestStatusRejected = 'rejected';

  // ============================================
  // COORDENADAS POR DEFECTO (QUITO, ECUADOR)
  // ============================================
  static const double defaultLatitude = -0.1807;
  static const double defaultLongitude = -78.4678;
  static const double defaultMapZoom = 12.0;

  // ============================================
  // CONFIGURACIÓN DE NOTIFICACIONES (si implementas)
  // ============================================

  /// Tópicos de notificaciones push
  static const String notificationTopicNewPets = 'new_pets';
  static const String notificationTopicRequests = 'adoption_requests';

  /// Canales de notificaciones (Android)
  static const String notificationChannelGeneral = 'general';
  static const String notificationChannelRequests = 'requests';
  static const String notificationChannelChat = 'chat';

  // ============================================
  // QUERY FILTERS Y ORDENAMIENTO
  // ============================================

  /// Campos para ordenamiento
  static const String orderByCreatedAt = 'created_at';
  static const String orderByUpdatedAt = 'updated_at';
  static const String orderByName = 'name';
  static const String orderByDistance = 'distance';

  /// Direcciones de ordenamiento
  static const String orderAscending = 'asc';
  static const String orderDescending = 'desc';

  // ============================================
  // MÉTODOS HELPER
  // ============================================

  /// Retorna la URL completa de una imagen en Storage
  static String getStorageUrl(String bucket, String path) {
    return '$supabaseUrl/storage/v1/object/public/$bucket/$path';
  }

  /// Retorna el path para guardar imagen de mascota
  static String getPetImagePath(
      String shelterId, String petId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$shelterId/$petId/${timestamp}_$fileName';
  }

  /// Retorna el path para guardar avatar de usuario
  static String getAvatarPath(String userId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$userId/avatar_$timestamp.$fileName';
  }

  /// Valida si un formato de imagen es permitido
  static bool isImageFormatAllowed(String extension) {
    return allowedImageFormats.contains(extension.toLowerCase());
  }

  /// Valida si un MIME type de imagen es permitido
  static bool isImageMimeTypeAllowed(String mimeType) {
    return allowedImageMimeTypes.contains(mimeType.toLowerCase());
  }

  // ============================================
  // REGEX PATTERNS
  // ============================================

  /// Pattern para validación de email
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Pattern para validación de teléfono (Ecuador)
  static final RegExp phonePattern = RegExp(
    r'^\+593\s?\d{2}\s?\d{3}\s?\d{4}$',
  );

  /// Pattern para validación de URL
  static final RegExp urlPattern = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  // ============================================
  // MENSAJES DE ERROR GENÉRICOS DE API
  // ============================================
  static const String errorNetworkConnection =
      'Error de conexión. Verifica tu internet.';
  static const String errorTimeout =
      'La solicitud tardó demasiado. Intenta nuevamente.';
  static const String errorServerError =
      'Error del servidor. Intenta más tarde.';
  static const String errorUnauthorized =
      'No autorizado. Inicia sesión nuevamente.';
  static const String errorForbidden =
      'No tienes permisos para realizar esta acción.';
  static const String errorNotFound = 'Recurso no encontrado.';
  static const String errorBadRequest = 'Solicitud inválida.';
  static const String errorUnknown = 'Ocurrió un error desconocido.';

  // ============================================
  // CACHE KEYS (para SharedPreferences)
  // ============================================
  static const String cacheKeyUser = 'cached_user';
  static const String cacheKeyUserType = 'cached_user_type';
  static const String cacheKeyToken = 'cached_token';
  static const String cacheKeyLastLocation = 'cached_last_location';
  static const String cacheKeyTheme = 'cached_theme';
  static const String cacheKeyLanguage = 'cached_language';

  // ============================================
  // VERSIÓN DE LA APP
  // ============================================
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // ============================================
  // LINKS EXTERNOS
  // ============================================
  static const String termsUrl = '';
  static const String privacyUrl = '';
  static const String helpCenterUrl = '';
  static const String githubRepoUrl = '';
}
