import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/order_model.dart';
import '../../../services/auth_storage_service.dart';

class OrderApiService {
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

  // GET: Fetch all orders for the logged-in user
  Future<OrderList> getOrders({int page = 1, int size = 10}) async {
    debugPrint('🔵 API Call: GET $baseUrl/api/orders?page=$page&size=$size');
    
    try {
      final headers = await _getHeaders();
      debugPrint('🔵 Headers: $headers');
      final url = Uri.parse('$baseUrl/api/orders?page=$page&size=$size');
      
      final response = await http.get(url, headers: headers);
      debugPrint('🔵 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        debugPrint('🔵 Response Body: ${response.body}');
        return OrderList.fromJson(jsonResponse);
      } else {
        debugPrint('🔴 Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Exception: ${e.toString()}');
      
      // Return empty response for development/testing
      return OrderList.fromJson({
        'success': false,
        'data': [],
        'pagination': {
          'total': 0,
          'page': page,
          'size': size,
          'totalPages': 0
        }
      });
    }
  }

  // GET: Fetch a specific order by ID
  Future<Order> getOrderById(int orderId) async {
    debugPrint('🔵 API Call: GET $baseUrl/api/orders/$orderId');
    
    try {
      final headers = await _getHeaders();
      debugPrint('🔵 Headers: $headers');
      final url = Uri.parse('$baseUrl/api/orders/$orderId');
      
      final response = await http.get(url, headers: headers);
      debugPrint('🔵 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        debugPrint('🔵 Response Body: ${response.body}');
        return Order.fromJson(jsonResponse['data']);
      } else {
        debugPrint('🔴 Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Exception: ${e.toString()}');
      
      // For development/testing, return a mock order
      throw Exception('Failed to load order: ${e.toString()}');
    }
  }

  // Mock data for testing
  Future<OrderList> getMockOrders() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    return OrderList.fromJson({
      'success': true,
      'data': [
        {
          'id': 1,
          'orderNumber': 'ORD20250821001',
          'status': 'PENDING',
          'pickupDate': '2025-07-29T00:00:00',
          'pickupTimeSlot': '10:00 AM to 11:00 AM',
          'totalAmount': 415.27,
          'createdAt': '2025-08-21T23:33:00'
        },
        {
          'id': 2,
          'orderNumber': 'ORD20250822002',
          'status': 'CONFIRMED',
          'pickupDate': '2025-07-30T00:00:00',
          'pickupTimeSlot': '2:00 PM to 3:00 PM',
          'totalAmount': 325.50,
          'createdAt': '2025-08-22T10:15:00'
        },
        {
          'id': 3,
          'orderNumber': 'ORD20250823003',
          'status': 'DELIVERED',
          'pickupDate': '2025-07-25T00:00:00',
          'pickupTimeSlot': '9:00 AM to 10:00 AM',
          'totalAmount': 520.75,
          'createdAt': '2025-08-23T08:45:00'
        }
      ],
      'pagination': {
        'total': 3,
        'page': 1,
        'size': 10,
        'totalPages': 1
      }
    });
  }
}
