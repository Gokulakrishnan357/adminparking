import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  const CommonSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search Best Parking',
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              width: 370,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onTap: onTap,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF777777),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

          ),


        ],
      ),
    );
  }
}
