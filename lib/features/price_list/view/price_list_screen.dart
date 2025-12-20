import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../view_model/price_list_view_model.dart';
import '../model/price_list_item.dart';
import 'price_list_details_screen.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  late final PriceListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PriceListViewModel();
    _viewModel.loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<PriceListViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFFFFF),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              centerTitle: true,
              title: Text(
                'Price List',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202124),
                ),
              ),
              iconTheme: const IconThemeData(color: Color(0xFF5F6368)),
            ),
            body: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(PriceListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
        ),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.error!,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD93025),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.loadServices(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.price_check_outlined, size: 48, color: Color(0xFF9AA0A6)),
            const SizedBox(height: 16),
            Text(
              'No services available',
              style: GoogleFonts.poppins(
                color: const Color(0xFF5F6368),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: viewModel.services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(viewModel.services[index]);
      },
    );
  }



  Widget _buildServiceCard(PriceListItem service) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Service icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_laundry_service, color: Color(0xFF1A73E8)),
            ),
            const SizedBox(width: 16),
            // Service name and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF202124),
                      height: 1.3,
                    ),
                  ),
                  if (service.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF5F6368),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Price or See Price List
            service.hasPriceList
                ? GestureDetector(
                    onTap: () => _showPriceListDialog(service),
                    child: Text(
                      'See Price List',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A73E8),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF1A73E8),
                        height: 1.3,
                      ),
                    ),
                  )
                : Text(
                    '₹${service.price.toStringAsFixed(0)}/${service.unit.toLowerCase()}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202124),
                      height: 1.3,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showPriceListDialog(PriceListItem service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PriceListDetailsScreen(service: service),
      ),
    );
  }
}
