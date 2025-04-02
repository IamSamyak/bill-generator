import 'package:bill_generator/widgets/bill_list_history_page.dart';
import 'package:bill_generator/widgets/filter_row_history_page.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialBills;

  const HistoryPage({
    super.key,
    required this.initialBills,
  });

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';
  bool _isDescending = true;
  Map<String, List<Map<String, dynamic>>> _bills = {};

  final List<String> _filters = ['All', 'Paid', 'Unpaid'];

  @override
  void initState() {
    super.initState();
    _categorizeBills();
  }

  void _categorizeBills() {
    Map<String, List<Map<String, dynamic>>> categorizedBills = {};
    DateTime now = DateTime.now();
    int currentMonth = now.month, currentYear = now.year;
    int lastMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    int lastYear = currentMonth == 1 ? currentYear - 1 : currentYear;

    for (var bill in widget.initialBills) {
      DateTime billDate = DateTime.parse(bill['date']);
      String category = _getCategory(billDate, currentMonth, currentYear, lastMonth, lastYear);
      categorizedBills.putIfAbsent(category, () => []).add(bill);
    }

    setState(() => _bills = categorizedBills);
  }

  String _getCategory(DateTime billDate, int currentMonth, int currentYear, int lastMonth, int lastYear) {
    if (billDate.month == currentMonth && billDate.year == currentYear) return 'This Month';
    if (billDate.month == lastMonth && billDate.year == lastYear) return 'Last Month';
    return '${_getMonthName(billDate.month)} ${billDate.year}';
  }

  String _getMonthName(int month) {
    const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return monthNames[month - 1];
  }

  void _toggleSortOrder() => setState(() => _isDescending = !_isDescending);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          FilterRow(
            filters: _filters,
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) => setState(() => _selectedFilter = filter),
            isDescending: _isDescending,
            onSortToggle: _toggleSortOrder,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BillList(bills: _bills, selectedFilter: _selectedFilter, isDescending: _isDescending),
          ),
        ],
      ),
    );
  }
}
