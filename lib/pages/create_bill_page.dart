import 'dart:io';
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

  // Validate the name and mobile number
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
        phone: '919881102237',
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
    final finalAmount = total - discount;

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
            ),
            const SizedBox(height: 20),
            OrderSummary(
              total: total,
              discount: discount,
              finalAmount: finalAmount,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _viewPdf,
              icon: const Icon(Icons.receipt_long, color: Colors.white),
              label: const Text(
                "Generate Bill",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
