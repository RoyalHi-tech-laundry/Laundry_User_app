import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/colors/app_colors.dart';
import '../../features/auth/view/login_screen.dart';
import '../../services/auth_storage_service.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.primaryDarkColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
         
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'About Us',
                    iconColor: Colors.black87,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Services',
                    iconColor: Colors.black87,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.local_offer_outlined,
                    title: 'Prices',
                    iconColor: Colors.black87,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Locate Us',
                    iconColor: Colors.black87,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.business_outlined,
                    title: 'Apply for Franchise',
                    iconColor: Colors.black87,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.highlight_outlined,
                    title: 'Media Highlights',
                    iconColor: Colors.black87,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'FAQ\'s',
                    iconColor: Colors.black87,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy & Policy',
                    iconColor: Colors.black87,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Condition',
                    iconColor: Colors.black87,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.contact_support_outlined,
                    title: 'Contact Us',
                    iconColor: Colors.black87,
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Log Out',
                    iconColor: AppColors.primaryLightColor,
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle logout action
  void _handleLogout(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Clear auth data
              await AuthStorageService.clearAuthData();
              
              // Close drawer and dialog
              Navigator.pop(context);
              Navigator.pop(context);
              
              // Navigate to login screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 50.ms)
      .slideX(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
