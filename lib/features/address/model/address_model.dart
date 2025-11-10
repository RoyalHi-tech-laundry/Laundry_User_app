class Address {
  final String id;
  final String name;
  final String fullAddress;
  final String houseNumber;
  final String street;
  final String landmark;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;
  final AddressType type;

  Address({
    required this.id,
    required this.name,
    required this.fullAddress,
    required this.houseNumber,
    required this.street,
    required this.landmark,
    required this.city,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.type,
  });

  // Create a copy of the address with updated fields
  Address copyWith({
    String? id,
    String? name,
    String? fullAddress,
    String? houseNumber,
    String? street,
    String? landmark,
    String? city,
    String? pincode,
    double? latitude,
    double? longitude,
    AddressType? type,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      fullAddress: fullAddress ?? this.fullAddress,
      houseNumber: houseNumber ?? this.houseNumber,
      street: street ?? this.street,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
    );
  }

  // Convert address to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullAddress': fullAddress,
      'houseNumber': houseNumber,
      'street': street,
      'landmark': landmark,
      'city': city,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.toString().split('.').last,
    };
  }

  // Create address from JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name: json['name'],
      fullAddress: json['fullAddress'],
      houseNumber: json['houseNumber'],
      street: json['street'],
      landmark: json['landmark'],
      city: json['city'],
      pincode: json['pincode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      type: _getAddressTypeFromString(json['type']),
    );
  }

  // Helper method to convert string to AddressType enum
  static AddressType _getAddressTypeFromString(String type) {
    switch (type) {
      case 'home':
        return AddressType.home;
      case 'work':
        return AddressType.work;
      case 'family':
        return AddressType.family;
      case 'other':
        return AddressType.other;
      default:
        return AddressType.home;
    }
  }
}

enum AddressType {
  home,
  work,
  family,
  other,
}
