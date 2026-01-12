import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../../../features/auth/domain/usecases/complete_oauth_profile.dart';
import '../../../../features/auth/domain/usecases/sign_up.dart';
import '../../../../features/auth/domain/usecases/sign_out.dart';
import '../../../../features/auth/domain/usecases/reset_password.dart';
import '../../../../features/auth/domain/usecases/get_current_user.dart';

/// BLoC de autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final CompleteOAuthProfile completeOAuthProfile;
  final SignUp signUp;
  final SignOut signOut;
  final ResetPassword resetPassword;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.signInWithEmail,
    required this.signInWithGoogle,
    required this.completeOAuthProfile,
    required this.signUp,
    required this.signOut,
    required this.resetPassword,
    required this.getCurrentUser,
  }) : super(const AuthInitial()) {
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<CompleteOAuthProfileEvent>(_onCompleteOAuthProfile);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
    on<ResetPasswordEvent>(_onResetPassword);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  /// Iniciar sesión con email
  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signInWithEmail(
      SignInParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  /// Iniciar sesión con Google
  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signInWithGoogle();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        // Verificar si el usuario necesita seleccionar rol (OAuth sin user_type)
        if (user.userType == null) {
          emit(OAuthRoleSelectionNeeded(
            userId: user.id,
            email: user.email,
            fullName: user.fullName,
          ));
        } else {
          emit(Authenticated(user: user));
        }
      },
    );
  }

  /// Completar perfil OAuth después de seleccionar rol
  Future<void> _onCompleteOAuthProfile(
    CompleteOAuthProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await completeOAuthProfile(
      CompleteOAuthProfileParams(
        userId: event.userId,
        userType: event.userType,
        phone: event.phone,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  /// Registrarse
  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        userType: event.userType,
        phone: event.phone,
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthRegistered(user: user)),
    );
  }

  /// Cerrar sesión
  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔓 AuthBloc - Iniciando cierre de sesión...');

    final result = await signOut();

    result.fold(
      (failure) {
        print('❌ AuthBloc - Error al cerrar sesión: ${failure.message}');
        // Siempre emitir Unauthenticated incluso si hay error
        emit(const Unauthenticated());
      },
      (_) {
        print('✅ AuthBloc - Sesión cerrada correctamente');
        // Emitir directamente sin AuthLoading
        emit(const Unauthenticated());
      },
    );
  }

  /// Recuperar contraseña
  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await resetPassword(
      ResetPasswordParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(PasswordResetEmailSent(email: event.email)),
    );
  }

  /// Verificar estado de autenticación
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUser();

    result.fold(
      (_) => emit(const Unauthenticated()),
      (user) {
        if (user == null) {
          emit(const Unauthenticated());
        } else {
          emit(Authenticated(user: user));
        }
      },
    );
  }
}
