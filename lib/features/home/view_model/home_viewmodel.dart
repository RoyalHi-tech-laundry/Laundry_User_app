import 'package:flutter/foundation.dart';
import '../../cart/model/service_model.dart';
import '../../cart/service/cart_service.dart';
import '../../../services/auth_storage_service.dart';

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
      // Load user details from storage first
      final userDetails = await AuthStorageService.getUserDetails();
      _userName = userDetails['name'] ?? 'Guest';
      
      // Try to load last selected address from SharedPreferences
      final lastSelectedAddress = await AuthStorageService.getLastSelectedAddress();
      
      if (lastSelectedAddress != null && lastSelectedAddress.isNotEmpty) {
        final parts = lastSelectedAddress.split('||');
        if (parts.length >= 5) {
          // Create a simple map with address details to display
          _currentAddress = {
            'id': parts[0],
            'type': parts[1],
            'fullAddress': parts[2],
            'latitude': double.tryParse(parts[3]) ?? 0.0,
            'longitude': double.tryParse(parts[4]) ?? 0.0,
          };
        }
      }
      
      // If no last selected address, set to unknown
      if (_currentAddress == null) {
        _currentAddress = {
          'fullAddress': 'Unknown - Please select address',
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
