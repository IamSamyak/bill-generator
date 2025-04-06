import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> monthlyRevenue;

  const BarChartWidget({super.key, required this.monthlyRevenue});

  // Month map without using intl
  String getMonthShortName(String monthNum) {
    const monthMap = {
      '01': 'Jan',
      '02': 'Feb',
      '03': 'Mar',
      '04': 'Apr',
      '05': 'May',
      '06': 'Jun',
      '07': 'Jul',
      '08': 'Aug',
      '09': 'Sep',
      '10': 'Oct',
      '11': 'Nov',
      '12': 'Dec',
    };
    return monthMap[monthNum] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    List<String> months = monthlyRevenue.keys.toList();
    List<String> reversedMonths = months.reversed.toList();

    // Extract years from the keys
    Set<int> years = months.map((e) => int.parse(e.split('-')[0])).toSet();

    // Determine the year label
    String yearLabel;
    if (years.length == 1) {
      yearLabel = years.first.toString();
    } else {
      int minYear = years.reduce((a, b) => a < b ? a : b);
      int maxYear = years.reduce((a, b) => a > b ? a : b);
      yearLabel = "$minYear–${maxYear % 100}";
    }

    // Calculate minY and maxY
    double minY = monthlyRevenue.values.reduce((a, b) => a < b ? a : b);
    double maxY = monthlyRevenue.values.reduce((a, b) => a > b ? a : b);

    // Adjust to nearest 1000 for cleaner axis
    double interval = 1000;
    minY = (minY ~/ interval) * interval;
    maxY = ((maxY / interval).ceil()) * interval;

    List<BarChartGroupData> barGroups = reversedMonths.asMap().entries.map(
      (entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: monthlyRevenue[entry.value]!,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(6),
              width: 16,
            ),
          ],
        );
      },
    ).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(show: true,drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      return Text("₹${value.toInt()}",
                          style: const TextStyle(fontSize: 12));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < reversedMonths.length) {
                        String raw = reversedMonths[value.toInt()];
                        List<String> parts = raw.split('-');
                        String monthName = getMonthShortName(parts[1]);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            monthName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
        Text(
          yearLabel,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
