import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MenuOption(
            icon: Icons.category,
            label: 'Categories',
            onTap: () {
              // Add your navigation logic for Categories here
            },
          ),
          MenuOption(
            icon: Icons.add,
            label: 'Add Categories',
            onTap: () {
              // Add your navigation logic for Add Categories here
            },
          ),
          MenuOption(
            icon: Icons.shopping_cart,
            label: 'Shop Now',
            onTap: () {
              // Add your navigation logic for Shop Now here
            },
          ),
          MenuOption(
            icon: Icons.account_circle,
            label: 'Profile',
            onTap: () {
              // Add your navigation logic for Profile here
            },
          ),
          MenuOption(
            icon: Icons.logout,
            label: 'Log Out',
            onTap: () {
              // Add your log-out logic here
            },
          ),
        ],
      ),
    );
  }
}

class MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function onTap;

  MenuOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(icon, color: Colors.black),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
