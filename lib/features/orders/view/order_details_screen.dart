import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants/colors/app_colors.dart';
import '../model/order_model.dart';
import '../service/order_api_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderApiService _orderApiService = OrderApiService();
  late Future<Order> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = _orderApiService.getOrderById(widget.orderId);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Order>(
      future: _orderFuture,
      builder: (context, snapshot) {
        // Show loading state while fetching headers/data
        if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(elevation: 0, backgroundColor: Colors.white, leading: const BackButton(color: Colors.black)),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('No order found')));
        }

        final order = snapshot.data!;
        
        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F5), // Light grey background like Swiggy
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER #${order.orderNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${order.statusDisplay} • ${order.items?.length ?? 0} Items • ₹${order.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // TODO: Implement Help/Support chat or call
                  _makePhoneCall('1800-123-4567'); // Dummy support number
                },
                child: Text(
                  'HELP',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummaryParams(order),
                _buildAddressSection(order),
                const SizedBox(height: 16),
                _buildBillDetails(order),
                const SizedBox(height: 16),
                _buildOrderInfoFooter(order),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomReorderBar(order),
        );
      },
    );
  }

  Widget _buildOrderSummaryParams(Order order) {
      // Just a placeholder for "Order Delivered on..." with a tick
      // If order is active, maybe show generic status or "Arriving in..."
      
      bool isDelivered = order.status == OrderStatus.delivered;
      String statusText = isDelivered 
          ? 'Order delivered on ${DateFormat('MMMM d, h:mm a').format(order.pickupDate)}' // Using pickupDate as proxy for delivery if deliveryDate missing
          : 'Order Status: ${order.statusDisplay}';
          
      return Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDelivered ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDelivered ? Icons.check : Icons.access_time_filled,
                color: isDelivered ? AppColors.successColor : AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                          statusText,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                          ),
                      ),
                      if (isDelivered) 
                      Text(
                          'Rate order to help us improve',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                      )
                  ],
              )
            )
          ],
        ),
      );
  }

  Widget _buildAddressSection(Order order) {
    // Handling generic address object if dynamic
    String addressLine = 'Address details not available';
    String city = '';
    
    if (order.address != null) {
      if (order.address is Map) {
         addressLine = "${order.address['addressLine1'] ?? ''}, ${order.address['addressLine2'] ?? ''}";
         city = "${order.address['city'] ?? ''} - ${order.address['pincode'] ?? ''}";
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 1),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
               const Icon(Icons.storefront, size: 24, color: Colors.black87), // Store Icon
               Container(
                 width: 1, 
                 height: 30, 
                 color: Colors.grey[300], 
                 margin: const EdgeInsets.symmetric(vertical: 4)
               ),
               const Icon(Icons.location_on_outlined, size: 24, color: Colors.black87), // User Location Icon
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Address (Static for now as laundry service usually single/few points)
                Text(
                  'Laundry Service',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  'Main Branch, City Center',
                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 32), // Space for connector line visual alignment
                // User Address
                Text(
                  'Delivery Address',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  addressLine,
                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (city.isNotEmpty)
                  Text(
                    city,
                    style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetails(Order order) {
    final items = order.items ?? [];
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BILL DETAILS',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          
          if (items.isEmpty)
             const Text("No items details available"),
          
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Row(
                   children: [
                     const Icon(Icons.dry_cleaning, size: 16, color: AppColors.primaryColor), // Item Type Icon
                     const SizedBox(width: 8),
                     Text(
                        '${item.name} x ${item.quantity}',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                     ),
                   ],
                 ),
                 Text(
                   '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                   style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                 ),
              ],
            ),
          )).toList(),
          
          const Divider(thickness: 1, height: 32),
          
          // Bill Summary
          _buildBillRow('Item Total', '₹${order.totalAmount.toStringAsFixed(2)}'), /* Assuming totalAmount is items total for now */
          // _buildBillRow('Service Charges', '₹25.00'), // Example fixed charge
          // _buildBillRow('Delivery Fee', 'FREE', isDiscount: true),
          
          const Divider(thickness: 1, height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paid Via',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text(
                    'Bill Total',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13, 
              color: isDiscount ? AppColors.successColor : Colors.black87,
              fontWeight: isDiscount ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoFooter(Order order) {
      return Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        width: double.infinity,
        child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                 Text('Order Details', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                 const SizedBox(height: 12),
                 _buildFooterRow('Order Number', order.orderNumber),
                 _buildFooterRow('Date', DateFormat('MMM d, yyyy h:mm a').format(order.createdAt)),
                 if(order.pickupTimeSlot.isNotEmpty)
                    _buildFooterRow('Pickup Slot', order.pickupTimeSlot),
             ],
        ),
      );
  }
  
  Widget _buildFooterRow(String label, String value) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                   Text(label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500], letterSpacing: 0.5)),
                   Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
              ],
          ),
      );
  }

  Widget _buildBottomReorderBar(Order order) {
      return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
                onPressed: () { 
                   // Reorder Logic
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reorder feature coming soon!")));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("REORDER", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
            ),
          ),
      );
  }
}
