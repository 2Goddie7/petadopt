import 'package:equatable/equatable.dart';
import '../../../../features/auth/domain/entities/user.dart';

/// Estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado: Cargando
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado: Registrado (esperando validación)
class AuthRegistered extends AuthState {
  final User user;

  const AuthRegistered({required this.user});

  @override
  List<Object> get props => [user];
}

/// Estado: Autenticado
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object> get props => [user];
}

/// Estado: No autenticado
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Estado: Necesita seleccionar rol (OAuth)
class OAuthRoleSelectionNeeded extends AuthState {
  final String userId;
  final String email;
  final String fullName;

  const OAuthRoleSelectionNeeded({
    required this.userId,
    required this.email,
    required this.fullName,
  });

  @override
  List<Object> get props => [userId, email, fullName];
}

/// Estado: Error
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

/// Estado: Contraseña enviada
class PasswordResetEmailSent extends AuthState {
  final String email;

  const PasswordResetEmailSent({required this.email});

  @override
  List<Object> get props => [email];
}
