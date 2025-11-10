import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:laun_easy/features/auth/models/phone_check_response.dart';
import 'package:laun_easy/features/auth/models/otp_request_response.dart';

class AuthService {
  final String baseUrl = 'http://laundry-app-env.eba-xpc8mpfi.ap-south-1.elasticbeanstalk.com';
  final Duration _timeout = const Duration(seconds: 15);

  // Check if phone number exists
  Future<PhoneCheckResponse> checkPhoneNumber(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/check-number'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phoneNumber,
        }),
      ).timeout(_timeout);
      
      return _handlePhoneCheckResponse(response);
    } on SocketException {
      throw Exception('No internet connection. Please check your network settings.');
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
      throw Exception('Failed to check phone number: $e');
    }
  }

  // Handle phone check response
  PhoneCheckResponse _handlePhoneCheckResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        return PhoneCheckResponse.fromJson(jsonData);
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // Request OTP
  Future<OtpRequestResponse> requestOtp(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/request-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phoneNumber,
        }),
      ).timeout(_timeout);
      
      return _handleOtpRequestResponse(response);
    } on SocketException {
      throw Exception('No internet connection. Please check your network settings.');
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
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
