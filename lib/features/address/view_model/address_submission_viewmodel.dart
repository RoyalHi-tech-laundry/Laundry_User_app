import 'package:flutter/material.dart';
import '../model/address_model.dart';
import '../service/address_service.dart';

class AddressSubmissionViewModel extends ChangeNotifier {
  final AddressService _addressService = AddressService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;
  
  String _successMessage = '';
  String get successMessage => _successMessage;
  
  // Submit address to the API
  Future<bool> submitAddress({
    required String type,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String pincode,
    required String country,
    required String landmark,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    _setLoading(true);
    _error = null;
    _isSuccess = false;
    _successMessage = '';
    
    try {
      final response = await _addressService.addAddress(
        type: type,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        pincode: pincode,
        country: country,
        landmark: landmark,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );
      
      if (response['success'] == true) {
        _isSuccess = true;
        _successMessage = response['message'] ?? 'Address added successfully';
        return true;
      } else {
        _error = response['message'] ?? 'Failed to add address';
        return false;
      }
    } catch (e) {
      _error = 'Error adding address: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Convert from Address model to API request format
  Future<bool> submitAddressFromModel(Address address, {
    required String addressLine1,
    required String addressLine2,
    required String state,
    required String country,
    bool isDefault = false,
  }) async {
    // Debug log coordinates in address model
    print('📍 COORDINATES DEBUG - In submitAddressFromModel:');
    print('📍 Address model latitude: ${address.latitude}');
    print('📍 Address model longitude: ${address.longitude}');
    
    // Validate coordinates before submission
    double lat = address.latitude;
    double lng = address.longitude;
    
    // Ensure coordinates are valid
    if (lat == 0.0 || lng == 0.0 || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      print('📍 WARNING: Invalid coordinates detected, using default Chennai coordinates');
      lat = 13.0827;
      lng = 80.2707;
    }
    
    return submitAddress(
      type: address.type.toString().split('.').last.toUpperCase(),
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: address.city,
      state: state,
      pincode: address.pincode,
      country: country,
      landmark: address.landmark,
      latitude: lat,
      longitude: lng,
      isDefault: isDefault,
    );
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void resetState() {
    _isLoading = false;
    _error = null;
    _isSuccess = false;
    _successMessage = '';
    notifyListeners();
  }
}
