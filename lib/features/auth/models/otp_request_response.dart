class OtpRequestResponse {
  final String message;
  final String phone;
  final String? otp;
  final bool success;

  OtpRequestResponse({
    required this.message,
    required this.phone,
    this.otp,
    this.success = true,
  });

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) {
    return OtpRequestResponse(
      message: json['message'] ?? '',
      phone: json['phone'] ?? '',
      otp: json['otp'],
      success: json['success'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'phone': phone,
      'otp': otp,
      'success': success,
    };
  }
}
