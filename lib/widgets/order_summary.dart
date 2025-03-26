import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  final double total;
  final double discount;
  final double finalAmount;

  const OrderSummary({
    Key? key,
    required this.total,
    required this.discount,
    required this.finalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // ✅ Consistent card background
      surfaceTintColor: Colors.white, // ✅ Avoid tint issues
      elevation: 3, // ✅ Subtle elevation for depth
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const Divider(thickness: 1.2), // ✅ Slightly thicker divider for clarity
            _buildSummaryRow("Total Amount:", "₹${total.toStringAsFixed(2)}", Colors.black, FontWeight.bold),
            const SizedBox(height: 5),
            _buildSummaryRow("Discount (10%):", "- ₹${discount.toStringAsFixed(2)}", Colors.red, FontWeight.bold),
            const SizedBox(height: 5),
            _buildSummaryRow("Final Amount:", "₹${finalAmount.toStringAsFixed(2)}", Colors.green, FontWeight.bold),
          ],
        ),
      ),
    );
  }

  /// 🔹 Helper function to keep the code cleaner
  Widget _buildSummaryRow(String label, String value, Color textColor, FontWeight fontWeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: fontWeight, color: textColor)),
      ],
    );
  }
}
