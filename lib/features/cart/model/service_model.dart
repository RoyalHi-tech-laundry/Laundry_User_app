class ServiceModel {
  final int id;
  final String serviceCode;
  final String name;
  final String description;
  final double price;
  final String unit;
  final String icon;
  final String turnaroundTime;
  final bool isActive;
  final bool hasPriceList;
  final String category;
  final int sortOrder;

  ServiceModel({
    required this.id,
    required this.serviceCode,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.icon,
    required this.turnaroundTime,
    required this.isActive,
    required this.hasPriceList,
    required this.category,
    required this.sortOrder,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      serviceCode: json['serviceCode'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] != null) ? (json['price'] is int ? (json['price'] as int).toDouble() : json['price'].toDouble()) : 0.0,
      unit: json['unit'] ?? 'Unit',
      icon: json['icon'] ?? '',
      turnaroundTime: json['turnaroundTime'] ?? '',
      isActive: json['isActive'] ?? true,
      hasPriceList: json['hasPriceList'] ?? false,
      category: json['category'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceCode': serviceCode,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'icon': icon,
      'turnaroundTime': turnaroundTime,
      'isActive': isActive,
      'hasPriceList': hasPriceList,
      'category': category,
      'sortOrder': sortOrder,
    };
  }
}

class ServiceResponse {
  final bool success;
  final List<ServiceModel> data;

  ServiceResponse({
    required this.success,
    required this.data,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((item) => ServiceModel.fromJson(item))
          .toList(),
    );
  }
}
