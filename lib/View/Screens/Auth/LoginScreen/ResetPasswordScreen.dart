import 'package:crestparkz/View/Screens/Auth/LoginScreen/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Components/Utills/TextformFiled.dart';
import '../../../../Configuration/Graphql_Config.dart';
import '../../../../Controller/UserController.dart';
import '../../../../Service/GraphqlService/Graphql_Service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final int userId;

  const ResetPasswordScreen({super.key, required this.userId});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late final UserController userController;

  @override
  void initState() {
    super.initState();
    final graphqlService = GraphQLService(GraphQLConfig().client.value);
    userController = UserController(graphqlService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/Png/LoginLogo.png',
                      width: 130,
                      height: 130,
                    ),

                    const SizedBox(height: 24),

                    // New Password Field
                    CustomTextFormField(
                      hintText: 'New Password',
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
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    CustomTextFormField(
                      hintText: 'Confirm New Password',
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
                        } else if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 60),

                    // Reset Password Button
                    SizedBox(
                      width: 300,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => isLoading = true);

                                    final response = await userController
                                        .updateUserPassword(
                                          widget.userId,
                                          passwordController.text.trim(),
                                        );

                                    setState(() => isLoading = false);

                                    if (response?.data?.updateUser?.success ==
                                        true) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Password updated successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LoginScreen(),
                                        ),
                                      ); // or go to login screen
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response
                                                    ?.data
                                                    ?.updateUser
                                                    ?.message ??
                                                'Password update failed',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  "Reset Password",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),

                    const SizedBox(height: 230),
                    Image.asset(
                      'assets/Png/BottomText.png',
                      width: 230,
                      height: 60,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
