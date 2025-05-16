import 'package:bill_generator/models/Bill.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> dataMap;

  const CategoryPieChart({Key? key, required this.dataMap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert the dataMap into a list of ChartData for Syncfusion chart
    final List<_ChartData> chartData = dataMap.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();

    return SizedBox(
      height: 300,
      child: SfCircularChart(
        legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.bottom,
        ),
        series: <CircularSeries<_ChartData, String>>[
          PieSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.total,
            dataLabelMapper: (_ChartData data, _) => data.category,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.inside,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            radius: '70%',
          ),
        ],
        // Optionally customize center space
        // center space equivalent is "innerRadius" here
        // Set innerRadius > 0 to get donut chart style
        // innerRadius: '40%',
      ),
    );
  }
}

// Helper class for chart data
class _ChartData {
  final String category;
  final double total;

  _ChartData(this.category, this.total);
}

// Your existing function for calculating totals remains the same
Map<String, double> calculateCategoryTotals(List<Bill> bills) {
  final Map<String, double> categoryTotals = {};
  for (final bill in bills) {
    for (final item in bill.purchaseList) {
      categoryTotals.update(item.productCategory, (value) => value + item.total,
          ifAbsent: () => item.total);
    }
  }
  return categoryTotals;
}
