import 'package:bill_generator/models/Bill.dart';
import 'package:bill_generator/widgets/bill_list_history_page.dart';
import 'package:flutter/material.dart';
import 'package:bill_generator/services/bill_service.dart';
import 'package:intl/intl.dart'; 

class HistoryPage extends StatefulWidget {
  String payStatusParam;
  HistoryPage({super.key, required this.payStatusParam});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final BillService billService = BillService();

  Map<String, List<Bill>> _bills = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndCategorizeBills();
  }

  Future<void> _fetchAndCategorizeBills() async {
    try {
      final List<Bill> bills = await billService.fetchBills(
        payStatusFilter: widget.payStatusParam,
      );
      _categorizeBills(bills);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

 void _categorizeBills(List<Bill> bills) {
  Map<String, List<Bill>> categorizedBills = {};

  for (var bill in bills) {
    DateTime billDate = bill.date;
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
            child:
                _bills.isNotEmpty
                    ? BillList(bills: _bills)
                    : const Center(child: Text("No bills available")),
          ),
        ],
      ),
    );
  }
}
