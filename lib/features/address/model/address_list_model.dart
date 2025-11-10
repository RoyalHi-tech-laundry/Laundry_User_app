class AddressList {
  final bool success;
  final List<AddressItem> data;

  AddressList({
    required this.success,
    required this.data,
  });

  factory AddressList.fromJson(Map<String, dynamic> json) {
    return AddressList(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>)
          .map((item) => AddressItem.fromJson(item))
          .toList(),
    );
  }
}

class AddressItem {
  final int id;
  final String type;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String? landmark;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final bool isActive;

  AddressItem({
    required this.id,
    required this.type,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    this.landmark,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    required this.isActive,
  });

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    // Handle potential data format issues
    String pincode = '';
    String country = 'India'; // Default country
    
    // Fix pincode and country fields if they're swapped
    if (json['pincode'] != null) {
      final pincodeValue = json['pincode'].toString();
      // Check if pincode looks like a valid Indian pincode (6 digits)
      if (pincodeValue.length == 6 && int.tryParse(pincodeValue) != null) {
        pincode = pincodeValue;
      } else {
        // If not a valid pincode format, it might be something else
        pincode = '';
      }
    }
    
    if (json['country'] != null) {
      final countryValue = json['country'].toString();
      // If country field contains what looks like a pincode
      if (countryValue.length <= 6 && int.tryParse(countryValue) != null) {
        // It's likely a pincode in the country field
        pincode = countryValue;
      } else {
        // Otherwise use it as country
        country = countryValue;
      }
    }
    
    // Handle latitude and longitude
    double latitude = 0.0;
    double longitude = 0.0;
    
    try {
      if (json['latitude'] != null) {
        latitude = double.tryParse(json['latitude'].toString()) ?? 0.0;
      }
      
      if (json['longitude'] != null) {
        longitude = double.tryParse(json['longitude'].toString()) ?? 0.0;
      }
    } catch (e) {
      print('Error parsing lat/long: $e');
    }
    
    return AddressItem(
      id: json['id'],
      type: json['type'] ?? 'HOME',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: pincode,
      country: country,
      landmark: json['landmark'],
      latitude: latitude,
      longitude: longitude,
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  String get formattedAddress {
    List<String> parts = [];
    
    if (addressLine1.isNotEmpty) {
      parts.add(addressLine1);
    }
    
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      parts.add(addressLine2!);
    }
    
    if (landmark != null && landmark!.isNotEmpty) {
      parts.add('Near $landmark');
    }
    
    if (city.isNotEmpty) {
      parts.add(city);
    }
    
    if (state.isNotEmpty) {
      parts.add(state);
    }
    
    if (pincode.isNotEmpty) {
      parts.add(pincode);
    }
    
    if (country.isNotEmpty) {
      parts.add(country);
    }
    
    return parts.join(', ');
  }

  String get typeDisplay {
    return type.substring(0, 1).toUpperCase() + type.substring(1).toLowerCase();
  }

  String get distanceDisplay {
    // This would be calculated based on current location in a real app
    // For now, just return a mock value
    return '${(id * 100) % 1000} m';
  }
}
