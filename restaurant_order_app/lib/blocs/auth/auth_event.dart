part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? phoneNumber;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, email, password, phoneNumber];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
} 