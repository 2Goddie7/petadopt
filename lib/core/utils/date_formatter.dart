import 'package:intl/intl.dart';

/// Helper para formatear fechas
class DateFormatter {
  // Prevenir instanciación
  DateFormatter._();

  // ============================================
  // FORMATS
  // ============================================
  
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _fullFormat = DateFormat('EEEE, dd MMMM yyyy', 'es');
  static final _shortFormat = DateFormat('dd MMM yyyy', 'es');

  // ============================================
  // DATE FORMATTING
  // ============================================
  
  /// Formatea fecha: 05/01/2026
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }
  
  /// Formatea hora: 14:30
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }
  
  /// Formatea fecha y hora: 05/01/2026 14:30
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }
  
  /// Formatea fecha completa: Lunes, 05 enero 2026
  static String formatFullDate(DateTime date) {
    return _fullFormat.format(date);
  }
  
  /// Formatea fecha corta: 05 ene 2026
  static String formatShortDate(DateTime date) {
    return _shortFormat.format(date);
  }

  // ============================================
  // TIME AGO
  // ============================================
  
  /// Retorna tiempo transcurrido en formato legible
  /// Ejemplos: "Hace 5 minutos", "Hace 2 horas", "Hace 3 días"
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Hace ${minutes} ${minutes == 1 ? 'minuto' : 'minutos'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Hace ${hours} ${hours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Hace ${days} ${days == 1 ? 'día' : 'días'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace ${weeks} ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace ${months} ${months == 1 ? 'mes' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace ${years} ${years == 1 ? 'año' : 'años'}';
    }
  }

  // ============================================
  // AGE CALCULATION
  // ============================================
  
  /// Calcula edad en años
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
  
  /// Formatea edad de mascota
  /// Ejemplos: "2 años", "6 meses", "1 año y 3 meses"
  static String formatPetAge(int years, int months) {
    if (years == 0 && months == 0) {
      return 'Recién nacido';
    } else if (years == 0) {
      return '$months ${months == 1 ? 'mes' : 'meses'}';
    } else if (months == 0) {
      return '$years ${years == 1 ? 'año' : 'años'}';
    } else {
      return '$years ${years == 1 ? 'año' : 'años'} y $months ${months == 1 ? 'mes' : 'meses'}';
    }
  }

  // ============================================
  // DATE COMPARISON
  // ============================================
  
  /// Verifica si una fecha es hoy
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  
  /// Verifica si una fecha es ayer
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
  
  /// Verifica si una fecha es esta semana
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  // ============================================
  // SMART FORMATTING
  // ============================================
  
  /// Formatea fecha de manera inteligente según contexto
  /// Hoy: "Hoy 14:30"
  /// Ayer: "Ayer 14:30"
  /// Esta semana: "Lunes 14:30"
  /// Más antiguo: "05/01/2026"
  static String smartFormat(DateTime date) {
    if (isToday(date)) {
      return 'Hoy ${formatTime(date)}';
    } else if (isYesterday(date)) {
      return 'Ayer ${formatTime(date)}';
    } else if (isThisWeek(date)) {
      final dayName = DateFormat('EEEE', 'es').format(date);
      return '$dayName ${formatTime(date)}';
    } else {
      return formatDate(date);
    }
  }
}