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

  // Fetch all orders for the logged-in user
  Future<OrderList> getOrders() async {
    const url = '/api/users/order';
    debugPrint('\n📡 API Request:');
    debugPrint('URL: $baseUrl$url');
    
    try {
      final headers = await _getHeaders();
      debugPrint('🔑 Headers: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl$url'),
        headers: headers,
      );
      
      debugPrint('\n📡 API Response:');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        debugPrint('\n📊 Response Summary:');
        debugPrint('Success: ${jsonResponse['success']}');
        if (jsonResponse['data'] is List) {
          final orders = jsonResponse['data'] as List;
          debugPrint('Number of orders: ${orders.length}');
          if (orders.isNotEmpty) {
            debugPrint('First order details:');
            debugPrint(jsonEncode(orders[0]));
          }
        }
        
        // Convert to OrderList with empty pagination
        return OrderList(
          success: jsonResponse['success'] ?? false,
          data: (jsonResponse['data'] as List? ?? [])
              .map((item) => Order.fromJson(item))
              .toList(),
          pagination: Pagination(
            total: jsonResponse['data']?.length ?? 0,
            page: 1,
            size: jsonResponse['data']?.length ?? 0,
            totalPages: 1,
          ),
        );
      } else {
        debugPrint('🔴 Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Exception: ${e.toString()}');
      rethrow; // Re-throw to see the actual error in the console
    }
  }

  // GET: Fetch a specific order by ID
  Future<Order> getOrderById(int orderId) async {
    debugPrint('🔵 API Call: GET $baseUrl/api/users/order/$orderId');
    
    try {
      final headers = await _getHeaders();
      debugPrint('🔵 Headers: $headers');
      final url = Uri.parse('$baseUrl/api/users/order/$orderId');
      
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

  // // Mock data for testing
  // Future<OrderList> getMockOrders() async {
  //   // Simulate network delay
  //   await Future.delayed(const Duration(seconds: 1));
    
  //   return OrderList.fromJson({
  //     'success': true,
  //     'data': [
  //       {
  //         'id': 1,
  //         'orderNumber': 'ORD20250821001',
  //         'status': 'PENDING',
  //         'pickupDate': '2025-07-29T00:00:00',
  //         'pickupTimeSlot': '10:00 AM to 11:00 AM',
  //         'totalAmount': 415.27,
  //         'createdAt': '2025-08-21T23:33:00'
  //       },
  //       {
  //         'id': 2,
  //         'orderNumber': 'ORD20250822002',
  //         'status': 'CONFIRMED',
  //         'pickupDate': '2025-07-30T00:00:00',
  //         'pickupTimeSlot': '2:00 PM to 3:00 PM',
  //         'totalAmount': 325.50,
  //         'createdAt': '2025-08-22T10:15:00'
  //       },
  //       {
  //         'id': 3,
  //         'orderNumber': 'ORD20250823003',
  //         'status': 'DELIVERED',
  //         'pickupDate': '2025-07-25T00:00:00',
  //         'pickupTimeSlot': '9:00 AM to 10:00 AM',
  //         'totalAmount': 520.75,
  //         'createdAt': '2025-08-23T08:45:00'
  //       }
  //     ],
  //     'pagination': {
  //       'total': 3,
  //       'page': 1,
  //       'size': 10,
  //       'totalPages': 1
  //     }
  //   });
  // }

  // Cancel an order with a reason
  Future<bool> cancelOrder(int orderId, String reason) async {
    final url = '/api/users/order/$orderId/cancel';
    debugPrint('\n📡 API Request:');
    debugPrint('URL: $baseUrl$url');
    debugPrint('Reason: $reason');
    
    try {
      final headers = await _getHeaders();
      debugPrint('🔑 Headers: $headers');
      
      final response = await http.put(
        Uri.parse('$baseUrl$url'),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': reason}),
      );
      
      debugPrint('\n📡 API Response:');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] == true;
      } else {
        debugPrint('🔴 Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Exception: ${e.toString()}');
      rethrow;
    }
  }
}
