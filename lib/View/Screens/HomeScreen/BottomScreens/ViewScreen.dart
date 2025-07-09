import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../Components/Utills/TextformFiled.dart';
import '../../../../Configuration/Graphql_Config.dart';
import '../../../../Controller/CompanyController.dart';
import '../../../../Model/SummaryModel.dart';
import '../../../../Service/GraphqlService/Graphql_Service.dart';

class ViewSummaryScreen extends StatefulWidget {
  final int adminId;
  final String date;

  const ViewSummaryScreen({
    required this.adminId,
    required this.date,
    super.key,
  });

  @override
  State<ViewSummaryScreen> createState() => _ViewSummaryScreenState();
}

class _ViewSummaryScreenState extends State<ViewSummaryScreen> {
  final TextEditingController vehiclesController = TextEditingController();
  final TextEditingController revenueController = TextEditingController();
  final TextEditingController cashController = TextEditingController();
  final TextEditingController upiCardController = TextEditingController();
  late CompanyController companyController;
  bool _isLoading = true;
  String formattedDate = '';

  @override
  void initState() {
    super.initState();

    // ✅ Initialize companyController before using it
    final graphqlService = GraphQLService(GraphQLConfig().client.value);
    companyController = CompanyController(graphqlService);

    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    final LogSummaryData? summary = await companyController.fetchLogSummary(
      adminId: widget.adminId,
      date: widget.date,
    );

    final parsedDate =
        widget.date.isNotEmpty
            ? DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.date))
            : 'NA';

    if (summary != null) {
      setState(() {
        formattedDate = parsedDate;
        vehiclesController.text = summary.parkedVehicles?.toString() ?? '0';
        revenueController.text = "₹ ${summary.totalRevenue ?? Decimal.zero}";
        cashController.text = "₹ ${summary.cashRevenue ?? Decimal.zero}";
        upiCardController.text = "₹ ${summary.upiCardRevenue ?? Decimal.zero}";
        _isLoading = false;
      });
    } else {
      setState(() {
        formattedDate = parsedDate;
        vehiclesController.text = '0';
        revenueController.text = '₹ 0';
        cashController.text = '₹ 0';
        upiCardController.text = '₹ 0';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle fieldTextStyle = GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF494747),
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false; // prevent default handler (since we manually pop)
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '$formattedDate Summary',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1C1C),
            ),
          ),
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel('Vehicles Parked'),
                        CustomTextFormField(
                          hintText: 'Enter number',
                          controller: vehiclesController,
                          readOnly: true,
                          style: fieldTextStyle,
                        ),
                        const SizedBox(height: 16),
                        buildLabel('Total Revenue'),
                        CustomTextFormField(
                          hintText: '₹ 0',
                          controller: revenueController,
                          readOnly: true,
                          style: fieldTextStyle,
                        ),
                        const SizedBox(height: 16),
                        buildLabel('Cash'),
                        CustomTextFormField(
                          hintText: '₹ 0',
                          controller: cashController,
                          readOnly: true,
                          style: fieldTextStyle,
                        ),
                        const SizedBox(height: 16),
                        buildLabel('UPI/Card'),
                        CustomTextFormField(
                          hintText: '₹ 0',
                          controller: upiCardController,
                          readOnly: true,
                          style: fieldTextStyle,
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1C1C1C),
        ),
      ),
    );
  }
}
