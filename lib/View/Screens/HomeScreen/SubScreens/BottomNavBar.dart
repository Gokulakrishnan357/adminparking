import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onAddTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 7,
            left: 0,
            right: 0,
            child: Container(
              height: 72,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildNavItem('assets/Svg/Home.svg', 'Home', 0),
                  ),
                  Expanded(
                    child: _buildNavItem('assets/Svg/Logs.svg', 'Logs', 1),
                  ),
                  const SizedBox(width: 68), // Leave space for the central FAB
                  Expanded(
                    child: _buildNavItem(
                      'assets/Svg/Members.svg',
                      'Summary',
                      2,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      'assets/Svg/Profile.svg',
                      'Profile',
                      3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Center Plus Button
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onAddTap,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C448E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String asset, String label, int index) {
    final bool isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive ? const Color(0x331462E5) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              asset,
              width: 30,
              height: 30,
              fit: BoxFit.scaleDown,
              color:
              isActive ? const Color(0xFF0C448E) : const Color(0xFF333333),
            ),
          ),

          Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color:
              isActive ? const Color(0xFF0C448E) : const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
