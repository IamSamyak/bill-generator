import 'package:flutter/material.dart';

Widget buildReportItem(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget buildSoldItem(String itemName, int quantity, int price) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(itemName, style: const TextStyle(fontSize: 15)),
        Text(
          'Qty: $quantity  |  \$${price.toString()}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}
