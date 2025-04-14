import 'package:flutter/material.dart';

class GraphDescription extends StatelessWidget {
  const GraphDescription({
    super.key,
    required this.totalRevenue,
    required this.maxRevenueMonth,
    required this.minRevenueMonth,
    required this.averageRevenue,
    required this.currentMonthRevenue,
    required this.avgPreviousRevenue,
  });

  final double totalRevenue;
  final String maxRevenueMonth;
  final String minRevenueMonth;
  final double averageRevenue;
  final double currentMonthRevenue;
  final double avgPreviousRevenue;

  @override
  Widget build(BuildContext context) {
    double percentageAchieved = avgPreviousRevenue > 0
        ? ((currentMonthRevenue + 200) / avgPreviousRevenue).clamp(0.0, 2.0)
        : 0.0;

    return SingleChildScrollView( // Allow the whole GraphDescription to be scrollable
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: (percentageAchieved > 1.0 ? 1.0 : percentageAchieved),
                          strokeWidth: 8,
                          backgroundColor: Colors.blue.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      Text(
                        "${(percentageAchieved * 100).clamp(0, 999).toStringAsFixed(1)}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Current Month Performance",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${currentMonthRevenue.toStringAsFixed(2)} collected\nAvg Prev. Months: ₹${avgPreviousRevenue.toStringAsFixed(2)}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _infoCard(
            icon: Icons.monetization_on,
            title: "Total Revenue",
            value: "₹${totalRevenue.toStringAsFixed(2)}",
            color: Colors.green,
          ),
          _infoCard(
            icon: Icons.trending_up,
            title: "Max Revenue Month",
            value: maxRevenueMonth,
            color: Colors.blue,
          ),
          _infoCard(
            icon: Icons.trending_down,
            title: "Least Revenue Month",
            value: minRevenueMonth,
            color: Colors.red,
          ),
          _infoCard(
            icon: Icons.calculate,
            title: "Average Revenue",
            value: "₹${averageRevenue.toStringAsFixed(2)}",
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
