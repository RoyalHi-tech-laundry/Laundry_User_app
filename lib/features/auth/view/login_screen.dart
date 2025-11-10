import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laun_easy/constants/colors/app_colors.dart';
import 'package:laun_easy/features/auth/view_model/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> {
  final LoginViewModel _viewModel = LoginViewModel();

  void _validatePhone() {
    _viewModel.validatePhone();
    setState(() {}); // Update UI based on validation result
  }
  
  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_viewModelListener);
  }
  
  void _viewModelListener() {
    // Force rebuild when view model changes
    if (mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => SystemNavigator.pop(),
        ),
        title: const Text(
          'Login',
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

          // Main content with padding
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // Login title and greeting
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hi there, nice to see you',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Phone number input field
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
                            onChanged: (value) {
                              _validatePhone();
                            },
                            decoration: const InputDecoration(
                              hintText: 'Phone Number',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_viewModel.isPhoneValid && !_viewModel.isLoading)
                        ? () => _viewModel.checkUserAndNavigate(context)
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _viewModel.isPhoneValid ? AppColors.primaryDarkColor : Colors.grey[200],
                        foregroundColor: _viewModel.isPhoneValid ? Colors.white : Colors.grey[500],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _viewModel.isLoading
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

                  const Spacer(flex: 4),

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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_viewModelListener);
    _viewModel.dispose();
    super.dispose();
  }
}
