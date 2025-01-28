import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  void _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Simulate a short delay (like a network request)
    await Future.delayed(const Duration(milliseconds: 500));

    final success = authService.login(event.username, event.password);

    if (success) {
      emit(AuthAuthenticated(event.username));
    } else {
      emit(const AuthFailure("Invalid username or password"));
    }
  }

  void _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    authService.logout();
    emit(AuthInitial());
  }
}
