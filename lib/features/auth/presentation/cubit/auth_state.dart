abstract class AuthState {}

class AuthInatialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {}

class AuthVerifyEmailState extends AuthState {}

class AuthTermsState extends AuthState {
  final bool accepted;

  AuthTermsState({required this.accepted});
}

class AuthPasswordResetEmailSentState extends AuthState {}

class AuthPasswordResetSuccessState extends AuthState {}

class AuthErrorState extends AuthState {
  final String error;

  AuthErrorState({required this.error});
}