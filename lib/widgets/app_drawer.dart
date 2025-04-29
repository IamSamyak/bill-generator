import 'package:flutter/material.dart';

const Color kMainColor = Color(0xFF1A66BE);

class AppDrawer extends StatelessWidget {
  final Function(String) onNavigate;

  const AppDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Custom header with reduced height
          Container(
            height: 100,
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
          // Newly added options placed above
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => onNavigate('Home'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () => onNavigate('History'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () => onNavigate('Reports'),
          ),
          ListTile(
            leading: const Icon(Icons.menu),
            title: const Text('Edit Details'),
            onTap: () => onNavigate('EditDetails'),
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Share Media'),
            onTap: () => onNavigate('Share-Media'),
          ),
        ],
      ),
    );
  }
}
