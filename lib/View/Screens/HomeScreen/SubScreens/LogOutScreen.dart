import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Auth/LoginScreen/LoginScreen.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 48),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 👈 this lets dialog size itself to fit contents
            children: [
              // Logout Confirmation Text
              Text(
                'Logout Confirmation',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDA1A0C),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: 220,
                height: 40,
                child: Text(
                  'Are you sure you want to log out?',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),


              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Button (just text)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Logout Button
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog

                      // Clear all data from SharedPreferences
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.clear();  // Clear all saved data

                      // Navigate to login screen and remove all previous routes
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDA1A0C),
                      minimumSize: const Size(100, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

}






