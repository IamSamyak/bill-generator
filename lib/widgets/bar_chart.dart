import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> weeklyRevenue; // keys are like "2025-05-17"

  const BarChartWidget({super.key, required this.weeklyRevenue});

  String formatDayLabel(String yyyyMMdd) {
    try {
      DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(yyyyMMdd);
      return DateFormat('E d').format(parsedDate); // e.g. "Sat 17"
    } catch (e) {
      return yyyyMMdd;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<_RevenueData> data = weeklyRevenue.entries.map((entry) {
      return _RevenueData(entry.key, formatDayLabel(entry.key), entry.value);
    }).toList();

    data.sort((a, b) {
      DateTime aDate = DateFormat('yyyy-MM-dd').parse(a.dateKey);
      DateTime bDate = DateFormat('yyyy-MM-dd').parse(b.dateKey);
      return aDate.compareTo(bDate);
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0), // 👈 Add right padding here
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelRotation: 45,
            ),
            primaryYAxis: NumericAxis(
              numberFormat: NumberFormat.compact(),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<_RevenueData, String>(
                dataSource: data,
                xValueMapper: (_RevenueData revenue, _) => revenue.dayLabel,
                yValueMapper: (_RevenueData revenue, _) => revenue.revenue,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                color: const Color(0xFF1A66BE),
                width: 0.6,
                name: 'Revenue',
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getYearLabel(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getYearLabel() {
    Set<int> years = weeklyRevenue.keys
        .map((e) => int.parse(e.split('-')[0]))
        .toSet();

    if (years.length == 1) {
      return years.first.toString();
    } else {
      int minYear = years.reduce((a, b) => a < b ? a : b);
      int maxYear = years.reduce((a, b) => a > b ? a : b);
      return "$minYear–${maxYear % 100}";
    }
  }
}

class _RevenueData {
  final String dateKey;
  final String dayLabel;
  final double revenue;

  _RevenueData(this.dateKey, this.dayLabel, this.revenue);
}
