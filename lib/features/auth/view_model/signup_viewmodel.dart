import 'package:flutter/material.dart';
import 'package:laun_easy/features/auth/view/otp_verification_screen.dart';
import 'package:laun_easy/features/auth/services/register_service.dart';

class SignupViewModel with ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  
  bool isPhoneValid = false;
  bool isNameValid = false;
  bool isEmailValid = false;
  bool isLoading = false;
  String? errorMessage;
  final RegisterService _registerService = RegisterService();
  
  bool get isFormValid => isPhoneValid && isNameValid;

  // Validate phone number
  void validatePhone() {
    final text = phoneController.text.trim();
    // Simple validation: must be 10 digits
    isPhoneValid = text.length == 10 && RegExp(r'^[0-9]+$').hasMatch(text);
    return;
  }

  // Validate name
  void validateName() {
    final text = nameController.text.trim();
    // Simple validation: must not be empty
    isNameValid = text.isNotEmpty;
    notifyListeners();
    return;
  }
  
  // Validate email
  void validateEmail() {
    final text = emailController.text.trim();
    // Simple validation: must contain @ and .
    isEmailValid = text.contains('@') && text.contains('.');
    notifyListeners();
    return;
  }

  // Register user and navigate to OTP verification screen
  Future<void> registerAndNavigate(BuildContext context) async {
    if (!isFormValid) return;
    
    final phoneNumber = phoneController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    
    // Show loading state
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      // Register user
      final response = await _registerService.registerUser(
        name: name,
        phone: phoneNumber,
        email: email,
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to OTP verification screen with isFromRegistration set to true
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            phoneNumber: phoneNumber,
            isFromRegistration: true,
          ),
        ),
      );
    } catch (e) {
      // Handle errors
      errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset loading state
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
