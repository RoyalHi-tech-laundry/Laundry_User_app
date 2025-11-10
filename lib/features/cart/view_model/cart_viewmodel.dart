import 'package:flutter/material.dart';
import '../model/cart_model.dart';
import '../model/service_model.dart';
import '../service/cart_service.dart';

enum CartTab { buildCart, dateTime, address, confirm }

class CartViewModel extends ChangeNotifier {
  final CartService _cartService = CartService();
  final CartModel _cart = CartModel();
  
  // Current tab
  CartTab _currentTab = CartTab.buildCart;
  CartTab get currentTab => _currentTab;
  
  // Services
  List<ServiceModel> _services = [];
  List<ServiceModel> get services => _services;
  
  // Selected services
  List<ServiceModel> _selectedServices = [];
  List<ServiceModel> get selectedServices => _selectedServices;
  
  // Selected service (for backward compatibility)
  ServiceModel? get selectedService => _selectedServices.isNotEmpty ? _selectedServices.first : null;
  
  // Time slots
  List<String> _timeSlots = [];
  List<String> get timeSlots => _timeSlots;
  
  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Error state
  String? _error;
  String? get error => _error;
  
  // Cart data
  CartModel get cart => _cart;
  
  // Initialize the view model
  Future<void> init() async {
    await loadServices();
  }
  
  // Load services from API
  Future<void> loadServices() async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _cartService.getServices();
      _services = response.data;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load services: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }
  
  // Toggle service selection
  void toggleServiceSelection(ServiceModel service) {
    final isSelected = isServiceSelected(service);
    
    if (isSelected) {
      // Remove service
      _selectedServices.removeWhere((s) => s.id == service.id);
      _cart.selectedServices.removeWhere((s) => s.id == service.id);
      _cart.removeItem(service.id);
    } else {
      // Add service
      _selectedServices.add(service);
      _cart.selectedServices.add(service);
      _cart.addItem(service);
    }
    
    // Update the legacy selectedService field for backward compatibility
    _cart.selectedService = _selectedServices.isNotEmpty ? _selectedServices.first : null;
    
    notifyListeners();
  }
  
  // Check if a service is selected
  bool isServiceSelected(ServiceModel service) {
    return _selectedServices.any((s) => s.id == service.id);
  }
  
  // Navigate to next tab
  void nextTab() {
    if (_currentTab == CartTab.buildCart && _selectedServices.isNotEmpty) {
      _currentTab = CartTab.dateTime;
      loadTimeSlots();
    } else if (_currentTab == CartTab.dateTime && _cart.pickupDate != null && _cart.timeSlot != null) {
      _currentTab = CartTab.address;
    } else if (_currentTab == CartTab.address && _cart.addressId != null) {
      _currentTab = CartTab.confirm;
    }
    notifyListeners();
  }
  
  // Navigate to previous tab and clear data for the current tab
  void previousTab() {
    if (_currentTab == CartTab.dateTime) {
      // Clear date and time data when going back to build cart
      clearDataForTab(CartTab.dateTime);
      _currentTab = CartTab.buildCart;
    } else if (_currentTab == CartTab.address) {
      // Clear address data when going back to date time
      clearDataForTab(CartTab.address);
      _currentTab = CartTab.dateTime;
    } else if (_currentTab == CartTab.confirm) {
      _currentTab = CartTab.address;
    }
    notifyListeners();
  }
  
  // Set pickup date
  void setPickupDate(DateTime date) {
    _cart.pickupDate = date;
    // Calculate delivery date (default: pickup date + 2 days)
    _cart.deliveryDate = date.add(Duration(days: 2));
    loadTimeSlots();
    notifyListeners();
  }
  
  // Set time slot
  void setTimeSlot(String timeSlot) {
    _cart.timeSlot = timeSlot;
    notifyListeners();
  }
  
  // Load time slots for selected date
  Future<void> loadTimeSlots() async {
    if (_cart.pickupDate == null) return;
    
    _setLoading(true);
    try {
      _timeSlots = await _cartService.getTimeSlots(_cart.pickupDate!);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load time slots: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }
  
  // Set address
  void setAddress(int addressId, String addressDetails) {
    _cart.addressId = addressId;
    _cart.addressDetails = addressDetails;
    notifyListeners();
  }
  
  // Submit order
  Future<Map<String, dynamic>> submitOrder() async {
    _setLoading(true);
    _error = null;
    
    try {
      final result = await _cartService.submitCart(_cart.toJson());
      _setLoading(false);
      return result;
    } catch (e) {
      _error = 'Failed to submit order: ${e.toString()}';
      _setLoading(false);
      return {'success': false, 'message': _error};
    }
  }
  
  // Reset cart
  void resetCart() {
    _cart.clear();
    _currentTab = CartTab.buildCart;
    _selectedServices.clear();
    notifyListeners();
  }
  
  // Clear data for a specific tab
  void clearDataForTab(CartTab tab) {
    switch (tab) {
      case CartTab.buildCart:
        _selectedServices.clear();
        _cart.selectedServices.clear();
        _cart.items.clear();
        _cart.selectedService = null;
        _cart.totalAmount = 0;
        break;
      case CartTab.dateTime:
        _cart.pickupDate = null;
        _cart.deliveryDate = null;
        _cart.timeSlot = null;
        _timeSlots = [];
        break;
      case CartTab.address:
        _cart.addressId = null;
        _cart.addressDetails = null;
        break;
      case CartTab.confirm:
        // No specific data to clear for confirm tab
        break;
    }
    notifyListeners();
  }
  
  // Check if continue button should be enabled for current tab
  bool canContinue() {
    switch (_currentTab) {
      case CartTab.buildCart:
        return _selectedServices.isNotEmpty;
      case CartTab.dateTime:
        return _cart.pickupDate != null && _cart.timeSlot != null;
      case CartTab.address:
        return _cart.addressId != null;
      case CartTab.confirm:
        return _cart.isReadyForCheckout;
    }
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
