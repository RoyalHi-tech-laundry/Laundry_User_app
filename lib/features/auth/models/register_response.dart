class RegisterResponse {
  final String message;
  final String phone;
  final bool success;
  final String? error;

  RegisterResponse({
    required this.message,
    required this.phone,
    this.success = true,
    this.error,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
      phone: json['phone'] ?? '',
      success: !json.containsKey('error'),
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'phone': phone,
      'success': success,
      'error': error,
    };
  }
}
