import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Model/QRModel.dart';

class QrDisplayPage extends StatelessWidget {
  final QrCodeDetails qrDetails;

  const QrDisplayPage({super.key, required this.qrDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Ticket Payment QR",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF333333),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFF333333),
        ),
      ),
      body:
          qrDetails.qrCodeUrl == null
              ? const Center(child: Text("QR Code not available"))
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 120,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "₹ ${qrDetails.amount ?? '0'}",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w800,
                          fontSize: 40,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          qrDetails.qrCodeUrl!,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Text("Failed to load QR"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
