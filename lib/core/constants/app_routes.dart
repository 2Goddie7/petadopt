/// Rutas de navegación de la aplicación PetAdopt
class AppRoutes {
  // Prevenir instanciación
  AppRoutes._();

  // ============================================
  // RUTAS DE AUTENTICACIÓN
  // ============================================
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String userTypeSelection = '/user-type-selection';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String resetPassword = '/reset-password';

  // ============================================
  // RUTAS PRINCIPALES - ADOPTANTE
  // ============================================
  static const String home = '/home';
  static const String petDetail = '/pet-detail';
  static const String map = '/map';
  static const String chat = '/chat';
  static const String myRequests = '/my-requests';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String shelterDetail = '/shelter-detail';

  // ============================================
  // RUTAS PRINCIPALES - REFUGIO
  // ============================================
  static const String shelterDashboard = '/shelter-dashboard';
  static const String shelterPets = '/shelter-pets';
  static const String createPet = '/create-pet';
  static const String editPet = '/edit-pet';
  static const String shelterRequests = '/shelter-requests';
  static const String requestDetail = '/request-detail';
  static const String shelterProfile = '/shelter-profile';
  static const String editShelterProfile = '/edit-shelter-profile';

  // ============================================
  // RUTAS DE CONFIGURACIÓN
  // ============================================
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  static const String notifications = '/notifications';
  static const String language = '/language';
  static const String about = '/about';
  static const String helpCenter = '/help-center';
  static const String termsAndConditions = '/terms';
  static const String privacyPolicy = '/privacy';

  // ============================================
  // MÉTODOS HELPER PARA RUTAS CON PARÁMETROS
  // ============================================

  /// Retorna la ruta del detalle de mascota con su ID
  static String petDetailWithId(String petId) => '$petDetail/$petId';

  /// Retorna la ruta de edición de mascota con su ID
  static String editPetWithId(String petId) => '$editPet/$petId';

  /// Retorna la ruta del detalle de refugio con su ID
  static String shelterDetailWithId(String shelterId) => '$shelterDetail/$shelterId';

  /// Retorna la ruta del detalle de solicitud con su ID
  static String requestDetailWithId(String requestId) => '$requestDetail/$requestId';

  // ============================================
  // NOMBRES DE PARÁMETROS
  // ============================================
  static const String petIdParam = 'petId';
  static const String shelterIdParam = 'shelterId';
  static const String requestIdParam = 'requestId';
  static const String userIdParam = 'userId';

  // ============================================
  // DEEP LINKS (para notificaciones push, etc.)
  // ============================================
  static const String deepLinkPrefix = 'petadopt://';
  static const String deepLinkHome = '${deepLinkPrefix}home';
  static const String deepLinkPet = '${deepLinkPrefix}pet';
  static const String deepLinkRequest = '${deepLinkPrefix}request';
  static const String deepLinkChat = '${deepLinkPrefix}chat';

  // ============================================
  // MÉTODO PARA VALIDAR RUTAS DE ADOPTANTE
  // ============================================
  static bool isAdopterRoute(String route) {
    return [
      home,
      petDetail,
      map,
      chat,
      myRequests,
      profile,
      editProfile,
      shelterDetail,
    ].contains(route);
  }

  // ============================================
  // MÉTODO PARA VALIDAR RUTAS DE REFUGIO
  // ============================================
  static bool isShelterRoute(String route) {
    return [
      shelterDashboard,
      shelterPets,
      createPet,
      editPet,
      shelterRequests,
      requestDetail,
      shelterProfile,
      editShelterProfile,
    ].contains(route);
  }

  // ============================================
  // MÉTODO PARA VALIDAR RUTAS PÚBLICAS (sin auth)
  // ============================================
  static bool isPublicRoute(String route) {
    return [
      splash,
      login,
      register,
      userTypeSelection,
      forgotPassword,
      emailVerification,
      resetPassword,
    ].contains(route);
  }
}