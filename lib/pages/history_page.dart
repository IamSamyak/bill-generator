import 'package:bill_generator/widgets/bill_list_history_page.dart';
import 'package:flutter/material.dart';
import 'package:bill_generator/services/bill_service.dart';
import 'package:intl/intl.dart'; // <-- Added for date formatting

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final BillService billService = BillService();

  Map<String, List<Map<String, dynamic>>> _bills = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndCategorizeBills();
  }

  Future<void> _fetchAndCategorizeBills() async {
    try {
      final bills = await billService.fetchBills();
      _categorizeBills(bills);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _categorizeBills(List<Map<String, dynamic>> bills) {
    Map<String, List<Map<String, dynamic>>> categorizedBills = {};

    for (var bill in bills) {
      DateTime billDate = DateTime.tryParse(bill['date']) ?? DateTime.now();
      String category = _getCategory(billDate);
      categorizedBills.putIfAbsent(category, () => []).add(bill);
    }

    setState(() {
      _bills = categorizedBills;
      _isLoading = false;
    });
  }

  String _getCategory(DateTime billDate) {
    return DateFormat('MMMM yyyy').format(billDate); // e.g., January 2024
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: _bills.isNotEmpty
                ? BillList(
                    bills: _bills,
                  )
                : const Center(child: Text("No bills available")),
          ),
        ],
      ),
    );
  }
}
