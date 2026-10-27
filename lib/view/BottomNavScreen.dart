import 'package:amarislam/view/DashboardScreen.dart';
import 'package:amarislam/view/ExploreScreen.dart';
import 'package:amarislam/view/SettingsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'quran/QuranScreen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {

  int currentIndex = 0;

  final List<Widget> pages = const [
    DashboardScreen(),
    QuranScreen(),
    ExploreScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: const Color(0xFFDDDDDD),
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: "Quran",
          ),
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: "Explore",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
