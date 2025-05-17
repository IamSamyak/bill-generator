import 'package:bill_generator/models/Bill.dart';
import 'package:bill_generator/widgets/bill_list_history_page.dart';
import 'package:flutter/material.dart';
import 'package:bill_generator/services/bill_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  final String payStatusParam;
  const HistoryPage({super.key, required this.payStatusParam});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final BillService billService = BillService();

  Map<String, List<Bill>> _bills = {};
  List<Bill> _allBills = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndCategorizeBills();
  }

  Future<void> _fetchAndCategorizeBills({bool loadMore = false}) async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      List<Bill> bills = await billService.fetchBills(
        payStatusFilter: widget.payStatusParam,
        limit: 20,
        lastDocument: loadMore ? _lastDocument : null,
      );

      if (bills.length < 20) {
        _hasMore = false;
      }

      if (bills.isNotEmpty) {
        _lastDocument = billService.lastDocument;
        _allBills.addAll(bills);
      }

      _categorizeBills(_allBills);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
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
    });
  }

  String _getCategory(DateTime billDate) {
    return DateFormat('MMMM yyyy').format(billDate); // e.g., January 2024
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _allBills.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoadingMore &&
              _hasMore &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            _fetchAndCategorizeBills(loadMore: true);
          }
          return false;
        },
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: _bills.isNotEmpty
                  ? BillList(bills: _bills)
                  : const Center(child: Text("No bills available")),
            ),
            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
