import 'dart:convert';
import 'package:bill_generator/widgets/bill_list_history_page.dart';
import 'package:bill_generator/widgets/filter_row_history_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final String projectId = dotenv.env['PROJECT_ID'] ?? '';
  final String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';

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
      final bills = await _fetchBills();
      _categorizeBills(bills);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchBills() async {
    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/bills?key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<Map<String, dynamic>> bills = [];

      for (var doc in decoded['documents'] ?? []) {
        final fields = doc['fields'];

        // Now print and debug the purchaseList
        var purchaseList =
            (fields['purchaseList']?['arrayValue']?['values'] ?? []).map<
              Map<String, dynamic>
            >((item) {
              var productCategory =
                  item['mapValue']['fields']['productCategory']?['stringValue'] ??
                  '';
              var productName =
                  item['mapValue']['fields']['productName']?['stringValue'] ??
                  '';
              var price =
                  double.tryParse(
                    fields['mapValue']?['fields']?['price']?['doubleValue']
                            .toString() ??
                        '0',
                  ) ??
                  0.0;
              var quantity =
                  int.tryParse(
                    item['mapValue']['fields']['quantity']?['integerValue'] ??
                        '0',
                  ) ??
                  0;
              var total =
                  double.tryParse(
                    fields['mapValue']?['fields']?['total']?['doubleValue']
                            .toString() ??
                        '0',
                  ) ??
                  0.0;

              return {
                'productCategory': productCategory,
                'productName': productName,
                'price': price,
                'quantity': quantity,
                'total': total,
              };
            }).toList();

        // Print the entire purchaseList before adding it to the bill
        final rawDate = fields['billDate']?['stringValue'];
        String formattedDate = '';
        if (rawDate != null) {
          final parsedDate = DateTime.tryParse(rawDate);
          if (parsedDate != null) {
            formattedDate =
                '${parsedDate.year.toString().padLeft(4, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
          }
        }

        // Add to the bills list after debugging
        bills.add({
          'customerName': fields['customerName']?['stringValue'] ?? '',
          'mobileNumber': fields['mobileNumber']?['stringValue'] ?? '',
          'date': formattedDate,
          'payStatus': fields['payStatus']?['C'] ?? '',
          'paymentMethod': fields['paymentMethod']?['stringValue'] ?? '',
          'totalAmount':
              double.tryParse(
                fields['totalAmount']?['doubleValue']?.toString() ?? '0',
              ) ??
              0.0,
          'discount':
              double.tryParse(
                fields['discount']?['doubleValue']?.toString() ?? '0',
              ) ??
              0.0,
          'netAmount':
              double.tryParse(
                fields['netAmount']?['doubleValue']?.toString() ?? '0',
              ) ??
              0.0,
          'soldBy': fields['soldBy']?['stringValue'] ?? '',
          'purchaseList': purchaseList,
        });
      }

      return bills;
    } else {
      throw Exception('Failed to fetch bills: ${response.body}');
    }
  }

  void _categorizeBills(List<Map<String, dynamic>> bills) {
    Map<String, List<Map<String, dynamic>>> categorizedBills = {};
    DateTime now = DateTime.now();
    int currentMonth = now.month, currentYear = now.year;
    int lastMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    int lastYear = currentMonth == 1 ? currentYear - 1 : currentYear;

    for (var bill in bills) {
      DateTime billDate = DateTime.tryParse(bill['date']) ?? DateTime.now();
      String category = _getCategory(
        billDate,
        currentMonth,
        currentYear,
        lastMonth,
        lastYear,
      );
      categorizedBills.putIfAbsent(category, () => []).add(bill);
    }

    setState(() {
      _bills = categorizedBills;
      _isLoading = false;
    });
  }

  String _getCategory(
    DateTime billDate,
    int currentMonth,
    int currentYear,
    int lastMonth,
    int lastYear,
  ) {
    if (billDate.month == currentMonth && billDate.year == currentYear)
      return 'This Month';
    if (billDate.month == lastMonth && billDate.year == lastYear)
      return 'Last Month';
    return '${_getMonthName(billDate.month)} ${billDate.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
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
