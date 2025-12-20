class PriceListItem {
  final int id;
  final String serviceCode;
  final String name;
  final String description;
  final double price;
  final String unit;
  final bool hasPriceList;
  final String category;
  final List<dynamic> items;

  PriceListItem({
    required this.id,
    required this.serviceCode,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.hasPriceList,
    required this.category,
    required this.items,
  });

  factory PriceListItem.fromJson(Map<String, dynamic> json) {
    return PriceListItem(
      id: json['id'] ?? 0,
      serviceCode: json['serviceCode'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      hasPriceList: json['hasPriceList'] ?? false,
      category: json['category'] ?? '',
      items: json['items'] ?? [],
    );
  }
}
