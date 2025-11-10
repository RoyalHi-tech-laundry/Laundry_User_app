import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:laun_easy/features/auth/models/phone_check_response.dart';

class PhoneCheckService {
  final String baseUrl = 'http://laundry-app-env.eba-xpc8mpfi.ap-south-1.elasticbeanstalk.com';
  final Duration _timeout = const Duration(seconds: 15);

  // Check if phone number exists
  Future<PhoneCheckResponse> checkPhoneNumber(String phoneNumber) async {
    try {
      final url = '$baseUrl/api/auth/check-number';
      final requestBody = jsonEncode({
        'phone': phoneNumber,
      });
      
    
      // Log request details
      print('=== Phone Check Request URL: $url ===');
      print('=== Phone Check Request Body: $requestBody ===');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      ).timeout(_timeout);
      
      // Log response
      print('=== Phone Check Response Status: ${response.statusCode} ===');
      print('=== Phone Check Response Body: ${response.body} ===');
      
      return _handlePhoneCheckResponse(response);
    } on SocketException {
      final error = 'No internet connection. Please check your network settings.';
      print('=== PhoneCheckService Error: $error ===');
      throw Exception(error);
    } on TimeoutException {
      final error = 'Request timed out. Please try again.';
      print('=== PhoneCheckService Error: $error ===');
      throw Exception(error);
    } catch (e) {
      print('=== Failed to check phone number: $e ===');
      throw Exception('Failed to check phone number: $e');
    }
  }

  // Handle phone check response
  PhoneCheckResponse _handlePhoneCheckResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        final phoneCheckResponse = PhoneCheckResponse.fromJson(jsonData);
        
        // Log parsed response
        print('=== Phone Check Parsed Response: ${jsonEncode(phoneCheckResponse.toJson())} ===');
        print('=== Phone exists: ${phoneCheckResponse.exists} ===');
        
        return phoneCheckResponse;
      } catch (e) {
        final error = 'Failed to parse response: $e';
        print('=== PhoneCheckService Error: $error ===');
        throw Exception(error);
      }
    } else {
      final error = 'Server error: ${response.statusCode}';
      print('=== PhoneCheckService Error: $error ===');
      throw Exception(error);
    }
  }
}
