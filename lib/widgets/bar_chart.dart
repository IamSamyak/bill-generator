import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
    List<_RevenueData> data = monthlyRevenue.entries.map((entry) {
      return _RevenueData(formatMonthName(entry.key), entry.value);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
            numberFormat: NumberFormat.compact(), // e.g., 2.5k
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            ColumnSeries<_RevenueData, String>(
              dataSource: data,
              xValueMapper: (_RevenueData revenue, _) => revenue.month,
              yValueMapper: (_RevenueData revenue, _) => revenue.revenue,
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              color: const Color(0xFF1A66BE),
              width: 0.6,
              name: 'Revenue',
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
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
    Set<int> years =
        monthlyRevenue.keys.map((e) => int.parse(e.split('-')[0])).toSet();

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
  final String month;
  final double revenue;

  _RevenueData(this.month, this.revenue);
}
