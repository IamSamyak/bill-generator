import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback onBack;
  final List<Map<String, dynamic>> initialBills;

  const HistoryPage({super.key, required this.onBack, required this.initialBills});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';
  bool _isDescending = true;

  final List<String> _filters = ['All', 'Paid', 'Unpaid'];
  Map<String, List<Map<String, dynamic>>> _bills = {};

  @override
  void initState() {
    super.initState();
    _categorizeBills();
  }

  void _categorizeBills() {
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;
    int lastMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    int lastYear = currentMonth == 1 ? currentYear - 1 : currentYear;

    Map<String, List<Map<String, dynamic>>> categorizedBills = {};

    for (var bill in widget.initialBills) {
      DateTime billDate = DateTime.parse(bill['date']);
      int billMonth = billDate.month;
      int billYear = billDate.year;

      String category;
      if (billMonth == currentMonth && billYear == currentYear) {
        category = 'This Month';
      } else if (billMonth == lastMonth && billYear == lastYear) {
        category = 'Last Month';
      } else {
        category = '${_getMonthName(billMonth)} $billYear';
      }

      if (!categorizedBills.containsKey(category)) {
        categorizedBills[category] = [];
      }
      categorizedBills[category]!.add(bill);
    }

    setState(() {
      _bills = categorizedBills;
    });
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  void _toggleSortOrder() {
    setState(() {
      _isDescending = !_isDescending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing History'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: _filters.map((filter) {
                    bool isActive = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? Colors.amber[700] : Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Text(filter),
                      ),
                    );
                  }).toList(),
                ),
                IconButton(
                  onPressed: _toggleSortOrder,
                  icon: Icon(
                    _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: _bills.entries.map((entry) {
                  List<Map<String, dynamic>> filteredBills = entry.value
                      .where((bill) => _selectedFilter == 'All' || bill['status'] == _selectedFilter)
                      .toList();

                  filteredBills.sort((a, b) {
                    DateTime dateA = DateTime.parse(a['date']);
                    DateTime dateB = DateTime.parse(b['date']);
                    return _isDescending ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
                  });

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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillItem(Map<String, dynamic> bill) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(bill['name'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Bill Date: ${bill['date']}'),
                ],
              ),
            ),
          ],
        ),
        const Divider(color: Colors.grey, thickness: 0.5),
      ],
    );
  }
}
