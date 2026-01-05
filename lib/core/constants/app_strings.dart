/// Strings y textos constantes de la aplicación PetAdopt
class AppStrings {
  // Prevenir instanciación
  AppStrings._();

  // ============================================
  // GENERAL
  // ============================================
  static const String appName = 'PetAdopt';
  static const String appSlogan = 'Encuentra tu compañero perfecto';
  static const String appDescription = 'Adopta, no compres';

  // ============================================
  // AUTENTICACIÓN
  // ============================================
  
  // Login
  static const String loginTitle = '¡Bienvenido!';
  static const String loginSubtitle = 'Inicia sesión para continuar';
  static const String emailLabel = 'EMAIL';
  static const String emailHint = 'tu@email.com';
  static const String passwordLabel = 'CONTRASEÑA';
  static const String passwordHint = '••••••••';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String loginButton = 'Iniciar Sesión';
  static const String orContinueWith = 'o continúa con';
  static const String googleButton = 'Google';
  static const String noAccount = '¿No tienes cuenta?';
  static const String register = 'Regístrate';

  // Register
  static const String registerTitle = 'Crear Cuenta';
  static const String registerSubtitle = 'Únete a nuestra comunidad';
  static const String fullNameLabel = 'NOMBRE COMPLETO';
  static const String fullNameHint = 'Juan Pérez';
  static const String phoneLabel = 'TELÉFONO (OPCIONAL)';
  static const String phoneHint = '+593 99 123 4567';
  static const String confirmPasswordLabel = 'CONFIRMAR CONTRASEÑA';
  static const String confirmPasswordHint = '••••••••';
  static const String registerButton = 'Crear Cuenta';
  static const String alreadyHaveAccount = '¿Ya tienes cuenta?';
  static const String login = 'Inicia Sesión';
  static const String acceptTerms = 'Acepto los términos y condiciones';

  // User Type Selection
  static const String userTypeTitle = '¿Quién eres?';
  static const String userTypeSubtitle = 'Selecciona el tipo de cuenta que deseas crear';
  static const String adopterTitle = 'Adoptante';
  static const String adopterDescription = 'Busco adoptar una mascota y darle un hogar lleno de amor';
  static const String shelterTitle = 'Refugio';
  static const String shelterDescription = 'Represento un refugio o fundación de animales';

  // Forgot Password
  static const String forgotPasswordTitle = 'Recuperar Contraseña';
  static const String forgotPasswordSubtitle = 'Ingresa tu email para recibir instrucciones';
  static const String sendInstructions = 'Enviar Instrucciones';
  static const String backToLogin = 'Volver a Iniciar Sesión';

  // ============================================
  // NAVEGACIÓN PRINCIPAL
  // ============================================
  static const String navHome = 'Inicio';
  static const String navMap = 'Mapa';
  static const String navChat = 'Chat IA';
  static const String navRequests = 'Solicitudes';
  static const String navProfile = 'Perfil';
  static const String navPets = 'Mascotas';

  // ============================================
  // HOME / LISTA DE MASCOTAS
  // ============================================
  static const String homeGreeting = 'Hola';
  static const String homeTitle = 'Encuentra tu mascota';
  static const String searchHint = 'Buscar mascota...';
  static const String filterAll = 'Todos';
  static const String filterDogs = 'Perros';
  static const String filterCats = 'Gatos';
  static const String filterOther = 'Otros';
  static const String noPetsFound = 'No se encontraron mascotas';
  static const String noPetsDescription = 'Intenta cambiar los filtros de búsqueda';
  static const String distance = 'km';

  // ============================================
  // DETALLE DE MASCOTA
  // ============================================
  static const String petDetails = 'Detalles';
  static const String available = 'Disponible';
  static const String pending = 'Pendiente';
  static const String adopted = 'Adoptado';
  static const String ageLabel = 'Edad';
  static const String genderLabel = 'Sexo';
  static const String sizeLabel = 'Tamaño';
  static const String male = 'Macho';
  static const String female = 'Hembra';
  static const String small = 'Pequeño';
  static const String medium = 'Mediano';
  static const String large = 'Grande';
  static const String years = 'años';
  static const String months = 'meses';
  static const String shelterInfo = 'Refugio';
  static const String aboutPet = 'Sobre';
  static const String healthStatus = 'Estado de Salud';
  static const String vaccinated = 'Vacunado/a';
  static const String dewormed = 'Desparasitado/a';
  static const String sterilized = 'Esterilizado/a';
  static const String microchip = 'Microchip';
  static const String specialCare = 'Requiere cuidados especiales';
  static const String requestAdoption = 'Solicitar Adopción';
  static const String adoptionRequested = 'Solicitud Enviada';
  static const String callShelter = 'Llamar al Refugio';

  // ============================================
  // MAPA
  // ============================================
  static const String mapTitle = 'Refugios Cercanos';
  static const String searchShelters = 'Buscar refugios...';
  static const String yourLocation = 'Tú';
  static const String sheltersNearby = 'refugios cercanos';
  static const String getDirections = 'Obtener Direcciones';
  static const String viewPets = 'Ver Mascotas';
  static const String noLocationPermission = 'Permiso de ubicación denegado';
  static const String enableLocation = 'Habilita el acceso a tu ubicación para ver refugios cercanos';
  static const String openSettings = 'Abrir Configuración';

  // ============================================
  // CHAT IA
  // ============================================
  static const String chatTitle = 'Asistente PetAdopt';
  static const String chatPoweredBy = 'Powered by Gemini AI';
  static const String chatWelcome = '¡Hola! 🐾 Soy tu asistente de mascotas. ¿En qué puedo ayudarte hoy?';
  static const String chatPlaceholder = 'Escribe tu pregunta...';
  static const String chatError = 'Ocurrió un error. Intenta nuevamente.';
  static const String chatEmpty = 'Inicia una conversación';
  static const String chatEmptyDescription = 'Pregúntame sobre cuidados, salud o comportamiento de mascotas';
  static const String chatExamples = 'Ejemplos:';
  static const String chatExample1 = '¿Cómo cuidar a un cachorro?';
  static const String chatExample2 = '¿Qué vacunas necesita un gato?';
  static const String chatExample3 = '¿Cómo entrenar a mi perro?';

  // ============================================
  // SOLICITUDES DE ADOPCIÓN
  // ============================================
  static const String myRequestsTitle = 'Mis Solicitudes';
  static const String allRequests = 'Todas';
  static const String pendingRequests = 'Pendientes';
  static const String approvedRequests = 'Aprobadas';
  static const String rejectedRequests = 'Rechazadas';
  static const String requestFor = 'Solicitud para';
  static const String requestFrom = 'De:';
  static const String requestDate = 'Fecha:';
  static const String requestStatus = 'Estado:';
  static const String statusPending = 'Pendiente';
  static const String statusApproved = 'Aprobada';
  static const String statusRejected = 'Rechazada';
  static const String approveRequest = 'Aprobar';
  static const String rejectRequest = 'Rechazar';
  static const String cancelRequest = 'Cancelar Solicitud';
  static const String noRequests = 'No tienes solicitudes';
  static const String noRequestsDescription = 'Cuando solicites adoptar una mascota, aparecerán aquí';
  static const String rejectionReason = 'Motivo del rechazo';

  // ============================================
  // PANEL DE REFUGIO
  // ============================================
  static const String dashboardTitle = 'Panel de Administración';
  static const String stats = 'Estadísticas';
  static const String totalPets = 'Mascotas';
  static const String totalPending = 'Pendientes';
  static const String totalAdopted = 'Adoptadas';
  static const String recentRequests = 'Solicitudes Recientes';
  static const String viewAll = 'Ver todas';
  static const String myPets = 'Mis Mascotas';
  static const String addPet = 'Agregar';
  static const String editPet = 'Editar';
  static const String deletePet = 'Eliminar';
  static const String noPets = 'No tienes mascotas registradas';
  static const String noPetDescription = 'Agrega tu primera mascota para comenzar'; // noPetsDescription OJOOO

  // ============================================
  // CREAR/EDITAR MASCOTA
  // ============================================
  static const String newPet = 'Nueva Mascota';
  static const String editPetTitle = 'Editar Mascota';
  static const String completeAllFields = 'Completa todos los campos requeridos';
  static const String petPhotos = 'Fotos de la Mascota';
  static const String photosDescription = 'Mínimo 1 foto, máximo 5. La primera será la principal.';
  static const String mainPhoto = 'PRINCIPAL';
  static const String setAsMain = 'Hacer principal';
  static const String addPhoto = 'Agregar';
  static const String photosAdded = 'fotos agregadas. Las fotos de buena calidad aumentan las adopciones.';
  static const String basicInfo = 'Información Básica';
  static const String petNameLabel = 'NOMBRE DE LA MASCOTA';
  static const String petNameHint = 'Ej: Luna, Rocky, Michi...';
  static const String speciesLabel = 'ESPECIE';
  static const String selectSpecies = 'Selecciona una especie';
  static const String dog = 'Perro';
  static const String cat = 'Gato';
  static const String other = 'Otro';
  static const String breedLabel = 'RAZA';
  static const String breedHint = 'Ej: Labrador, Persa, Mestizo...';
  static const String ageYearsLabel = 'EDAD (AÑOS)';
  static const String ageMonthsLabel = 'MESES';
  static const String genderInput = 'SEXO';
  static const String sizeInput = 'TAMAÑO';
  static const String description = 'Descripción';
  static const String descriptionLabel = 'CUÉNTANOS SOBRE ESTA MASCOTA';
  static const String descriptionHint = 'Describe su personalidad, historia, comportamiento con niños y otras mascotas, nivel de actividad, qué tipo de hogar sería ideal...';
  static const String characterLimit = '0/500';
  static const String suggestions = 'Sugerencias:';
  static const String playful = '+ Juguetón';
  static const String calm = '+ Tranquilo';
  static const String affectionate = '+ Cariñoso';
  static const String goodWithKids = '+ Ideal para niños';
  static const String apartmentFriendly = '+ Apto departamento';
  static const String healthStatusLabel = 'Estado de Salud';
  static const String vaccinatedOption = 'Tiene todas las vacunas al día';
  static const String dewormedOption = 'Tratamiento antiparasitario completado';
  static const String sterilizedOption = 'Ha sido castrado/a o esterilizado/a';
  static const String microchipOption = 'Tiene microchip de identificación';
  static const String specialCareOption = 'Necesita medicación o atención particular';
  static const String additionalHealthNotes = 'NOTAS ADICIONALES DE SALUD (OPCIONAL)';
  static const String healthNotesHint = 'Alergias, medicamentos, condiciones crónicas, historial médico relevante...';
  static const String publishPet = 'Publicar Mascota';
  static const String updatePet = 'Actualizar Mascota';
  static const String saveDraft = 'Guardar Borrador';

  // ============================================
  // PERFIL
  // ============================================
  static const String profile = 'Perfil';
  static const String editProfile = 'Editar Perfil';
  static const String accountSettings = 'Configuración de Cuenta';
  static const String changePassword = 'Cambiar Contraseña';
  static const String notifications = 'Notificaciones';
  static const String language = 'Idioma';
  static const String about = 'Acerca de';
  static const String helpCenter = 'Centro de Ayuda';
  static const String termsAndConditions = 'Términos y Condiciones';
  static const String privacyPolicy = 'Política de Privacidad';
  static const String logout = 'Cerrar Sesión';
  static const String deleteAccount = 'Eliminar Cuenta';

  // ============================================
  // PERFIL DE REFUGIO
  // ============================================
  static const String shelterProfile = 'Perfil del Refugio';
  static const String shelterNameLabel = 'NOMBRE DEL REFUGIO';
  static const String shelterDescriptionLabel = 'DESCRIPCIÓN';
  static const String addressLabel = 'DIRECCIÓN';
  static const String cityLabel = 'CIUDAD';
  static const String websiteLabel = 'SITIO WEB (OPCIONAL)';
  static const String saveChanges = 'Guardar Cambios';

  // ============================================
  // DIÁLOGOS Y MENSAJES
  // ============================================
  static const String confirm = 'Confirmar';
  static const String cancel = 'Cancelar';
  static const String accept = 'Aceptar';
  static const String delete = 'Eliminar';
  static const String yes = 'Sí';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String close = 'Cerrar';
  static const String save = 'Guardar';
  static const String edit = 'Editar';
  static const String send = 'Enviar';
  static const String retry = 'Reintentar';
  static const String skip = 'Omitir';

  // Confirmaciones
  static const String confirmLogout = '¿Estás seguro que deseas cerrar sesión?';
  static const String confirmDeleteAccount = '¿Estás seguro que deseas eliminar tu cuenta? Esta acción no se puede deshacer.';
  static const String confirmDeletePet = '¿Estás seguro que deseas eliminar esta mascota?';
  static const String confirmCancelRequest = '¿Deseas cancelar esta solicitud de adopción?';
  static const String confirmApproveRequest = '¿Aprobar esta solicitud de adopción?';
  static const String confirmRejectRequest = '¿Rechazar esta solicitud de adopción?';

  // Mensajes de éxito
  static const String loginSuccess = 'Inicio de sesión exitoso';
  static const String registerSuccess = 'Cuenta creada exitosamente';
  static const String profileUpdated = 'Perfil actualizado';
  static const String petCreated = 'Mascota publicada exitosamente';
  static const String petUpdated = 'Mascota actualizada';
  static const String petDeleted = 'Mascota eliminada';
  static const String requestSent = 'Solicitud enviada';
  static const String requestCancelled = 'Solicitud cancelada';
  static const String requestApproved = 'Solicitud aprobada';
  static const String requestRejected = 'Solicitud rechazada';
  static const String passwordResetSent = 'Instrucciones enviadas a tu email';

  // Mensajes de error
  static const String errorGeneric = 'Ocurrió un error. Intenta nuevamente.';
  static const String errorNetwork = 'Error de conexión. Verifica tu internet.';
  static const String errorInvalidEmail = 'Email inválido';
  static const String errorInvalidPassword = 'La contraseña debe tener al menos 8 caracteres';
  static const String errorPasswordsNotMatch = 'Las contraseñas no coinciden';
  static const String errorEmailInUse = 'Este email ya está registrado';
  static const String errorUserNotFound = 'Usuario no encontrado';
  static const String errorWrongPassword = 'Contraseña incorrecta';
  static const String errorWeakPassword = 'La contraseña es muy débil';
  static const String errorRequiredFields = 'Completa todos los campos requeridos';
  static const String errorMinPhotos = 'Debes agregar al menos 1 foto';
  static const String errorMaxPhotos = 'Máximo 5 fotos permitidas';
  static const String errorImageUpload = 'Error al subir la imagen';
  static const String errorLoadingData = 'Error al cargar los datos';

  // ============================================
  // VALIDACIONES
  // ============================================
  static const String validationRequired = 'Este campo es requerido';
  static const String validationEmail = 'Ingresa un email válido';
  static const String validationPassword = 'Mínimo 8 caracteres';
  static const String validationPasswordMatch = 'Las contraseñas no coinciden';
  static const String validationPhone = 'Número de teléfono inválido';
  static const String validationUrl = 'URL inválida';
  static const String validationMinLength = 'Mínimo {min} caracteres';
  static const String validationMaxLength = 'Máximo {max} caracteres';
  static const String validationNumberOnly = 'Solo números';

  // ============================================
  // ESTADOS DE CARGA
  // ============================================
  static const String loading = 'Cargando...';
  static const String loadingPets = 'Cargando mascotas...';
  static const String loadingShelters = 'Cargando refugios...';
  static const String loadingRequests = 'Cargando solicitudes...';
  static const String uploading = 'Subiendo...';
  static const String processing = 'Procesando...';
  static const String sending = 'Enviando...';

  // ============================================
  // PERMISOS
  // ============================================
  static const String permissionCamera = 'Permiso de Cámara';
  static const String permissionCameraMessage = 'Necesitamos acceso a tu cámara para tomar fotos';
  static const String permissionGallery = 'Permiso de Galería';
  static const String permissionGalleryMessage = 'Necesitamos acceso a tu galería para seleccionar fotos';
  static const String permissionLocation = 'Permiso de Ubicación';
  static const String permissionLocationMessage = 'Necesitamos tu ubicación para mostrar refugios cercanos';
  static const String permissionDenied = 'Permiso denegado';
  static const String permissionDeniedMessage = 'No podemos continuar sin este permiso';

  // ============================================
  // OTROS
  // ============================================
  static const String comingSoon = 'Próximamente';
  static const String underDevelopment = 'Esta función está en desarrollo';
  static const String noInternet = 'Sin conexión a internet';
  static const String tryAgain = 'Intenta nuevamente';
  static const String refresh = 'Actualizar';
  static const String version = 'Versión';
  static const String developedBy = 'Desarrollado por';
}