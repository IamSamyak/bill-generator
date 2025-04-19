import 'package:bill_generator/widgets/bill_item_history_page.dart';
import 'package:flutter/material.dart';

class BillList extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> bills;

  const BillList({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: bills.entries.map((entry) {
        List<Map<String, dynamic>> billList = entry.value;

        if (billList.isEmpty) return Container();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.key, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Column(
              children: billList.map((bill) => BillItemWidget(bill: bill)).toList(),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}
