import 'package:flutter/material.dart';
import 'package:bill_generator/widgets/line_chart.dart';
import 'package:bill_generator/widgets/bar_chart.dart';
import 'package:bill_generator/widgets/graph_description.dart';

class ReportsPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialBills;

  const ReportsPage({super.key, required this.initialBills});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String selectedChartType = "Bar Chart";

  Map<String, double> calculateMonthlyRevenue() {
    Map<String, double> revenue = {};
    for (var bill in widget.initialBills) {
      DateTime date = DateTime.parse(bill['date']);
      String month = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      revenue[month] = (revenue[month] ?? 0) + bill['amount'];
    }
    return revenue;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> monthlyRevenue = calculateMonthlyRevenue();
    double totalRevenue = monthlyRevenue.values.fold(0, (sum, amount) => sum + amount);
    double averageRevenue = monthlyRevenue.isNotEmpty ? totalRevenue / monthlyRevenue.length : 0;

    String maxRevenueMonth = monthlyRevenue.isNotEmpty
        ? monthlyRevenue.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : "N/A";
    String minRevenueMonth = monthlyRevenue.isNotEmpty
        ? monthlyRevenue.entries.reduce((a, b) => a.value < b.value ? a : b).key
        : "N/A";

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Reports",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: selectedChartType,
                onChanged: (value) {
                  setState(() {
                    selectedChartType = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: "Bar Chart", child: Text("Bar Chart")),
                  DropdownMenuItem(value: "Line Chart", child: Text("Line Chart")),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedChartType == "Bar Chart"
              ? BarChartWidget(monthlyRevenue: monthlyRevenue)
              : LineChartWidget(monthlyRevenue: monthlyRevenue),
        ),
        graph_description(totalRevenue: totalRevenue, maxRevenueMonth: maxRevenueMonth, minRevenueMonth: minRevenueMonth, averageRevenue: averageRevenue),
      ],
    );
  }
}
