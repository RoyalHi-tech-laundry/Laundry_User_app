import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../constants/colors/app_colors.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/account/view/account_screen.dart';
import '../../features/orders/view/order_history_screen.dart';
import '../../utils/app_router.dart';
import '../widgets/drawer_menu.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChecklistScreen(),
    const OrderHistoryScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Show exit confirmation dialog
  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // If not on home screen, navigate to home
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    
    // If on home screen, show confirmation dialog
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => AlertDialog(
        title: Text(
          'Exit App',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryColor,
          ),
        ),
        content: Text(
          'Are you sure you want to close the app?',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Yes',
              style: GoogleFonts.poppins(
                color: AppColors.primaryLightColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
    );
    
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop) {
            // Actually exit the app when user confirms
            if (context.mounted) {
              SystemNavigator.pop();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        extendBody: true,
        drawer: const DrawerMenu(),
        body: _screens[_selectedIndex],
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to cart screen
          Navigator.pushNamed(context, AppRouter.cartRoute);
        },
        backgroundColor: Colors.blue[700],
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.shopping_cart, size: 24, color: Colors.white),
      ).animate()
        .scale(duration: 300.ms)
        .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.6)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        height: 60,
        padding: EdgeInsets.zero,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.checklist_rounded, 'Pricelist', 1),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(Icons.access_time, 'Order', 2),
            _buildNavItem(Icons.person_outline, 'Account', 3),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.blue : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens for other tabs
class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Checklist',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Checklist Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// OrderScreen has been replaced with OrderHistoryScreen
