import 'dart:async';
import '../features/address/model/address_model.dart';

class AddressApiService {
  // Mock data for address API
  static const List<Map<String, dynamic>> _mockAddresses = [
    {
      'id': '1',
      'name': 'Home',
      'fullAddress': 'R6JH+PM4, Egaittur, Tamil Nadu 603103, India',
      'houseNumber': 'R6JH+PM4',
      'street': 'Main Street',
      'landmark': 'Near Temple',
      'city': 'Tamil Nadu',
      'pincode': '603103',
      'latitude': 12.8373,
      'longitude': 79.7421,
      'type': 'home',
    },
    {
      'id': '2',
      'name': 'Work',
      'fullAddress': 'IT Park, OMR, Chennai, Tamil Nadu 600096, India',
      'houseNumber': 'Block A',
      'street': 'OMR',
      'landmark': 'IT Park',
      'city': 'Chennai',
      'pincode': '600096',
      'latitude': 12.9716,
      'longitude': 80.2434,
      'type': 'work',
    },
  ];

  /// Get current user's default address
  Future<Address> getCurrentUserAddress() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Return first address as default
      final defaultAddress = _mockAddresses.first;
      
      return Address.fromJson(defaultAddress);
    } catch (e) {
      throw Exception('Failed to fetch user address: $e');
    }
  }

  /// Get all user addresses
  Future<List<Address>> getUserAddresses() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      return _mockAddresses
          .map((addressJson) => Address.fromJson(addressJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user addresses: $e');
    }
  }

  /// Add new address
  Future<Address> addAddress(Address address) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // In real implementation, this would make API call to save address
      // For now, just return the address with a generated ID
      final newAddress = Address(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: address.name,
        fullAddress: address.fullAddress,
        houseNumber: '',
        street: '',
        landmark: '',
        city: address.city,
        pincode: address.pincode,
        latitude: address.latitude,
        longitude: address.longitude,
        type: address.type,
      );
      
      return newAddress;
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  /// Update existing address
  Future<Address> updateAddress(Address address) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // In real implementation, this would make API call to update address
      return address;
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  /// Delete address
  Future<bool> deleteAddress(String addressId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      // In real implementation, this would make API call to delete address
      return true;
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  /// Set address as default
  Future<bool> setDefaultAddress(String addressId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // In real implementation, this would make API call to set default address
      return true;
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }
}
