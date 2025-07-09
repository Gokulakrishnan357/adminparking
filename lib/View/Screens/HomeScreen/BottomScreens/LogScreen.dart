import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Components/Utills/LogSearchBar.dart';
import '../../../../Components/Utills/TextformFiled.dart';
import '../../../../Configuration/Graphql_Config.dart';
import '../../../../Controller/CompanyController.dart';
import '../../../../Controller/UserController.dart';
import '../../../../Model/CompanyModel.dart';
import '../../../../Service/GraphqlService/Graphql_Service.dart';
import '../HomeScreen.dart';
import '../SubScreens/BottomNavBar.dart';
import '../SubScreens/CompanyCard.dart';
import 'CompanyScreen/AddCompanyScreen.dart';
import 'SummaryScreen.dart';
import 'ProfileScreen/ProfileScreen.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;

  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  String selectedFilter = "All";
  final int _currentIndex = 1;

  final Color activeColor = const Color(0xFF042C73);
  final Color inactiveColor = const Color(0xFF777777);
  final Color activeBackground = const Color(0x3374AAF3);

  List<LogDetails> allLogs = [];
  List<LogDetails> filteredLog = [];

  late CompanyController companyController;

  bool _showMessage = false;
  bool _showDateFields = false;

  late Timer _timer;
  late UserController userController;

  Future<int?>? _adminIdFuture;

  @override
  void initState() {
    super.initState();

    final graphqlService = GraphQLService(GraphQLConfig().client.value);
    companyController = CompanyController(graphqlService);
    userController = Get.find<UserController>();

    _adminIdFuture = getAdminIdFromPrefs();

    _initialize();
    _timer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _showMessage = true;
        });
      }
    });
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final int? adminId = prefs.getInt('userId');

    if (adminId != null) {
      print("Fetching logs for adminId: $adminId");
      await fetchLogs(adminId: adminId);
      print("Logs fetched: ${allLogs.length}");
    } else {
      print('Admin ID is null. Skipping fetchLogs in Logs Screen.');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  Future<int?> getAdminIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> fetchLogs({required int adminId}) async {
    List<LogDetails>? fetched = await companyController.fetchLogs(
      adminId: adminId,
    );

    if (fetched != null) {
      // Sort by createdat (newest first)
      fetched.sort((a, b) {
        final aTime = DateTime.tryParse(a.entryDate ?? '') ?? DateTime(2000);
        final bTime = DateTime.tryParse(b.entryDate ?? '') ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      setState(() {
        allLogs = fetched;
        applyFilter();
      });
    }
  }

  void applyFilter() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredLog =
          allLogs.where((log) {
            // Query-based filtering
            final vehicleMatch = (log.vehiclenumber ?? '')
                .toLowerCase()
                .contains(query);
            final entryTimeMatch = (log.entrytime ?? '').toLowerCase().contains(
              query,
            );
            final exitTimeMatch = (log.exittime ?? '').toLowerCase().contains(
              query,
            );

            final queryMatch =
                query.isEmpty ||
                vehicleMatch ||
                entryTimeMatch ||
                exitTimeMatch;

            // Status-based filtering using isExit
            final statusMatch =
                selectedFilter == "All"
                    ? true
                    : selectedFilter == "In"
                    ? (log.isExit != true)
                    : (log.isExit == true);

            // Date range filter on exittime
            bool dateMatch = true;
            if (fromDate != null && toDate != null) {
              final exitDate = DateTime.tryParse(log.entryDate ?? '');
              if (exitDate != null) {
                dateMatch =
                    exitDate.isAfter(
                      fromDate!.subtract(const Duration(days: 1)),
                    ) &&
                    exitDate.isBefore(toDate!.add(const Duration(days: 1)));
              } else {
                dateMatch = false;
              }
            }

            return queryMatch && statusMatch && dateMatch;
          }).toList();
    });
  }

  void filterSearch(String query) => applyFilter();

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

  void _selectFromDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        fromDate = selectedDate;
        fromDateController.text = dateFormat.format(fromDate!);
      });
      applyFilter();
    }
  }

  void _selectToDate(BuildContext context) async {
    if (fromDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select From Date first.')));
      return;
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: fromDate!,
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        toDate = selectedDate;
        toDateController.text = dateFormat.format(toDate!);
      });
      applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 65, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LogSearchBar(
                        controller: searchController,
                        onChanged: filterSearch,
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showDateFields = true;
                        });
                        _selectFromDate(context);
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_month, size: 28),
                      ),
                    ),
                  ],
                ),

                if (_showDateFields)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            hintText: 'From Date',
                            controller: fromDateController,
                            readOnly: true,
                            suffixIcon: const Icon(
                              Icons.calendar_month,
                              size: 28,
                            ),
                            onTap: () => _selectFromDate(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextFormField(
                            hintText: 'To Date',
                            controller: toDateController,
                            readOnly: true,
                            suffixIcon: const Icon(
                              Icons.calendar_month,
                              size: 28,
                            ),
                            onTap: () => _selectToDate(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                SizedBox(
                  width: 372,
                  height: 36,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          ['All', 'In', 'Out'].map((filter) {
                            final isSelected = selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => selectedFilter = filter);
                                  applyFilter();
                                },
                                child: Container(
                                  width: 117,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Color(0xFF0C448E)
                                            : Color(0xFFEDEDED),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    filter,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child:
                filteredLog.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child:
                            _showMessage
                                ? Text(
                                  'No Entry Results found...!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0C448E),
                                  ),
                                )
                                : const SpinKitFadingCircle(
                                  color: Color(0xFF0C448E),
                                  size: 40.0,
                                ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      itemCount: filteredLog.length,
                      itemBuilder: (context, index) {
                        final company = filteredLog[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CompanyCard(company: company),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        onAddTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCompanyForm()),
          );
        },
      ),
    );
  }
}
