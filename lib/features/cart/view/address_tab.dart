import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/colors/app_colors.dart';
import '../../address/model/address_list_model.dart';
import '../../address/view_model/address_list_viewmodel.dart';
import '../view_model/cart_viewmodel.dart';

class AddressTab extends StatefulWidget {
  const AddressTab({Key? key}) : super(key: key);

  @override
  State<AddressTab> createState() => _AddressTabState();
}

class _AddressTabState extends State<AddressTab> {
  late AddressListViewModel _addressViewModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _addressViewModel = Provider.of<AddressListViewModel>(context, listen: false);
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
    });
    
    await _addressViewModel.loadAddresses();
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartViewModel, AddressListViewModel>(
      builder: (context, cartViewModel, addressViewModel, child) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ));
        }

        final addresses = addressViewModel.addresses;
        
        if (addresses.isEmpty) {
          return _buildNoAddressesView(context);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Choose Pickup Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: addresses.length + 1, // +1 for add new address button
                  itemBuilder: (context, index) {
                    if (index == addresses.length) {
                      return _buildAddNewAddressButton(context);
                    }
                    
                    final address = addresses[index];
                    final isSelected = cartViewModel.cart.addressId == address.id;
                    
                    return _buildAddressCard(
                      context,
                      address,
                      isSelected,
                      () {
                        cartViewModel.setAddress(
                          address.id,
                          address.formattedAddress,
                        );
                      },
                    ).animate(delay: (50 * index).ms).fadeIn(duration: 300.ms);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoAddressesView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No addresses found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please add a delivery address to continue',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddAddress(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.add_location),
            label: const Text('Add New Address'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressItem address,
    bool isSelected,
    VoidCallback onSelect,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAddressTypeIcon(address.type),
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              
              // Address details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.typeDisplay,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Default',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.formattedAddress,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Checkbox
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewAddressButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: OutlinedButton.icon(
        onPressed: () => _navigateToAddAddress(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        icon: Icon(Icons.add, color: AppColors.primaryColor),
        label: Text(
          'Add New Address',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 300.ms);
  }

  void _navigateToAddAddress(BuildContext context) async {
    await _addressViewModel.navigateToAddressSelectionScreen(context);
    // After returning from address selection, refresh the list
    _loadAddresses();
  }

  IconData _getAddressTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'HOME':
        return Icons.home;
      case 'WORK':
        return Icons.business;
      case 'OTHER':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }

  // Note: We're using AppColors.successColor directly in the UI now
}
