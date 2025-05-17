import 'package:flutter/material.dart';

class GraphDescription extends StatelessWidget {
  const GraphDescription({
    super.key,
    required this.totalRevenue,
    required this.totalPaidBills,
    required this.pendingBills,
  });

  final double totalRevenue;
  final int totalPaidBills;
  final int pendingBills;

  static const Color customTextColor = Color(0xFF374151); // Custom font color

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  title: "Paid Bills",
                  value: totalPaidBills.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _simpleCard(
                  title: "Unpaid Bills",
                  value: pendingBills.toString(),
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
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: customTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: customTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
