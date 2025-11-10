import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:laun_easy/features/auth/view/otp_verification_screen.dart';
import 'package:laun_easy/features/auth/view/signup_screen.dart';
import 'package:laun_easy/features/auth/services/phone_check_service.dart';
import 'package:laun_easy/features/auth/services/otp_request_service.dart';

class LoginViewModel with ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  final PhoneCheckService _phoneCheckService = PhoneCheckService();
  final OtpRequestService _otpRequestService = OtpRequestService();
  
  bool isPhoneValid = false;
  bool isLoading = false;
  String? errorMessage;
  String? testOtp; // For testing purposes only

  // Validate phone number
  void validatePhone() {
    final text = phoneController.text.trim();
    // Simple validation: must be 10 digits
    isPhoneValid = text.length == 10 && RegExp(r'^[0-9]+$').hasMatch(text);
    return;
  }

  // Check user existence and navigate accordingly
  Future<void> checkUserAndNavigate(BuildContext context) async {
    if (!isPhoneValid) return;
    
    final phoneNumber = phoneController.text.trim();
    
    // Show loading state
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      // Check if phone number exists
      final checkResponse = await _phoneCheckService.checkPhoneNumber(phoneNumber);
      
      if (checkResponse.exists) {
        // If user exists, request OTP and navigate to OTP verification
        final otpResponse = await _otpRequestService.requestOtp(phoneNumber);
        
        // Store OTP for testing purposes
        testOtp = otpResponse.otp;
        developer.log('Test OTP in view model: $testOtp', name: 'LoginViewModel');
        
        // Show OTP in a snackbar for testing purposes
        if (testOtp != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Testing OTP: $testOtp'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.green,
            )
          );
        }
        
        // Navigate to OTP verification screen
        navigateToOtpScreen(context, phoneNumber);
      } else {
        // If user doesn't exist, navigate to signup
        navigateToSignupScreen(context, phoneNumber);
      }
    } catch (e) {
      // Handle errors
      errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!))
      );
    } finally {
      // Reset loading state
      isLoading = false;
      notifyListeners();
    }
  }
  
  // Navigate to OTP verification screen
  void navigateToOtpScreen(BuildContext context, String phoneNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          phoneNumber: phoneNumber,
          isFromRegistration: false, // Coming from login
        ),
      ),
    );
  }
  
  // Navigate to signup screen
  void navigateToSignupScreen(BuildContext context, String phoneNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupScreen(phoneNumber: phoneNumber),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
