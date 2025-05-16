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
    if (isSearching) return; // prevent multiple simultaneous requests

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
        isInputDisabled = false; // enable input after search
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
      });

      setState(() {
        searchController.text = scannedCode.toString();
        isInputDisabled = false;
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    return ListTile(
                      title: Text(bill.customerName),
                      subtitle: Text('Amount: ${bill.amount}'),
                      trailing: Text(
                        DateFormat('yyyy-MM-dd').format(bill.date),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateBillPage(bill: bill),
                          ),
                        );
                      },
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
                child:
                    isSearching
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
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
    );
  }
}
