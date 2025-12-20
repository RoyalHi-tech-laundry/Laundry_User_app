import 'package:flutter/material.dart';
import 'package:laun_easy/constants/colors/app_colors.dart';
import 'package:laun_easy/features/address/model/address_model.dart';
import 'package:laun_easy/features/address/view_model/address_selection_viewmodel.dart';
import 'package:laun_easy/features/address/view/address_type_selector.dart';
import 'package:laun_easy/core/navigation/main_navigation.dart';

class AddressDetailsSheet extends StatefulWidget {
  final AddressSelectionViewModel viewModel;
  final Function(Address) onSaveAddress;
  final bool isFirstTimeSignup;

  const AddressDetailsSheet({
    super.key,
    required this.viewModel,
    required this.onSaveAddress,
    this.isFirstTimeSignup = false,
  });

  @override
  State<AddressDetailsSheet> createState() => _AddressDetailsSheetState();
}

class _AddressDetailsSheetState extends State<AddressDetailsSheet> {
  late AddressType _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.viewModel.selectedAddressType;
    
    // Pre-fill city and pincode from current location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.prefillFromCurrentLocation();
      setState(() {}); // Refresh UI with prefilled data
    });
  }

  void _updateAddressType(AddressType type) {
    setState(() {
      _selectedType = type;
      widget.viewModel.updateAddressType(type);
    });
  }

  Future<void> _saveAddress() async {
    print('📍 DEBUG: _saveAddress method called');
    
    // Use different validation logic for first-time signup
    bool isValid = widget.isFirstTimeSignup 
        ? widget.viewModel.isFormValidForSignup 
        : widget.viewModel.isFormValid;
    
    if (!isValid) {
      print('📍 DEBUG: Form is not valid, cannot save address');
      // Get specific validation error message
      String errorMessage = widget.viewModel.getValidationError() ?? 'Please fill in all required fields';
      print('📍 DEBUG: Validation error: $errorMessage');
      
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // If we're in first-time signup and some fields are empty, pre-fill them with defaults
    if (widget.isFirstTimeSignup) {
      if (widget.viewModel.houseNumberController.text.isEmpty) {
        widget.viewModel.houseNumberController.text = 'Not specified';
      }
      if (widget.viewModel.streetController.text.isEmpty) {
        widget.viewModel.streetController.text = 'Not specified';
      }
      if (widget.viewModel.landmarkController.text.isEmpty) {
        widget.viewModel.landmarkController.text = 'Not specified';
      }
    }
    
    // Show loading indicator
    setState(() {
      _isLoading = true;
    });
    print('📍 DEBUG: Showing loading indicator, _isLoading = $_isLoading');
    
    try {
      print('📍 DEBUG: Creating address object');
      // Create address object with appropriate validation level
      final address = widget.viewModel.saveAddress(isFirstTimeSignup: widget.isFirstTimeSignup);
      print('📍 DEBUG: Address object created successfully');
      
      if (widget.isFirstTimeSignup) {
        print('📍 DEBUG: First-time signup scenario - calling saveAddressAndNavigateToHome directly');
        try {
          // For first-time signup, call saveAddressAndNavigateToHome directly
          // This will navigate to the home screen regardless of API result
          await widget.viewModel.saveAddressAndNavigateToHome(context);
          print('📍 DEBUG: saveAddressAndNavigateToHome completed successfully');
          // No need to hide loading indicator as we're navigating away
          
          // Add a failsafe navigation in case the previous one didn't work
          print('📍 DEBUG: Adding failsafe navigation to ensure we reach home screen');
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainNavigation()),
                (route) => false, // Remove all previous routes
              );
            }
          });
        } catch (e) {
          print('📍 DEBUG: Error in saveAddressAndNavigateToHome: ${e.toString()}');
          // Try direct navigation as a fallback
          print('📍 DEBUG: Attempting direct navigation as fallback');
          try {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainNavigation()),
              (route) => false, // Remove all previous routes
            );
            print('📍 DEBUG: Fallback navigation completed');
          } catch (navError) {
            print('📍 DEBUG: Fallback navigation failed: ${navError.toString()}');
            // Hide loading indicator and show error
            setState(() {
              _isLoading = false;
            });
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error navigating to home: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        print('📍 DEBUG: Regular address addition scenario');
        // For regular address addition, call onSaveAddress callback
        await widget.onSaveAddress(address);
        print('📍 DEBUG: onSaveAddress callback completed');
        
        // Show success message and navigate back
        // This will hide the loading indicator
        widget.viewModel.showSuccessAndNavigateBack(context);
      }
    } catch (e) {
      print('📍 DEBUG: Error saving address: ${e.toString()}');
      // Hide loading indicator and show error
      setState(() {
        _isLoading = false;
      });
      print('📍 DEBUG: Loading indicator hidden due to error');
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save address: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Close button and title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Address Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Accurate address details ensures seamless pick-up and delivery services.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Address type selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Address type',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                AddressTypeSelector(
                  selectedType: _selectedType,
                  onTypeSelected: _updateAddressType,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form fields
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // House/Flat/Floor No.
                _buildTextField(
                  controller: widget.viewModel.houseNumberController,
                  hintText: 'House/Flat/Floor No.',
                ),
                const SizedBox(height: 12),
                
                // Apartment / Road / Area
                _buildTextField(
                  controller: widget.viewModel.streetController,
                  hintText: 'Apartment / Road / Area',
                ),
                const SizedBox(height: 12),
                
                // Landmark
                _buildTextField(
                  controller: widget.viewModel.landmarkController,
                  hintText: 'Landmark',
                  isRequired: false,
                ),
                const SizedBox(height: 12),
                
                // Location Details (City, State, Country, Pincode)
                _buildTextField(
                  controller: widget.viewModel.locationDetailsController,
                  hintText: 'City, State, Country, Pincode',
                  isEnabled: false,
                  suffixIcon: const Icon(Icons.location_on, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.7),
                  disabledForegroundColor: Colors.white70,
                ),
                child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isRequired = true,
    bool isEnabled = true,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: isEnabled 
        ? TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: true,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: suffixIcon,
            ),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            maxLines: 1,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? hintText : controller.text,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (suffixIcon != null) suffixIcon,
              ],
            ),
          ),
    );
  }
}
