import 'package:flutter/material.dart';
import '../constants.dart';

class AppDrawer extends StatelessWidget {
  final Function(String) onNavigate;

  const AppDrawer({super.key, required this.onNavigate});

  void _handleTap(BuildContext context, String page) {
    Navigator.pop(context); // Close the drawer
    onNavigate(page);       // Trigger navigation
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
              leading: const Icon(Icons.create_sharp),
              title: const Text('Update Categories'),
              onTap: () => _handleTap(context, 'UpdateCategories'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Update Bills'),
              onTap: () => _handleTap(context, 'UpdateBills'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Pending Bills'),
              onTap: () => _handleTap(context, 'History-Unpaid'),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('RangeSelector'),
              onTap: () => _handleTap(context, 'RangeSelector'),
            ),
          ],
        ),
      ),
    );
  }
}
