import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'config/dependency_injection/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/pets/presentation/pages/pets_list_page.dart';
import 'features/pets/presentation/pages/create_pet_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/pets/presentation/bloc/pets_bloc.dart';
import 'features/pets/presentation/bloc/pets_event.dart';
import 'features/adoptions/presentation/bloc/adoptions_bloc.dart';
import 'features/ai_chat/presentation/bloc/chat_bloc.dart';
import 'features/map/presentation/bloc/map_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await ApiConstants.loadConfig();
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );
    await di.init();
    AppTheme.setSystemUIOverlayStyle();
    AppTheme.setPreferredOrientations();
    runApp(const MyApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error de inicialización:\n$e', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Escuchar deep links cuando la app está abierta
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Error en deep link stream: $err');
    });

    // Manejar deep link inicial (cuando la app se abre desde cerrada)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _handleDeepLink(initialUri);
    } catch (e) {
      debugPrint('Error obteniendo initial URI: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('🔗 Deep link recibido: $uri');
    
    // petadopt://auth/success o petadopt://auth/error
    if (uri.scheme == 'petadopt' && uri.host == 'auth') {
      final context = navigatorKey.currentContext;
      if (context == null) return;

      if (uri.path == '/success') {
        final message = uri.queryParameters['message'];
        String text = '✓ Acción completada exitosamente';
        
        if (message == 'email_confirmed') {
          text = '✓ Email confirmado. Ya puedes iniciar sesión';
        } else if (message == 'password_updated') {
          text = '✓ Contraseña actualizada correctamente';
          // Verificar sesión actualizada
          context.read<AuthBloc>().add(const CheckAuthStatusEvent());
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(text),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (uri.path == '/error') {
        final message = uri.queryParameters['message'] ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $message'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            signInWithEmail: di.sl(),
            signInWithGoogle: di.sl(),
            signUp: di.sl(),
            signOut: di.sl(),
            resetPassword: di.sl(),
            getCurrentUser: di.sl(),
          )..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (context) => PetsBloc(
            getAllPets: di.sl(),
            searchPets: di.sl(),
          )..add(LoadPetsEvent()),
        ),
        BlocProvider(
          create: (context) => AdoptionsBloc(
            getUserRequests: di.sl(),
            getShelterRequests: di.sl(),
            createAdoptionRequest: di.sl(),
            approveRequest: di.sl(),
            rejectRequest: di.sl(),
            cancelRequest: di.sl(),
          ),
        ),
        BlocProvider(
          create: (context) => ChatBloc(
            sendMessage: di.sl(),
            getChatHistory: di.sl(),
            clearChatHistory: di.sl(),
          ),
        ),
        BlocProvider(
          create: (context) => MapBloc(
            getAllShelters: di.sl(),
            getNearbyShelters: di.sl(),
            getUserLocation: di.sl(),
          ),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            getProfile: di.sl(),
            updateProfile: di.sl(),
            uploadProfileImage: di.sl(),
            getCurrentUser: di.sl(),
          ),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(
            getFavoritePets: di.sl(),
            isFavorite: di.sl(),
            toggleFavorite: di.sl(),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'PetAdopt',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/home': (context) => const HomePage(),
          '/profile': (context) => const ProfilePage(),
          '/pets': (context) => const PetsListPage(),
          '/create-pet': (context) => const CreatePetPage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        } else if (state is Authenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Cargando PetAdopt...', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}