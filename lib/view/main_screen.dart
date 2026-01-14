import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:siaga_tani/view/dashboard_screen.dart';
import 'package:siaga_tani/view/my_farm_screen.dart';
import 'package:siaga_tani/view/education_screen.dart'; 
import 'package:siaga_tani/view/profile_screen.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      const DashboardScreen(),
      const MyFarmScreen(),
      const EducationScreen(), 
      const ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.house_fill),
        inactiveIcon: const Icon(CupertinoIcons.house),
        title: ("Beranda"),
        activeColorPrimary: const Color(0xFF4CAF50),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.spa), 
        inactiveIcon: const Icon(Icons.spa_outlined),
        title: ("Lahan Saya"),
        activeColorPrimary: const Color(0xFF4CAF50),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.book_fill),
        inactiveIcon: const Icon(CupertinoIcons.book),
        title: ("Edukasi"),
        activeColorPrimary: const Color(0xFF4CAF50),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.person_fill),
        inactiveIcon: const Icon(CupertinoIcons.person),
        title: ("Profil"),
        activeColorPrimary: const Color(0xFF4CAF50),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: Colors.white, 
      handleAndroidBackButtonPress: true, 
      resizeToAvoidBottomInset: true, 
      stateManagement: true, 
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
        boxShadow: [
          const BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      navBarStyle: NavBarStyle.style3, 
    );
  }
}