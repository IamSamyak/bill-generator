import 'package:flutter/material.dart';
import '../widgets/order_list.dart';
import '../widgets/order_summary.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/generate_bill_dialog.dart'; // Import the new dialog component

class CreateBillPage extends StatefulWidget {
  final VoidCallback onBack;

  const CreateBillPage({Key? key, required this.onBack}) : super(key: key);

  @override
  _CreateBillPageState createState() => _CreateBillPageState();
}

class _CreateBillPageState extends State<CreateBillPage> {
  List<Map<String, dynamic>> items = [];

  void _addItem() async {
    Map<String, dynamic>? newItem = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddItemDialog();
      },
    );

    if (newItem != null) {
      setState(() {
        items.add(newItem);
      });
    }
  }

  void _openGenerateBillDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GenerateBillDialog(
          items: items, // ✅ Pass items to dialog
          onConfirm: (String name, String mobile) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Bill generated for $name")));
          },
        );
      },
    );
  }

  double _calculateTotal() {
    return items.fold(0.0, (sum, item) {
      return sum +
          (double.parse(item["price"]) * double.parse(item["quantity"]));
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = _calculateTotal();
    double discount = total * 0.10; // 10% Discount
    double finalAmount = total - discount; // Subtract discount

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Bill"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 3,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: OrderList(items: items)),

            /// 🔹 Buttons arranged with **spaceBetween**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _openGenerateBillDialog,
                  icon: const Icon(Icons.receipt_long, color: Colors.black),
                  label: const Text(
                    "Generate Bill",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green.shade400, // ✅ Green shade for billing
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "Add Item",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors
                            .amber
                            .shade400, // ✅ Yellow shade for adding items
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Space before order summary
            /// 🔹 Order Summary below buttons
            OrderSummary(
              total: total,
              discount: discount,
              finalAmount: finalAmount,
            ),
          ],
        ),
      ),
    );
  }
}
