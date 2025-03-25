import 'package:flutter/material.dart';

class OrderList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const OrderList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        var item = items[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${index + 1}. ${item["type"]}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text("Qty: ${item["quantity"]}", style: TextStyle(fontSize: 12)),
                Text("Price: ₹${item["price"]}", style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ),
        );
      },
    );
  }
}
