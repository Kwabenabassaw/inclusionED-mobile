import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/features/authentication/data/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  
  const AuthState({this.isLoading = false, this.errorMessage, this.isSuccess = false});
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();
  
  Future<void> signIn(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password);
      state = const AuthState(isLoading: false, isSuccess: true);
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signUp(String email, String password, String fullName, String studentId) async {
    state = const AuthState(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).signUpWithEmailAndPassword(email, password, fullName, studentId);
      state = const AuthState(isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      state = const AuthState(isLoading: false, isSuccess: true);
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
