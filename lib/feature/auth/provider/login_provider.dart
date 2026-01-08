import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:proplus/core/network/dio_client.dart';
import 'package:proplus/feature/auth/models/request/user_request_body.dart';
import 'package:proplus/feature/auth/repository/auth_repository.dart';
import 'package:proplus/feature/auth/state/login_state.dart';


final authProvider = StateNotifierProvider<AuthNotifier, LoginState>((ref) {
  return AuthNotifier(AuthRepository(ref.read(dioClientProvider)),
  );
});

final rememberMeProvider = StateProvider<bool>((ref) {
  return false;
});

final selectedCountryProvider = StateProvider<String>((ref) {
  return 'Bangladesh';
});


class AuthNotifier extends StateNotifier<LoginState>{
  final AuthRepository authRepository;

  AuthNotifier(this.authRepository) : super(LoginState());


  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = UserRequestBody(username: email, password: password, expiresInMins: 30);
      final users = await authRepository.loginUser(userRequestBody: user);
      state = state.copyWith(isLoading: false, user: users);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }


}

