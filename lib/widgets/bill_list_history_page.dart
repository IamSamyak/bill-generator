import 'package:bill_generator/widgets/bill_item_history_page.dart';
import 'package:flutter/material.dart';
import '../models/Bill.dart';

class BillList extends StatelessWidget {
  final Map<String, List<Bill>> bills;

  const BillList({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bills.entries.map((entry) {
        List<Bill> billList = entry.value;

        if (billList.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Column(
              children: billList
                  .map((bill) => BillItemWidget(bill: bill))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}
