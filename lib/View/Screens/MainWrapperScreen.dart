import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../Controller/UserController.dart';
import 'HomeScreen/BottomScreens/CompanyScreen/AddCompanyScreen.dart';
import 'HomeScreen/BottomScreens/LogScreen.dart';
import 'HomeScreen/BottomScreens/SummaryScreen.dart';
import 'HomeScreen/BottomScreens/ProfileScreen/ProfileScreen.dart';
import 'HomeScreen/HomeScreen.dart';
import 'HomeScreen/SubScreens/BottomNavBar.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();

}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _selectedIndex = 0;
  late UserController userController;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();

    _screens = [
      HomeScreen(userData: userController.userData.value),
      const LogScreen(),
      const SummaryScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}



