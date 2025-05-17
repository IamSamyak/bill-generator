import 'dart:io';
import 'package:bill_generator/models/ShopDetail.dart';
import 'package:bill_generator/widgets/bill_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import '../widgets/order_summary.dart';
import '../widgets/customer_input_form.dart';
import '../widgets/item_input_row.dart';
import '../services/bill_service.dart';
import 'pdf_viewer_page.dart';
import 'package:bill_generator/models/Bill.dart';

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
  String _receiptIdForBill = "";
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
    final productCategory = TextEditingController();
    final quantity = TextEditingController();
    final price = TextEditingController();

    void refreshIfComplete() {
      if (productCategory.text.isNotEmpty &&
          quantity.text.isNotEmpty &&
          price.text.isNotEmpty) {
        setState(() {});
      }
    }

    productCategory.addListener(refreshIfComplete);
    quantity.addListener(refreshIfComplete);
    price.addListener(refreshIfComplete);

    itemControllers.add({
      "productCategory": productCategory,
      "quantity": quantity,
      "price": price,
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

    List<PurchaseItem> validItems = [];
    for (var controllers in itemControllers) {
      final type = controllers["productCategory"]!.text.trim();
      final qtyText = controllers["quantity"]!.text.trim();
      final priceText = controllers["price"]!.text.trim();

      if (type.isNotEmpty && qtyText.isNotEmpty && priceText.isNotEmpty) {
        final qty = int.tryParse(qtyText) ?? 0;
        final price = double.tryParse(priceText) ?? 0.0;
        if (qty > 0 && price > 0) {
          validItems.add(
            PurchaseItem(
              productCategory: type,
              productName:
                  type, // or update if you have a different productName
              quantity: qty,
              price: price,
              total: qty * price,
            ),
          );
        }
      }
    }

    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ Please enter at least one valid item")),
      );
      return false;
    }

    // Calculate total from PurchaseItem totals
    double total = validItems.fold(0, (sum, item) => sum + item.total);
    double discount = total * 0.10;
    finalAmount = total - discount;

    final bill = Bill(
      receiptId: '',
      customerName: _nameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      date: DateTime.now(),
      payStatus: _payStatus,
      paymentMethod: "Cash",
      amount: finalAmount,
      purchaseList: validItems,
    );

    String receiptId = await _billService.uploadBillToFirebase(bill);

    setState(() {
      _billUploadSuccess = (receiptId != "");
      _receiptIdForBill = receiptId;
    });
    generatedPdf = await _billService.generatePdfAndSave(
      bill,
      _receiptIdForBill
    );
    return (receiptId != "");
  }

  void _viewPdf() async {
    if (generatedPdf == null || !await generatedPdf!.exists()) {
      bool result = await _generateBill();
      if (result == false) return;
    }
    if (_billUploadSuccess) {
      if (generatedPdf != null && await generatedPdf!.exists()) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => Dialog(
                insetPadding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PdfViewerDialogContent(path: generatedPdf!.path),
              ),
        );
      }
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
        phone: '91${_mobileController.text.trim()}',
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
                onRemove: () => _removeItem(index),
                showRemoveIcon: itemControllers.length > 1,
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
