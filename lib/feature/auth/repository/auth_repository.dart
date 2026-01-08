import 'package:proplus/core/constants/api_config.dart';
import 'package:proplus/core/network/dio_client.dart';
import 'package:proplus/core/error/app_exception.dart';
import 'package:proplus/feature/auth/models/request/user_request_body.dart';
import 'package:proplus/feature/auth/models/response/userResponse.dart';



class AuthRepository {
  final DioClient dioClient;

  AuthRepository(this.dioClient);

  /// Login user with email and password
  Future<UserResponse> loginUser({required UserRequestBody userRequestBody}) async {
    try {
      final response = await dioClient.post(
        ApiConfig.loginPath,
        data: userRequestBody.toJson()
      );
      return UserResponse.fromJson(response.data);
    } on AppException {
      rethrow; // pass to usecase / presentation
    }
  }
}