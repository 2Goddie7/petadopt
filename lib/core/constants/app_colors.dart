import 'package:flutter/material.dart';

/// Colores principales de la aplicación PetAdopt
/// Basados en el diseño proporcionado
class AppColors {
  // Prevenir instanciación
  AppColors._();

  // ============================================
  // COLORES PRINCIPALES
  // ============================================
  
  /// Color principal naranja - Usado en botones y acentos principales
  static const Color primary = Color(0xFFFF8243);
  
  /// Color naranja más claro - Para hover states y backgrounds
  static const Color primaryLight = Color(0xFFFFB088);
  
  /// Color naranja más oscuro - Para pressed states
  static const Color primaryDark = Color(0xFFE6552A);

  // ============================================
  // COLORES SECUNDARIOS (REFUGIOS)
  // ============================================
  
  /// Color turquesa/verde azulado - Usado en secciones de refugios
  static const Color secondary = Color(0xFF1DB5B5);
  
  /// Color turquesa claro
  static const Color secondaryLight = Color(0xFF4DD4D4);
  
  /// Color turquesa oscuro
  static const Color secondaryDark = Color(0xFF17A2A2);

  // ============================================
  // COLORES DE FONDO
  // ============================================
  
  /// Fondo principal - Crema/Beige muy claro
  static const Color background = Color(0xFFFFFBF5);
  
  /// Fondo de cards - Blanco puro
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  /// Fondo alternativo - Gris muy claro
  static const Color backgroundAlt = Color(0xFFF5F5F5);

  // ============================================
  // COLORES DE TEXTO
  // ============================================
  
  /// Texto principal - Negro/Gris muy oscuro
  static const Color textPrimary = Color(0xFF2D2D2D);
  
  /// Texto secundario - Gris medio
  static const Color textSecondary = Color(0xFF8E8E8E);
  
  /// Texto terciario - Gris claro
  static const Color textTertiary = Color(0xFFC4C4C4);
  
  /// Texto en fondo oscuro - Blanco
  static const Color textOnDark = Color(0xFFFFFFFF);
  
  /// Texto en fondo primary (naranja)
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  /// Texto en fondo secondary (turquesa)
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // ============================================
  // COLORES DE ESTADO
  // ============================================
  
  /// Estado de éxito - Verde
  static const Color success = Color(0xFF4CAF50);
  
  /// Estado de éxito claro - Para backgrounds
  static const Color successLight = Color(0xFFE8F5E9);
  
  /// Estado de error - Rojo
  static const Color error = Color(0xFFF44336);
  
  /// Estado de error claro - Para backgrounds
  static const Color errorLight = Color(0xFFFFEBEE);
  
  /// Estado de advertencia - Amarillo/Naranja
  static const Color warning = Color(0xFFFF9800);
  
  /// Estado de advertencia claro
  static const Color warningLight = Color(0xFFFFF3E0);
  
  /// Estado de información - Azul
  static const Color info = Color(0xFF2196F3);
  
  /// Estado de información claro
  static const Color infoLight = Color(0xFFE3F2FD);

  // ============================================
  // COLORES DE CARDS DE MASCOTAS (PASTELES)
  // ============================================
  
  /// Card amarillo pastel
  static const Color cardYellow = Color(0xFFFFF8DC);
  
  /// Card verde menta pastel
  static const Color cardMint = Color(0xFFE0F4F4);
  
  /// Card azul pastel
  static const Color cardBlue = Color(0xFFE3F2FD);
  
  /// Card rosa pastel
  static const Color cardPink = Color(0xFFFFE4E9);
  
  /// Card lavanda pastel
  static const Color cardLavender = Color(0xFFF3E5F5);
  
  /// Card melocotón pastel
  static const Color cardPeach = Color(0xFFFFE5D9);

  // Lista de colores pastel para asignar aleatoriamente a cards
  static const List<Color> cardColors = [
    cardYellow,
    cardMint,
    cardBlue,
    cardPink,
    cardLavender,
    cardPeach,
  ];

  // ============================================
  // COLORES DE ESTADOS DE SOLICITUD
  // ============================================
  
  /// Estado pendiente - Amarillo
  static const Color statusPending = Color(0xFFFFC107);
  
  /// Background para estado pendiente
  static const Color statusPendingBg = Color(0xFFFFF9E6);
  
  /// Estado aprobado - Verde
  static const Color statusApproved = Color(0xFF4CAF50);
  
  /// Background para estado aprobado
  static const Color statusApprovedBg = Color(0xFFE8F5E9);
  
  /// Estado rechazado - Rojo
  static const Color statusRejected = Color(0xFFF44336);
  
  /// Background para estado rechazado
  static const Color statusRejectedBg = Color(0xFFFFEBEE);

  // ============================================
  // COLORES DE NAVEGACIÓN
  // ============================================
  
  /// Color del bottom navigation bar - Blanco
  static const Color bottomNavBar = Color(0xFFFFFFFF);
  
  /// Color del item activo en navigation
  static const Color navItemActive = primary;
  
  /// Color del item inactivo en navigation
  static const Color navItemInactive = Color(0xFFBDBDBD);

  // ============================================
  // COLORES DE INPUTS Y BORDERS
  // ============================================
  
  /// Border de inputs - Gris claro
  static const Color inputBorder = Color(0xFFE0E0E0);
  
  /// Border de inputs en foco
  static const Color inputBorderFocused = primary;
  
  /// Background de inputs
  static const Color inputBackground = Color(0xFFFFFFFF);
  
  /// Color de placeholder en inputs
  static const Color inputPlaceholder = Color(0xFFBDBDBD);

  // ============================================
  // COLORES DE SOMBRAS Y DIVIDERS
  // ============================================
  
  /// Sombra suave
  static const Color shadow = Color(0x1A000000);
  
  /// Sombra media
  static const Color shadowMedium = Color(0x33000000);
  
  /// Divider - Línea divisoria
  static const Color divider = Color(0xFFE0E0E0);

  // ============================================
  // COLORES ESPECÍFICOS DE FEATURES
  // ============================================
  
  /// Color del header de chat IA
  static const Color chatHeader = primary;
  
  /// Background del mensaje del usuario
  static const Color chatUserBubble = primary;
  
  /// Background del mensaje de la IA
  static const Color chatAiBubble = Color(0xFFF5F5F5);
  
  /// Color de los marcadores en el mapa
  static const Color mapMarkerUser = error;
  
  /// Color de los marcadores de refugios en el mapa
  static const Color mapMarkerShelter = secondary;

  // ============================================
  // GRADIENTES
  // ============================================
  
  /// Gradiente naranja para botones y headers
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF8243), Color(0xFFFFB088)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente turquesa para secciones de refugio
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF1DB5B5), Color(0xFF4DD4D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // COLORES PARA GÉNERO DE MASCOTAS
  // ============================================
  
  /// Masculino - Azul suave
  static const Color genderMale = Color(0xFF64B5F6);
  
  /// Femenino - Rosa suave
  static const Color genderFemale = Color(0xFFFF8A80);

  // ============================================
  // COLORES PARA TIPO DE MASCOTA
  // ============================================
  
  /// Perros - Naranja
  static const Color petDog = Color(0xFFFF8243);
  
  /// Gatos - Púrpura
  static const Color petCat = Color(0xFF9C27B0);
  
  /// Otros - Gris
  static const Color petOther = Color(0xFF757575);

  // ============================================
  // MÉTODO HELPER PARA OBTENER COLOR DE CARD
  // ============================================
  
  /// Retorna un color de card basado en un índice
  static Color getCardColor(int index) {
    return cardColors[index % cardColors.length];
  }

  /// Retorna color según el género de la mascota
  static Color getGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
      case 'macho':
        return genderMale;
      case 'female':
      case 'hembra':
        return genderFemale;
      default:
        return textSecondary;
    }
  }

  /// Retorna color según el tipo de mascota
  static Color getPetTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
      case 'perro':
        return petDog;
      case 'cat':
      case 'gato':
        return petCat;
      default:
        return petOther;
    }
  }

  /// Retorna color según el estado de la solicitud
  static Color getRequestStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pendiente':
        return statusPending;
      case 'approved':
      case 'aprobada':
        return statusApproved;
      case 'rejected':
      case 'rechazada':
        return statusRejected;
      default:
        return textSecondary;
    }
  }

  /// Retorna background color según el estado de la solicitud
  static Color getRequestStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pendiente':
        return statusPendingBg;
      case 'approved':
      case 'aprobada':
        return statusApprovedBg;
      case 'rejected':
      case 'rechazada':
        return statusRejectedBg;
      default:
        return backgroundAlt;
    }
  }
}