import 'package:flutter/material.dart';
import '../widgets/order_list.dart';
import '../widgets/order_summary.dart';
import '../widgets/add_item_dialog.dart';

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

  double _calculateTotal() {
    return items.fold(0.0, (sum, item) {
      return sum + (double.parse(item["price"]) * double.parse(item["quantity"]));
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = _calculateTotal();
    double discount = total * 0.10;  // 10% Discount
    double finalAmount = total - discount;  // Subtract discount

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Bill"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(child: OrderList(items: items)),

            /// 🔹 "Add Item" button aligned right below the last item
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Add Item", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 10),  // Space before order summary

            /// 🔹 Order Summary below "Add Item"
            OrderSummary(total: total, discount: discount, finalAmount: finalAmount),
          ],
        ),
      ),
    );
  }
}
