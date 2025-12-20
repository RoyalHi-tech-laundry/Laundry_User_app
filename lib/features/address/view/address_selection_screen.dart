import 'package:flutter/material.dart';
import 'package:laun_easy/constants/colors/app_colors.dart';
import 'package:laun_easy/features/address/model/address_model.dart';
import 'package:laun_easy/services/place_search_service.dart';
import 'package:laun_easy/features/address/view_model/address_selection_viewmodel.dart';
import 'package:laun_easy/features/address/view_model/address_submission_viewmodel.dart';
import 'package:laun_easy/features/address/view/address_details_sheet.dart';
import 'package:laun_easy/features/address/view/map_view.dart';

class AddressSelectionScreen extends StatefulWidget {
  final bool isFirstTimeSignup;
  
  const AddressSelectionScreen({
    super.key,
    this.isFirstTimeSignup = false,
  });

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  late AddressSelectionViewModel _viewModel;
  bool _addressAddedSuccessfully = false; // Flag to track if an address was added successfully

  @override
  void initState() {
    super.initState();
    _viewModel = AddressSelectionViewModel();
    _initializeLocation();
  }
  
  Future<void> _initializeLocation() async {
    setState(() {
      _viewModel.isLoading = true;
      _viewModel.errorMessage = null;
    });
    
    // Test API key first
    final apiWorking = await PlaceSearchService.testApiKey();
    print('API Key test result: $apiWorking');
    
    // Check if location services are enabled
    bool serviceEnabled = await _viewModel.checkLocationServicesEnabled();
    if (!serviceEnabled) {
      setState(() {
        _viewModel.isLoading = false;
        _viewModel.errorMessage = 'Location services are disabled. Please enable location services.';
      });
      return;
    }

    // Request location permission
    await _viewModel.requestLocationPermission();
    
    // Initialize with current location
    await _viewModel.initializeWithCurrentLocation();
    
    // Load search history
    await _viewModel.loadSearchHistory();
    
    setState(() {}); // Refresh UI with actual location data
  }

  Future<void> _onCenterLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await _viewModel.checkLocationServicesEnabled();
    
    if (!serviceEnabled) {
      // If location services are disabled, show error message with enable button
      setState(() {
        _viewModel.isLoading = false;
        _viewModel.errorMessage = 'Location services are disabled. Please enable location services.';
      });
      return;
    }
    
    // Recenter the map to the user's current location
    setState(() {
      _viewModel.isLoading = true;
    });
    
    await _viewModel.initializeWithCurrentLocation();
    setState(() {});
  }
  
  Future<void> _onLocationChanged(double latitude, double longitude) async {
    // First update the UI to show the marker at the new position
    setState(() {
      _viewModel.currentLatitude = latitude;
      _viewModel.currentLongitude = longitude;
      _viewModel.currentLocationName = "Updating location...";
    });
    
    // Then fetch the address details for the new location
    await _viewModel.updateAddressFromCoordinates(latitude, longitude);
    setState(() {}); // Refresh UI with new location data
  }

  void _showAddressDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddressDetailsSheet(
          viewModel: _viewModel,
          onSaveAddress: _onSaveAddress,
          isFirstTimeSignup: widget.isFirstTimeSignup,
        ),
      ),
    );
  }

  Future<void> _onSaveAddress(Address address) async {
    print('📍 DEBUG: _onSaveAddress called with address: ${address.toString()}');
    print('📍 DEBUG: isFirstTimeSignup = ${widget.isFirstTimeSignup}');
    
    if (widget.isFirstTimeSignup) {
      // For first-time signup, the _saveAddress method in AddressDetailsSheet will handle navigation
      print('📍 DEBUG: First-time signup scenario in _onSaveAddress - no action needed');
      // No need to do anything here as saveAddressAndNavigateToHome will be called directly
    } else {
      // For regular address addition, we need to submit the address to the API
      print('📍 DEBUG: Regular address addition scenario in _onSaveAddress');
      try {
        // Create submission view model
        final submissionViewModel = AddressSubmissionViewModel();
        
        // Extract state and country from the location details
        final locationParts = _viewModel.locationDetailsController.text.split(', ');
        String state = '';
        String country = 'India'; // Default to India
        
        if (locationParts.length >= 2) {
          // Assume second-to-last part is state if we have enough parts
          state = locationParts[locationParts.length - 2];
        }
        
        if (locationParts.length >= 3) {
          // Assume last part is country if we have enough parts
          country = locationParts[locationParts.length - 1];
        }
        
        print('📍 DEBUG: Submitting address to API from _onSaveAddress');
        // Submit address to API
        final success = await submissionViewModel.submitAddressFromModel(
          address,
          addressLine1: _viewModel.houseNumberController.text,
          addressLine2: _viewModel.streetController.text,
          state: state,
          country: country,
          isDefault: false, // Set default as needed
        );
        print('📍 DEBUG: Address submitted to API successfully, result: $success');
        
        // Set a flag to ensure the address list is refreshed when returning
        // This will be used when the address details sheet is closed
        _addressAddedSuccessfully = true;
      } catch (e) {
        print('📍 DEBUG: Error submitting address to API: ${e.toString()}');
        // Error will be shown by the AddressDetailsSheet
      }
    }
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    print('📍 DEBUG: _onWillPop called, _addressAddedSuccessfully = $_addressAddedSuccessfully');
    // If an address was added successfully, return true to trigger a refresh in the address list screen
    if (_addressAddedSuccessfully) {
      print('📍 DEBUG: Returning true from _onWillPop to trigger refresh');
      Navigator.of(context).pop(true);
      return false; // Don't pop again
    }
    return true; // Allow normal back button behavior
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
      body: Stack(
        children: [
          // Map view
          Stack(
            children: [
              MapView(
                latitude: _viewModel.currentLatitude ?? 0.0,
                longitude: _viewModel.currentLongitude ?? 0.0,
                onCenterLocation: _onCenterLocation,
                onLocationChanged: _onLocationChanged,
              ),
              
              // Loading indicator
              if (_viewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                
              // Error message overlay
              if (_viewModel.errorMessage != null)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_off,
                              size: 32,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Location Services Required',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We need access to your location to show nearby pickup points and provide accurate address details.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await _viewModel.openLocationSettings();
                                // Wait a bit for user to enable location, then retry
                                await Future.delayed(const Duration(seconds: 2));
                                _initializeLocation();
                              },
                              icon: const Icon(Icons.settings, size: 20),
                              label: const Text(
                                'Open Location Settings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _viewModel.errorMessage = null;
                              });
                              _initializeLocation();
                            },
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // App bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // App bar with back button and title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Add Address',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        children: [
                          // Search input field
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _viewModel.searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search for a location',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    onChanged: (value) async {
                                      if (value.length >= 2) {
                                        await _viewModel.searchPlaces(value);
                                        setState(() {
                                          _viewModel.isShowingHistory = false;
                                        });
                                      } else if (value.isEmpty) {
                                        setState(() {
                                          _viewModel.searchResults = [];
                                          _viewModel.isShowingHistory = true;
                                        });
                                      }
                                    },
                                    onTap: () async {
                                      // Load and show search history when search field is focused
                                      if (_viewModel.searchController.text.isEmpty) {
                                        await _viewModel.loadSearchHistory();
                                        setState(() {
                                          _viewModel.isShowingHistory = true;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                if (_viewModel.searchController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () async {
                                      _viewModel.searchController.clear();
                                      await _viewModel.loadSearchHistory();
                                      setState(() {
                                        _viewModel.searchResults = [];
                                        _viewModel.isShowingHistory = true;
                                      });
                                    },
                                    child: const Icon(Icons.clear, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                          
                          // Search results list
                          if (_viewModel.searchResults.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(maxHeight: 300),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _viewModel.searchResults.length,
                                separatorBuilder: (context, index) => const Divider(
                                  height: 1,
                                  thickness: 1,
                                  indent: 56,
                                  endIndent: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final place = _viewModel.searchResults[index];
                                  return ListTile(
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLightColor.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: AppColors.primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      place.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      place.address,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    onTap: () async {
                                      // Dismiss keyboard
                                      FocusScope.of(context).unfocus();
                                      
                                      await _viewModel.selectPlace(place);
                                      setState(() {}); // Refresh UI with selected place
                                    },
                                  );
                                },
                              ),
                            ),
                          
                          // Search history list
                          if (_viewModel.isShowingHistory && _viewModel.searchHistory.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(maxHeight: 300),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.history, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Recent Searches',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  Flexible(
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: _viewModel.searchHistory.length,
                                      separatorBuilder: (context, index) => const Divider(
                                        height: 1,
                                        thickness: 1,
                                        indent: 56,
                                        endIndent: 16,
                                      ),
                                      itemBuilder: (context, index) {
                                        final place = _viewModel.searchHistory[index];
                                        return ListTile(
                                          leading: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.history,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                          ),
                                          title: Text(
                                            place.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            place.address,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          onTap: () async {
                                            // Dismiss keyboard
                                            FocusScope.of(context).unfocus();
                                            
                                            await _viewModel.selectPlace(place);
                                            setState(() {}); // Refresh UI with selected place
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Search error message
                          if (_viewModel.searchError != null)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _viewModel.searchError!,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Loading indicator for search
                          if (_viewModel.isSearching)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom location info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Location info card
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your clothes will be collected from here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLightColor.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _viewModel.currentLocationName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _buildAccuracyIndicator(_viewModel.locationAccuracy),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _viewModel.currentFullAddress,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Confirm & Add Details button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _showAddressDetailsSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Confirm & Add Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
  
  // Build accuracy indicator widget
  Widget _buildAccuracyIndicator(String accuracy) {
    Color indicatorColor;
    String tooltipText;
    IconData iconData;
    
    switch (accuracy) {
      case 'high':
        indicatorColor = Colors.green;
        tooltipText = 'High accuracy';
        iconData = Icons.gps_fixed;
        break;
      case 'medium':
        indicatorColor = Colors.orange;
        tooltipText = 'Medium accuracy';
        iconData = Icons.gps_not_fixed;
        break;
      case 'low':
        indicatorColor = Colors.red;
        tooltipText = 'Low accuracy';
        iconData = Icons.gps_off;
        break;
      case 'unknown':
      default:
        indicatorColor = Colors.grey;
        tooltipText = 'Unknown accuracy';
        iconData = Icons.gps_off;
        break;
    }
    
    return Tooltip(
      message: tooltipText,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: indicatorColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: indicatorColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 12, color: indicatorColor),
            const SizedBox(width: 4),
            Text(
              accuracy.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: indicatorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    print('📍 DEBUG: AddressSelectionScreen dispose called, _addressAddedSuccessfully = $_addressAddedSuccessfully');
    // If an address was added successfully, return true to trigger a refresh in the address list screen
    if (_addressAddedSuccessfully && Navigator.canPop(context)) {
      print('📍 DEBUG: Returning true to trigger refresh');
      Navigator.of(context).pop(true);
    }
    _viewModel.dispose();
    super.dispose();
  }
}
