/// Clase de validación para formularios
class Validators {
  // Prevenir instanciación
  Validators._();

  // ============================================
  // EMAIL
  // ============================================
  
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }

  // ============================================
  // PASSWORD
  // ============================================
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    return null;
  }
  
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  // ============================================
  // REQUIRED FIELD
  // ============================================
  
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  // ============================================
  // NAME
  // ============================================
  
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    return null;
  }

  // ============================================
  // PHONE
  // ============================================
  
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }
    
    // Validar formato ecuatoriano: 09########
    final phoneRegex = RegExp(r'^0[9][0-9]{8}$');
    
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Ingresa un número válido (09########)';
    }
    
    return null;
  }

  // ============================================
  // URL
  // ============================================
  
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Ingresa una URL válida';
    }
    
    return null;
  }

  // ============================================
  // NUMBER
  // ============================================
  
  static String? number(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    
    if (int.tryParse(value) == null) {
      return 'Ingresa un número válido';
    }
    
    return null;
  }
  
  static String? positiveNumber(String? value, [String? fieldName]) {
    final numberError = number(value, fieldName);
    if (numberError != null) return numberError;
    
    if (int.parse(value!) < 0) {
      return 'El número debe ser positivo';
    }
    
    return null;
  }

  // ============================================
  // MIN/MAX LENGTH
  // ============================================
  
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    
    if (value.length < min) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $min caracteres';
    }
    
    return null;
  }
  
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value == null) return null;
    
    if (value.length > max) {
      return '${fieldName ?? 'Este campo'} debe tener máximo $max caracteres';
    }
    
    return null;
  }

  // ============================================
  // CUSTOM VALIDATORS
  // ============================================
  
  /// Validador para descripción de mascota
  static String? petDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción es requerida';
    }
    
    if (value.trim().length < 20) {
      return 'La descripción debe tener al menos 20 caracteres';
    }
    
    if (value.length > 500) {
      return 'La descripción no puede exceder 500 caracteres';
    }
    
    return null;
  }
  
  /// Validador para nombre de mascota
  static String? petName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de la mascota es requerido';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (value.length > 50) {
      return 'El nombre no puede exceder 50 caracteres';
    }
    
    return null;
  }
}