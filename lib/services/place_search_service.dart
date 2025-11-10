import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlaceSearchService {
  // API key should be stored securely in a real app
  // For demo purposes, we'll use a placeholder
  static String _apiKey = 'AIzaSyDlbTVZ3jALbPOwSK3wGgYWSGzZZvYeLt8';
  static const String _cachePrefix = 'place_search_';
  static const String _historyKey = 'place_search_history';
  static const int _cacheDurationMinutes = 30;
  static const int _maxHistoryItems = 5;
  
  // Set API key
  static void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }
  
  // Test API key validity
  static Future<bool> testApiKey() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'places.displayName',
      };
      
      final body = json.encode({
        'textQuery': 'Mumbai',
        'regionCode': 'IN',
        'maxResultCount': 1,
      });
      
      final testUrl = Uri.parse('https://places.googleapis.com/v1/places:searchText');
      
      final response = await http.post(
        testUrl,
        headers: headers,
        body: body,
      );
      
      print('API Test Response: ${response.statusCode}');
      print('API Test Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['places'] != null && (data['places'] as List).isNotEmpty;
      }
      return false;
    } catch (e) {
      print('API Test Error: $e');
      return false;
    }
  }
  
  // Search for places based on query
  static Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    try {
      // Try to get from cache first for performance
      final cachedResults = await _getFromCache(query);
      if (cachedResults.isNotEmpty) {
        return cachedResults;
      }
      
      // If API key is not set or is the placeholder, use mock data
      if (_apiKey == 'YOUR_API_KEY_HERE') {
        final results = _getMockResults(query);
        // Cache the results
        await _saveToCache(query, results);
        return results;
      }
      
      // Make actual API call
      final results = await _searchPlacesApi(query);
      
      // If API returns empty results, try mock data as fallback
      if (results.isEmpty) {
        print('API returned no results, falling back to mock data');
        final mockResults = _getMockResults(query);
        if (mockResults.isNotEmpty) {
          return mockResults;
        }
      }
      
      // Cache the results
      await _saveToCache(query, results);
      return results;
    } catch (e) {
      print('Error searching places: $e');
      // Fallback to mock data on error
      final mockResults = _getMockResults(query);
      print('Returning ${mockResults.length} mock results as fallback');
      return mockResults;
    }
  }
  
  // Get results from cache
  static Future<List<PlaceSearchResult>> _getFromCache(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cachePrefix + query.toLowerCase();
      final cachedData = prefs.getString(key);
      
      if (cachedData != null) {
        final cacheMap = json.decode(cachedData) as Map<String, dynamic>;
        final timestamp = cacheMap['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Check if cache is still valid (not expired)
        if (now - timestamp < _cacheDurationMinutes * 60 * 1000) {
          final resultsJson = cacheMap['results'] as List<dynamic>;
          return resultsJson.map((json) => PlaceSearchResult.fromJson(json)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting from cache: $e');
      return [];
    }
  }
  
  // Save results to cache
  static Future<void> _saveToCache(String query, List<PlaceSearchResult> results) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cachePrefix + query.toLowerCase();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final cacheMap = {
        'timestamp': now,
        'results': results.map((result) => result.toJson()).toList(),
      };
      
      await prefs.setString(key, json.encode(cacheMap));
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }
  
  // Save a place to search history
  static Future<void> saveToHistory(PlaceSearchResult place) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<PlaceSearchResult> history = await getSearchHistory();
      
      // Check if this place is already in history
      final existingIndex = history.indexWhere(
        (item) => item.name == place.name && item.address == place.address
      );
      
      // If exists, remove it (to add it back at the top)
      if (existingIndex != -1) {
        history.removeAt(existingIndex);
      }
      
      // Add to the beginning of the list
      history.insert(0, place);
      
      // Limit history size
      if (history.length > _maxHistoryItems) {
        history = history.sublist(0, _maxHistoryItems);
      }
      
      // Save updated history
      final historyJson = history.map((item) => item.toJson()).toList();
      await prefs.setString(_historyKey, json.encode(historyJson));
    } catch (e) {
      print('Error saving to history: $e');
    }
  }
  
  // Get search history
  static Future<List<PlaceSearchResult>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson != null) {
        final historyList = json.decode(historyJson) as List<dynamic>;
        return historyList.map((item) => PlaceSearchResult.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error getting search history: $e');
    }
    
    return [];
  }
  
  // Real API implementation
  static Future<List<PlaceSearchResult>> _searchPlacesApi(String query) async {
    try {
      print('Searching for: $query with API key: ${_apiKey.substring(0, 10)}...');
      
      // Use the new Places API (New) - Text Search endpoint
      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.location',
      };
      
      final body = json.encode({
        'textQuery': query,
        'regionCode': 'IN', // Bias to India
        'maxResultCount': 5,
      });
      
      final newApiUrl = Uri.parse('https://places.googleapis.com/v1/places:searchText');
      
      print('Making request to new API: $newApiUrl');
      final response = await http.post(
        newApiUrl,
        headers: headers,
        body: body,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['places'] != null) {
          final places = data['places'] as List;
          
          return places.map((place) => PlaceSearchResult(
            name: place['displayName']?['text'] ?? 'Unnamed Place',
            address: place['formattedAddress'] ?? 'Address not available',
            latitude: place['location']?['latitude'] ?? 0.0,
            longitude: place['location']?['longitude'] ?? 0.0,
          )).toList();
        }
      }
      
      // If new API fails, return empty (will trigger fallback to mock data)
      return [];
      
    } catch (e) {
      print('Error in _searchPlacesApi: $e');
      return []; // Return empty list on error
    }
  }
  
  // Get place details from place ID
  static Future<PlaceSearchResult?> _getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=name,formatted_address,geometry'
      '&key=$_apiKey'
    );
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          
          return PlaceSearchResult(
            name: result['name'],
            address: result['formatted_address'],
            latitude: location['lat'],
            longitude: location['lng'],
          );
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }
  
  // Mock implementation for demo purposes
  static List<PlaceSearchResult> _getMockResults(String query) {
    query = query.toLowerCase();
    
    // Common Indian cities and locations
    final List<Map<String, dynamic>> allPlaces = [
      {
        'name': 'Mumbai',
        'address': 'Mumbai, Maharashtra, India, 400008',
        'lat': 18.9691,
        'lng': 72.8193,
      },
      {
        'name': 'Delhi',
        'address': 'New Delhi, Delhi, India, 110001',
        'lat': 28.6139,
        'lng': 77.2090,
      },
      {
        'name': 'Bangalore',
        'address': 'Bengaluru, Karnataka, India, 560001',
        'lat': 12.9716,
        'lng': 77.5946,
      },
      {
        'name': 'Chennai',
        'address': 'Chennai, Tamil Nadu, India, 600001',
        'lat': 13.0827,
        'lng': 80.2707,
      },
      {
        'name': 'Kolkata',
        'address': 'Kolkata, West Bengal, India, 700001',
        'lat': 22.5726,
        'lng': 88.3639,
      },
      {
        'name': 'Hyderabad',
        'address': 'Hyderabad, Telangana, India, 500001',
        'lat': 17.3850,
        'lng': 78.4867,
      },
      {
        'name': 'Pune',
        'address': 'Pune, Maharashtra, India, 411001',
        'lat': 18.5204,
        'lng': 73.8567,
      },
      {
        'name': 'Ahmedabad',
        'address': 'Ahmedabad, Gujarat, India, 380001',
        'lat': 23.0225,
        'lng': 72.5714,
      },
      {
        'name': 'Jaipur',
        'address': 'Jaipur, Rajasthan, India, 302001',
        'lat': 26.9124,
        'lng': 75.7873,
      },
      {
        'name': 'Surat',
        'address': 'Surat, Gujarat, India, 395001',
        'lat': 21.1702,
        'lng': 72.8311,
      },
      {
        'name': 'Lucknow',
        'address': 'Lucknow, Uttar Pradesh, India, 226001',
        'lat': 26.8467,
        'lng': 80.9462,
      },
      {
        'name': 'Kanpur',
        'address': 'Kanpur, Uttar Pradesh, India, 208001',
        'lat': 26.4499,
        'lng': 80.3319,
      },
      {
        'name': 'Nagpur',
        'address': 'Nagpur, Maharashtra, India, 440001',
        'lat': 21.1458,
        'lng': 79.0882,
      },
      {
        'name': 'Indore',
        'address': 'Indore, Madhya Pradesh, India, 452001',
        'lat': 22.7196,
        'lng': 75.8577,
      },
      {
        'name': 'Thane',
        'address': 'Thane, Maharashtra, India, 400601',
        'lat': 19.2183,
        'lng': 72.9781,
      },
      {
        'name': 'Bhopal',
        'address': 'Bhopal, Madhya Pradesh, India, 462001',
        'lat': 23.2599,
        'lng': 77.4126,
      },
      {
        'name': 'Visakhapatnam',
        'address': 'Visakhapatnam, Andhra Pradesh, India, 530001',
        'lat': 17.6868,
        'lng': 83.2185,
      },
      {
        'name': 'Patna',
        'address': 'Patna, Bihar, India, 800001',
        'lat': 25.5941,
        'lng': 85.1376,
      },
      {
        'name': 'Vadodara',
        'address': 'Vadodara, Gujarat, India, 390001',
        'lat': 22.3072,
        'lng': 73.1812,
      },
      {
        'name': 'Ghaziabad',
        'address': 'Ghaziabad, Uttar Pradesh, India, 201001',
        'lat': 28.6692,
        'lng': 77.4538,
      },
    ];

    final filteredPlaces = allPlaces.where((place) {
      return place['name'].toString().toLowerCase().contains(query) ||
          place['address'].toString().toLowerCase().contains(query);
    }).toList();

    return filteredPlaces.map((place) => PlaceSearchResult(
      name: place['name'],
      address: place['address'],
      latitude: place['lat'],
      longitude: place['lng'],
    )).toList();
  }
}

class PlaceSearchResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  
  PlaceSearchResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
  
  // Create from JSON
  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) {
    return PlaceSearchResult(
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
