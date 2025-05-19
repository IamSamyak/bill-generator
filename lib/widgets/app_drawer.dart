import 'package:flutter/material.dart';
import '../constants.dart';

class AppDrawer extends StatelessWidget {
  final Function(String) onNavigate;

  const AppDrawer({super.key, required this.onNavigate});

  void _handleTap(BuildContext context, String page) {
    Navigator.pop(context); // Close the drawer
    onNavigate(page); // Trigger navigation
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 91,
              color: primaryColor,
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text(
                'Home',
              ), // For Home
              onTap: () => _handleTap(context, 'Home'),
            ),
            
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text(
                'Categories',
              ), // For adding/editing clothing categories
              onTap: () => _handleTap(context, 'UpdateCategories'),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Bill'), // For updating bill by receipt ID
              onTap: () => _handleTap(context, 'UpdateBills'),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Unpaid Bills'), // For unpaid customer bills
              onTap: () => _handleTap(context, 'History-Unpaid'),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Analytics'), // For analytics by date range
              onTap: () => _handleTap(context, 'Analytics'),
            ),
          ],
        ),
      ),
    );
  }
}
