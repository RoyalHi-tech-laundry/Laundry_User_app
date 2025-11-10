class PhoneCheckResponse {
  final bool exists;
  final bool success;
  final String? message;

  PhoneCheckResponse({
    required this.exists,
    required this.success,
    this.message,
  });

  factory PhoneCheckResponse.fromJson(Map<String, dynamic> json) {
    return PhoneCheckResponse(
      exists: json['exists'] ?? false,
      success: json['success'] ?? true,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exists': exists,
      'success': success,
      'message': message,
    };
  }
}
