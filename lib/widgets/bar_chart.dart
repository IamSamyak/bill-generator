import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> monthlyRevenue;

  const BarChartWidget({super.key, required this.monthlyRevenue});

  // Format date using intl
  String formatMonthName(String yyyyMM) {
    try {
      DateTime parsedDate = DateFormat('yyyy-MM').parse(yyyyMM);
      return DateFormat('MMM').format(parsedDate); // e.g., Jan, Feb
    } catch (e) {
      return yyyyMM;
    }
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
    minY = minY > 0 ? 0 : (minY ~/ interval) * interval;
    maxY = ((maxY / interval).ceil()) * interval;

    List<BarChartGroupData> barGroups = reversedMonths.asMap().entries.map(
      (entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: monthlyRevenue[entry.value]!,
              color: const Color(0xFF1A66BE), // Custom color
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              width: 24,
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  );
                },
                checkToShowHorizontalLine: (value) => true,
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: const Color.fromARGB(255, 14, 14, 14),
                    strokeWidth: 0.5,
                  ),
                ],
              ),
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
                        String label = formatMonthName(reversedMonths[value.toInt()]);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            label,
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
