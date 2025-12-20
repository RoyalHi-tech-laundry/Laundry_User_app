import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/price_list_item.dart';

class PriceListDetailsScreen extends StatelessWidget {
  final PriceListItem service;

  const PriceListDetailsScreen({
    super.key,
    required this.service,
  });

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
                    service.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202124),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (service.description.isNotEmpty)
                    Text(
                      service.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF5F6368),
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            
            // Price List Items
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: service.items.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final item = service.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['name'] ?? 'Item',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF202124),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '₹${(item['price'] ?? 0).toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF202124),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
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
