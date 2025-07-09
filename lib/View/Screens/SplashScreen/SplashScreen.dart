import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Configuration/Graphql_Config.dart';
import '../../../Controller/CompanyController.dart';
import '../../../Controller/UserController.dart';
import '../../../Model/CompanyModel.dart';
import '../../../Service/GraphqlService/Graphql_Service.dart';
import '../Auth/LoginScreen/LoginScreen.dart';
import '../HomeScreen/HomeScreen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinish;
  const SplashScreen({super.key, this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<LogDetails> recentLog = [];
  List<LogDetails> allLogs = [];
  List<LogDetails> filteredLog = [];
  bool _showMessage = false;

  late UserController userController;
  late CompanyController companyController;

  @override
  void initState() {
    super.initState();

    final graphqlService = GraphQLService(GraphQLConfig().client.value);

    companyController = CompanyController(graphqlService);
    userController = Get.put(UserController(graphqlService));

    initData();
  }

  Future<void> initData() async {
    await initFetchLog();
    await fetchVisitors();
    await _checkLoginStatus();
  }

  Future<int?> getAdminIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> initFetchLog() async {
    final int? adminId = await getAdminIdFromPrefs();

    if (adminId != null) {
      await fetchLog(adminId: adminId);
    } else {
      print("Admin ID is null. Cannot fetch logs.");
    }
  }

  Future<void> fetchLog({required int adminId}) async {
    List<LogDetails>? fetched = await companyController.fetchLogs(adminId: adminId);

    if (fetched != null) {
      // Sort logs by entry date (newest first)
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
    } else {
      print("No logs found.");
    }
  }

  Future<void> fetchVisitors() async {
    final int? adminId = await getAdminIdFromPrefs();

    if (adminId == null) {
      print("Admin ID is null. Cannot fetch visitors.");
      return;
    }

    List<LogDetails>? fetched = await companyController.fetchLogs(adminId: adminId);

    if (fetched != null && fetched.isNotEmpty) {
      setState(() {
        recentLog = fetched.reversed.take(10).toList();
      });

      print("Visitors count: ${recentLog.length}");
      for (var company in recentLog) {
        print("Vehicle: ${company.vehiclenumber}, Entry: ${company.entrytime}");
      }
    } else {
      print("Failed to fetch visitors or empty list received.");
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.get('isLoggedIn');

    final isLoggedIn = storedValue == true || storedValue == 'true';

    await Future.delayed(const Duration(seconds: 1)); // splash delay

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userData: userController.userData.value),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Center(
          child: SizedBox(
            width: 153,
            height: 115.24,
            child: Image.asset(
              'assets/Png/LoginLogo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

