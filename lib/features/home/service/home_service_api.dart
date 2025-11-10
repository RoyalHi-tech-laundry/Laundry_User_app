import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../features/cart/model/service_model.dart';
import '../../../services/auth_storage_service.dart';

class HomeServiceApi {
  // Base URL for the API
  final String baseUrl = 'http://laundry-app-env.eba-xpc8mpfi.ap-south-1.elasticbeanstalk.com';

  // Headers for the API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET: Fetch all services for the home screen
  Future<List<ServiceModel>> getHomeServices() async {
    debugPrint('🔵 API Call: GET $baseUrl/api/services');
    
    try {
      final headers = await _getHeaders();
      debugPrint('🔵 Headers: $headers');
      final url = Uri.parse('$baseUrl/api/services');
      
      final response = await http.get(url, headers: headers);
      debugPrint('🔵 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        debugPrint('🔵 Response Body: ${response.body}');
        final serviceResponse = ServiceResponse.fromJson(jsonResponse);
        return serviceResponse.data;
      } else {
        debugPrint('🔴 Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Exception: ${e.toString()}');
      
      // Return mock data for development/testing
      return _getMockServices();
    }
  }

  // Mock data for testing
  List<ServiceModel> _getMockServices() {
    return [
      ServiceModel(
        id: 1,
        serviceCode: "WASH_FOLD",
        name: "Wash & Fold",
        description: "Regular laundry service with washing and folding",
        price: 79.00,
        unit: "KG",
        icon: "Icons.local_laundry_service",
        turnaroundTime: "12-24 Hrs",
        isActive: true,
        hasPriceList: false,
        category: "REGULAR",
        sortOrder: 1
      ),
      ServiceModel(
        id: 2,
        serviceCode: "WASH_IRON",
        name: "Wash & Iron",
        description: "Laundry service with washing and ironing",
        price: 109.00,
        unit: "KG",
        icon: "Icons.iron",
        turnaroundTime: "24-48 Hrs",
        isActive: true,
        hasPriceList: false,
        category: "REGULAR",
        sortOrder: 2
      ),
      ServiceModel(
        id: 3,
        serviceCode: "DRY_CLEAN",
        name: "Dry Cleaning",
        description: "Professional dry cleaning service",
        price: 29.00,
        unit: "PC",
        icon: "Icons.dry_cleaning",
        turnaroundTime: "3-5 Days",
        isActive: true,
        hasPriceList: true,
        category: "DRY_CLEAN",
        sortOrder: 4
      ),
      ServiceModel(
        id: 4,
        serviceCode: "STAIN_REMOVAL",
        name: "Stain Removal",
        description: "Professional stain removal service",
        price: 49.00,
        unit: "PC",
        icon: "Icons.cleaning_services",
        turnaroundTime: "2-3 Days",
        isActive: true,
        hasPriceList: false,
        category: "SPECIAL",
        sortOrder: 5
      ),
      ServiceModel(
        id: 5,
        serviceCode: "FABRIC_CARE",
        name: "Fabric Care",
        description: "Special care for delicate fabrics",
        price: 59.00,
        unit: "PC",
        icon: "Icons.checkroom",
        turnaroundTime: "3-4 Days",
        isActive: true,
        hasPriceList: false,
        category: "SPECIAL",
        sortOrder: 6
      ),
    ];
  }
}
