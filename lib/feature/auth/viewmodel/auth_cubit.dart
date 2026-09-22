import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(AuthInitial());

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await _repository.signUp(
        username: username,
        email: email,
        password: password,
      );
      emit(AuthSuccess(
        message: 'Account created successfully! Please verify your email before signing in.',
      ));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await _repository.signIn(email: email, password: password);
      emit(AuthSuccess(message: 'Signed in successfully!'));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(errorMessage: 'An error occurred while signing out'));
    }
  }

  Future<void> resetPassword({required String email}) async {
    emit(AuthLoading());
    try {
      await _repository.resetPassword(email: email);
      emit(AuthSuccess(message: 'Password reset email sent! Please check your inbox.'));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await _repository.signInWithGoogle();
      emit(AuthSuccess(message: 'Google Sign-In successful!'));
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        emit(AuthInitial());
        return;
      }
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }
}
