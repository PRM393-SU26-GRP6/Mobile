class LoginResponseModel {
  final bool success;
  final String? message;
  final AuthData? data;

  LoginResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final success = json["success"] ?? false;
    final message = json["message"];

    Map<String, dynamic>? dataMap;
    if (json["data"] != null && json["data"] is Map<String, dynamic>) {
      dataMap = Map<String, dynamic>.from(json["data"] as Map);
    } else if (json["accessToken"] != null ||
        json["refreshToken"] != null ||
        json["user"] != null) {
      dataMap = Map<String, dynamic>.from(json);
    }

    return LoginResponseModel(
      success: success,
      message: message,
      data: dataMap == null ? null : AuthData.fromJson(dataMap),
    );
  }
}

class AuthData {
  final String? accessToken;
  final String? refreshToken;
  final UserAuthData? user;

  AuthData({
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
        user: json["user"] == null ? null : UserAuthData.fromJson(json["user"]),
      );
}

class UserAuthData {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final List<String>? roles;

  UserAuthData({
    this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.roles,
  });

  factory UserAuthData.fromJson(Map<String, dynamic> json) => UserAuthData(
        id: json["id"],
        fullName: json["fullName"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        roles: _parseRoles(json),
      );

  static List<String>? _parseRoles(Map<String, dynamic> json) {
    // API có thể trả về "roles" (array) hoặc "role" (string)
    if (json["roles"] != null) {
      return List<String>.from(json["roles"]);
    }
    if (json["role"] != null) {
      return [json["role"].toString()];
    }
    return null;
  }

  bool get isCustomer =>
      roles?.any((r) => r.toLowerCase() == 'customer') ?? false;

  bool get isOwner => roles?.any((r) => r.toLowerCase() == 'owner') ?? false;
}
