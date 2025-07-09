import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Components/Utills/TextformFiled.dart';
import '../../../../Controller/UserController.dart';
import '../../../../Service/GraphqlService/Graphql_Service.dart';
import '../../HomeScreen/HomeScreen.dart';
import 'OtpVerificationScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    contactController.addListener(_handleInputChange);
  }

  void _handleInputChange() {
    final value = contactController.text;

    // Allow only digits if input is number and limit to 10
    if (RegExp(r'^\d*$').hasMatch(value)) {
      if (value.length > 10) {
        contactController.text = value.substring(0, 10);
        contactController.selection = TextSelection.fromPosition(
          TextPosition(offset: contactController.text.length),
        );
      }
    }
  }

  // Function to login user
  Future<void> _login() async {
    final emailOrPhone = contactController.text.trim();
    final password = passwordController.text.trim();

    if (emailOrPhone.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    _showSnackBar("Please wait, Verifying login...");

    final userController = UserController(
      GraphQLService(GraphQLProvider.of(context).value),
    );

    final loginResponse = await userController.loginUser(
      emailOrPhone,
      password,
    );

    if (loginResponse == null || !(loginResponse.success ?? false)) {
      _showSnackBar(
        loginResponse?.message ?? "Login failed: Invalid credentials.",
      );
      return;
    }

    final user = loginResponse.data;
    if (user == null) {
      _showSnackBar("Login failed: No user data returned.");
      return;
    }

    // Store in SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    if (user.userid != null) {
      await prefs.setInt('userId', user.userid!);
    }

    _showSnackBar(loginResponse.message ?? "Successfully Logged In");

    userController.setUserData(loginResponse.data!);

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userData: loginResponse.data!),
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleForgotPassword() async {
    final emailOrPhone = contactController.text.trim();

    if (emailOrPhone.isEmpty) {
      _showSnackBar("Please enter your registered email id");
      return;
    }

    final isDigitsOnly = RegExp(r'^\d+$').hasMatch(emailOrPhone);
    final isEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailOrPhone);

    if (isDigitsOnly && emailOrPhone.length != 10) {
      _showSnackBar("Enter a valid 10-digit phone number.");
      return;
    } else if (!isDigitsOnly && !isEmail) {
      _showSnackBar("Enter a valid email address.");
      return;
    }

    _showSnackBar("Requesting OTP...");

    final userController = UserController(
      GraphQLService(GraphQLProvider.of(context).value),
    );

    final otpResponse = await userController.sendForgotPasswordOtp(
      emailOrPhone,
    );

    if (otpResponse == null ||
        !(otpResponse.forgotPasswordOtp?.success ?? false)) {
      final errorMessage =
          otpResponse?.forgotPasswordOtp?.message ?? "Failed to request OTP.";
      if (errorMessage.toLowerCase().contains("no user") ||
          errorMessage.toLowerCase().contains("not found")) {
        _showSnackBar("You have entered an Unregistered email Id.");
      } else {
        _showSnackBar(errorMessage);
      }
      return;
    }

    _showSnackBar(
      otpResponse.forgotPasswordOtp?.message ?? "OTP sent successfully...!",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OtpVerificationScreen(
              emailOrPhone: emailOrPhone,
              otpData: otpResponse.forgotPasswordOtp?.data,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.05),

                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/Png/LoginLogo.png',
                        width: width * 0.4,
                        height: width * 0.4,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    // Email or Phone Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "E mail",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),

                    // Email/Phone Input
                    CustomTextFormField(
                      hintText: "Enter your mail id",
                      controller: contactController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'E mail id required';
                        }

                        final isDigitsOnly = RegExp(r'^\d+$').hasMatch(value);
                        final isEmail = RegExp(
                          r'^[^@]+@[^@]+\.[^@]+',
                        ).hasMatch(value);

                        if (isDigitsOnly) {
                          if (value.length != 10) {
                            return 'Enter a valid 10-digit phone number';
                          }
                        } else if (!isEmail) {
                          return 'Please enter a valid email address';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: height * 0.02),

                    // Password Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Password",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),

                    CustomTextFormField(
                      hintText: "Enter password",
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

                    SizedBox(height: height * 0.015),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _handleForgotPassword,
                        child: Text(
                          "Forgot Password ?",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0052B0),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.06),

                    // Login Button
                    SizedBox(
                      width: width * 0.8,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0052B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.15),

                    // Bottom Image
                    Image.asset(
                      'assets/Png/BottomText.png',
                      width: width * 0.6,
                      height: width * 0.15,
                      fit: BoxFit.contain,
                    ),
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
