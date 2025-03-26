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
          color: Colors.white, // ✅ Consistent white card background
          surfaceTintColor: Colors.white, // ✅ Prevent unwanted tint on some devices
          elevation: 3, // ✅ Slight elevation for depth
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${index + 1}. ${item["type"]}",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  "Qty: ${item["quantity"]}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  "Price: ₹${item["price"]}",
                  style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
