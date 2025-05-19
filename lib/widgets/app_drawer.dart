import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              title: const Text('Home'), // For Home
              onTap: () => _handleTap(context, 'Home'),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/svgs/category.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  bottomNavigationBarUnselectedColor,
                  BlendMode.srcIn,
                ),
              ),
              title: const Text('Categories'),
              onTap: () => _handleTap(context, 'UpdateCategories'),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/svgs/edit.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  bottomNavigationBarUnselectedColor,
                  BlendMode.srcIn,
                ),
              ),
              title: const Text('Edit Bill'),
              onTap: () => _handleTap(context, 'UpdateBills'),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Unpaid Bills'),
              onTap: () => _handleTap(context, 'History-Unpaid'),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/svgs/pie_chart.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  bottomNavigationBarUnselectedColor,
                  BlendMode.srcIn,
                ),
              ),
              title: const Text('Analytics'),
              onTap: () => _handleTap(context, 'Analytics'),
            ),
          ],
        ),
      ),
    );
  }
}
