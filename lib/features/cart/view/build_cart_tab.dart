import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors/app_colors.dart';
import '../view_model/cart_viewmodel.dart';
import '../model/service_model.dart';

class BuildCartTab extends StatelessWidget {
  const BuildCartTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        if (cartViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.successColor),
          ));
        }

        if (cartViewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${cartViewModel.error}',
                  style: const TextStyle(color: AppColors.errorColor),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => cartViewModel.loadServices(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Build your laundry cart',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: cartViewModel.services.length,
                  itemBuilder: (context, index) {
                    final service = cartViewModel.services[index];
                    return _buildServiceCard(context, service, cartViewModel)
                      .animate(delay: (50 * index).ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0, duration: 300.ms);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    ServiceModel service,
    CartViewModel cartViewModel,
  ) {
    final isSelected = cartViewModel.isServiceSelected(service);

    return Container(
      key: ValueKey('service-${service.id}'),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isSelected ? const Color(0xFF2196F3).withOpacity(0.15) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
        border: Border.all(
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade100,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => cartViewModel.toggleServiceSelection(service),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service icon with container
              Container(
                width: 70,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getServiceIcon(service.icon),
                        size: 22,
                        color: isSelected ? Colors.white : const Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${service.price}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Service details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          service.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SELECTED',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const Spacer(),
                        // Square Checkbox
                        InkWell(
                          onTap: () => cartViewModel.toggleServiceSelection(service),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(4),
                              color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                              border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildServiceDetail(
                          Icons.access_time,
                          service.turnaroundTime,
                        ),
                        const SizedBox(width: 16),
                        _buildServiceDetail(
                          Icons.shopping_bag,
                          'Per ${service.unit}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String? iconName) {
    // Try to parse the icon name from the API
    if (iconName != null && iconName.isNotEmpty) {
      // Check if the icon name contains a dot (like 'Icons.star')
      if (iconName.contains('Icons.')) {
        String iconKey = iconName.split('.').last;
        
        // Map common icon names to their corresponding IconData
        switch (iconKey) {
          case 'local_laundry_service':
            return Icons.local_laundry_service;
          case 'iron':
            return Icons.iron;
          case 'star':
            return Icons.star;
          case 'dry_cleaning':
            return Icons.dry_cleaning;
          case 'wash':
            return Icons.wash;
          case 'cleaning_services':
            return Icons.cleaning_services;
        }
      }
    }
    
    // Fallback to default icon if icon name is null or not recognized
    return Icons.local_laundry_service;
  }

  Widget _buildServiceDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2196F3)),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
