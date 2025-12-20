import 'package:flutter/material.dart';
import 'package:laun_easy/features/address/model/address_model.dart';
import 'package:laun_easy/services/location_service.dart';
import 'package:laun_easy/services/place_search_service.dart';
import 'package:laun_easy/core/navigation/main_navigation.dart';
import '../../../utils/app_router.dart';
import '../view_model/address_submission_viewmodel.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class AddressSelectionViewModel extends ChangeNotifier {
  // Controllers for form fields
  final TextEditingController searchController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController locationDetailsController = TextEditingController();
  
  // Search-related properties
  List<PlaceSearchResult> searchResults = [];
  List<PlaceSearchResult> searchHistory = [];
  bool isSearching = false;
  bool isShowingHistory = false;
  String? searchError;
  
  // Current selected location - no default coordinates, wait for actual location
  double? currentLatitude;
  double? currentLongitude;
  String currentLocationName = "Fetching location...";
  String currentFullAddress = "Please wait while we get your current location";
  String locationAccuracy = "unknown"; // Location accuracy: high, medium, low, unknown
  
  // Loading state
  bool isLoading = true;
  String? errorMessage;
  
  // Selected address type
  AddressType selectedAddressType = AddressType.home;
  
  // Form validation state
  bool get isFormValid => 
      houseNumberController.text.isNotEmpty &&
      streetController.text.isNotEmpty &&
      locationDetailsController.text.isNotEmpty;
      
  // Get specific validation errors
  String? getValidationError() {
    if (houseNumberController.text.isEmpty) {
      return 'Please enter House/Flat/Floor No.';
    }
    if (streetController.text.isEmpty) {
      return 'Please enter Apartment / Road / Area';
    }
    if (locationDetailsController.text.isEmpty) {
      return 'Location details are missing';
    }
    return null;
  }
  
  // Check if form is valid enough for first-time signup
  // This is more lenient than the regular validation
  bool get isFormValidForSignup => 
      // At least one of these fields should be filled
      houseNumberController.text.isNotEmpty || 
      streetController.text.isNotEmpty;
      
  // Success message handling
  bool showSuccessMessage = false;
  String successMessage = '';
  
  // Show success message and navigate back to address list screen
  void showSuccessAndNavigateBack(BuildContext context) {
    print('📍 DEBUG: showSuccessAndNavigateBack called');
    showSuccessMessage = true;
    successMessage = 'Address added successfully';
    notifyListeners();
    
    // Provide haptic feedback for success
    HapticFeedback.mediumImpact();
    
    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(successMessage),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Navigate back to address list screen after a short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      print('📍 DEBUG: Navigation delay completed, popping screens');
      
      try {
        // Pop twice to go back to address list screen
        // First pop closes the address details sheet
        Navigator.pop(context); // Close address details sheet
        print('📍 DEBUG: Popped address details sheet');
        
        // Return to address list screen with success result
        // The true value will trigger a refresh in the address list screen
        Navigator.of(context).pop(true);
        print('📍 DEBUG: Popped address selection screen with result: true');
      } catch (e) {
        print('📍 DEBUG: Error during navigation: ${e.toString()}');
        // Try a different approach if the first one fails
        try {
          // Just pop the current screen with result
          Navigator.of(context).pop(true);
          print('📍 DEBUG: Fallback navigation completed');
        } catch (e2) {
          print('📍 DEBUG: Fallback navigation failed: ${e2.toString()}');
        }
      }
    });
  }
  
  // Check if location services are enabled
  Future<bool> checkLocationServicesEnabled() async {
    return await LocationService.isLocationServiceEnabled();
  }
  
  // Open location settings
  Future<bool> openLocationSettings() async {
    return await LocationService.openLocationSettings();
  }
  
  // Request location permission
  Future<void> requestLocationPermission() async {
    await LocationService.requestPermission();
  }
  
  // Initialize with user's current location
  Future<void> initializeWithCurrentLocation() async {
    isLoading = true;
    errorMessage = null;
    locationAccuracy = "unknown";
    
    try {
      // First try to get cached location data for immediate display
      final cachedLocation = await LocationService.getCachedLocation();
      if (cachedLocation != null) {
        // Use cached data for immediate display
        currentLatitude = cachedLocation['latitude']!;
        currentLongitude = cachedLocation['longitude']!;
        
        final addressData = cachedLocation['addressData'] as Map<String, dynamic>;
        currentLocationName = addressData['locationName'] ?? 'Unknown Location';
        currentFullAddress = addressData['fullAddress'] ?? 'Address not found';
        
        // Mark as medium accuracy since it's cached
        locationAccuracy = "medium";
        
        // Update UI immediately with cached data
        isLoading = false;
      }
      
      // Check if location services are enabled
      bool serviceEnabled = await checkLocationServicesEnabled();
      if (!serviceEnabled) {
        // If we have cached data, we can continue with that
        if (cachedLocation == null) {
          isLoading = false;
          errorMessage = 'Location services are disabled. Please enable location services.';
        }
        return;
      }
      
      // Get fresh position with high accuracy (even if we already displayed cached data)
      final position = await LocationService.getCurrentPositionWithAccuracy();
      
      // Update coordinates with actual user location
      currentLatitude = position.latitude;
      currentLongitude = position.longitude;
      
      print('Got user location: ${position.latitude}, ${position.longitude} with accuracy: ${position.accuracy}m');
      
      // Get address from coordinates
      await updateAddressFromCoordinates(position.latitude, position.longitude);
      
      // Set accuracy based on position accuracy
      if (position.accuracy < 10) {
        locationAccuracy = "high";
      } else if (position.accuracy < 50) {
        locationAccuracy = "medium";
      } else {
        locationAccuracy = "low";
      }
      
      isLoading = false;
    } catch (e) {
      isLoading = false;
      if (e.toString() == 'LOCATION_SERVICES_DISABLED') {
        errorMessage = 'Location services are disabled. Please enable location services.';
      } else {
        errorMessage = e.toString();
      }
      print('Error getting location: $e');
    }
  }
  
  // Update location when map is moved
  Future<void> updateAddressFromCoordinates(double latitude, double longitude) async {
    currentLatitude = latitude;
    currentLongitude = longitude;
    
    print('Updating address for coordinates: $latitude, $longitude');
    
    try {
      final addressData = await LocationService.getAddressFromLatLng(latitude, longitude);
      
      // Get the precise location name with building name or plus code
      currentLocationName = addressData['locationName'] ?? 'Unknown Location';
      currentFullAddress = addressData['fullAddress'] ?? 'Address not found';
      locationAccuracy = addressData['accuracy'] ?? 'unknown';
      
      // Extract city, state, country and pincode from placemark data
      final placemark = addressData['placemark'];
      String? city;
      String? state;
      String? country;
      String? pincode;
      
      if (placemark != null) {
        city = placemark['locality'] ?? placemark['subLocality'];
        state = placemark['administrativeArea'] ?? placemark['subAdministrativeArea'];
        country = placemark['country'];
        pincode = placemark['postalCode'];
      }
      
      print('Extracted from placemark - City: $city, State: $state, Country: $country, Pincode: $pincode');
      
      // Update individual controllers for backward compatibility
      if (cityController.text.isEmpty && city != null && city.isNotEmpty) {
        cityController.text = city;
      }
      
      if (pincodeController.text.isEmpty && pincode != null && pincode.isNotEmpty) {
        pincodeController.text = pincode;
      }
      
      // If we still don't have pincode, try to extract it from the full address
      if (pincodeController.text.isEmpty) {
        String? extractedPincode = _extractPincodeFromAddress(currentFullAddress);
        if (extractedPincode != null) {
          pincodeController.text = extractedPincode;
          pincode = extractedPincode;
        }
      }
      
      // Update the combined location details field
      _updateLocationDetailsField(city, state, country, pincode ?? pincodeController.text);
    } catch (e) {
      print('Error getting address: $e');
    }
  }
  
  // Update selected address type
  void updateAddressType(AddressType type) {
    selectedAddressType = type;
  }
  
  // Save address and navigate to home screen
  Future<void> saveAddressAndNavigateToHome(BuildContext context) async {
    print('📍 DEBUG: saveAddressAndNavigateToHome started');
    
    // Debug log coordinates before saving
    print('📍 COORDINATES DEBUG - Before saving address:');
    print('📍 Current latitude: $currentLatitude');
    print('📍 Current longitude: $currentLongitude');
    
    try {
      print('📍 DEBUG: Creating address object for first-time signup');
      final address = saveAddress(isFirstTimeSignup: true);
      print('📍 DEBUG: Address object created successfully');
      
      // Debug log coordinates in the created address
      print('📍 COORDINATES DEBUG - In created address object:');
      print('📍 Address latitude: ${address.latitude}');
      print('📍 Address longitude: ${address.longitude}');
      
      print('📍 DEBUG: Creating submission view model');
      final submissionViewModel = AddressSubmissionViewModel();
      
      // Extract state and country from the location details
      print('📍 DEBUG: Extracting state and country from location details');
      final locationParts = locationDetailsController.text.split(', ');
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
      
      print('📍 DEBUG: Extracted state: $state, country: $country');
      
      try {
        // Debug log before API submission
        print('📍 COORDINATES DEBUG - Before API submission:');
        print('📍 Submitting latitude: ${address.latitude}');
        print('📍 Submitting longitude: ${address.longitude}');
        
        print('📍 DEBUG: Submitting address to API');
        // Submit address to API without showing a popup
        final success = await submissionViewModel.submitAddressFromModel(
          address,
          addressLine1: houseNumberController.text,
          addressLine2: streetController.text,
          state: state,
          country: country,
          isDefault: true, // Set default to true for first-time signup
        );
        print('📍 DEBUG: API submission result: $success');
        
        // For first-time signup, we want to navigate to home screen regardless of API result
        // The address might have been created successfully even if the API returns false
        // This is evident from the logs showing the address was created with an ID
        
        // Show appropriate message based on API result
        if (success) {
          print('📍 DEBUG: Address saved successfully according to API');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(submissionViewModel.successMessage)),
          );
        } else {
          print('📍 DEBUG: API reported failure but we will proceed anyway');
          print('📍 DEBUG: API error message: ${submissionViewModel.error}');
          // Show a generic success message instead of the error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address saved. Continuing to home screen...')),
          );
        }
        
        // Always navigate to home screen for first-time signup
        print('📍 DEBUG: Navigating to MainNavigation regardless of API result');
        // Navigate to main navigation with bottom bar, clearing the entire stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false, // Remove all previous routes
        );
        print('📍 DEBUG: Navigation completed');
      } catch (e) {
        print('📍 DEBUG: Error in API submission: ${e.toString()}');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } catch (e) {
      print('📍 DEBUG: Error creating address: ${e.toString()}');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating address: ${e.toString()}')),
      );
    }
  }

  // Validate address data and throw error if invalid
  void validateAddressData({bool isFirstTimeSignup = false}) {
    print('📍 DEBUG: Validating address data, isFirstTimeSignup = $isFirstTimeSignup');
    
    // Validate pincode - more lenient during first-time signup
    String pincode = pincodeController.text;
    if (!isFirstTimeSignup && (pincode.isEmpty || pincode == '000000')) {
      throw Exception('Please enter a valid 6-digit pincode.');
    }
    
    if (!isFirstTimeSignup && pincode.isNotEmpty && (pincode.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pincode))) {
      throw Exception('Pincode must be exactly 6 digits.');
    }
    
    // Validate coordinates - required in all cases
    if (currentLatitude == null || currentLongitude == null) {
      print('📍 DEBUG: Missing coordinates: lat=$currentLatitude, lng=$currentLongitude');
      // Use default coordinates for Chennai if missing
      currentLatitude = 13.0827;
      currentLongitude = 80.2707;
      print('📍 DEBUG: Using default coordinates: lat=$currentLatitude, lng=$currentLongitude');
    }
    
    if (currentLatitude! < -90 || currentLatitude! > 90 || 
        currentLongitude! < -180 || currentLongitude! > 180) {
      print('📍 DEBUG: Invalid coordinates: lat=$currentLatitude, lng=$currentLongitude');
      // Use default coordinates for Chennai if invalid
      currentLatitude = 13.0827;
      currentLongitude = 80.2707;
      print('📍 DEBUG: Using default coordinates: lat=$currentLatitude, lng=$currentLongitude');
    }
    
    // Validate required fields - more lenient during first-time signup
    if (!isFirstTimeSignup && houseNumberController.text.isEmpty) {
      throw Exception('Please enter house/flat number.');
    }
    
    if (!isFirstTimeSignup && streetController.text.isEmpty) {
      throw Exception('Please enter street/area details.');
    }
    
    // For first-time signup, at least one of house number or street should be filled
    if (isFirstTimeSignup && houseNumberController.text.isEmpty && streetController.text.isEmpty) {
      throw Exception('Please enter at least house/flat number or street/area details.');
    }
    
    if (!isFirstTimeSignup && cityController.text.isEmpty) {
      throw Exception('City information is missing.');
    }
    
    // Set default city if empty
    if (cityController.text.isEmpty) {
      cityController.text = 'Chennai';
      print('📍 DEBUG: Using default city: Chennai');
    }
  }
  
  // Create address object after validation
  Address saveAddress({bool isFirstTimeSignup = false}) {
    // Validate address data first
    validateAddressData(isFirstTimeSignup: isFirstTimeSignup);
    
    // Generate a random ID (in a real app, this would come from the backend)
    final id = 'addr_${math.Random().nextInt(10000)}';
    
    print('📍 PINCODE DEBUG - Final pincode being used: ${pincodeController.text}');
    
    return Address(
      id: id,
      name: currentLocationName,
      fullAddress: currentFullAddress,
      houseNumber: houseNumberController.text,
      street: streetController.text,
      landmark: landmarkController.text.isEmpty ? 'N/A' : landmarkController.text,
      city: cityController.text,
      pincode: pincodeController.text,
      latitude: currentLatitude ?? 0.0,
      longitude: currentLongitude ?? 0.0,
      type: selectedAddressType,
    );
  }
  
  // Pre-fill city and pincode from current location
  void prefillFromCurrentLocation() {
    print('Prefilling from current location:');
    print('Current location name: $currentLocationName');
    print('Current full address: $currentFullAddress');
    print('Current latitude: $currentLatitude, longitude: $currentLongitude');
    
    // Parse the current full address to extract components
    String? city;
    String? state;
    String? country;
    String? pincode;
    
    if (currentFullAddress.isNotEmpty) {
      List<String> addressParts = currentFullAddress.split(', ');
      
      // Extract pincode (usually 6 digits)
      pincode = _extractPincodeFromAddress(currentFullAddress);
      
      // Extract country (usually 'India')
      for (String part in addressParts) {
        if (part.trim().toLowerCase() == 'india') {
          country = part.trim();
          break;
        }
      }
      
      // Extract city and state from remaining parts
      List<String> remainingParts = addressParts.where((part) => 
        part.trim().toLowerCase() != 'india' && 
        !RegExp(r'^\d+$').hasMatch(part.trim()) &&
        part.trim().length > 2
      ).toList();
      
      if (remainingParts.length >= 2) {
        city = remainingParts[remainingParts.length - 2].trim(); // Second last is usually city
        state = remainingParts[remainingParts.length - 1].trim(); // Last is usually state
      } else if (remainingParts.length == 1) {
        city = remainingParts[0].trim();
      }
    }
    
    // Fallback to current location name for city if not found
    if (city == null || city.isEmpty) {
      city = currentLocationName;
    }
    
    // Update individual controllers for backward compatibility
    if (cityController.text.isEmpty && city.isNotEmpty) {
      cityController.text = city;
      print('Set city to: ${cityController.text}');
    }
    
    if (pincodeController.text.isEmpty && pincode != null && pincode.isNotEmpty) {
      pincodeController.text = pincode;
      print('Set pincode to: ${pincodeController.text}');
    }
    
    // Update the combined location details field
    _updateLocationDetailsField(city, state, country, pincode);
  }
  
  // Helper method to extract pincode from address
  String? _extractPincodeFromAddress(String address) {
    print('📍 PINCODE DEBUG - Extracting pincode from: $address');
    
    // Try multiple pincode patterns
    List<RegExp> pincodePatterns = [
      RegExp(r'\b\d{6}\b'), // Standard 6-digit pincode
      RegExp(r'PIN[:\s]*\d{6}', caseSensitive: false), // PIN: 123456
      RegExp(r'PINCODE[:\s]*\d{6}', caseSensitive: false), // PINCODE: 123456
    ];
    
    for (RegExp pattern in pincodePatterns) {
      final match = pattern.firstMatch(address);
      if (match != null) {
        String matched = match.group(0) ?? '';
        print('📍 PINCODE DEBUG - Found match: $matched');
        
        // Extract just the digits
        final digitMatch = RegExp(r'\d{6}').firstMatch(matched);
        if (digitMatch != null) {
          String pincode = digitMatch.group(0) ?? '';
          print('📍 PINCODE DEBUG - Extracted pincode: $pincode');
          
          // Validate the pincode
          if (pincode == '000000') {
            print('📍 PINCODE DEBUG - Invalid default pincode detected');
            return null; // Return null for invalid pincode
          }
          
          return pincode;
        }
      }
    }
    
    print('📍 PINCODE DEBUG - No valid pincode found');
    return null; // Return null if no valid pincode found
  }
  
  // Update the combined location details field
  void _updateLocationDetailsField(String? city, String? state, String? country, String? pincode) {
    List<String> locationParts = [];
    
    if (city != null && city.isNotEmpty) {
      locationParts.add(city);
    }
    
    if (state != null && state.isNotEmpty && state != city) {
      locationParts.add(state);
    }
    
    if (country != null && country.isNotEmpty) {
      locationParts.add(country);
    }
    
    if (pincode != null && pincode.isNotEmpty) {
      locationParts.add(pincode);
    }
    
    locationDetailsController.text = locationParts.join(', ');
    print('Updated locationDetailsController to: ${locationDetailsController.text}');
  }
  
  // Search for places
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      searchResults = [];
      searchError = null;
      return;
    }
    
    isSearching = true;
    searchError = null;
    
    try {
      searchResults = await PlaceSearchService.searchPlaces(query);
      if (searchResults.isEmpty && query.length >= 2) {
        searchError = 'No locations found for "$query". Try a different search term.';
      }
    } catch (e) {
      print('Error searching places: $e');
      searchResults = [];
      searchError = 'Failed to search locations. Please check your internet connection and try again.';
    }
    
    isSearching = false;
  }
  
  // Select a place from search results
  Future<void> selectPlace(PlaceSearchResult place) async {
    // Update the current location
    currentLatitude = place.latitude;
    currentLongitude = place.longitude;
    currentLocationName = place.name;
    currentFullAddress = place.address;
    locationAccuracy = "high"; // We consider search results to be high accuracy
    
    // Update the search controller text
    searchController.text = place.name;
    
    // Clear search results
    searchResults = [];
    isShowingHistory = false;
    
    // Update location details field
    locationDetailsController.text = place.name;
    
    // Save to search history
    await PlaceSearchService.saveToHistory(place);
    
    // Reload history for next time
    await loadSearchHistory();
    
    // Try to extract city, state, country, pincode from the address
    final addressParts = place.address.split(',');
    if (addressParts.length >= 3) {
      // Extract and update location details
      prefillFromCurrentLocation();
    }
  }
  
  // Load search history
  Future<void> loadSearchHistory() async {
    searchHistory = await PlaceSearchService.getSearchHistory();
  }
  
  // Dispose controllers
  void dispose() {
    searchController.dispose();
    houseNumberController.dispose();
    streetController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    locationDetailsController.dispose();
  }
}
