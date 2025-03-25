import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onCreateBill;

  const HomePage({super.key, required this.onCreateBill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSquareButton(Icons.receipt_long, 'Create Bill', onCreateBill),
          _buildSquareButton(Icons.payment, "Today's Collections", () {}),
          _buildSquareButton(Icons.edit, 'Edit Details', () {}),
          _buildSquareButton(Icons.report, 'Reports', () {}),
          _buildSquareButton(Icons.history, 'History', () {}),
        ],
      ),
    );
  }

  Widget _buildSquareButton(IconData icon, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.blueAccent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
