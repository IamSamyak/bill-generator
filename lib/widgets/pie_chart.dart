import 'package:bill_generator/models/Bill.dart';
import 'package:bill_generator/models/Category.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryPieChart extends StatelessWidget {
  final List<Category> allCategories; // all predefined categories
  final Map<String, double> dataMap; // data from calculateCategoryTotals

  const CategoryPieChart({
    Key? key,
    required this.allCategories,
    required this.dataMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_ChartData> chartData = allCategories.map((category) {
      final total = dataMap[category.label] ?? 0.0;
      return _ChartData(category, total);
    }).toList();

    return SizedBox(
      height: 300,
      child: SfCircularChart(
        legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.bottom,
          legendItemBuilder: (String name, dynamic series, dynamic point, int index) {
            final item = chartData[index].category;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.imagePath != null)
                    Image.asset(
                      item.imagePath!,
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => const Icon(Icons.category, size: 20),
                    )
                  else
                    const Icon(Icons.category, size: 20),
                  const SizedBox(width: 6),
                  Text(item.label, style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          },
        ),
        series: <CircularSeries<_ChartData, String>>[
          PieSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.category.label,
            yValueMapper: (_ChartData data, _) => data.total,
            // Remove the labels as text; use dataLabelMapper but hide text by returning empty string
            dataLabelMapper: (_ChartData data, _) => '',
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              // We'll show images as widgets inside the pie slices via builder
              labelPosition: ChartDataLabelPosition.inside,
              // Set builder to custom widget for image display
              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                final category = chartData[pointIndex].category;
                if (category.imagePath != null) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      category.imagePath!,
                      width: 30,
                      height: 30,
                      errorBuilder: (_, __, ___) => const Icon(Icons.category, color: Colors.white),
                    ),
                  );
                } else {
                  // Fallback icon if no imagePath
                  return const Icon(Icons.category, color: Colors.white, size: 30);
                }
              },
            ),
            // Remove slice border by setting borderWidth=0 or borderColor transparent
            strokeWidth: 0,
            pointColorMapper: (_ChartData data, int index) => _getColor(index),
            radius: '70%',
          ),
        ],
      ),
    );
  }

  Color _getColor(int index) {
    const List<Color> colorPalette = [
      Color(0xFFEF5350), // Red
      Color(0xFFAB47BC), // Purple
      Color(0xFF42A5F5), // Blue
      Color(0xFF26A69A), // Teal
      Color(0xFFFFCA28), // Yellow
      Color(0xFF8D6E63), // Brown
      Color(0xFF78909C), // Blue Grey
      Color(0xFF66BB6A), // Green
      Color(0xFFEC407A), // Pink
      Color(0xFFFF7043), // Deep Orange
    ];
    return colorPalette[index % colorPalette.length];
  }
}

class _ChartData {
  final Category category;
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
