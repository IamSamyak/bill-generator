import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  final Map<String, double> monthlyRevenue;

  const LineChartWidget({super.key, required this.monthlyRevenue});

  @override
  Widget build(BuildContext context) {
    List<String> months = monthlyRevenue.keys.toList();
    List<FlSpot> spots = [];

    // Reverse the order of months for left-to-right flow
    List<String> reversedMonths = months.reversed.toList();

    for (int i = 0; i < reversedMonths.length; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyRevenue[reversedMonths[i]]!));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) =>
                  Text("₹${value.toInt()}", style: const TextStyle(fontSize: 12)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < reversedMonths.length) {
                  return Text(reversedMonths[value.toInt()], style: const TextStyle(fontSize: 12));
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Colors.black, width: 1),
            bottom: BorderSide(color: Colors.black, width: 1),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 4,
            color: Colors.blue,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true),
          ),
        ],
      ),
    );
  }
}
