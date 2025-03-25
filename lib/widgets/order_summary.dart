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
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Amount:", style: TextStyle(fontSize: 14)),
                Text("₹${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Discount (10%):", style: TextStyle(fontSize: 14, color: Colors.red)),
                Text("- ₹${discount.toStringAsFixed(2)}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Final Amount:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                Text("₹${finalAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
