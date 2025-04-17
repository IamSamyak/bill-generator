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
            Icons.menu,
            size: selectedIndex == 3 ? 30 : 24,
          ),
          label: 'Menu',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: kMainColor,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: onItemTapped,
    );
  }
}
