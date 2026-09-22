abstract class AuthState {}

class AuthInitial extends AuthState {
  @override
  String toString() => 'AuthInitial';
}

class AuthLoading extends AuthState {
  @override
  String toString() => 'AuthLoading';
}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess({required this.message});
  @override
  String toString() => 'AuthSuccess{message: $message}';
}

class AuthFailure extends AuthState {
  final String errorMessage;
  AuthFailure({required this.errorMessage});
  @override
  String toString() => 'AuthFailure{errorMessage: $errorMessage}';
}
