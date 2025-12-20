import 'dart:convert';
import 'package:http/http.dart' as http;

class PriceListService {
  static const String baseUrl = 'http://laundry-app-env.eba-xpc8mpfi.ap-south-1.elasticbeanstalk.com/api';

  Future<Map<String, dynamic>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      throw Exception('Error fetching services: $e');
    }
  }
}
