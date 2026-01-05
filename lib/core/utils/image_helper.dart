import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Helper para manejo de imágenes
class ImageHelper {
  // Prevenir instanciación
  ImageHelper._();

  static final ImagePicker _picker = ImagePicker();

  // ============================================
  // PICK IMAGES
  // ============================================
  
  /// Selecciona una imagen de la galería
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      return image != null ? File(image.path) : null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }
  
  /// Selecciona una imagen de la cámara
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      return image != null ? File(image.path) : null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }
  
  /// Selecciona múltiples imágenes de la galería
  static Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      // Limitar cantidad
      final limitedImages = images.take(maxImages).toList();
      
      return limitedImages.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // ============================================
  // IMAGE VALIDATION
  // ============================================
  
  /// Verifica si el archivo es una imagen válida
  static bool isValidImage(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }
  
  /// Verifica el tamaño de la imagen
  static Future<bool> isImageSizeValid(File file, int maxSizeBytes) async {
    try {
      final size = await file.length();
      return size <= maxSizeBytes;
    } catch (e) {
      print('Error checking image size: $e');
      return false;
    }
  }
  
  /// Obtiene el tamaño de la imagen en MB
  static Future<double> getImageSizeInMB(File file) async {
    try {
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      print('Error getting image size: $e');
      return 0;
    }
  }

  // ============================================
  // FORMAT
  // ============================================
  
  /// Formatea el tamaño de archivo de manera legible
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}