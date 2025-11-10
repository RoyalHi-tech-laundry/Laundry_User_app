import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../constants/colors/app_colors.dart';
import '../model/order_model.dart';
import '../view_model/order_view_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late OrderViewModel _viewModel;
  late TabController _tabController;
  
  final List<Tab> _tabs = [
    const Tab(text: 'All'),
    const Tab(text: 'Active'),
    const Tab(text: 'Completed'),
    const Tab(text: 'Cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = OrderViewModel();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    await _viewModel.loadOrders();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Apply gradient to the entire screen
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFE6F0FF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make scaffold transparent to show gradient
        appBar: AppBar(
          title: Text(
            'Order History',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDarkColor,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(49), // Height for TabBar + divider
            child: Column(
              children: [
                Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
                TabBar(
                  controller: _tabController,
                  tabs: _tabs,
                  labelColor: AppColors.primaryDarkColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primaryDarkColor,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(null), // All orders
          _buildOrderList([OrderStatus.pending, OrderStatus.confirmed, OrderStatus.pickedUp, OrderStatus.inProgress, OrderStatus.readyForDelivery]), // Active orders
          _buildOrderList([OrderStatus.delivered]), // Completed orders
          _buildOrderList([OrderStatus.cancelled]), // Cancelled orders
        ],
      ),
    ),
    );
  }

  Widget _buildOrderList(List<OrderStatus>? statusFilter) {
    // Filter orders based on status if filter is provided
    List<Order> filteredOrders = _viewModel.orders;
    if (statusFilter != null) {
      filteredOrders = _viewModel.orders.where((order) => statusFilter.contains(order.status)).toList();
    }

    if (_viewModel.isLoading && filteredOrders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.error != null && filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load orders',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _viewModel.error!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusFilter == null
                  ? 'You haven\'t placed any orders yet'
                  : statusFilter.contains(OrderStatus.delivered)
                      ? 'You don\'t have any completed orders'
                      : statusFilter.contains(OrderStatus.cancelled)
                          ? 'You don\'t have any cancelled orders'
                          : 'You don\'t have any active orders',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _viewModel.loadOrders(refresh: true),
      color: const Color(0xFF2196F3),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order, index);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
    // Format currency
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    // Get status color
    Color statusColor;
    switch (order.status) {
      case OrderStatus.pending:
        statusColor = const Color(0xFFFFA000); // Amber
        break;
      case OrderStatus.confirmed:
        statusColor = const Color(0xFF1976D2); // Blue
        break;
      case OrderStatus.pickedUp:
        statusColor = const Color(0xFF7B1FA2); // Purple
        break;
      case OrderStatus.inProgress:
        statusColor = const Color(0xFF0097A7); // Cyan
        break;
      case OrderStatus.readyForDelivery:
        statusColor = const Color(0xFF388E3C); // Green
        break;
      case OrderStatus.delivered:
        statusColor = const Color(0xFF43A047); // Light Green
        break;
      case OrderStatus.cancelled:
        statusColor = const Color(0xFFD32F2F); // Red
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to order details screen
          // Navigator.pushNamed(context, '/order-details', arguments: order);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.statusDisplay,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pickup: ${order.formattedPickupDate} | ${order.pickupTimeSlot}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ordered on: ${order.formattedCreatedDate}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    currencyFormatter.format(order.totalAmount),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // View order details
                      // Navigator.pushNamed(context, '/order-details', arguments: order);
                    },
                    child: Text(
                      'View Details',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms);
  }
}
