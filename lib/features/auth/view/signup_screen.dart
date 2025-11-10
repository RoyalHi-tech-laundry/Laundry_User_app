import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:laun_easy/constants/colors/app_colors.dart';
import 'package:laun_easy/features/auth/view_model/signup_viewmodel.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  final String phoneNumber;
  
  const SignupScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late SignupViewModel _viewModel;
  
  @override
  void initState() {
    super.initState();
    _viewModel = SignupViewModel();
    
    // Pre-fill phone number if provided
    if (widget.phoneNumber.isNotEmpty) {
      _viewModel.phoneController.text = widget.phoneNumber;
      _viewModel.validatePhone();
    }
  }
  
  void _validateName() {
    _viewModel.validateName();
    setState(() {}); // Update UI based on validation result
  }
  
  void _validateEmail() {
    _viewModel.validateEmail();
    setState(() {}); // Update UI based on validation result
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<SignupViewModel>(
        builder: (context, viewModel, _) {
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
          'SIGN UP',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Sign up title and subtitle
                    const Text(
                      'Create an account with the new phone number',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Phone number field (pre-filled and disabled)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mobile number',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              // Country code selector
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    CountryFlag.fromCountryCode(
                                      'IN',
                                      width: 23,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '+91',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Vertical divider
                              Container(
                                height: 30,
                                width: 1,
                                color: Colors.grey[300],
                              ),
                              
                              // Phone number input
                              Expanded(
                                child: TextField(
                                  controller: _viewModel.phoneController,
                                  keyboardType: TextInputType.phone,
                                  readOnly: widget.phoneNumber.isNotEmpty,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Phone Number',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    suffixIcon: _viewModel.isPhoneValid
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: AppColors.successColor,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Name field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _viewModel.nameController,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (value) {
                              _validateName();
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter your full name',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Email field (optional)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Address (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _viewModel.emailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              _validateEmail();
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter your email address',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : viewModel.isNameValid
                                ? () => viewModel.registerAndNavigate(context)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: viewModel.isNameValid
                              ? AppColors.primaryDarkColor
                              : Colors.grey[200],
                          foregroundColor: viewModel.isNameValid
                              ? Colors.white
                              : Colors.grey[500],
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
                            : Text(
                                viewModel.isNameValid ? 'CONTINUE' : 'ENTER NAME',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                    
                    // Error message
                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
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
