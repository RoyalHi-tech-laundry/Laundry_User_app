import 'dart:convert';
import 'package:http/http.dart' as http;

class TokenVerificationService {
  // API base URL
  static const String baseUrl = 'http://laundry-app-env.eba-xpc8mpfi.ap-south-1.elasticbeanstalk.com';
  
  // Verify token endpoint
  static const String verifyTokenEndpoint = '/api/auth/verify-token';
  
  // Verify if token is valid
  static Future<bool> verifyToken(String token) async {
    try {
      // Log request details
      print('🔵 Verifying token');
      print('🔵 Request URL: $baseUrl$verifyTokenEndpoint');
      
      // Make API call
      final response = await http.post(
        Uri.parse('$baseUrl$verifyTokenEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
        }),
      );
      
      // Log response details
      print('🔵 Response status code: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');
      
      // Parse response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['valid'] ?? false;
      }
      
      return false;
    } catch (e) {
      // Log error
      print('🔴 Error verifying token: $e');
      return false;
    }
  }
}
