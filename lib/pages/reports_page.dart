import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatelessWidget {
  final List<Map<String, dynamic>> initialBills;

  const ReportsPage({super.key, required this.initialBills});

  Map<String, double> calculateMonthlyRevenue() {
    Map<String, double> revenue = {};
    for (var bill in initialBills) {
      DateTime date = DateTime.parse(bill['date']);
      String month = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      revenue[month] = (revenue[month] ?? 0) + bill['amount'];
    }
    return revenue;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> monthlyRevenue = calculateMonthlyRevenue();
    List<String> months = monthlyRevenue.keys.toList();

    double totalRevenue = monthlyRevenue.values.fold(0, (sum, amount) => sum + amount);
    double averageRevenue = monthlyRevenue.isNotEmpty ? totalRevenue / monthlyRevenue.length : 0;

    String maxRevenueMonth = months.isNotEmpty
        ? months[monthlyRevenue.values.toList().indexOf(monthlyRevenue.values.reduce((a, b) => a > b ? a : b))]
        : "N/A";

    String minRevenueMonth = months.isNotEmpty
        ? months[monthlyRevenue.values.toList().indexOf(monthlyRevenue.values.reduce((a, b) => a < b ? a : b))]
        : "N/A";

    double barWidth = months.length > 1 ? (300 / (months.length*1.1)) : 30;

    List<BarChartGroupData> barGroups = months
        .asMap()
        .entries
        .map((entry) => BarChartGroupData(
              x: entry.key,
              barsSpace: -1,
              barRods: [
                BarChartRodData(
                  toY: monthlyRevenue[entry.value]!,
                  color: Colors.yellow,
                  width: barWidth,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            ))
        .toList();

    return Column(
      children: [
        Padding(
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
        ),
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      "Revenue (₹)",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: true,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.5),
                          strokeWidth: 0.8,
                          dashArray: [5, 5],
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.5),
                          strokeWidth: 0.8,
                          dashArray: [5, 5],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text("₹${value.toInt()}", style: const TextStyle(fontSize: 12));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < months.length) {
                                return Text(months[value.toInt()], style: const TextStyle(fontSize: 12));
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(color: Colors.black, width: 1),
                          bottom: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      barGroups: barGroups,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Months",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
