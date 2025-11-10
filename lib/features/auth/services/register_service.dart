import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:laun_easy/features/auth/models/register_response.dart';

class RegisterService {
  final String baseUrl = 'http://laundry-app-env.eba-xpc8mpfi.ap-south-1.elasticbeanstalk.com';
  final Duration _timeout = const Duration(seconds: 15);

  // Register a new user
  Future<RegisterResponse> registerUser({
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      final url = '$baseUrl/api/auth/register';
      final requestBody = jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
      });
      
      // Log request details
      print('=== Register Request URL: $url ===');
      print('=== Register Request Body: $requestBody ===');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      ).timeout(_timeout);
      
      // Log response
      print('=== Register Response Status: ${response.statusCode} ===');
      print('=== Register Response Body: ${response.body} ===');
      
      return _handleRegisterResponse(response);
    } on SocketException {
      final error = 'No internet connection. Please check your network settings.';
      print('=== RegisterService Error: $error ===');
      throw Exception(error);
    } on TimeoutException {
      final error = 'Request timed out. Please try again.';
      print('=== RegisterService Error: $error ===');
      throw Exception(error);
    } catch (e) {
      print('=== Failed to register user: $e ===');
      throw Exception('Failed to register user: $e');
    }
  }

  // Handle register response
  RegisterResponse _handleRegisterResponse(http.Response response) {
    final jsonData = jsonDecode(response.body);
    
    if (response.statusCode == 201) {
      try {
        final registerResponse = RegisterResponse.fromJson(jsonData);
        
        // Log parsed response
        print('=== Register Parsed Response: ${jsonEncode(registerResponse.toJson())} ===');
        print('=== Registration successful: ${registerResponse.message} ===');
        
        return registerResponse;
      } catch (e) {
        final error = 'Failed to parse response: $e';
        print('=== RegisterService Error: $error ===');
        throw Exception(error);
      }
    } else {
      final error = jsonData['error'] ?? 'Server error: ${response.statusCode}';
      print('=== RegisterService Error: $error ===');
      throw Exception(error);
    }
  }
}
