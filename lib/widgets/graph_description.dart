import 'package:flutter/material.dart';

class graph_description extends StatelessWidget {
  const graph_description({
    super.key,
    required this.totalRevenue,
    required this.maxRevenueMonth,
    required this.minRevenueMonth,
    required this.averageRevenue,
  });

  final double totalRevenue;
  final String maxRevenueMonth;
  final String minRevenueMonth;
  final double averageRevenue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.monetization_on, color: Colors.green),
            title: const Text("Total Revenue"),
            trailing: Text("₹${totalRevenue.toStringAsFixed(2)}"),
          ),
          ListTile(
            leading: const Icon(Icons.trending_up, color: Colors.blue),
            title: const Text("Max Revenue Month"),
            trailing: Text(maxRevenueMonth),
          ),
          ListTile(
            leading: const Icon(Icons.trending_down, color: Colors.red),
            title: const Text("Least Revenue Month"),
            trailing: Text(minRevenueMonth),
          ),
          ListTile(
            leading: const Icon(Icons.calculate, color: Colors.orange),
            title: const Text("Average Revenue"),
            trailing: Text("₹${averageRevenue.toStringAsFixed(2)}"),
          ),
        ],
      ),
    );
  }
}

