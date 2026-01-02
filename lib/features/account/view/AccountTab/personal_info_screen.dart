import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants/colors/app_colors.dart';
import '../../../../services/auth_storage_service.dart';
import '../../../../services/auth_storage_service.dart';
import '../../services/account_service.dart';
import 'package:intl/intl.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dateOfBirthController = TextEditingController();
  
  // State variables
  bool _isEditMode = false;
  bool _isLoading = false;
  String _selectedGender = "Female";
  final bool isPhoneVerified = true;
  final AccountService _accountService = AccountService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await AuthStorageService.getUserDetails();
      if (mounted) {
        setState(() {
          _userNameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _dateOfBirthController.text = userData['dateOfBirth'] ?? '';
          
          if (userData['gender'] != null && userData['gender'].isNotEmpty) {
            String loadedGender = userData['gender'];
            // Normalize gender string (e.g. "MALE" -> "Male")
            if (loadedGender.toUpperCase() == 'MALE') _selectedGender = 'Male';
            else if (loadedGender.toUpperCase() == 'FEMALE') _selectedGender = 'Female';
            else if (loadedGender.toUpperCase() == 'OTHER') _selectedGender = 'Other';
            else _selectedGender = loadedGender; 
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Personal Info',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDarkColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEditableField(
                        label: 'User Name *',
                        controller: _userNameController,
                        icon: Icons.person_outline,
                        enabled: _isEditMode,
                      ),
                      const SizedBox(height: 20),
                      _buildEditablePhoneField(
                        label: 'Phone Number *',
                        controller: _phoneController,
                        enabled: _isEditMode,
                        isVerified: isPhoneVerified,
                      ),
                      const SizedBox(height: 20),
                      _buildEditableField(
                        label: 'Email Id',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        enabled: _isEditMode,
                        placeholder: 'Email Id',
                      ),
                      const SizedBox(height: 20),
                      _buildDateField(
                        label: 'Date of Birth',
                        controller: _dateOfBirthController,
                        enabled: _isEditMode,
                      ),
                      const SizedBox(height: 20),
                      _buildGenderField(
                        label: 'Gender',
                        selectedGender: _selectedGender,
                        enabled: _isEditMode,
                      ),
                      const SizedBox(height: 48),
                      if (!_isEditMode) _buildDeleteAccountButton(),
                      const SizedBox(height: 32),
                      _buildActionButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryLightColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryLightColor, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    String? placeholder,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: enabled ? Colors.grey[300]! : Colors.transparent),
            boxShadow: enabled ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
              ),
              prefixIcon: icon != null ? Icon(
                icon,
                color: enabled ? AppColors.primaryLightColor.withOpacity(0.7) : Colors.grey[400],
                size: 20,
              ) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (label.contains('*') && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              if (label.contains('Email') && value != null && value.isNotEmpty) {
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditablePhoneField({
    required String label,
    required TextEditingController controller,
    required bool isVerified,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: enabled ? Colors.grey[300]! : Colors.transparent),
            boxShadow: enabled ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: enabled ? AppColors.primaryLightColor.withOpacity(0.7) : Colors.grey[400],
                size: 20,
              ),
              suffixIcon: isVerified ? Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Verified',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.successColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.successColor,
                      size: 16,
                    ),
                  ],
                ),
              ) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteAccountButton() {
    return GestureDetector(
      onTap: () {
        _showDeleteAccountDialog();
      },
      child: Row(
        children: [
          Icon(
            Icons.delete_outline,
            color: AppColors.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Delete Account',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? () => _selectDate(context) : null,
          child: Container(
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: enabled ? Colors.grey[300]! : Colors.transparent),
              boxShadow: enabled ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: AbsorbPointer(
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: enabled ? AppColors.primaryLightColor.withOpacity(0.7) : Colors.grey[400],
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField({
    required String label,
    required String selectedGender,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 56, // Fixed height to match other fields
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: enabled ? Colors.grey[300]! : Colors.transparent),
            boxShadow: enabled ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline, // Added icon for consistency
                color: enabled ? AppColors.primaryLightColor.withOpacity(0.7) : Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: enabled ? DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedGender,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      }
                    },
                  ),
                ) : Text(
                  selectedGender,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: _isEditMode ? AppColors.primaryLightColor : Colors.white,
        border: Border.all(color: AppColors.primaryLightColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: _isLoading ? null : () {
          if (_isEditMode) {
            _savePersonalInfo();
          } else {
            setState(() {
              _isEditMode = true;
            });
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading 
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isEditMode ? Colors.white : AppColors.primaryLightColor,
                ),
              ),
            )
          : Text(
              _isEditMode ? 'Save Personal Info' : 'Edit Personal Info',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _isEditMode ? Colors.white : AppColors.primaryLightColor,
              ),
            ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Account',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.errorColor,
            ),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle delete account logic here
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.errorColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> _savePersonalInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call API to update profile
        await _accountService.updateProfile(
          name: _userNameController.text.trim(),
          email: _emailController.text.trim(),
          dateOfBirth: _dateOfBirthController.text.trim(),
          gender: _selectedGender.toUpperCase(),
        );

        // Get the current user data
        final userData = await AuthStorageService.getUserDetails();
        
        // Update user data in SharedPreferences
        await AuthStorageService.saveUserDetails(
          id: userData['id'] ?? 0,
          name: _userNameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          role: userData['role'] ?? 'user',
          dateOfBirth: _dateOfBirthController.text.trim(),
          gender: _selectedGender,
        );
        
        // Update UI state
        setState(() {
          _isEditMode = false;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update personal information: ${e.toString().replaceAll("Exception: ", "")}',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: AppColors.errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}
