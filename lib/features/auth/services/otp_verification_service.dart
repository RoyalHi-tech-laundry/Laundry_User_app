import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:laun_easy/features/auth/models/otp_verification_response.dart';

class OtpVerificationService {
  final String baseUrl = 'http://laundry-app-env.eba-xpc8mpfi.ap-south-1.elasticbeanstalk.com';

  Future<OtpVerificationResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final url = '$baseUrl/api/auth/verify-otp';
    
    print('🔵 Verifying OTP for phone: $phone with OTP: $otp');
    print('🔵 Request URL: $url');
    
    final requestBody = {
      'phone': phone,
      'otp': otp,
    };
    
    print('🔵 Request body: ${jsonEncode(requestBody)}');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('🔵 Response status code: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final parsedResponse = OtpVerificationResponse.fromJsonString(response.body);
        print('🔵 Parsed response: ${parsedResponse.toJson()}');
        
        if (parsedResponse.success) {
          print('🔵 OTP verification successful');
          print('🔵 User: ${parsedResponse.data?.user.name}');
          print('🔵 Token: ${parsedResponse.data?.token.substring(0, 20)}...');
          return parsedResponse;
        } else {
          print('🔴 OTP verification failed: ${parsedResponse.message}');
          throw Exception(parsedResponse.message);
        }
      } else {
        print('🔴 OTP verification failed with status code: ${response.statusCode}');
        
        // Try to parse error message from response
        try {
          final errorResponse = OtpVerificationResponse.fromJsonString(response.body);
          print('🔴 Error message: ${errorResponse.message}');
          throw Exception(errorResponse.message);
        } catch (e) {
          throw Exception('Failed to verify OTP. Please try again.');
        }
      }
    } catch (e) {
      print('🔴 Exception during OTP verification: $e');
      rethrow;
    }
  }
}
