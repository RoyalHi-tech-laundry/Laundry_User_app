import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../model/service_model.dart';
import '../../../services/auth_storage_service.dart';

class CartService {
  // API base URL - replace with your actual API base URL when ready
  final String baseUrl = 'http://laundry-app-env.eba-xpc8mpfi.ap-south-1.elasticbeanstalk.com';
  
  // Flag to control whether to use mock data or real API
  final bool useMockData = false; // Set to false to try real API first, fall back to mock data if it fails
  
  // Fetch all active services
  Future<ServiceResponse> getServices() async {
    if (useMockData) {
      // Use mock data for development and testing
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      print('🔄 MOCK API: Using mock data for services');
      return _getMockServices();
    }
    
    try {
      final url = '$baseUrl/api/services';
      print('🌐 API CALL: GET $url');
      debugPrint('Fetching services from API: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📥 API RESPONSE: Status ${response.statusCode}');
      debugPrint('API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final preview = response.body.length > 100 
            ? '${response.body.substring(0, 100)}...' 
            : response.body;
        print('📄 API DATA: $preview');
        debugPrint('API Response Data: $preview');
        return ServiceResponse.fromJson(jsonData);
      } else {
        print('❌ API ERROR: ${response.statusCode} - ${response.body}');
        debugPrint('API Error: ${response.body}');
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception during API call: $e');
      // Fallback to mock data if API call fails
      return _getMockServices();
    }
  }
  
  // Helper function to get minimum of two numbers
  int min(int a, int b) {
    return a < b ? a : b;
  }
  
  // Get available time slots for a specific date
  Future<List<String>> getTimeSlots(DateTime date) async {
    if (useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));
      print('🔄 MOCK API: Using mock data for time slots');
      
      // Return different time slots based on the day of week for more realistic behavior
      final dayOfWeek = date.weekday;
      
      // Weekend has fewer slots
      if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
        return [
          '09:00 AM to 10:00 AM',
          '11:00 AM to 01:00 PM',
          '03:00 PM to 05:00 PM',
          '05:00 PM to 07:00 PM',
        ];
      }
      
      // Weekdays have more slots
      return [
        '09:00 AM to 10:00 AM',
        '10:00 AM to 11:00 AM',
        '11:00 AM to 01:00 PM',
        '01:00 PM to 03:00 PM',
        '03:00 PM to 05:00 PM',
        '05:00 PM to 07:00 PM',
        '07:00 PM to 08:00 PM',
      ];
    }
    
    try {
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final url = '$baseUrl/api/timeslots?date=$formattedDate';
      
      print('🌐 API CALL: GET $url');
      debugPrint('Fetching time slots for date: $formattedDate');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📥 API RESPONSE: Status ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> slots = jsonData['data'] ?? [];
        print('📄 API DATA: Time slots received: ${slots.length}');
        print('📄 SLOTS: ${slots.join(', ')}');
        return slots.map((slot) => slot.toString()).toList();
      } else {
        print('❌ API ERROR: ${response.statusCode} - ${response.body}');
        debugPrint('Failed to load time slots: ${response.statusCode}');
        throw Exception('Failed to load time slots');
      }
    } catch (e) {
      debugPrint('Exception during time slots API call: $e');
      // Return default time slots if API call fails
      return [
        '09:00 AM to 10:00 AM',
        '11:00 AM to 01:00 PM',
        '03:00 PM to 05:00 PM',
        '05:00 PM to 07:00 PM',
      ];
    }
  }
  
  // Submit cart for processing
  Future<Map<String, dynamic>> submitCart(Map<String, dynamic> cartData) async {
    // Format the cart data to match the API parameters
    final formattedData = _formatCartDataForApi(cartData);
    
    // Log the request data for debugging
    print('📦 REQUEST BODY: ${json.encode(formattedData)}');
    
    try {
      // Make the API call to submit the order
      final url = '$baseUrl/api/users/order';
      print('🌐 API CALL: POST $url');
      
      // Get auth token from storage
      final authToken = await AuthStorageService.getToken();
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authToken ?? ""}', // Use actual auth token from storage
        },
        body: json.encode(formattedData),
      ).timeout(const Duration(seconds: 15)); // Add timeout to prevent hanging
      
      print('📥 API RESPONSE: Status ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('✅ ORDER CREATED: ${responseData['data']?['orderNumber'] ?? 'Unknown ID'}');
        print('📄 API DATA: ${response.body}');
        return responseData;
      } else {
        print('❌ API ERROR: ${response.statusCode} - ${response.body}');
        // Return error response with the actual error message from the API
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to submit order: ${response.statusCode}',
          'error_code': errorData['error_code'] ?? 'API_ERROR',
          'exception_type': errorData['exception_type'] ?? 'Unknown',
        };
      }
    } catch (e) {
      // Log the error and return error response
      print('⚠️ API ERROR: $e');
      
      // Return error response with the exception message
      return {
        'success': false,
        'message': e.toString(),
        'error_code': 'REQUEST_FAILED',
        'exception_type': e.runtimeType.toString(),
      };
    }
  }
  
  // Format cart data to match API parameters
  Map<String, dynamic> _formatCartDataForApi(Map<String, dynamic> cartData) {
    // Extract selected services
    final selectedServices = cartData['selectedServices'] as List<dynamic>? ?? [];
    final serviceIds = selectedServices.map((service) => service['id']).toList();
    
    // Extract pickup date and time slot
    final pickupDate = cartData['pickupDate'] as String?;
    final timeSlot = cartData['timeSlot'] as String?;
    
    // Format time slot to match API format (e.g., "10:00 AM to 11:00 AM" -> "10:00-12:00")
    String formattedTimeSlot = '';
    if (timeSlot != null) {
      // Extract times from format like "10:00 AM to 11:00 AM"
      final parts = timeSlot.split(' to ');
      if (parts.length == 2) {
        // Convert to 24-hour format and remove AM/PM
        final startTime = _convertTo24HourFormat(parts[0]);
        final endTime = _convertTo24HourFormat(parts[1]);
        formattedTimeSlot = '$startTime-$endTime';
      } else {
        formattedTimeSlot = timeSlot;
      }
    }
    
    // Format the request to match the API requirements
    return {
      'pickupAddressId': cartData['addressId'] ?? 1,
      'deliveryAddressId': cartData['addressId'] ?? 1,
      'pickupDate': pickupDate ?? DateTime.now().toIso8601String(),
      'pickupTimeSlot': formattedTimeSlot,
      'specialInstructions': cartData['specialInstructions'] ?? 'Please handle with care',
      'serviceIds': serviceIds
    };
  }
  
  // Helper method to convert time from 12-hour to 24-hour format
  String _convertTo24HourFormat(String time12h) {
    // Parse time like "10:00 AM"
    final parts = time12h.split(' ');
    if (parts.length != 2) return time12h;
    
    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) return time12h;
    
    int hours = int.tryParse(timeParts[0]) ?? 0;
    final minutes = timeParts[1];
    final amPm = parts[1].toUpperCase();
    
    // Convert to 24-hour format
    if (amPm == 'PM' && hours < 12) {
      hours += 12;
    } else if (amPm == 'AM' && hours == 12) {
      hours = 0;
    }
    
    return '${hours.toString().padLeft(2, '0')}:$minutes';
  }
  
  // Get store details - will be used in the confirm tab
  Future<Map<String, dynamic>> getStoreDetails() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      print('🔄 MOCK API: Using mock data for store details');
      return {
        'success': true,
        'data': {
          'id': 'UC430',
          'name': 'UClean Velachery',
          'address': 'Door No.5/8, DD Tower First Floor, F2 Plot.19, 3rd St, Near Tansi Nagar, Velachery, Chennai - 600042',
          'phone': '+91 9876543210',
          'email': 'velachery@uclean.in',
          'rating': 4.5,
          'openingHours': '09:00 AM - 08:00 PM',
          'coordinates': {
            'latitude': 12.9815,
            'longitude': 80.2180
          }
        }
      };
    }
    
    try {
      final url = '$baseUrl/api/stores/nearest';
      print('🌐 API CALL: GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📥 API RESPONSE: Status ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📄 API DATA: ${response.body}');
        return data;
      } else {
        print('❌ API ERROR: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load store details');
      }
    } catch (e) {
      debugPrint('Exception during store details API call: $e');
      // Return mock data as fallback
      return {
        'success': true,
        'data': {
          'id': 'UC430',
          'name': 'UClean Velachery',
          'address': 'Door No.5/8, DD Tower First Floor, F2 Plot.19, 3rd St, Near Tansi Nagar, Velachery, Chennai - 600042',
          'phone': '+91 9876543210',
          'email': 'velachery@uclean.in'
        }
      };
    }
  }
  
  // Mock data for testing
  ServiceResponse _getMockServices() {
    return ServiceResponse.fromJson({
      "success": true,
      "data": [
        {
          "id": 1,
          "serviceCode": "WASH_FOLD",
          "name": "Laundry - Wash & Fold",
          "description": "Regular laundry service with washing and folding",
          "price": 79.00,
          "unit": "KG",
          "icon": "Icons.local_laundry_service",
          "turnaroundTime": "12-24 Hrs",
          "isActive": true,
          "hasPriceList": false,
          "category": "REGULAR",
          "sortOrder": 1
        },
        {
          "id": 2,
          "serviceCode": "WASH_IRON",
          "name": "Laundry - Wash & Iron",
          "description": "Laundry service with washing and ironing",
          "price": 109.00,
          "unit": "KG",
          "icon": "Icons.iron",
          "turnaroundTime": "24-48 Hrs",
          "isActive": true,
          "hasPriceList": false,
          "category": "REGULAR",
          "sortOrder": 2
        },
        {
          "id": 3,
          "serviceCode": "PREMIUM",
          "name": "Premium Laundry Kg",
          "description": "Premium laundry service for delicate items",
          "price": 179.00,
          "unit": "KG",
          "icon": "Icons.star",
          "turnaroundTime": "24-48 Hrs",
          "isActive": true,
          "hasPriceList": false,
          "category": "PREMIUM",
          "sortOrder": 3
        },
        {
          "id": 4,
          "serviceCode": "DRY_CLEAN",
          "name": "Dry Cleaning",
          "description": "Professional dry cleaning service",
          "price": 29.00,
          "unit": "PC",
          "icon": "Icons.dry_cleaning",
          "turnaroundTime": "3-5 Days",
          "isActive": true,
          "hasPriceList": true,
          "category": "DRY_CLEAN",
          "sortOrder": 4
        }
      ]
    });
  }
}
