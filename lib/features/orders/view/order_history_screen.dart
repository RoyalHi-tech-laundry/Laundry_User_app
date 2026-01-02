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

  // Show cancel order dialog with enhanced UI
  Future<void> _showCancelOrderDialog(Order order) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    // State will be managed by the dialog itself

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Local state for the dialog
        bool dialogLoading = false;
        bool dialogSuccess = false;
        bool dialogHasError = false;
        String? dialogErrorMessage;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 8.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFf8f9fa), Color(0xFFe9ecef)],
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header with icon
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFE3E3),
                                ),
                                child: const Icon(
                                  Icons.cancel_outlined,
                                  size: 40,
                                  color: Color(0xFFE63946),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Cancel Order #${order.orderNumber}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF212529),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Reason input
                          Text(
                            'Please tell us why you want to cancel this order:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF495057),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Text field
                          TextFormField(
                            controller: reasonController,
                            style: GoogleFonts.poppins(fontSize: 14),
                            enabled: !dialogLoading,
                            decoration: InputDecoration(
                              hintText: 'Type your reason here...',
                              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFF4CC9F0),
                                  width: 2.0,
                                ),
                              ),
                            ),
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a reason for cancellation';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Buttons
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Show success/error state or action buttons
                              if (dialogSuccess)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFE8F5E9),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_outline,
                                        size: 64,
                                        color: Color(0xFF38B000),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Order Cancelled!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF212529),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        'Your order #${order.orderNumber} has been cancelled successfully.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: const Color(0xFF495057),
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF38B000),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: Text(
                                          'Go Back',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else if (dialogHasError)
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFFEEBEE),
                                      ),
                                      child: const Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Error',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFE53935),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      dialogErrorMessage ?? 'Failed to cancel order',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF495057),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              side: const BorderSide(color: Color(0xFF6C757D)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            child: Text(
                                              'Close',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF6C757D),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setDialogState(() {
                                                dialogHasError = false;
                                                dialogErrorMessage = null;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFE63946),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              elevation: 2,
                                            ),
                                            child: Text(
                                              'Try Again',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    // Confirm button with loading state
                                    ElevatedButton(
                                      onPressed: dialogLoading
                                          ? null
                                          : () async {
                                              if (formKey.currentState!.validate()) {
                                                setDialogState(() => dialogLoading = true);
                                                try {
                                                  final success = await _viewModel.cancelOrder(
                                                    order.id,
                                                    reasonController.text.trim(),
                                                  );

                                                  if (success) {
                                                    setDialogState(() {
                                                      dialogLoading = false;
                                                      dialogSuccess = true;
                                                    });
                                                  } else {
                                                    setDialogState(() {
                                                      dialogHasError = true;
                                                      dialogLoading = false;
                                                      dialogErrorMessage = 'Failed to cancel order';
                                                    });
                                                  }
                                                } catch (e) {
                                                  setDialogState(() {
                                                    dialogHasError = true;
                                                    dialogLoading = false;
                                                    dialogErrorMessage = 'Error: ${e.toString()}';
                                                  });
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE63946),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        elevation: 2,
                                        shadowColor: Colors.black26,
                                      ),
                                      child: dialogLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'Confirm Cancellation',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Cancel button
                                    OutlinedButton(
                                      onPressed: dialogLoading ? null : () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        side: const BorderSide(color: Color(0xFF6C757D)),
                                      ),
                                      child: Text(
                                        'Go Back',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF6C757D),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ).animate().fadeIn(duration: 300.ms).slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 300.ms,
                              curve: Curves.easeOutQuart,
                            ),
                        ],
                        ),
                ),
                  ),
              ),
              ),
            );
          },
        );
      },
    );
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
      onRefresh: () => _viewModel.loadOrders(),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel button - only show for active orders
                  if (order.status != OrderStatus.cancelled && 
                      order.status != OrderStatus.delivered)
                    TextButton(
                      onPressed: () => _showCancelOrderDialog(order),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Cancel Order',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  
                  // View Details button
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
