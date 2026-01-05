import 'package:equatable/equatable.dart';
import '../../../../features/auth/domain/entities/user.dart';

/// Eventos de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Iniciar sesión con email
class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Evento: Iniciar sesión con Google
class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

/// Evento: Registrarse
class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final UserType userType;
  final String? phone;

  const SignUpEvent({
    required this.email,
    required this.password,
    required this.fullName,
    required this.userType,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, fullName, userType, phone];
}

/// Evento: Cerrar sesión
class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

/// Evento: Recuperar contraseña
class ResetPasswordEvent extends AuthEvent {
  final String email;

  const ResetPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

/// Evento: Verificar autenticación
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}