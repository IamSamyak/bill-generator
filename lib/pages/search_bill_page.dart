import 'package:bill_generator/pages/update_bill_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/bill_service.dart';
import '../models/Bill.dart';
import '../services/qr_scanner.dart';

const Color kMainColor = Color(0xFF1864BF);

class SearchBillPage extends StatefulWidget {
  final Function(String) onNavigate;

  const SearchBillPage({super.key, required this.onNavigate});

  @override
  _SearchBillPageState createState() => _SearchBillPageState();
}

class _SearchBillPageState extends State<SearchBillPage> {
  TextEditingController searchController = TextEditingController();
  List<Bill> bills = [];
  String warningMessage = '';
  final BillService _billService = BillService();
  bool isSearching = false;
  bool isInputDisabled = false;

  void _searchBills() async {
    if (isSearching) return;

    setState(() {
      isSearching = true;
      warningMessage = '';
    });

    String input = searchController.text.trim();

    if (input.isEmpty) {
      setState(() {
        warningMessage = 'Please enter receipt ID or customer name.';
        bills = [];
        isSearching = false;
      });
      return;
    }

    try {
      List<Bill> results;

      if (RegExp(r'^\d+$').hasMatch(input)) {
        results = await _billService.searchBillsByReceiptId(receiptId: input);
      } else {
        results = await _billService.searchBillsByCustomerName(
          customerName: input,
        );
      }

      setState(() {
        bills = results;
      });
    } catch (e) {
      setState(() {
        warningMessage = 'Failed to fetch bills: ${e.toString()}';
      });
    } finally {
      setState(() {
        isSearching = false;
        isInputDisabled = false;
      });
    }
  }

  void _scanQRCode() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (scannedCode != null) {
      setState(() {
        searchController.text = scannedCode.toString();
        isInputDisabled = true;
        isSearching = true;
      });

      List<Bill> results = await _billService.searchBillsByReceiptId(
        receiptId: scannedCode.toString(),
      );

      setState(() {
        bills = results;
        isInputDisabled = false;
        isSearching = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Main UI content
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: searchController,
                    enabled: !isInputDisabled,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      labelText: 'Receipt ID or Customer Name',
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: isSearching ? null : _scanQRCode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Scan QR Code"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMainColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (warningMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      warningMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (bills.isEmpty) ...[
                  Center(
                    child: Transform.translate(
                      offset: const Offset(8, 0),
                      child: Image.asset(
                        'assets/images/SearchBill.png',
                        height: 240,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Text(
                    "No Bills Yet",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF184373),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Search for a bill by receipt ID or customer name",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (bills.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateBillPage(bill: bill),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          elevation: 3,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        bill.customerName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat('yyyy-MM-dd')
                                          .format(bill.date),
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bill.mobileNumber,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: bill.payStatus == 'Paid'
                                            ? Colors.green[100]
                                            : Colors.red[100],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        bill.payStatus,
                                        style: TextStyle(
                                          color: bill.payStatus == 'Paid'
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹${bill.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isSearching ? null : _searchBills,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMainColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Search Bill",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Full-screen loader overlay
      if (isSearching)
        Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
    ],
  );
}
}
