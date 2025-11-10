import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Select pick-up Date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 24),
              _buildDaySelector(cartViewModel),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Select Pick-Up Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              const SizedBox(height: 24),
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
      height: 90,
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
              width: 70,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
        final isSelected = timeSlot == selectedTimeSlot;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () => cartViewModel.setTimeSlot(timeSlot),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey[300]!,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Center(
                child: Text(
                  timeSlot,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ).animate(delay: (50 * index).ms).fadeIn(duration: 300.ms),
        );
      },
    );
  }
}
