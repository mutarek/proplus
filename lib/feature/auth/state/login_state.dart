import 'package:proplus/feature/auth/models/response/userResponse.dart';

class LoginState {
  final bool isLoading;
  final UserResponse? user;
  final String? error;

  LoginState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  LoginState copyWith({
    bool? isLoading,
    UserResponse? user,
    String? error,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}
