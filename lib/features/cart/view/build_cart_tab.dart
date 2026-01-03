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
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: InkWell(
        onTap: () => cartViewModel.toggleServiceSelection(service),
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Icon
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      _getServiceIcon(service.icon),
                      size: 32,
                      color: isSelected ? AppColors.primaryDarkColor : AppColors.primaryColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Service info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.local_offer_outlined, size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              '₹${service.price.toStringAsFixed(0)}/${service.unit} onwards',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              service.turnaroundTime,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Bullet points for description
                        ..._buildDescriptionBullets(service.description),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            
            // Selection indicator (Square Checkbox)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDescriptionBullets(String description) {
    if (description.isEmpty) return [];
    
    final points = description.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    return points.map((point) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              point,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    )).toList();
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
