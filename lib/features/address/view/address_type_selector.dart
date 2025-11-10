import 'package:flutter/material.dart';
import 'package:laun_easy/constants/colors/app_colors.dart';
import 'package:laun_easy/features/address/model/address_model.dart';

class AddressTypeSelector extends StatelessWidget {
  final AddressType selectedType;
  final Function(AddressType) onTypeSelected;

  const AddressTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
        _buildTypeButton(
          context,
          AddressType.home,
          'Home',
          Icons.home_outlined,
        ),
        const SizedBox(width: 10),
        _buildTypeButton(
          context,
          AddressType.work,
          'Work',
          Icons.work_outline,
        ),
        const SizedBox(width: 10),
        _buildTypeButton(
          context,
          AddressType.family,
          'Family',
          Icons.people_outline,
        ),
        const SizedBox(width: 10),
        _buildTypeButton(
          context,
          AddressType.other,
          'Others',
          Icons.location_on_outlined,
        ),
      ],
      ),
    );
  }

  Widget _buildTypeButton(
    BuildContext context,
    AddressType type,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedType == type;
    
    return InkWell(
      onTap: () => onTypeSelected(type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: isSelected ? AppColors.primaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
