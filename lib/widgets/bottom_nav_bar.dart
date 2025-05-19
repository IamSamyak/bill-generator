import 'package:flutter/material.dart';
import '../constants.dart'; // Import the constants

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_rounded,
            size: selectedIndex == 0 ? 30 : 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.history,
            size: selectedIndex == 1 ? 30 : 24,
          ),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.bar_chart_rounded,
            size: selectedIndex == 2 ? 30 : 24,
          ),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.account_circle_rounded,
            size: selectedIndex == 3 ? 30 : 24,
          ),
          label: 'Info',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: bottomNavigationBarUnselectedColor,
      selectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        // Note: color is ignored for unselectedLabelStyle in BottomNavigationBar
      ),
      onTap: onItemTapped,
    );
  }
}
