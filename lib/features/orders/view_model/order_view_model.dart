import 'package:flutter/foundation.dart';
import '../model/order_model.dart';
import '../service/order_api_service.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderApiService _orderApiService = OrderApiService();
  
  List<Order> _orders = [];
  List<Order> get orders => _orders;
  
  Order? _selectedOrder;
  Order? get selectedOrder => _selectedOrder;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  Pagination? _pagination;
  Pagination? get pagination => _pagination;
  
  int _currentPage = 1;
  int get currentPage => _currentPage;
  
  // Load all orders
  Future<void> loadOrders() async {
    _setLoading(true);
    _error = null;
    
    try {
      final orderList = await _orderApiService.getOrders();
      _orders = orderList.data;
      
      // Select the first order if available and none is selected
      if (_orders.isNotEmpty && _selectedOrder == null) {
        _selectedOrder = _orders.first;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load orders: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // No pagination support as per API response
  // This method is kept for backward compatibility but does nothing
  Future<void> loadMoreOrders() async {
    // No-op as pagination is not supported by the API
  }
  
  // Get order by ID
  Future<void> getOrderById(int orderId) async {
    _setLoading(true);
    _error = null;
    
    try {
      final order = await _orderApiService.getOrderById(orderId);
      _selectedOrder = order;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load order: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Select an order
  void selectOrder(Order order) {
    _selectedOrder = order;
    notifyListeners();
  }
  
  // Filter orders by status
  List<Order> filterOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Cancel an order with a reason
  Future<bool> cancelOrder(int orderId, String reason) async {
    _setLoading(true);
    _error = null;
    
    try {
      final success = await _orderApiService.cancelOrder(orderId, reason);
      if (success) {
        // Update the order status in the local list
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to cancel order: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
