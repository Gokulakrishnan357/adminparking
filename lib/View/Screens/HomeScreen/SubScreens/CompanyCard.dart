import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../Model/CompanyModel.dart';
import '../BottomScreens/CompanyScreen/AddCompanyScreen.dart';

class CompanyCard extends StatelessWidget {
  final LogDetails company;

  const CompanyCard({super.key, required this.company});

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '--:--';

    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh.mm a").format(parsedTime); // e.g., 05.16 PM
    } catch (e) {
      return '09.10 AM';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = company.paymentStatus?.toLowerCase() == 'paid';

    final iconColor =
        isPaid ? const Color(0xFF27AE60) : const Color(0xFFD00416);

    final badgeColor =
        isPaid ? const Color(0xFF27AE60) : const Color(0xFFE0E0E0);

    final badgeTextColor = isPaid ? Colors.white : const Color(0xFF4D4D4D);

    final badgeText = isPaid ? 'Paid' : 'Unpaid';

    return GestureDetector(
      onTap: () {
        if (company.entryId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCompanyForm(entryId: company.entryId!),
            ),
          );
        }
      },

      child: Container(
        width: 372,
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E2E2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Number + Arrow + Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    company.vehiclenumber ?? 'TN41BD1258',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),

                Flexible(
                  child: Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 21,
                          height: 21,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            company.isExit == true
                                ? 'assets/Png/Check_out.png'
                                : 'assets/Png/Check_in.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatTime(
                            company.isExit == true
                                ? company.exittime
                                : company.entrytime,
                          ),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: const Color(0xFF333333),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            // Bottom Row: Badge + View Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Paid / Unpaid badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      badgeText,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ),

                // View Details
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'View Details',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: const Color(0xFF0052B0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DateCard extends StatelessWidget {
  final String date;
  final VoidCallback onViewTap;

  const DateCard({super.key, required this.date, required this.onViewTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: onViewTap,
            child: Text(
              'View',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0052B0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
