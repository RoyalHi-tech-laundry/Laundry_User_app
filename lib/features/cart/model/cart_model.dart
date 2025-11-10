import 'package:flutter/foundation.dart';
import 'service_model.dart';

class CartItem {
  final ServiceModel service;
  int quantity;
  double totalPrice;

  CartItem({
    required this.service,
    this.quantity = 1,
  }) : totalPrice = service.price * quantity;

  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
    totalPrice = service.price * quantity;
  }

  Map<String, dynamic> toJson() {
    return {
      'service': service.toJson(),
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }
}

class CartModel {
  List<ServiceModel> selectedServices = [];
  ServiceModel? selectedService; // Keep for backward compatibility
  DateTime? pickupDate;
  DateTime? deliveryDate;
  String? timeSlot;
  int? addressId;
  String? addressDetails;
  List<CartItem> items = [];
  double totalAmount = 0;
  
  // Method to calculate total amount
  void calculateTotal() {
    totalAmount = items.fold(0, (sum, item) => sum + item.totalPrice);
  }
  
  // Method to add item to cart
  void addItem(ServiceModel service, {int quantity = 1}) {
    final existingItemIndex = items.indexWhere((item) => item.service.id == service.id);
    
    if (existingItemIndex != -1) {
      // Update existing item
      items[existingItemIndex].updateQuantity(items[existingItemIndex].quantity + quantity);
    } else {
      // Add new item
      final newItem = CartItem(service: service, quantity: quantity);
      items.add(newItem);
      
      // Add to selected services if not already there
      if (!selectedServices.any((s) => s.id == service.id)) {
        selectedServices.add(service);
      }
    }
    
    calculateTotal();
  }
  
  // Method to update item quantity
  void updateItemQuantity(int serviceId, int quantity) {
    final itemIndex = items.indexWhere((item) => item.service.id == serviceId);
    
    if (itemIndex != -1) {
      if (quantity > 0) {
        items[itemIndex].updateQuantity(quantity);
      } else {
        // Remove item if quantity is 0 or less
        items.removeAt(itemIndex);
      }
      
      calculateTotal();
    }
  }
  
  // Method to remove item from cart
  void removeItem(int serviceId) {
    items.removeWhere((item) => item.service.id == serviceId);
    selectedServices.removeWhere((service) => service.id == serviceId);
    calculateTotal();
  }
  
  // Method to clear cart
  void clear() {
    items.clear();
    selectedServices.clear();
    selectedService = null;
    totalAmount = 0;
    pickupDate = null;
    deliveryDate = null;
    timeSlot = null;
    addressId = null;
    addressDetails = null;
  }
  
  // Method to check if cart has items
  bool get hasItems => items.isNotEmpty;
  
  // Method to check if cart is ready for checkout
  bool get isReadyForCheckout => 
      hasItems && 
      pickupDate != null && 
      deliveryDate != null && 
      timeSlot != null && 
      addressId != null;
  
  Map<String, dynamic> toJson() {
    return {
      'selectedServices': selectedServices.map((service) => service.toJson()).toList(),
      'selectedService': selectedService?.toJson(), // Keep for backward compatibility
      'pickupDate': pickupDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'timeSlot': timeSlot,
      'addressId': addressId,
      'addressDetails': addressDetails,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }
}
