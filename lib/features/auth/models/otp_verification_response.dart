import 'dart:convert';

class OtpVerificationResponse {
  final bool success;
  final String message;
  final OtpVerificationData? data;

  OtpVerificationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerificationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? OtpVerificationData.fromJson(json['data']) : null,
    );
  }

  factory OtpVerificationResponse.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    
    // Check if the response has the expected structure or direct user/token format
    if (json.containsKey('user') && json.containsKey('token')) {
      // Direct format from API
      return OtpVerificationResponse(
        success: true,
        message: 'OTP verified successfully',
        data: OtpVerificationData(
          token: json['token'] ?? '',
          user: User.fromJson(json['user'] ?? {}),
        ),
      );
    }
    
    // Standard format with success/message/data
    return OtpVerificationResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class OtpVerificationData {
  final String token;
  final User user;

  OtpVerificationData({
    required this.token,
    required this.user,
  });

  factory OtpVerificationData.fromJson(Map<String, dynamic> json) {
    return OtpVerificationData(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

class User {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }
}
