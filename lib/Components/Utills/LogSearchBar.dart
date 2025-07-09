import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class LogSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const LogSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search a log',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 325,
      height: 52,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE), // Background color
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF777777), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.0,
                letterSpacing: 0.0,
                color: Color(0xFF111111),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.0,
                  letterSpacing: 0.0,
                  color: Color(0xFF777777),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


