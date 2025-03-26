import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback onBack;
  const HistoryPage({super.key, required this.onBack});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';
  bool _isDescending = true;

  final List<String> _filters = ['All', 'Paid', 'Unpaid'];

  final Map<String, List<Map<String, dynamic>>> _bills = {
    'This Month': [
      {'name': 'Ravi Kumar', 'date': '2024-07-25', 'amount': 1500, 'status': 'Paid'},
      {'name': 'Sneha Verma', 'date': '2024-07-22', 'amount': 2300, 'status': 'Unpaid'},
    ],
    'Last Month': [
      {'name': 'Amit Sharma', 'date': '2024-06-15', 'amount': 1800, 'status': 'Paid'},
      {'name': 'Neha Joshi', 'date': '2024-06-10', 'amount': 2700, 'status': 'Unpaid'},
    ],
  };

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
            // Filter Buttons & Sorting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: _filters.map((filter) {
                    bool isActive = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0), // Reduced spacing
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? Colors.amber[700] : Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(color: Colors.grey.shade400), // Add border for white buttons
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

                // Sorting Button
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

            // Bill List
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${bill['amount']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bill['status'] == 'Paid' ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    bill['status'],
                    style: TextStyle(
                      color: bill['status'] == 'Paid' ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(color: Colors.grey, thickness: 0.5),
      ],
    );
  }
}
