import 'package:bill_generator/models/Bill.dart';
import 'package:flutter/material.dart';
import 'package:bill_generator/services/bill_service.dart';
import 'package:bill_generator/widgets/bar_chart.dart';
import 'package:bill_generator/widgets/graph_description.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final BillService billService =
      BillService(); // Create an instance of BillService
  bool _isLoading = true;
  String? _error;
  List<Bill> _bills = [];

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    try {
      final bills =
          await billService.fetchBills(); // Use BillService to fetch bills
      setState(() {
        _bills = bills;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, double> calculateMonthlyRevenue() {
    Map<String, double> revenue = {};
    for (var bill in _bills) {
      DateTime date = bill.date;
      String month = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      revenue[month] = (revenue[month] ?? 0) + bill.amount;
    }
    return revenue;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    Map<String, double> monthlyRevenue = calculateMonthlyRevenue();
    double totalRevenue = monthlyRevenue.values.fold(
      0,
      (sum, amount) => sum + amount,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Revenue",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          BarChartWidget(monthlyRevenue: monthlyRevenue),
          GraphDescription(
            totalRevenue: totalRevenue,
            // Add other variables here as needed
          ),
        ],
      ),
    );
  }
}
