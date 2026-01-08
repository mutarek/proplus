class UserRequestBody {
  final String username;
  final String password;
  final int expiresInMins;

  const UserRequestBody({
    required this.username,
    required this.password,
    required this.expiresInMins,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'expiresInMins': expiresInMins,
    };
  }

  factory UserRequestBody.fromJson(Map<String, dynamic> json) {
    return UserRequestBody(
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      expiresInMins: (json['expiresInMins'] is int)
          ? json['expiresInMins'] as int
          : int.tryParse('${json['expiresInMins']}') ?? 0,
    );
  }

  @override
  String toString() =>
      'UserRequestBody(username: $username, expiresInMins: $expiresInMins)';
}