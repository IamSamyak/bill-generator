import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/order_summary.dart';
import '../widgets/CustomerInputForm.dart';
import '../widgets/item_input_row.dart';
import 'package:url_launcher/url_launcher.dart';

final apiKey = dotenv.env['API_KEY'] ?? '';
final projectId = dotenv.env['PROJECT_ID'] ?? '';

class CreateBillPage extends StatefulWidget {
  final VoidCallback onBack;

  const CreateBillPage({Key? key, required this.onBack}) : super(key: key);

  @override
  _CreateBillPageState createState() => _CreateBillPageState();
}

class _CreateBillPageState extends State<CreateBillPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String _payStatus = 'Paid';

  List<Map<String, TextEditingController>> itemControllers = [];

  @override
  void initState() {
    super.initState();
    _addItemControllers();
  }

  void _addItemControllers() {
    itemControllers.add({
      "productCategory": TextEditingController(),
      "quantity": TextEditingController(),
      "price": TextEditingController(),
    });
    setState(() {});
  }

  double _calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (sum, item) {
      return sum + ((item["price"] ?? 0.0) * (item["quantity"] ?? 0));
    });
  }

  bool _canAddMore() {
    final last = itemControllers.last;
    return last["productCategory"]!.text.isNotEmpty &&
        last["quantity"]!.text.isNotEmpty &&
        last["price"]!.text.isNotEmpty;
  }

  void _generateBill() async {
    if (_nameController.text.isEmpty || _mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❗ Please enter customer name and mobile number"),
        ),
      );
      return;
    }

    List<Map<String, dynamic>> validItems = [];
    for (var controllers in itemControllers) {
      final type = controllers["productCategory"]!.text.trim();
      final qty = controllers["quantity"]!.text.trim();
      final price = controllers["price"]!.text.trim();

      if (type.isNotEmpty && qty.isNotEmpty && price.isNotEmpty) {
        validItems.add({
          "productCategory": type,
          "productName": type,
          "quantity": int.tryParse(qty) ?? 0,
          "price": double.tryParse(price) ?? 0,
        });
      }
    }

    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ Please enter at least one valid item")),
      );
      return;
    }

    double total = _calculateTotal(validItems);
    double discount = total * 0.10;
    double finalAmount = total - discount;

    final billData = {
      "customerName": _nameController.text.trim(),
      "mobileNumber": _mobileController.text.trim(),
      "billDate": DateTime.now().toIso8601String(),
      "payStatus": _payStatus,
      "paymentMethod": "Cash",
      "totalAmount": total,
      "discount": discount,
      "netAmount": finalAmount,
      "soldBy": "Akash",
      "createdAt": DateTime.now().toIso8601String(),
      "updatedAt": DateTime.now().toIso8601String(),
      "purchaseList": validItems.map((item) {
        return {
          "productCategory": item["productCategory"],
          "productName": item["productName"],
          "price": item["price"],
          "quantity": item["quantity"],
          "total": (item["price"] as double) * (item["quantity"] as int),
        };
      }).toList(),
    };

    try {
      final Uri url = Uri.parse(
        "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/bills?key=$apiKey",
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "fields": billData.map((key, value) {
            if (value is String) {
              return MapEntry(key, {"stringValue": value});
            } else if (value is num) {
              return MapEntry(key, {"doubleValue": value});
            } else if (value is List) {
              return MapEntry(key, {
                "arrayValue": {
                  "values": value.map((item) {
                    return {
                      "mapValue": {
                        "fields": item.map((k, v) {
                          return MapEntry(
                            k,
                            v is num
                                ? {"doubleValue": v}
                                : {"stringValue": v.toString()},
                          );
                        }),
                      },
                    };
                  }).toList(),
                },
              });
            } else {
              return MapEntry(key, {"stringValue": value.toString()});
            }
          }),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Bill generated for ${_nameController.text}"),
          ),
        );
        setState(() {
          _nameController.clear();
          _mobileController.clear();
          itemControllers.clear();
          _addItemControllers();
          _payStatus = 'Paid'; // reset status
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to store bill")),
        );
        print("Error: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Exception: $e")),
      );
    }
  }

  void _shareOnWhatsApp() {
    final String message = "🧾 Bill generated for: ${_nameController.text}\n"
        "📞 Mobile: ${_mobileController.text}\n"
        "📦 Items: ${itemControllers.length}\n"
        "💰 Total: ₹${_calculateTotal(itemControllers.map((c) {
          return {
            "price": double.tryParse(c["price"]!.text) ?? 0,
            "quantity": int.tryParse(c["quantity"]!.text) ?? 0,
          };
        }).toList()).toStringAsFixed(2)}";

    final url = "https://wa.me/?text=${Uri.encodeComponent(message)}";
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final items = itemControllers.map((c) {
      return {
        "price": double.tryParse(c["price"]!.text) ?? 0,
        "quantity": int.tryParse(c["quantity"]!.text) ?? 0,
      };
    }).toList();

    final total = _calculateTotal(items);
    final discount = total * 0.10;
    final finalAmount = total - discount;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomerInputForm(  // Use the new widget
              nameController: _nameController,
              mobileController: _mobileController,
              payStatus: _payStatus,
              onPayStatusChanged: (value) {
                if (value != null) {
                  setState(() {
                    _payStatus = value;
                  });
                }
              },
            ),
            const Text(
              "Items",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF184373),
              ),
            ),
            const SizedBox(height: 10),
            ...itemControllers.map((controller) {
              return ItemInputRow(
                productCategoryController: controller["productCategory"]!,
                quantityController: controller["quantity"]!,
                priceController: controller["price"]!,
              );
            }).toList(),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  if (_canAddMore()) {
                    _addItemControllers();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("⚠️ Fill all fields before adding new item"),
                      ),
                    );
                  }
                },
                child: const CircleAvatar(
                  backgroundColor: Color(0xFF0f58b9),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            OrderSummary(
              total: total,
              discount: discount,
              finalAmount: finalAmount,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _generateBill,
              icon: const Icon(Icons.receipt_long, color: Colors.white),
              label: const Text(
                "Generate Bill",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1864c3),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _shareOnWhatsApp,
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                "Share on WhatsApp",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1864c3),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
 ],
        ),
      ),
    );
  }
}
