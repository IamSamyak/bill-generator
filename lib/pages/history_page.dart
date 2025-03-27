import 'package:bill_generator/widgets/bill_item_history_page.dart';
import 'package:flutter/material.dart';

// Widget for HistoryPage
class HistoryPage extends StatefulWidget {
  final VoidCallback onBack;
  final List<Map<String, dynamic>> initialBills;

  const HistoryPage({super.key, required this.onBack, required this.initialBills});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

// State Management for HistoryPage
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

      if (!categorizedBills.containsKey(category)) categorizedBills[category] = [];
      categorizedBills[category]!.add(bill);
    }

    setState(() => _bills = categorizedBills);
  }

  String _getCategory(DateTime billDate, int currentMonth, int currentYear, int lastMonth, int lastYear) {
    if (billDate.month == currentMonth && billDate.year == currentYear) return 'This Month';
    if (billDate.month == lastMonth && billDate.year == lastYear) return 'Last Month';
    return '${_getMonthName(billDate.month)} ${billDate.year}';
  }

  String _getMonthName(int month) {
    const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 
                        'July', 'August', 'September', 'October', 'November', 'December'];
    return monthNames[month - 1];
  }

  void _toggleSortOrder() => setState(() => _isDescending = !_isDescending);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildFiltersRow(),
            const SizedBox(height: 8),
            _buildBillsList(),
          ],
        ),
      ),
    );
  }

  // Reusable Components
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Billing History'),
      centerTitle: true,
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: _filters.map((filter) => _buildFilterButton(filter)).toList(),
        ),
        IconButton(
          onPressed: _toggleSortOrder,
          icon: Icon(
            _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String filter) {
    bool isActive = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? const Color.fromARGB(255, 0, 123, 255) : Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: Colors.grey.shade400),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        onPressed: () => setState(() => _selectedFilter = filter),
        child: Text(filter),
      ),
    );
  }

  Widget _buildBillsList() {
    return Expanded(
      child: ListView(
        children: _bills.entries.map((entry) {
          List<Map<String, dynamic>> filteredBills = _applyFilters(entry.value);

          if (filteredBills.isEmpty) return Container();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Column(
                children: filteredBills.map((bill) => _buildBillItem(bill)).toList(),
              ),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> bills) {
    return bills
        .where((bill) => _selectedFilter == 'All' || bill['status'] == _selectedFilter)
        .toList()
      ..sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return _isDescending ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
      });
  }

  Widget _buildBillItem(Map<String, dynamic> bill) {
    return BillItemWidget(bill: bill);
  }
}

