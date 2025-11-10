import 'package:flutter/material.dart';
import '../model/address_list_model.dart';
import '../service/address_service.dart';
import '../view/address_selection_screen.dart';
import '../../../services/auth_storage_service.dart';

class AddressListViewModel extends ChangeNotifier {
  // Navigation service
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Method to navigate to address selection screen
  Future<void> navigateToAddressSelectionScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressSelectionScreen()),
    );
    
    // Always reload addresses when returning from address selection screen
    // This ensures the list is refreshed even if the user didn't add an address
    await loadAddresses();
    
    // Force UI update
    notifyListeners();
    
    // Return the result in case the caller needs it
    return result;
  }
  final AddressService _addressService = AddressService();
  
  List<AddressItem> _addresses = [];
  List<AddressItem> get addresses => _addresses;
  
  AddressItem? _selectedAddress;
  AddressItem? get selectedAddress => _selectedAddress;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  // Load all addresses
  Future<void> loadAddresses() async {
    _setLoading(true);
    _error = null;
    
    try {
      final addressList = await _addressService.getAddresses();
      _addresses = addressList.data;
      
      // Try to load the last selected address from SharedPreferences
      final lastSelectedAddress = await AuthStorageService.getLastSelectedAddress();
      
      if (lastSelectedAddress != null && lastSelectedAddress.isNotEmpty) {
        final parts = lastSelectedAddress.split('||');
        if (parts.isNotEmpty) {
          final lastSelectedId = parts[0];
          // Find the address with the matching ID
          if (_addresses.isNotEmpty) {
            _selectedAddress = _addresses.firstWhere(
              (addr) => addr.id == lastSelectedId,
              orElse: () => _addresses.first,
            );
          }
        }
      } 
      
      // If no address is selected, select the first one if available
      if (_selectedAddress == null && _addresses.isNotEmpty) {
        _selectedAddress = _addresses.first;
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load addresses: ${e.toString()}';
      _addresses = [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Select an address
  Future<void> selectAddress(AddressItem address) async {
    _selectedAddress = address;
    
    // Save the selected address to SharedPreferences
    final fullAddress = '${address.addressLine1}${address.addressLine2 != null ? ', ${address.addressLine2}' : ''}, ${address.city}, ${address.state} ${address.pincode}, ${address.country}';
    await AuthStorageService.saveLastSelectedAddress(
      '${address.id}||${address.type}||$fullAddress||${address.latitude}||${address.longitude}'
    );
    
    notifyListeners();
  }
  
  // Delete an address
  Future<bool> deleteAddress(dynamic addressId) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Call the service to delete the address
      final result = await _addressService.deleteAddress(addressId);
      
      // If successful, reload the addresses to update the list
      if (result['success'] == true) {
        // Remove from local list immediately for UI responsiveness
        _addresses.removeWhere((address) => address.id == addressId);
        
        // If selected address was deleted, select another one
        if (_selectedAddress != null && _selectedAddress!.id == addressId) {
          _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
        }
        
        // Notify listeners to update UI immediately
        notifyListeners();
        
        // Also reload from server to ensure data consistency
        await loadAddresses();
        
        return true;
      } else {
        _error = result['message'] ?? 'Failed to delete address';
        // Reload addresses to ensure UI is in sync with server
        await loadAddresses();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting address: ${e.toString()}';
      // Reload addresses to ensure UI is in sync with server
      await loadAddresses();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Set loading state

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
