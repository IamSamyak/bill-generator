import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelectionWidget extends StatefulWidget {
  const DateRangeSelectionWidget({Key? key}) : super(key: key);

  @override
  State<DateRangeSelectionWidget> createState() =>
      _DateRangeSelectionWidgetState();
}

class _DateRangeSelectionWidgetState extends State<DateRangeSelectionWidget> {
  DateTimeRange? selectedRange;

  Future<void> pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: selectedRange,
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      child: Column(
        children: [
          if (selectedRange == null) ...[
            // Full-width Banner Image (Top Section)
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.asset('assets/RangeAsset.png', fit: BoxFit.cover),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Select a Date range to view ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'sales data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Date Range Selector Button
            Center(
              child: OutlinedButton(
                onPressed: pickDateRange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1864BF),
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
          ],

          if (selectedRange != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Selector Button (Above Sales Report)
                  const SizedBox(height: 16),

                  // Two Blue-bordered Date Boxes
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.shade50,
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateFormat.format(selectedRange!.start),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.shade50,
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'End Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateFormat.format(selectedRange!.end),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: OutlinedButton(
                      onPressed: pickDateRange,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF1864BF),
                        ), // Blue border
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Less roundness
                        ),
                      ),
                      child: const Text(
                        "SELECT DATE RANGE",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1864BF), // Blue text
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sales Report
                  const Text(
                    'Sales Report',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  buildReportItem('Total Revenue', '\$12,500'),
                  buildReportItem('Bills Paid', '120'),
                  buildReportItem('Unpaid Bills', '15'),

                  const SizedBox(height: 16),
                  const Text(
                    'Sold Items',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  buildSoldItem('Shirt', 80, 4000),
                  buildSoldItem('Pant', 50, 3500),
                  buildSoldItem('T-Shirt', 100, 5000),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget to build sales report rows
  Widget buildReportItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget to build sold item rows
  Widget buildSoldItem(String itemName, int quantity, int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(itemName, style: const TextStyle(fontSize: 15)),
          Text(
            'Qty: $quantity  |  \$${price.toString()}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
