import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/bill_service.dart'; 
import '../models/Bill.dart'; 

// Define the main color as a constant
const Color kMainColor = Color(0xFF1864BF);

class SearchBillPage extends StatefulWidget {
  final Function(String) onNavigate;

  const SearchBillPage({super.key, required this.onNavigate});

  @override
  _SearchBillPageState createState() => _SearchBillPageState();
}

class _SearchBillPageState extends State<SearchBillPage> {
  TextEditingController receiptIdController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  List<Bill> bills = [];
  String warningMessage = '';
  final BillService _billService = BillService();

  // Function to handle search logic
  void _searchBills() async {
    String receiptId = receiptIdController.text.trim();
    String customerName = customerNameController.text.trim();

    // If both receiptId and customerName are entered, show warning
    if (receiptId.isNotEmpty && customerName.isNotEmpty) {
      setState(() {
        warningMessage = "Please choose only one: either Receipt ID or Customer Name.";
      });
      return;
    } else {
      setState(() {
        warningMessage = ''; // Clear any previous warning message
      });
    }

    // Call the service to search bills by customer name
    if (customerName.isNotEmpty) {
      try {
        final results = await _billService.searchBillsByCustomerName(customerName: customerName);
        setState(() {
          bills = results;
        });
      } catch (e) {
        // Handle error gracefully (show error message if needed)
        setState(() {
          warningMessage = 'Failed to fetch bills: ${e.toString()}';
        });
      }
    } else {
       try {
        final results = await _billService.searchBillsByReceiptId(receiptId: '#$receiptId');
        setState(() {
          bills = results;
        });
      } catch (e) {
        // Handle error gracefully (show error message if needed)
        setState(() {
          warningMessage = 'Failed to fetch bills: ${e.toString()}';
        });
      }
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
              // Receipt ID input with padding and space adjustments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: receiptIdController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    labelText: 'Receipt ID',
                    labelStyle: const TextStyle(fontSize: 14),
                    prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey[700]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Customer Name input with padding and space adjustments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: customerNameController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    labelText: 'Customer Name',
                    labelStyle: const TextStyle(fontSize: 14),
                    prefixIcon: Icon(Icons.person, size: 18, color: Colors.grey[700]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Show warning message if both fields are filled
              if (warningMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    warningMessage,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Centered image and slightly shifted to the right
              if (bills.isEmpty) ...[
                Center(
                  child: Transform.translate(
                    offset: const Offset(8, 0), // Shift 8 pixels right
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
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Display the list of bills
              if (bills.isNotEmpty) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    final bill = bills[index];
                    return ListTile(
                      title: Text(bill.customerName),
                      subtitle: Text('Amount: ${bill.amount}'),
                     trailing: Text(DateFormat('yyyy-MM-dd').format(bill.date)),
                    );
                  },
                ),
              ],

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _searchBills,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMainColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
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
    );
  }
}
