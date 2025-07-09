import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Configuration/Graphql_Config.dart';
import '../../../../Controller/UserController.dart';
import '../../../../Model/UserModel.dart';
import '../../../../Service/GraphqlService/Graphql_Service.dart';
import 'ResetPasswordScreen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String emailOrPhone;
  final ForgotPasswordOtpData? otpData;

  const OtpVerificationScreen({
    super.key,
    required this.emailOrPhone,
    this.otpData,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late List<String> otpDigits;
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  late UserController userController;

  @override
  void initState() {
    super.initState();

    final graphqlService = GraphQLService(GraphQLConfig().client.value);
    userController = UserController(graphqlService);
    userController = Get.find<UserController>();

    // Initialize OTP digits from the otpcode if available
    final otp = widget.otpData?.otpcode ?? '';
    otpDigits = List<String>.filled(4, '');

    for (int i = 0; i < otp.length && i < 4; i++) {
      otpDigits[i] = otp[i];
    }

    otpController.text = otp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/Png/LoginLogo.png',
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  "Please Verify OTP",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: const Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                /// Auto-filled OTP display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => Container(
                      width: 40,
                      height: 48,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1.5, color: Colors.black54),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        otpDigits[index].isNotEmpty ? otpDigits[index] : '_',
                        style: TextStyle(
                          fontSize: 24,
                          color:
                              otpDigits[index].isNotEmpty
                                  ? Colors.black
                                  : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 30 Sec and Resend OTP
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "30 Sec",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => ResetPasswordScreen(),
                          //   ),
                          // );
                        },
                        child: Text(
                          "Resend OTP",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Color(0xFF0052B0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Confirm OTP Button
                SizedBox(
                  width: 300,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              final enteredOtp = otpController.text.trim();
                              final userId = widget.otpData?.userid;

                              if (enteredOtp.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Please enter the OTP"),
                                  ),
                                );
                                return;
                              }

                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("User ID not found")),
                                );
                                return;
                              }

                              setState(() {
                                isLoading = true;
                              });

                              final response = await userController.verifyOtp(
                                userId,
                                enteredOtp,
                              );

                              setState(() {
                                isLoading = false;
                              });

                              if (response?.data?.verifyOtp?.success == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("OTP verified successfully"),
                                  ),
                                );

                                // Navigate to next screen or update UI
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            ResetPasswordScreen(userId: userId),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      response?.data?.verifyOtp?.message ??
                                          "OTP verification failed",
                                    ),
                                  ),
                                );
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
                            ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : Text(
                              "Confirm OTP",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 250),

                // Bottom Text Image
                Center(
                  child: Image.asset(
                    'assets/Png/BottomText.png',
                    width: 230,
                    height: 60,
                    fit: BoxFit.contain,
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
