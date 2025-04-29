import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueDateRangeSelector extends StatefulWidget {
  const RevenueDateRangeSelector({super.key});

  @override
  State<RevenueDateRangeSelector> createState() => _RevenueDateRangeSelectorState();
}

class _RevenueDateRangeSelectorState extends State<RevenueDateRangeSelector> {
  DateTimeRange? selectedRange;

  final List<Map<String, dynamic>> dummyRevenueData = [
    {'date': DateTime(2025, 4, 20), 'revenue': 1200},
    {'date': DateTime(2025, 4, 21), 'revenue': 1500},
    {'date': DateTime(2025, 4, 22), 'revenue': 800},
    {'date': DateTime(2025, 4, 23), 'revenue': 900},
    {'date': DateTime(2025, 4, 24), 'revenue': 2000},
    {'date': DateTime(2025, 4, 25), 'revenue': 1800},
  ];

  List<Map<String, dynamic>> get filteredData {
    if (selectedRange == null) return [];
    return dummyRevenueData.where((item) {
      return item['date'].isAfter(selectedRange!.start.subtract(const Duration(days: 1))) &&
          item['date'].isBefore(selectedRange!.end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      initialDateRange: selectedRange,
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickDateRange,
          child: Text(selectedRange == null
              ? 'Select Date Range'
              : '${DateFormat('yyyy-MM-dd').format(selectedRange!.start)} to ${DateFormat('yyyy-MM-dd').format(selectedRange!.end)}'),
        ),
        const SizedBox(height: 16),
        if (filteredData.isEmpty)
          const Text('No data available for selected range.')
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                return ListTile(
                  title: Text(DateFormat('yyyy-MM-dd').format(item['date'])),
                  trailing: Text('\$${item['revenue']}'),
                );
              },
            ),
          ),
      ],
    );
  }
}
