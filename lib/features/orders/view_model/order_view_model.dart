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
  
  // Load orders
  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }
    
    _setLoading(true);
    _error = null;
    
    try {
      // For development/testing, use mock data
      // In production, use the real API call
      // final orderList = await _orderApiService.getOrders(page: _currentPage);
      final orderList = await _orderApiService.getMockOrders();
      
      if (_currentPage == 1) {
        _orders = orderList.data;
      } else {
        _orders.addAll(orderList.data);
      }
      
      _pagination = orderList.pagination;
      
      // If there are orders and no selected order, select the first one
      if (_orders.isNotEmpty && _selectedOrder == null) {
        _selectedOrder = _orders.first;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load orders: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (_pagination == null || _currentPage >= _pagination!.totalPages) {
      return; // No more pages to load
    }
    
    _currentPage++;
    await loadOrders();
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
}
