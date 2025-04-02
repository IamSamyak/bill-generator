import 'package:bill_generator/widgets/bill_item_history_page.dart';
import 'package:flutter/material.dart';

class BillList extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> bills;
  final String selectedFilter;
  final bool isDescending;

  const BillList({super.key, required this.bills, required this.selectedFilter, required this.isDescending});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: bills.entries.map((entry) {
        List<Map<String, dynamic>> filteredBills = entry.value
            .where((bill) => selectedFilter == 'All' || bill['status'] == selectedFilter)
            .toList()
          ..sort((a, b) => isDescending ? DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])) : DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

        if (filteredBills.isEmpty) return Container();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.key, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Column(children: filteredBills.map((bill) => BillItemWidget(bill: bill)).toList()),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}
