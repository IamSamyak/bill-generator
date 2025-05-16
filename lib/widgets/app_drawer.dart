import 'package:flutter/material.dart';

const Color kMainColor = Color(0xFF1A66BE);

class AppDrawer extends StatelessWidget {
  final Function(String) onNavigate;

  const AppDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // <-- Force background to be white
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 91,
              color: kMainColor,
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
              onTap: () => onNavigate('UpdateCategories'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Update Bills'),
              onTap: () => onNavigate('UpdateBills'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Pending Bills'),
              onTap: () => onNavigate('History-Unpaid'),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('RangeSelector'),
              onTap: () => onNavigate('RangeSelector'),
            ),
          ],
        ),
      ),
    );
  }
}
