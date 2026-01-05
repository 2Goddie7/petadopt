import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Cargar variables de entorno (.env)
    await ApiConstants.loadConfig();

    // 2. Inicializar Supabase
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );

    // 3. Configurar UI del sistema
    AppTheme.setSystemUIOverlayStyle();
    AppTheme.setPreferredOrientations();

    // 4. Ejecutar app
    runApp(const MyApp());
  } catch (e) {
    // Si falla la inicialización, mostrar error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error de inicialización:\n$e',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetAdopt',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

/// Pantalla de splash mientras verifica autenticación
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verificar si hay usuario autenticado
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // Usuario autenticado - navegar a home
      // TODO: Implementar navegación cuando tengas las páginas
      _showMessage('Usuario autenticado: ${session.user.email}');
    } else {
      // No hay usuario - navegar a login
      // TODO: Implementar navegación cuando tengas las páginas
      _showMessage('No hay usuario autenticado');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo o icono de la app
            Icon(
              Icons.pets,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            
            // Indicador de carga
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            
            // Texto
            Text(
              'Cargando PetAdopt...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Conectando con Supabase',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}