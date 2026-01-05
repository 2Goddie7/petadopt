import 'package:flutter/material.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno (.env)
  await ApiConstants.loadConfig();

  // Configurar UI del sistema
  AppTheme.setSystemUIOverlayStyle();
  AppTheme.setPreferredOrientations();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetAdopt',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Tu pantalla inicial
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text('Cargando PetAdopt...', style: Theme.of(context).textTheme.bodyLarge),
        ]),
      ),
    );
  }
}