import 'package:bill_generator/models/Category.dart';
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

Widget buildSoldItem(Category category, int quantity, double price) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (category.imagePath != null && category.imagePath!.isNotEmpty)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: AssetImage(category.imagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Text(
              category.label,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        Text(
          'Qty: $quantity  |  ₹${price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

