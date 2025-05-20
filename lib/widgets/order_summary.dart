import 'package:bill_generator/models/Bill.dart';
import 'package:bill_generator/services/bill_summary.dart';
import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  final List<PurchaseItem> purchases;

  const OrderSummary({Key? key, required this.purchases}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final billSummary = BillSummary.fromPurchases(purchases);

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 3,
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
            const Divider(thickness: 1.2),
            _buildSummaryRow("Total Amount:", "₹${billSummary.subtotal.toStringAsFixed(2)}", Colors.black, FontWeight.bold),
            const SizedBox(height: 5),
            _buildSummaryRow("Total Discount:", "- ₹${billSummary.totalDiscount.toStringAsFixed(2)}", Colors.red, FontWeight.bold),
            const SizedBox(height: 5),
            _buildSummaryRow("Final Amount:", "₹${billSummary.netAmount.toStringAsFixed(2)}", Colors.green, FontWeight.bold),
          ],
        ),
      ),
    );
  }

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
