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
    return Consumer<CartViewModel>(
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
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                'Cart',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDarkColor,
                ),
              ),
              centerTitle: true,
              leading: cartViewModel.currentTab == CartTab.buildCart
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => cartViewModel.previousTab(),
                  ),
              actions: [
                if (cartViewModel.currentTab == CartTab.buildCart)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87, size: 28),
                    onPressed: () {
                      cartViewModel.resetCart();
                      Navigator.of(context).pop();
                    },
                  ),
              ],
              elevation: 0,
              backgroundColor: Colors.white,
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
    );
  }

  Widget _buildProgressIndicator(CartTab currentTab) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          _buildProgressStep('Build Cart', CartTab.buildCart, currentTab),
          _buildProgressStep('Date & Time', CartTab.dateTime, currentTab),
          _buildProgressStep('Address', CartTab.address, currentTab),
          _buildProgressStep('Confirm', CartTab.confirm, currentTab),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, CartTab step, CartTab currentTab) {
    final isActive = currentTab == step;
    final isCompleted = currentTab.index > step.index;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          children: [
            Container(
              height: 3, // Thinner bars like the image
              decoration: BoxDecoration(
                color: isActive || isCompleted 
                    ? AppColors.primaryColor 
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isActive ? const Color(0xFF004D40) : Colors.grey[400], // Dark teal like image
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: cartViewModel.canContinue()
            ? () => cartViewModel.nextTab()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          disabledBackgroundColor: Colors.grey[200],
          disabledForegroundColor: Colors.grey[400],
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.poppins(
            fontSize: 16, 
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
