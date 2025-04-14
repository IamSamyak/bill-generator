import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Function(String) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return _buildCompactCard(
            item['icon'] as IconData,
            item['title'] as String,
            item['route'] as String,
          );
        },
      ),
    );
  }

  Widget _buildCompactCard(IconData icon, String title, String route) {
    return GestureDetector(
      onTap: () => onNavigate(route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFFc1dff6), // Light blue background
              child: Icon(
                icon,
                size: 24,
                color: Color(0xFF4ca7e4), // Blue icon color
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Menu items data
final _menuItems = [
  {'icon': Icons.receipt_long, 'title': 'Create Bill', 'route': 'CreateBill'},
  {'icon': Icons.print, 'title': 'Connect', 'route': 'Connect'},
  {'icon': Icons.category, 'title': 'Add Categories', 'route': 'Categories'},
  {'icon': Icons.share, 'title': 'Share Products', 'route': 'Share-Media'},
];
