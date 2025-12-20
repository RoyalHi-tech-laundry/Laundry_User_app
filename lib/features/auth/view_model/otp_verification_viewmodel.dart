import 'package:flutter/material.dart';
import 'package:laun_easy/features/address/view/address_selection_screen.dart';
import 'package:laun_easy/features/auth/services/otp_verification_service.dart';
import 'package:laun_easy/features/auth/services/otp_request_service.dart';
import 'package:laun_easy/core/navigation/main_navigation.dart';
import 'package:laun_easy/services/auth_storage_service.dart';

class OtpVerificationViewModel with ChangeNotifier {
  final String phoneNumber;
  final bool isFromRegistration;
  
  // Controllers for each OTP digit
  final List<TextEditingController> otpControllers = List.generate(
    4, 
    (_) => TextEditingController()
  );
  
  // Focus nodes for each OTP field
  final List<FocusNode> focusNodes = List.generate(
    4, 
    (_) => FocusNode()
  );
  
  bool isOtpComplete = false;
  int resendSeconds = 21; // Starting with 21 seconds for countdown
  bool canResend = false;
  bool isLoading = false;
  String? successMessage;
  
  final OtpVerificationService _otpVerificationService = OtpVerificationService();
  final OtpRequestService _otpRequestService = OtpRequestService();
  String? testOtp;
  
  OtpVerificationViewModel({
    required this.phoneNumber,
    this.isFromRegistration = false,
  });
  
  // Format phone number to show last 4 digits
  String getMaskedPhoneNumber() {
    return '+91 ' + phoneNumber.replaceRange(
      0, 
      phoneNumber.length - 4, 
      '*' * (phoneNumber.length - 4)
    );
  }
  
  void startResendTimer(Function setState) {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (resendSeconds > 0) {
          resendSeconds--;
          startResendTimer(setState);
        } else {
          canResend = true;
        }
      });
    });
  }
  
  void checkOtpComplete(Function setState) {
    bool complete = true;
    for (var controller in otpControllers) {
      if (controller.text.isEmpty) {
        complete = false;
        break;
      }
    }
    
    if (complete != isOtpComplete) {
      setState(() {
        isOtpComplete = complete;
      });
      notifyListeners();
    }
  }
  
  void onOtpDigitChanged(int index, String value, BuildContext context, Function setState) {
    if (value.isNotEmpty && index < 3) {
      // Move to next field
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      // If field is cleared, move to previous field
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
    
    // Check if OTP is complete after each digit entry
    checkOtpComplete(setState);
  }
  
  String getOtp() {
    final otp = otpControllers.map((controller) => controller.text).join();
    print('🔍 Generated OTP from input fields: "$otp"');
    
    // Check if OTP is empty or incomplete
    if (otp.isEmpty || otp.length < 4) {
      print('⚠️ Warning: OTP is empty or incomplete');
      return '';
    }
    
    return otp;
  }
  
  Future<void> verifyOtp(BuildContext context) async {
    final otp = getOtp();
    
    // Check if OTP is empty
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Set loading state
    isLoading = true;
    successMessage = null;
    notifyListeners();
    
    try {
      // Call the OTP verification service
      final response = await _otpVerificationService.verifyOtp(
        phone: phoneNumber,
        otp: otp,
      );
      
      // Store token and user details in shared preferences
      if (response.data != null) {
        final userData = response.data!.user;
        final token = response.data!.token;
        
        // Save token
        await AuthStorageService.saveToken(token);
        
        // Save user details
        await AuthStorageService.saveUserDetails(
          id: userData.id,
          name: userData.name,
          phone: userData.phone,
          email: userData.email,
          role: userData.role,
        );
        
        print('🔵 Token and user details saved to shared preferences');
      }
      
      // Set success message
      successMessage = 'OTP verified successfully!';
      
      // Show success message
      _showCustomSnackBar(
        context: context,
        message: successMessage!,
        isError: false,
      );
      
      // Navigate based on the source of OTP
      if (isFromRegistration) {
        // If coming from registration, go to address screen
        // Use pushAndRemoveUntil to clear the entire navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AddressSelectionScreen(isFirstTimeSignup: true)),
          (route) => false, // Remove all previous routes
        );
      } else {
        // If coming from login, go to main navigation which includes bottom bar
        // Use pushAndRemoveUntil to clear the entire navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      // Handle errors - only show in SnackBar
      _showCustomSnackBar(
        context: context,
        message: e.toString(),
        isError: true,
      );
    } finally {
      // Reset loading state
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> resendOtp(Function setState, BuildContext context) async {
    if (!canResend) return;
    
    // Reset timer first to prevent multiple requests
    setState(() {
      resendSeconds = 21;
      canResend = false;
    });
    
    try {
      // Call the OTP request service
      final otpResponse = await _otpRequestService.requestOtp(phoneNumber);
      
      // Store test OTP for debugging
      testOtp = otpResponse.otp;
      
      // Show test OTP in debug console
      print('Resent OTP: $testOtp');
      
      // Auto-fill OTP fields for testing
      if (testOtp != null && testOtp!.length >= 4) {
        for (int i = 0; i < 4; i++) {
          if (i < testOtp!.length) {
            otpControllers[i].text = testOtp![i];
          }
        }
      }
      
      // Show test OTP in SnackBar for testing purposes
      _showCustomSnackBar(
        context: context,
        message: 'Testing OTP: $testOtp',
        isError: false,
      );
      
    } catch (e) {
      // If there's an error, we still want to start the timer
      print('Error resending OTP: $e');
    }
    
    // Start the timer regardless of success/failure
    startResendTimer(setState);
    notifyListeners();
  }
  
  // Helper method to show custom SnackBar with proper overflow handling
  void _showCustomSnackBar({
    required BuildContext context,
    required String message,
    required bool isError,
  }) {
    // Clear any existing SnackBars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Show new SnackBar with proper overflow handling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Text(
            message,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
