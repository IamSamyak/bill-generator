import 'package:flutter/material.dart';

class GraphDescription extends StatelessWidget {
  const GraphDescription({
    super.key,
    required this.totalRevenue,
  });

  final double totalRevenue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Makes children take full width
        children: [
          _simpleCard(
            title: "Total Revenue",
            value: "₹${totalRevenue.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _simpleCard(
                  title: "Total Bills",
                  value: "120", // Dummy value
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _simpleCard(
                  title: "Pending",
                  value: "25", // Dummy value
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simpleCard({
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 1, // Low shadow
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
