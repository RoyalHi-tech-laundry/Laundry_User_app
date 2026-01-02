import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../services/auth_storage_service.dart';

class AccountService {
  final String baseUrl = 'http://laundry-app-env.eba-xpc8mpfi.ap-south-1.elasticbeanstalk.com';
  
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String dateOfBirth,
    required String gender,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'dateOfBirth': dateOfBirth,
          'gender': gender.toUpperCase(), // API expects uppercase based on curl example "MALE"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
