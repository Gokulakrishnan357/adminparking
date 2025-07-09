import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Components/Utills/TextformFiled.dart';
import '../../../../Controller/UserController.dart';
import '../SubScreens/BottomNavBar.dart';
import '../HomeScreen.dart';
import 'LogScreen.dart';
import 'SummaryScreen.dart';
import 'ProfileScreen/ProfileScreen.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final int _currentIndex = 2;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  late UserController userController;
  void _onNavItemTapped(int index) {
    if (index == _currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = HomeScreen(userData: userController.userData.value);
        break;
      case 1:
        nextScreen = LogScreen();
        break;
      case 2:
        nextScreen = SummaryScreen();
        break;
      case 3:
        nextScreen = ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Perform the send logic
      print('Form is valid. Proceeding...');
    } else {
      print('Form is invalid. Fix errors.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Member",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Employee Name"),
              const SizedBox(height: 8),
              CustomTextFormField(
                hintText: "Enter the Name",
                controller: nameController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Name is required'
                            : null,
              ),
              const SizedBox(height: 20),

              _buildLabel("E-Mail (working mail ID)"),
              const SizedBox(height: 8),

              CustomTextFormField(
                hintText: "Enter mail ID",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabel("Phone"),
              const SizedBox(height: 8),
              _buildPhoneInput(),

              const SizedBox(height: 40),

              SizedBox(
                width: 372,
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel button
                    SizedBox(
                      width: 176,
                      height: 52,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),

                    // Send a Link button
                    SizedBox(
                      width: 176,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C448E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: const EdgeInsets.all(10),
                        ),
                        child: Text(
                          "Send a Link",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        onAddTap: () {
          print("Floating Add tapped");
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildPhoneInput() {
    return FormField<String>(
      validator: (value) {
        final phone = phoneController.text.trim();
        if (phone.isEmpty) {
          return 'Phone number is required';
        }
        if (phone.length != 10) {
          return 'Phone number must be 10 digits';
        }
        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
          return 'Enter a valid Indian mobile number';
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: state.hasError ? Colors.red : const Color(0xFFD4D4D4),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/Png/flag_india.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "+91",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  const VerticalDivider(color: Colors.grey, thickness: 0.8),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration.collapsed(
                        hintText: "Enter Mobile Number",
                        hintStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: const Color(0xFFA4A4A4),
                        ),
                      ),
                      onChanged: (_) {
                        state.didChange(phoneController.text);
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
