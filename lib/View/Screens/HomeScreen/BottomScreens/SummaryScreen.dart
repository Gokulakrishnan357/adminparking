import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Components/Utills/LogSearchBar2.dart';
import '../../../../Configuration/Graphql_Config.dart';
import '../../../../Controller/CompanyController.dart';
import '../../../../Controller/UserController.dart';
import '../../../../Model/CompanyModel.dart';
import '../../../../Service/GraphqlService/Graphql_Service.dart';
import '../HomeScreen.dart';
import '../SubScreens/BottomNavBar.dart';
import '../SubScreens/CompanyCard.dart';
import 'CompanyScreen/AddCompanyScreen.dart';
import 'LogScreen.dart';
import 'ProfileScreen/ProfileScreen.dart';
import 'ViewScreen.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TextEditingController searchController = TextEditingController();

  final int _currentIndex = 2;
  List<LogDetails> filteredLog = [];
  List<LogDetails> allLogs = [];
  late CompanyController companyController;
  bool _showMessage = false;
  late UserController userController;
  bool _isNavigating = false;

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

  @override
  void initState() {
    super.initState();

    final graphqlService = GraphQLService(GraphQLConfig().client.value);
    companyController = CompanyController(graphqlService);

    // ✅ Use Future.delayed to safely initialize controllers and fetch logs
    Future.delayed(Duration.zero, () async {
      userController = Get.find<UserController>();

      final prefs = await SharedPreferences.getInstance();
      final int? adminId = prefs.getInt('userId');

      if (adminId != null) {
        print("Fetching logs for adminId: $adminId");
        await fetchLog(adminId: adminId);
      } else {
        print("Admin ID (userId) is null. Cannot fetch logs.");
      }

      if (mounted) {
        setState(() {
          _showMessage = true;
        });
      }
    });
  }

  Future<void> fetchLog({required int adminId}) async {
    List<LogDetails>? fetched = await companyController.fetchLogs(
      adminId: adminId,
    );

    if (fetched != null) {
      fetched.sort((a, b) {
        final aTime = DateTime.tryParse(a.entryDate ?? '') ?? DateTime(2000);
        final bTime = DateTime.tryParse(b.entryDate ?? '') ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      setState(() {
        allLogs = fetched;
        filteredLog = fetched;
        _showMessage = fetched.isEmpty;
      });
    }
  }

  void filterSearch(String query) => applyFilter();

  void applyFilter() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredLog =
          allLogs.where((log) {
            final vehicleMatch = (log.vehiclenumber ?? '')
                .toLowerCase()
                .contains(query);

            final entryTimeMatch = (log.entrytime ?? '').toLowerCase().contains(
              query,
            );

            final exitTimeMatch = (log.exittime ?? '').toLowerCase().contains(
              query,
            );

            final paymentStatusMatch = (log.paymentStatus ?? '')
                .toLowerCase()
                .contains(query);

            final paymentMethodMatch = (log.paymentMethod ?? '')
                .toLowerCase()
                .contains(query);

            final queryMatch =
                query.isEmpty ||
                vehicleMatch ||
                entryTimeMatch ||
                exitTimeMatch ||
                paymentStatusMatch ||
                paymentMethodMatch;

            return queryMatch;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              color: Color(0xFFF9F9F9),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: LogSearchBar2(
                        controller: searchController,
                        onChanged: filterSearch,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Company list view (after search bar)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child:
                    filteredLog.isEmpty
                        ? Center(
                          child:
                              _showMessage
                                  ? Text(
                                    'No Results Found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0C448E),
                                    ),
                                  )
                                  : const SpinKitFadingCircle(
                                    color: Color(0xFF0C448E),
                                    size: 40.0,
                                  ),
                        )
                        : ListView.separated(
                          itemCount: filteredLog.length,
                          itemBuilder: (context, index) {
                            final company = filteredLog[index];

                            // Ensure createdDate is a formatted String
                            final formattedDate =
                                company.entryDate != null
                                    ? DateFormat(
                                      'dd-MM-yyyy',
                                    ).format(DateTime.parse(company.entryDate!))
                                    : 'NA';

                            print(formattedDate);

                            return DateCard(
                              date: formattedDate,

                              onViewTap: () async {
                                if (_isNavigating) return;
                                _isNavigating = true;

                                final prefs =
                                    await SharedPreferences.getInstance();
                                final int? adminId = prefs.getInt('userId');

                                if (adminId != null &&
                                    company.entryDate != null) {
                                  final String graphqlFormattedDate =
                                      DateFormat('yyyy-MM-dd').format(
                                        DateTime.parse(company.entryDate!),
                                      );

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ViewSummaryScreen(
                                            adminId: adminId,
                                            date: graphqlFormattedDate,
                                          ),
                                    ),
                                  );
                                } else {
                                  print(
                                    "Cannot proceed. adminId or entryDate is null.",
                                  );
                                }

                                _isNavigating = false;
                              },
                            );
                          },
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 8),
                        ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        onAddTap: () {
          print("Floating Add tapped");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCompanyForm()),
          );
        },
      ),
    );
  }
}
