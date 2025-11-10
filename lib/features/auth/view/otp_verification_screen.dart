import 'package:flutter/material.dart';
import 'package:laun_easy/constants/colors/app_colors.dart';
import 'package:laun_easy/features/auth/view_model/otp_verification_viewmodel.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isFromRegistration;
  
  const OtpVerificationScreen({
    super.key, 
    required this.phoneNumber,
    this.isFromRegistration = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late OtpVerificationViewModel _viewModel;
  
  @override
  void initState() {
    super.initState();
    // Initialize view model
    _viewModel = OtpVerificationViewModel(
      phoneNumber: widget.phoneNumber,
      isFromRegistration: widget.isFromRegistration,
    );
    
    // Start countdown timer
    _viewModel.startResendTimer(setState);
    
    // Add listeners to check if OTP is complete
    for (var controller in _viewModel.otpControllers) {
      controller.addListener(() => _viewModel.checkOtpComplete(setState));
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<OtpVerificationViewModel>(
        builder: (context, viewModel, _) {
          // Get masked phone number from view model
          final String maskedNumber = viewModel.getMaskedPhoneNumber();
          
          return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Enter OTP',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Divider line below app bar
          Container(height: 1, color: Colors.grey[300]),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                      AppBar().preferredSize.height - 1, // Subtract appbar height and divider
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const SizedBox(height: 40),
                  
                  // Verification title
                  const Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Instruction text
                  Text(
                    'Please enter OTP received on your registered mobile number - $maskedNumber',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 32),
                  
                  // OTP input fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: viewModel.otpControllers[index],
                          focusNode: viewModel.focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                            ),
                          ),
                          onChanged: (value) => viewModel.onOtpDigitChanged(index, value, context, setState),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Didn't receive OTP text
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Didn't receive the OTP?",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: viewModel.canResend ? () => viewModel.resendOtp(setState, context) : null,
                          child: Text(
                            viewModel.canResend ? 'Resend OTP' : 'Resend OTP (${viewModel.resendSeconds}s)',
                            style: TextStyle(
                              color: viewModel.canResend ? AppColors.primaryColor : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : viewModel.isOtpComplete
                              ? () => viewModel.verifyOtp(context)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: viewModel.isOtpComplete ? AppColors.primaryDarkColor : Colors.grey[200],
                        foregroundColor: viewModel.isOtpComplete ? Colors.white : Colors.grey[500],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  
                  // Success message only
                  if (viewModel.successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        viewModel.successMessage!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(height: 80),
                  
                  // Need Help text at bottom
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: TextButton(
                        onPressed: () {
                          // Handle help action
                        },
                        child: const Text(
                          'Need Help?',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
