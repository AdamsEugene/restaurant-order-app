import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import 'package:restaurant_order_app/repositories/auth/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(Unauthenticated()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // In a real app, we would check for a valid token in local storage
    // and automatically log the user in if it exists
    emit(Unauthenticated());
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final result = await authRepository.login(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );
      
      if (result['success']) {
        emit(Authenticated(
          token: result['token'],
          user: result['user'],
        ));
      } else {
        emit(AuthFailure(message: result['message'] ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthFailure(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final result = await authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      
      if (result['success']) {
        emit(Authenticated(
          token: result['token'],
          user: result['user'],
        ));
      } else {
        emit(AuthFailure(message: result['message'] ?? 'Registration failed'));
      }
    } catch (e) {
      emit(AuthFailure(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final success = await authRepository.logout();
      
      if (success) {
        emit(Unauthenticated());
      } else {
        emit(AuthFailure(message: 'Logout failed'));
      }
    } catch (e) {
      emit(AuthFailure(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onPasswordResetRequested(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final result = await authRepository.resetPassword(event.email);
      
      if (result['success']) {
        emit(PasswordResetEmailSent());
      } else {
        emit(AuthFailure(message: result['message'] ?? 'Password reset failed'));
      }
    } catch (e) {
      emit(AuthFailure(message: 'An error occurred: ${e.toString()}'));
    }
  }
} 