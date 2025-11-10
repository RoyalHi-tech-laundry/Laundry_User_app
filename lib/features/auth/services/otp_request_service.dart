import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:laun_easy/features/auth/models/otp_request_response.dart';

class OtpRequestService {
  final String baseUrl = 'http://laundry-app-env.eba-xpc8mpfi.ap-south-1.elasticbeanstalk.com';
  final Duration _timeout = const Duration(seconds: 15);

  // Request OTP
  Future<OtpRequestResponse> requestOtp(String phoneNumber) async {
    try {
      print('=== Requesting OTP for phone: $phoneNumber ===');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/request-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phoneNumber,
        }),
      ).timeout(_timeout);
      
      // Log the raw response
      print('=== OTP API Response: ${response.body} ===');
      
      final otpResponse = _handleOtpRequestResponse(response);
      
      // Log the parsed response
      print('=== Parsed OTP Response: ${otpResponse.toJson()} ===');
      print('=== OTP for testing: ${otpResponse.otp} ===');
      
      return otpResponse;
    } on SocketException {
      throw Exception('No internet connection. Please check your network settings.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      print('=== Error requesting OTP: $e ===');
      throw Exception('Failed to request OTP: $e');
    }
  }

  // Handle OTP request response
  OtpRequestResponse _handleOtpRequestResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        return OtpRequestResponse.fromJson(jsonData);
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
