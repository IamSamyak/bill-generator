import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  final Function(String) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildElevatedButton(Icons.receipt_long, 'Create Bill', () => onNavigate('CreateBill')),
          _buildElevatedButton(Icons.payment, "Today's Collections", () {}),
          _buildElevatedButton(Icons.edit, 'Edit Details', () => onNavigate('EditDetails')),
          _buildElevatedButton(Icons.report, 'Reports', () => onNavigate('Reports')),
          _buildElevatedButton(Icons.history, 'History', () => onNavigate('History')),
          _buildElevatedButton(Icons.print, 'Connect', () => onNavigate('Connect')),
        ],
      ),
    );
  }

  Widget _buildElevatedButton(IconData icon, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(10),
        elevation: 5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Colors.black),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(color: Colors.black, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
