import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../constants/colors/app_colors.dart';
import '../view_model/cart_viewmodel.dart';

class DateTimeTab extends StatefulWidget {
  const DateTimeTab({Key? key}) : super(key: key);

  @override
  State<DateTimeTab> createState() => _DateTimeTabState();
}

class _DateTimeTabState extends State<DateTimeTab> {
  DateTime? _selectedDay;
  List<DateTime> _availableDays = [];

  @override
  void initState() {
    super.initState();
    final cartViewModel = context.read<CartViewModel>();
    _selectedDay = cartViewModel.cart.pickupDate ?? DateTime.now();
    
    // Generate available days (next 7 days)
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      _availableDays.add(now.add(Duration(days: i)));
    }
    
    // Load time slots for the selected date
    if (_selectedDay != null) {
      cartViewModel.setPickupDate(_selectedDay!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Select pick-up Date',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkColor,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 12),
              _buildDaySelector(cartViewModel),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Select Pick-Up Time',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkColor,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              const SizedBox(height: 8),
              if (cartViewModel.isLoading)
                const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ))
              else
                Expanded(
                  child: _buildTimeSlots(cartViewModel),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDaySelector(CartViewModel cartViewModel) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableDays.length,
        itemBuilder: (context, index) {
          final day = _availableDays[index];
          final isSelected = _selectedDay != null && 
          isSameDay(_selectedDay!, day);
          final dayName = DateFormat('EEE').format(day);
          final dayNumber = DateFormat('dd').format(day);
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
              });
              cartViewModel.setPickupDate(day);
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? AppColors.primaryColor.withOpacity(0.08) : Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primaryColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: (50 * index).ms).fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
  
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildTimeSlots(CartViewModel cartViewModel) {
    final timeSlots = cartViewModel.timeSlots;
    final selectedTimeSlot = cartViewModel.cart.timeSlot;
    
    if (timeSlots.isEmpty) {
      return Center(
        child: Text(
          'No time slots available for the selected date',
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20, top: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3.2,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
        final isSelected = timeSlot == selectedTimeSlot;
        
        return GestureDetector(
          onTap: () => cartViewModel.setTimeSlot(timeSlot),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.grey.shade200,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? AppColors.primaryColor.withOpacity(0.05)
                  : Colors.white,
            ),
            child: Center(
              child: Text(
                timeSlot,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isSelected
                      ? AppColors.primaryDarkColor
                      : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ).animate(delay: (50 * index).ms).fadeIn(duration: 300.ms);
      },
    );
  }
}
