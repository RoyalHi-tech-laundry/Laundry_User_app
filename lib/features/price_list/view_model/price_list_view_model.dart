import 'package:flutter/foundation.dart';
import '../model/price_list_item.dart';
import '../service/price_list_service.dart';

class PriceListViewModel extends ChangeNotifier {
  final PriceListService _priceListService = PriceListService();
  
  List<PriceListItem> _services = [];
  bool _isLoading = true;
  String? _error;

  List<PriceListItem> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _priceListService.getServices();
      if (response['success'] == true) {
        _services = (response['data'] as List)
            .map((item) => PriceListItem.fromJson(item))
            .toList()
          ..sort((a, b) {
            // Sort by hasPriceList (false first, then true) and then by name
            if (a.hasPriceList == b.hasPriceList) {
              return a.name.compareTo(b.name);
            }
            return a.hasPriceList ? 1 : -1;
          });
      } else {
        _error = 'Failed to load services';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter services by category if needed
  List<PriceListItem> getServicesByCategory(String category) {
    return _services.where((service) => service.category == category).toList();
  }
}
