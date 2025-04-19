import 'package:flutter/material.dart';

class UpdateBillsPage extends StatefulWidget {
  const UpdateBillsPage({super.key});

  @override
  State<UpdateBillsPage> createState() => _UpdateBillsPageState();
}

class _UpdateBillsPageState extends State<UpdateBillsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> allBills = [
    {
      'customerName': 'Alice Johnson',
      'mobile': '1234567890',
      'amount': '500',
      'status': 'Unpaid',
    },
    {
      'customerName': 'Bob Smith',
      'mobile': '9876543210',
      'amount': '750',
      'status': 'Paid',
    },
    {
      'customerName': 'Charlie Adams',
      'mobile': '1122334455',
      'amount': '300',
      'status': 'Pending',
    },
  ];

  List<Map<String, dynamic>> filteredBills = [];

  @override
  void initState() {
    super.initState();
    filteredBills = allBills;
  }

  void _filterBills(String query) {
    setState(() {
      filteredBills = allBills.where((bill) {
        final name = bill['customerName'].toString().toLowerCase();
        final mobile = bill['mobile'].toString();
        return name.contains(query.toLowerCase()) || mobile.contains(query);
      }).toList();
    });
  }

  void _updateBill(int index, String field, String value) {
    setState(() {
      filteredBills[index][field] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or mobile',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: _filterBills,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredBills.length,
            itemBuilder: (context, index) {
              final bill = filteredBills[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${bill['customerName']}'),
                      Text('Mobile: ${bill['mobile']}'),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Bill Amount'),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: bill['amount']),
                        onChanged: (val) => _updateBill(index, 'amount', val),
                      ),
                      DropdownButtonFormField<String>(
                        value: bill['status'],
                        items: ['Paid', 'Unpaid', 'Pending']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) _updateBill(index, 'status', val);
                        },
                        decoration: const InputDecoration(labelText: 'Pay Status'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
