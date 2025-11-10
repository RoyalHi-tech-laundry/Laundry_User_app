import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocationService {
  // Cache keys
  static const String _cachedLatitudeKey = 'cached_latitude';
  static const String _cachedLongitudeKey = 'cached_longitude';
  static const String _cachedAddressKey = 'cached_address';
  static const String _cachedTimestampKey = 'cached_timestamp';
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Request permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Save location to cache
  static Future<void> saveLocationToCache(double latitude, double longitude, Map<String, dynamic> addressData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_cachedLatitudeKey, latitude);
    await prefs.setDouble(_cachedLongitudeKey, longitude);
    await prefs.setString(_cachedAddressKey, json.encode(addressData));
    await prefs.setInt(_cachedTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get cached location
  static Future<Map<String, dynamic>?> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we have cached data
    if (!prefs.containsKey(_cachedLatitudeKey) || 
        !prefs.containsKey(_cachedLongitudeKey) || 
        !prefs.containsKey(_cachedAddressKey)) {
      return null;
    }
    
    // Check if cache is not too old (30 minutes)
    final timestamp = prefs.getInt(_cachedTimestampKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - timestamp > 30 * 60 * 1000) { // 30 minutes in milliseconds
      return null;
    }
    
    // Return cached data
    return {
      'latitude': prefs.getDouble(_cachedLatitudeKey),
      'longitude': prefs.getDouble(_cachedLongitudeKey),
      'addressData': json.decode(prefs.getString(_cachedAddressKey) ?? '{}'),
    };
  }

  // Get the current position
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return Future.error('LOCATION_SERVICES_DISABLED');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can get the position
    return await Geolocator.getCurrentPosition();
  }

  // Get current position with high accuracy
  static Future<Position> getCurrentPositionWithAccuracy() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('LOCATION_SERVICES_DISABLED');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can get the position
    // Using best accuracy and longer timeout for precise location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 30),
      forceAndroidLocationManager: false,
    );
  }

  // Get address from latitude and longitude with caching
  static Future<Map<String, dynamic>> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      // Get multiple placemarks to increase chances of finding precise location
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, 
        longitude,
        localeIdentifier: 'en_US' // Use English locale for consistent results
      );
      
      if (placemarks.isNotEmpty) {
        // Try to find the most precise location name
        String locationName = '';
        String plusCode = _generatePlusCode(latitude, longitude);
        
        // Check for building name or point of interest in all placemarks
        for (var place in placemarks) {
          // Check for thoroughfare (usually contains building number + street)
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty && 
              place.thoroughfare != place.street) {
            locationName = place.thoroughfare!;
            break;
          }
          
          // Check for name (often contains building name)
          if (place.name != null && place.name!.isNotEmpty && 
              place.name != place.street && 
              !place.name!.contains(RegExp(r'^\d+$'))) { // Avoid just numbers
            locationName = place.name!;
            break;
          }
        }
        
        // If no specific building name found, use street address with number
        Placemark place = placemarks[0];
        if (locationName.isEmpty) {
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty && 
              place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
            locationName = '${place.subThoroughfare} ${place.thoroughfare}';
          } else {
            locationName = place.street ?? '';
          }
        }
        
        // If still empty, try to use subLocality or locality
        if (locationName.isEmpty) {
          locationName = place.subLocality ?? place.locality ?? 'Unknown Location';
        }
        
        // Add plus code to location name if we don't have a precise address
        if (!_isPreciseAddress(locationName)) {
          locationName = '$locationName ($plusCode)';
        }
        
        String fullAddress = [
          place.street ?? '',
          place.subLocality ?? '',
          place.locality ?? '',
          place.postalCode ?? '',
          place.country ?? ''
        ].where((element) => element.isNotEmpty).join(', ');
        
        // Create address data map
        final addressData = {
          'locationName': locationName,
          'fullAddress': fullAddress,
          'plusCode': plusCode,
          'placemark': {
            'name': place.name,
            'street': place.street,
            'thoroughfare': place.thoroughfare,
            'subThoroughfare': place.subThoroughfare,
            'subLocality': place.subLocality,
            'locality': place.locality,
            'postalCode': place.postalCode,
            'country': place.country,
          },
        };
        
        // Save to cache
        await saveLocationToCache(latitude, longitude, addressData);
        
        return addressData;
      }
      
      final defaultData = {
        'locationName': 'Unknown Location',
        'fullAddress': 'Address not found',
        'plusCode': _generatePlusCode(latitude, longitude),
        'placemark': null,
      };
      
      return defaultData;
    } catch (e) {
      return {
        'locationName': 'Error',
        'fullAddress': 'Failed to get address: $e',
        'plusCode': _generatePlusCode(latitude, longitude),
        'placemark': null,
      };
    }
  }
  
  // Generate a simple plus code from coordinates
  static String _generatePlusCode(double latitude, double longitude) {
    // Format to 6 decimal places (about 10cm precision)
    String lat = latitude.toStringAsFixed(6);
    String lng = longitude.toStringAsFixed(6);
    
    // Take the last 4 digits of each for a shorter code
    String shortLat = lat.substring(lat.length - 4);
    String shortLng = lng.substring(lng.length - 4);
    
    // Combine them with a plus
    return '$shortLat+$shortLng';
  }
  
  // Check if an address is precise enough (has building number or specific name)
  static bool _isPreciseAddress(String address) {
    // Check if address contains building numbers
    bool hasNumber = RegExp(r'\b\d+\b').hasMatch(address);
    
    // Check if address is longer than just a street name (likely has specific details)
    bool isDetailed = address.split(' ').length > 2;
    
    // Check if address contains specific identifiers
    bool hasIdentifier = [
      'building', 'apartment', 'apt', 'suite', 'ste', 'floor', 'fl',
      'block', 'unit', 'tower', 'complex', 'plaza', 'mall', 'center',
      'centre', 'house', 'villa', 'mansion', 'residence'
    ].any((word) => address.toLowerCase().contains(word));
    
    return hasNumber || hasIdentifier || isDetailed;
  }
}
