import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> monthlyRevenue;

  const BarChartWidget({super.key, required this.monthlyRevenue});

  @override
  Widget build(BuildContext context) {
    List<String> months = monthlyRevenue.keys.toList();
    List<String> reversedMonths = months.reversed.toList(); // Reverse month order
    double barWidth = months.length > 1 ? (300 / (months.length * 1.2)) : 30;

    List<BarChartGroupData> barGroups = reversedMonths.asMap().entries.map(
      (entry) {
        return BarChartGroupData(
          x: entry.key,
          barsSpace: -1,
          barRods: [
            BarChartRodData(
              toY: monthlyRevenue[entry.value]!,
              color: Colors.blue,
              width: barWidth,
              borderRadius: BorderRadius.zero,
            ),
          ],
        );
      },
    ).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: false),
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
          barGroups: barGroups,
        ),
      ),
    );
  }
}
