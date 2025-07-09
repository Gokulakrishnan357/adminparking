import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Components/Utills/TextformFiled.dart';
import '../../../../Controller/UserController.dart';
import '../../../../Service/GraphqlService/Graphql_Service.dart';
import '../LoginScreen/LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // final companyController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void showRegistrationFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 400,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Registration Failed',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFDA1A0C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'You have entered the wrong email ID or password.\n\n'
                    'If you want to purchase a domain, please contact our sales team.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDA1A0C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.montserrat(
                        color: Color(0xFF0C448E),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Future<void> _submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     // Display a loading message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Please Wait... Until User Details Saved"),
  //       ),
  //     );
  //
  //     final userController = UserController(
  //       GraphQLService(GraphQLProvider.of(context).value),
  //     );
  //
  //     final newUser = await userController.loginUser(
  //
  //     );
  //
  //     if (newUser != null) {
  //       final prefs = await SharedPreferences.getInstance();
  //
  //       await prefs.setBool('isLoggedIn', true);
  //       await prefs.setInt('userId', newUser.companyuserid ?? 0);
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text(
  //             "User registered successfully. Please log in to continue...",
  //           ),
  //         ),
  //       );
  //
  //       await Future.delayed(const Duration(seconds: 2)); // Wait 2 seconds
  //
  //       if (mounted) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => LoginScreen()),
  //         );
  //       }
  //     } else {
  //       final responseData = userController.lastResponseData;
  //       final message =
  //           responseData?['message'] ?? "An error occurred. Please try again.";
  //
  //       showErrorDialog("User creation failed: $message");
  //     }
  //   }
  // }

  void showRegistrationFailedDialog2(
    BuildContext context,
    String? errorMessage,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            title: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  "Registration Failed",
                  style: GoogleFonts.montserrat(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
              errorMessage ?? "An error occurred. Please try again.",
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "OK",
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF0C448E),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Registration Failed",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            content: Text(message, style: const TextStyle(fontSize: 16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF0C448E), // Button background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color on dark background
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF000000),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: 412,
          height: 917,
          padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Logo
                SizedBox(
                  height: 115.25,
                  width: 153,
                  child: Image.asset(
                    'assets/Png/SplashLogo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 48),

                // // 1. Company Name
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text("Company Name", style: labelStyle),
                //     const SizedBox(height: 8),
                //     CustomTextFormField(
                //       hintText: 'Enter company name',
                //
                //       controller: companyController,
                //       validator:
                //           (value) =>
                //               value == null || value.isEmpty
                //                   ? 'Company name is required'
                //                   : null,
                //       inputFormatters: [
                //         FilteringTextInputFormatter.allow(
                //           RegExp(r'[a-zA-Z\s]'),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                const SizedBox(height: 20),

                // 2. Email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("E-Mail", style: labelStyle),
                    const SizedBox(height: 8),

                    CustomTextFormField(
                      hintText: 'Enter your official mail ID',
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Official Email is required';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address that matches your domain';
                        }
                        if (!value.contains('crestclimbers')) {
                          return 'Please use your official crestclimbers email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 3. Phone
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Phone No.", style: labelStyle),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("🇮🇳 +91"),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextFormField(
                            hintText: 'Enter your mobile number',
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (value.length != 10) {
                                return 'Phone number must be 10 digits';
                              }
                              if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                                return 'Enter a valid Indian mobile number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. Password
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Create Password", style: labelStyle),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      hintText: 'Enter password',
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      showSuffixIcon: true,
                      togglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 5. Confirm Password
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Confirm Password", style: labelStyle),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      hintText: 'Reconfirm password',
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      showSuffixIcon: true,
                      togglePassword: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Register Button
                SizedBox(
                  width: 310,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0C448E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: null,
                    child: Text(
                      'Register',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
