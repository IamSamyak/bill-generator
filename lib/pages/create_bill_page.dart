import 'dart:io';
import 'package:bill_generator/widgets/bill_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import '../widgets/order_summary.dart';
import '../widgets/CustomerInputForm.dart';
import '../widgets/item_input_row.dart';
import '../services/bill_service.dart';
import 'pdf_viewer_page.dart';

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
  bool _billUploadSuccess = false;
  List<Map<String, TextEditingController>> itemControllers = [];
  final BillService _billService = BillService();
  File? generatedPdf;

  double finalAmount = 0;

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

  bool _validateInputs() {
    if (_nameController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ Name should be at least 3 characters")),
      );
      return false;
    }
    if (_mobileController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ Mobile number should be 10 digits")),
      );
      return false;
    }
    return true;
  }

  void _removeItem(int index) {
    setState(() {
      itemControllers.removeAt(index);
    });
  }

  Future<bool> _generateBill() async {
    if (!_validateInputs()) {
      return false;
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
      return false;
    }

    double total = _calculateTotal(validItems);
    double discount = total * 0.10;

    // Calculate finalAmount, now we use the state value of finalAmount
    finalAmount = total - discount;

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
      "purchaseList": validItems,
    };

    bool isSuccess = await _billService.uploadBillToFirebase(billData);
    setState(() {
      _billUploadSuccess = isSuccess;
    });
    generatedPdf = await _billService.generatePdfAndSave(billData);
    return isSuccess;
  }

  void _viewPdf() async {
    if (generatedPdf == null || !await generatedPdf!.exists()) {
      bool result = await _generateBill();
      if (result == false) return;
    }
    if (_billUploadSuccess) {
      if (generatedPdf != null && await generatedPdf!.exists()) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerPage(path: generatedPdf!.path),
          ),
        );
      }

      setState(() {
        _nameController.clear();
        _mobileController.clear();
        itemControllers.clear();
        _addItemControllers();
        _payStatus = 'Paid';
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to store bill")));
    }
  }

  void _shareOnWhatsApp() async {
    if (generatedPdf == null || !await generatedPdf!.exists()) {
      bool result = await _generateBill();
      if (result == false) return;
    }

    try {
      await WhatsappShare.shareFile(
        phone: '918888308015',
        filePath: [generatedPdf!.path],
      );
    } catch (e) {
      print("error $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to share PDF on WhatsApp: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items =
        itemControllers.map((c) {
          return {
            "price": double.tryParse(c["price"]!.text) ?? 0,
            "quantity": int.tryParse(c["quantity"]!.text) ?? 0,
          };
        }).toList();

    final total = _calculateTotal(items);
    final discount = total * 0.10;

    // Use finalAmount from state
    finalAmount = total - discount;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomerInputForm(
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
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
            ...itemControllers.asMap().entries.map((entry) {
              int index = entry.key;
              var controller = entry.value;
              return ItemInputRow(
                productCategoryController: controller["productCategory"]!,
                quantityController: controller["quantity"]!,
                priceController: controller["price"]!,
                onRemove:
                    () => _removeItem(index), // 👈 pass the index to remove
                showRemoveIcon:
                    itemControllers.length >
                    1, // only show remove if more than one
              );
            }),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      final last = itemControllers.last;
                      final filled =
                          last["productCategory"]!.text.isNotEmpty &&
                          last["quantity"]!.text.isNotEmpty &&
                          last["price"]!.text.isNotEmpty;
                      if (filled) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✅ Current item row is valid."),
                          ),
                        );
                        setState(() {}); // Refresh total
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "⚠️ Please fill all fields to confirm this item",
                            ),
                          ),
                        );
                      }
                    },
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF28a745),
                      child: Icon(Icons.done, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (_canAddMore()) {
                        _addItemControllers();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "⚠️ Fill all fields before adding new item",
                            ),
                          ),
                        );
                      }
                    },
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF0f58b9),
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            OrderSummary(
              total: total,
              discount: discount,
              finalAmount: finalAmount,
            ),
            const SizedBox(height: 20),
            BillActionButtons(
              onGeneratePressed: _viewPdf,
              onSharePressed: _shareOnWhatsApp,
            ),
          ],
        ),
      ),
    );
  }
}
