import 'package:flutter/material.dart';

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
    const Color kMainColor = Color(0xFF1A66BE);
    const Color customTextColor = Color(0xFF374151); // Font color for unselected items

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
      selectedItemColor: kMainColor,
      unselectedItemColor: customTextColor, // Apply the font color here
      selectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: customTextColor, // Flutter will ignore this for BottomNavigationBar
      ),
      onTap: onItemTapped,
    );
  }
}
