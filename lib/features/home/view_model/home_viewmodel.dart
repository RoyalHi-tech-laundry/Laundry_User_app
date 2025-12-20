import 'package:flutter/foundation.dart';
import '../../cart/model/service_model.dart';
import '../../cart/service/cart_service.dart';
import '../../../services/auth_storage_service.dart';
import '../../address/service/address_service.dart';
import '../../address/model/address_list_model.dart';

class HomeViewModel extends ChangeNotifier {
  final CartService _cartService = CartService();
  
  String _userName = '';
  String get userName => _userName;
  
  // Can be either Address from API or AddressItem from selection
  dynamic _currentAddress;
  dynamic get currentAddress => _currentAddress;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  List<ServiceModel> _services = [];
  List<ServiceModel> get services => _services;

  Future<void> loadUserData() async {
    _setLoading(true);
    try {
      // Load user details and last selected address first
      final userDetails = await AuthStorageService.getUserDetails();
      _userName = userDetails['name'] ?? 'Guest';
      final lastSelectedAddress = await AuthStorageService.getLastSelectedAddress();
      
      // Load user's saved addresses
      final addressService = AddressService();
      try {
        final addressList = await addressService.getAddresses();
        final userAddresses = addressList.data;

        // Variable to store the selected address
        Map<String, dynamic>? selectedAddress;

        // If we have a last selected address, try to use it
        if (lastSelectedAddress != null && lastSelectedAddress.isNotEmpty) {
          final parts = lastSelectedAddress.split('||');
          if (parts.length >= 5) {
            final addressId = parts[0];
            
            // Check if this address still exists in the user's address list
            final addressExists = userAddresses.any((addr) => addr.id.toString() == addressId);
            
            if (addressExists) {
              // Use the last selected address
              selectedAddress = {
                'id': parts[0],
                'type': parts[1],
                'fullAddress': parts[2],
                'latitude': double.tryParse(parts[3]) ?? 0.0,
                'longitude': double.tryParse(parts[4]) ?? 0.0,
              };
            }
          }
        }
        
        // If no valid last selected address, but we have addresses, use the first one
        if (selectedAddress == null && userAddresses.isNotEmpty) {
          final defaultAddress = userAddresses.first;
          selectedAddress = {
            'id': defaultAddress.id.toString(),
            'type': defaultAddress.type,
            'fullAddress': defaultAddress.formattedAddress,
            'latitude': defaultAddress.latitude,
            'longitude': defaultAddress.longitude,
          };
          
          // Save as last selected address for future use
          await AuthStorageService.saveLastSelectedAddress(
            '${defaultAddress.id}||${defaultAddress.type}||${defaultAddress.formattedAddress}||${defaultAddress.latitude}||${defaultAddress.longitude}'
          );
        }
        
        // Set the current address if we found one
        _currentAddress = selectedAddress;
        
      } catch (e) {
        debugPrint('Error loading addresses: $e');
        // If we can't load addresses but have a last selected address, use it
        if (lastSelectedAddress != null && lastSelectedAddress.isNotEmpty) {
          final parts = lastSelectedAddress.split('||');
          if (parts.length >= 5) {
            _currentAddress = {
              'id': parts[0],
              'type': parts[1],
              'fullAddress': parts[2],
              'latitude': double.tryParse(parts[3]) ?? 0.0,
              'longitude': double.tryParse(parts[4]) ?? 0.0,
            };
          }
        }
      }
      
      // If still no address, set to unknown
      if (_currentAddress == null) {
        _currentAddress = {
          'fullAddress': 'Please add an address',
          'type': 'unknown'
        };
      }
      
      // Load services
      await loadServices();
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load user data: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadServices() async {
    try {
      final serviceResponse = await _cartService.getServices();
      _services = serviceResponse.data;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load services: ${e.toString()}';
      debugPrint(_error);
      _services = [];
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Update current address from selection
  void updateCurrentAddress(dynamic address) {
    _currentAddress = address;
    notifyListeners();
  }

  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}
