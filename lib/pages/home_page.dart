import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onCreateBill;

  const HomePage({super.key, required this.onCreateBill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.count(
        crossAxisCount: 3, // Three items per row
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildElevatedButton(Icons.receipt_long, 'Create Bill', onCreateBill),
          _buildElevatedButton(Icons.payment, "Today's Collections", () {}),
          _buildElevatedButton(Icons.edit, 'Edit Details', () {}),
          _buildElevatedButton(Icons.report, 'Reports', () {}),
          _buildElevatedButton(Icons.history, 'History', () {}),
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
        elevation: 5, // Added elevation for the elevated effect
        backgroundColor: Colors.white, // White background
        foregroundColor: Colors.black, // Black text and icon
        shadowColor: Colors.grey.withOpacity(0.5), // Soft shadow effect
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Colors.black), // Black icon
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
