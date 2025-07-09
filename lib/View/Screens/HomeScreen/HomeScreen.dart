import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Configuration/Graphql_Config.dart';
import '../../../Controller/CompanyController.dart';
import '../../../Controller/UserController.dart';
import '../../../Model/CompanyModel.dart';
import '../../../Model/UserModel.dart';
import '../../../Service/GraphqlService/Graphql_Service.dart';
import 'BottomScreens/CompanyScreen/AddCompanyScreen.dart';
import 'BottomScreens/LogScreen.dart';
import 'BottomScreens/SummaryScreen.dart';
import 'BottomScreens/ProfileScreen/ProfileScreen.dart';
import 'SubScreens/BottomNavBar.dart';
import 'SubScreens/CompanyCard.dart';

class HomeScreen extends StatefulWidget {
  final UserData userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;
  final TextEditingController searchController = TextEditingController();
  final Color activeColor = const Color(0xFF042C73);
  final Color inactiveColor = const Color(0xFF777777);
  final Color activeBackground = const Color(0x3374AAF3);
  late final CompanyController companyController;
  List<LogDetails> recentLogs = [];
  bool _showMessage = false;
  late UserController userController;
  Future<int?>? _adminIdFuture;
  LogsSummary? summaryCounts;
  String name = 'User';
  UserData? userDetails;

  @override
  void initState() {
    super.initState();

    final graphqlService = GraphQLService(GraphQLConfig().client.value);
    companyController = CompanyController(graphqlService);

    Future.delayed(Duration.zero, () async {
      userController = Get.find<UserController>();

      final prefs = await SharedPreferences.getInstance();
      final int? adminId = prefs.getInt('userId');
      name = prefs.getString('fullname') ?? 'User';

      if (adminId != null) {
        await fetchLogs(adminId: adminId);
        await fetchLogscount(adminId: adminId);
      } else {
        print('Admin ID is null. Skipping fetchLogs.');
      }

      _adminIdFuture = getAdminIdFromPrefs();

      if (mounted) {
        setState(() {
          name = prefs.getString('fullname') ?? 'User';
          _showMessage = true;
        });
      }
    });
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
      fetched.sort((a, b) {
        final aTime = DateTime.tryParse(a.entryDate ?? '') ?? DateTime(2000);
        final bTime = DateTime.tryParse(b.entryDate ?? '') ?? DateTime(2000);
        return bTime.compareTo(aTime); // newest first
      });

      setState(() {
        recentLogs = fetched.reversed.take(10).toList();
        _showMessage = fetched.isEmpty;
      });

      print("Logs count: ${recentLogs.length}");
      for (var log in recentLogs) {
        print("Vehicle: ${log.vehiclenumber}, Entry: ${log.entrytime}");
      }
    } else {
      print("Failed to fetch logs or empty list.");
    }
  }

  Future<void> fetchLogscount({required int adminId}) async {
    final LogResponseWrapper? fetched = await companyController
        .fetchLogsWithSummary(adminId: adminId);

    if (fetched != null) {
      final sortedLogs = fetched.logs;
      sortedLogs.sort((a, b) {
        final aTime = DateTime.tryParse(a.entryDate ?? '') ?? DateTime(2000);
        final bTime = DateTime.tryParse(b.entryDate ?? '') ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      setState(() {
        recentLogs = sortedLogs.take(10).toList();

        summaryCounts = LogsSummary(
          totalSlots: fetched.totalSlots,
          availableSlots: fetched.availableSlots,
          occupiedSlots: fetched.occupiedSlots,
          todayRevenue: fetched.todayRevenue,
        );
      });
    } else {
      print("Failed to fetch logs or empty list.");
    }
  }

  Future<void> loadUserLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('loginData');

    if (storedData != null) {
      final Map<String, dynamic> loginJson = jsonDecode(storedData);
      final loginResponse = LoginResponse.fromJson(loginJson);
      final user = loginResponse.data;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    int totalSlots = summaryCounts?.totalSlots?.toInt() ?? 0;
    int totalAvailableSlots = summaryCounts?.availableSlots?.toInt() ?? 0;
    int totalOccupiedSlots = summaryCounts?.occupiedSlots?.toInt() ?? 0;
    int totalRevenue = summaryCounts?.todayRevenue?.toInt() ?? 0;

    print(totalAvailableSlots);
    print(totalOccupiedSlots);
    print(totalRevenue);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140), // Increased height
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFE6F2FF),
          elevation: 0,
          toolbarHeight: 140,
          flexibleSpace: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Top Row: Profile + Welcome + Date + Notification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Profile + Welcome + Date
                      Row(
                        children: [
                          /// Profile image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/Png/UserProfile.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// Welcome text + date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Welcome, ",
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextSpan(
                                      text: name,

                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd-MM-yyyy').format(DateTime.now()),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF777777),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      /// Notification icon with red dot
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/Png/Notification.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LogScreen(),
                                ),
                              );
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                textAlignVertical:
                                    TextAlignVertical
                                        .center, // Vertically center text
                                decoration: InputDecoration(
                                  hintText: 'Search best parking',
                                  hintStyle: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF777777),
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.directions_bike,
                                    color: Colors.grey,
                                  ),
                                  isCollapsed: false,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ), // Adjust for vertical alignment
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Icon(Icons.search, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // Scrollable content with RefreshIndicator
          Expanded(
            child: Container(
              color: const Color(0xFFE6F2FF),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 372,
                      height: 90,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          bottom: BorderSide(
                            color: Color(0xFF8DBBDC),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              'assets/Png/Company_count.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Parking',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF606060),
                                  ),
                                ),

                                Text(
                                  "Slot’s",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF00448C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              totalSlots.toString(),
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(minHeight: 90),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: const Border(
                                bottom: BorderSide(
                                  color: Color(0xFF6FD277),
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Container(
                                //   width: 42,
                                //   height: 42,
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(8),
                                //   ),
                                //   child: Image.asset(
                                //     'assets/Png/Check_in.png',
                                //     fit: BoxFit.contain,
                                //   ),
                                // ),
                                // const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Available Slots',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF777777),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: Text(
                                          totalAvailableSlots.toString(),
                                          style: GoogleFonts.montserrat(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF25D578),
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
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(minHeight: 90),
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: const Border(
                                bottom: BorderSide(
                                  color: Color(0xFFD26F6F),
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Occupied Slots',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF777777),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: Text(
                                          '$totalOccupiedSlots',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFFB3748),
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
                      ],
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: 372,
                      height: 90,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          bottom: BorderSide(
                            color: Color(0xFF8DBBDC),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF606060),
                                  ),
                                ),

                                Text(
                                  "Revenue",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF00448C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              '$totalRevenue',
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Updates',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF333333),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LogScreen(),
                              ),
                            );
                          },

                          child: Text(
                            'View All >>>',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0C448E),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    FutureBuilder<int?>(
                      future: _adminIdFuture,
                      builder: (context, adminIdSnapshot) {
                        if (adminIdSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (!adminIdSnapshot.hasData ||
                            adminIdSnapshot.data == null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 60.0),
                            child: const Center(
                              child: SpinKitFadingCircle(
                                color: Color(0xFF0C448E),
                                size: 40.0,
                              ),
                            ),
                          );
                        }

                        final int adminId = adminIdSnapshot.data!;

                        return FutureBuilder<List<LogDetails>?>(
                          future: companyController.fetchLogs(adminId: adminId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child:
                                    _showMessage
                                        ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 60.0,
                                            ),
                                            child: Text(
                                              'Please Wait...!',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0C448E),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                        : const SpinKitFadingCircle(
                                          color: Color(0xFF0C448E),
                                          size: 40.0,
                                        ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 80,
                                ),
                                child: Center(
                                  child: Text(
                                    'No Entry Results Found...!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0C448E),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            } else {
                              List<LogDetails> fetchedCompany = snapshot.data!;
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: fetchedCompany.length,
                                itemBuilder: (context, index) {
                                  final company = fetchedCompany[index];
                                  return CompanyCard(company: company);
                                },
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 10),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        onAddTap: () {
          print("Add button tapped");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCompanyForm()),
          );
        },
      ),
    );
  }
}
