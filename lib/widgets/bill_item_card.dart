import 'package:flutter/material.dart';

class BillItemCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> item;

  const BillItemCard({Key? key, required this.index, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${index + 1}. ${item["type"]}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("Qty: ${item["quantity"]}", style: const TextStyle(fontSize: 12)),
            Text("Price: ₹${item["price"]}", style: const TextStyle(fontSize: 12, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
