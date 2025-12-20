import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/price_list_item.dart';

class PriceListDetailsScreen extends StatefulWidget {
  final PriceListItem service;

  const PriceListDetailsScreen({
    super.key,
    required this.service,
  });

  @override
  State<PriceListDetailsScreen> createState() => _PriceListDetailsScreenState();
}

class _PriceListDetailsScreenState extends State<PriceListDetailsScreen> {
  // Track expanded state for each category
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    // Group items by type
    _groupItemsByType();
  }

  final Map<String, List<Map<String, dynamic>>> _groupedItems = {};
  final List<String> _categoryOrder = [];

  void _groupItemsByType() {
    // Clear previous data
    _groupedItems.clear();
    _categoryOrder.clear();

    // Map to store display names for each type
    final typeDisplayNames = {
      'MEN': 'Men',
      'WOMEN': 'Women',
      'KIDS': 'Kids',
      'MEN_LUXURY': 'Men (Luxury)',
      'WOMEN_LUXURY': 'Women (Luxury)',
      'HOUSEHOLD': 'Household',
      'HOUSEHOLD_LUXURY': 'Household (Luxury)',
    };

    // Group items by type
    for (var item in widget.service.items) {
      final type = item['type'] ?? 'OTHER';
      final displayName = typeDisplayNames[type] ?? type.replaceAll('_', ' ');
      
      if (!_groupedItems.containsKey(displayName)) {
        _groupedItems[displayName] = [];
        _categoryOrder.add(displayName);
        _expandedCategories[displayName] = false; // Collapsed by default
      }
      _groupedItems[displayName]!.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5F6368)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Price List',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF202124),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Header
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.service.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202124),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.service.description.isNotEmpty)
                    Text(
                      widget.service.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF5F6368),
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            
            // Grouped Price List Items
            ..._categoryOrder.map((category) {
              final items = _groupedItems[category] ?? [];
              final isExpanded = _expandedCategories[category] ?? false;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Category Header
                    InkWell(
                      onTap: () {
                        setState(() {
                          _expandedCategories[category] = !isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF202124),
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.remove : Icons.add,
                              color: const Color(0xFF1A73E8),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Items List (conditionally shown)
                    if (isExpanded) ...[
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['name']?.toString() ?? 'Item',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFF5F6368),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '₹${(item['price'] ?? 0).toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF5F6368),
                              ),
                            ),
                            ],
                          ),
                        )).toList(),
                    ],
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 24),
            
            // Note Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 5% GST will be applicable on the total bill amount',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF5F6368),
                      height: 1.5,
                    ),
                  ),
                  Text(
                    '• Minimum order value is ₹250',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF5F6368),
                      height: 1.5,
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
}
