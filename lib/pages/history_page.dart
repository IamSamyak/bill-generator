import 'dart:convert';
import 'package:bill_generator/widgets/bill_list_history_page.dart';
import 'package:bill_generator/widgets/filter_row_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bill_generator/services/bill_service.dart'; // Import the BillService

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final BillService billService = BillService(); // Create an instance of BillService

  String _selectedFilter = 'All';
  bool _isDescending = true;
  Map<String, List<Map<String, dynamic>>> _bills = {};
  final List<String> _filters = ['All', 'Paid', 'Unpaid'];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndCategorizeBills();
  }

  Future<void> _fetchAndCategorizeBills() async {
    try {
      final bills = await billService.fetchBills(); // Fetch bills using the service
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
    return '${_getMonthName(billDate.month)} ${billDate.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return monthNames[month - 1];
  }

  void _toggleSortOrder() => setState(() => _isDescending = !_isDescending);

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
          FilterRow(
            filters: _filters,
            selectedFilter: _selectedFilter,
            onFilterSelected:
                (filter) => setState(() => _selectedFilter = filter),
            isDescending: _isDescending,
            onSortToggle: _toggleSortOrder,
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _bills.isNotEmpty
                    ? BillList(
                      bills: _bills,
                      selectedFilter: _selectedFilter,
                      isDescending: _isDescending,
                    )
                    : const Center(child: Text("No bills available")),
          ),
        ],
      ),
    );
  }
}
