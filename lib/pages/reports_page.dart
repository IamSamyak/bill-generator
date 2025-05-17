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
  final BillService billService = BillService();
  bool _isLoading = true;
  String? _error;
  WeeklyBillReport? _report;

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    try {
      final report = await billService.getBillsFromLast7Days();
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    // Unwrap the report
    final weeklyRevenue = _report!.weeklyRevenue;
    final totalRevenue = _report!.totalRevenue;
    final totalPaid = _report!.totalPaidBills;
    final totalPending = _report!.totalPendingBills;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Revenue",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          BarChartWidget(weeklyRevenue: weeklyRevenue), // you might want to rename this widget or adapt labels for weekly data
          GraphDescription(
            totalRevenue: totalRevenue,
            totalPaidBills: totalPaid,
            pendingBills: totalPending,
          ),
        ],
      ),
    );
  }
}
