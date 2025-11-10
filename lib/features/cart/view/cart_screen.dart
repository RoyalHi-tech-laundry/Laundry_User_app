import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors/app_colors.dart';
import '../view_model/cart_viewmodel.dart';
import 'build_cart_tab.dart';
import 'date_time_tab.dart';
import 'address_tab.dart';
import 'confirm_tab.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the cart view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().init();
    });
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
      child: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          return WillPopScope(
            onWillPop: () async {
              if (cartViewModel.currentTab != CartTab.buildCart) {
                cartViewModel.previousTab();
                return false;
              } else {
                // Clear all data when exiting the cart flow completely
                cartViewModel.resetCart();
              }
              return true;
            },
            child: Scaffold(
              backgroundColor: Colors.transparent, // Make scaffold transparent to show gradient
              appBar: AppBar(
                title: Text(
                  'Cart',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                leading: cartViewModel.currentTab == CartTab.buildCart
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () {
                        cartViewModel.resetCart();
                        Navigator.of(context).pop();
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => cartViewModel.previousTab(),
                    ),
                actions: [],
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              body: Column(
                children: [
                  // Progress indicator
                  _buildProgressIndicator(cartViewModel.currentTab),
                  
                  // Current tab content
                  Expanded(
                    child: _buildCurrentTabContent(cartViewModel),
                  ),
                  
                  // Continue button - only show on non-confirm tabs
                  if (cartViewModel.currentTab != CartTab.confirm)
                    _buildContinueButton(cartViewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(CartTab currentTab) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildProgressStep('Build Cart', CartTab.buildCart, currentTab),
          _buildProgressLine(CartTab.buildCart, currentTab),
          _buildProgressStep('Date & Time', CartTab.dateTime, currentTab),
          _buildProgressLine(CartTab.dateTime, currentTab),
          _buildProgressStep('Address', CartTab.address, currentTab),
          _buildProgressLine(CartTab.address, currentTab),
          _buildProgressStep('Confirm', CartTab.confirm, currentTab),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, CartTab step, CartTab currentTab) {
    final isActive = currentTab.index >= step.index;
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primaryDarkColor : Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(CartTab step, CartTab currentTab) {
    final isActive = currentTab.index > step.index;
    
    return Container(
      width: 10,
      height: 1,
      color: isActive ? AppColors.primaryColor : Colors.grey[300],
    );
  }

  Widget _buildCurrentTabContent(CartViewModel cartViewModel) {
    switch (cartViewModel.currentTab) {
      case CartTab.buildCart:
        return const BuildCartTab();
      case CartTab.dateTime:
        return const DateTimeTab();
      case CartTab.address:
        return const AddressTab();
      case CartTab.confirm:
        return const ConfirmTab();
    }
  }

  Widget _buildContinueButton(CartViewModel cartViewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: cartViewModel.canContinue()
            ? () => cartViewModel.nextTab()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          elevation: 2,
          shadowColor: const Color(0xFF2196F3).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.poppins(
            fontSize: 16, 
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
