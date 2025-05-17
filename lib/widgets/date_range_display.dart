import 'package:bill_generator/widgets/pie_chart.dart';
import 'package:bill_generator/widgets/range_reports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bill_generator/models/Bill.dart';
import 'package:bill_generator/models/Category.dart';
import 'package:bill_generator/services/category_service.dart';

class DateRangeDisplay extends StatelessWidget {
  final DateTimeRange selectedRange;
  final List<Bill> filteredBills;
  final VoidCallback onPickDateRange;

  const DateRangeDisplay({
    Key? key,
    required this.selectedRange,
    required this.filteredBills,
    required this.onPickDateRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    final totalRevenue = filteredBills.fold<double>(
      0.0,
      (sum, bill) => sum + bill.amount,
    );

    final billsPaid = filteredBills
        .where((bill) => bill.payStatus.toLowerCase() == 'paid')
        .length;

    final unpaidBills = filteredBills.length - billsPaid;

    // Get all predefined categories
    final List<Category> availableCategories =
        CategoryService().getCategories();

    // Map to hold sales data for each category
    final Map<Category, Map<String, dynamic>> soldItemsMap = {
      for (var category in availableCategories)
        category: {'quantity': 0, 'total': 0.0},
    };

    // Populate map with actual sold data
    for (var bill in filteredBills) {
      for (var item in bill.purchaseList) {
        final matchingCategory = availableCategories.firstWhere(
          (cat) => cat.label.toLowerCase() == item.productName.toLowerCase(),
          orElse: () => Category(label: item.productName),
        );

        // If not already added (non-predefined), initialize
        soldItemsMap.putIfAbsent(matchingCategory, () => {
              'quantity': 0,
              'total': 0.0,
            });

        soldItemsMap[matchingCategory]!['quantity'] += item.quantity;
        soldItemsMap[matchingCategory]!['total'] += item.total;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildDateBox(
                  label: 'Start Date',
                  date: dateFormat.format(selectedRange.start),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildDateBox(
                  label: 'End Date',
                  date: dateFormat.format(selectedRange.end),
                ),
              ),
            ],
          ),
          CategoryPieChart(dataMap: calculateCategoryTotals(filteredBills)),
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton(
              onPressed: onPickDateRange,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1864BF)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "SELECT DATE RANGE",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1864BF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sales Report',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          buildReportItem(
            'Total Revenue',
            '₹${totalRevenue.toStringAsFixed(2)}',
          ),
          buildReportItem('Bills Paid', billsPaid.toString()),
          buildReportItem('Unpaid Bills', unpaidBills.toString()),
          const SizedBox(height: 16),
          const Text(
            'Sold Items',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...soldItemsMap.entries.map(
            (entry) => buildSoldItem(
              entry.key,
              entry.value['quantity'],
              entry.value['total'],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateBox({required String label, required String date}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue.shade50,
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.blue)),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
