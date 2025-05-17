import 'package:flutter/material.dart';
import 'package:bill_generator/models/Bill.dart';
import 'package:bill_generator/services/bill_service.dart';
import '../widgets/date_range_display.dart';

class DateRangeSelectionWidget extends StatefulWidget {
  const DateRangeSelectionWidget({super.key});

  @override
  State<DateRangeSelectionWidget> createState() =>
      _DateRangeSelectionWidgetState();
}

class _DateRangeSelectionWidgetState extends State<DateRangeSelectionWidget> {
  DateTimeRange? selectedRange;
  List<Bill> _filteredBills = [];
  final BillService _billService = BillService();

  bool _isLoading = false;

  Future<void> pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: selectedRange,
    );

    if (picked != null) {
      setState(() {
        _isLoading = true;
      });

      List<Bill> result = await _billService.searchBillsWithinDateRange(
        dateRange: picked,
        payStatusFilter: 'Paid', // or 'All'
      );

      setState(() {
        selectedRange = picked;
        _filteredBills = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          if (selectedRange == null) ...[
            Center(
              child: Transform.translate(
                offset: const Offset(4, 0),
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.8,
                    child: Image.asset(
                      'assets/images/RangeAsset.png',
                      height: 360,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Select a date range to view ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'sales data',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton(
                onPressed: pickDateRange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1864BF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "SELECT DATE RANGE",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ] else if (_isLoading) ...[
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          ] else ...[
            DateRangeDisplay(
              selectedRange: selectedRange!,
              filteredBills: _filteredBills,
              onPickDateRange: pickDateRange,
            ),
          ],
        ],
      ),
    );
  }
}
