import 'dart:io';
import 'package:bill_generator/services/category_service.dart';
import 'package:bill_generator/widgets/bill_action_buttons.dart';
import 'package:bill_generator/widgets/pdf_viewer_modal.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import '../widgets/order_summary.dart';
import '../widgets/customer_input_form.dart';
import '../widgets/item_input_row.dart';
import '../services/bill_service.dart';
import 'package:bill_generator/models/Bill.dart';
import '../services/lottefile_dialog.dart';
import '../constants.dart';

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
    FocusScope.of(context).unfocus();
    if (!_validateInputs()) {
      return false;
    }

    List<PurchaseItem> validItems = _getPurchaseItems();
    print("valid Items $validItems");
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ Please enter at least one valid item")),
      );
      return false;
    }

    final bill = Bill(
      receiptId: '',
      customerName: _nameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      date: DateTime.now(),
      payStatus: _payStatus,
      paymentMethod: "Cash",
      amount: 0,
      purchaseList: validItems,
    );

    String receiptId = await _billService.uploadBillToFirebase(bill);

    setState(() {
      _billUploadSuccess = (receiptId != "");
      _receiptIdForBill = receiptId;
    });
    generatedPdf = await _billService.generatePdfAndSave(
      bill,
      _receiptIdForBill,
    );
    return (receiptId != "");
  }

  void _viewPdf() async {
    showLottieDialog(
      context,
      'assets/animations/BillPrint.json',
      message: 'Please wait while we are printing your bill',
    );

    // Start a timer for 5 seconds AND start PDF generation simultaneously
    final pdfFuture =
        (generatedPdf == null || !await generatedPdf!.exists())
            ? _generateBill()
            : Future.value(true);

    // Wait for both the PDF generation and the 5 second delay
    final results = await Future.wait([
      pdfFuture,
      Future.delayed(Duration(seconds: 5)),
    ]);

    // Close the loading animation dialog
    Navigator.of(context).pop();

    bool pdfReady = results[0] == true;

    // Show the PDF viewer if ready
    if (pdfReady && generatedPdf != null && await generatedPdf!.exists()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => Dialog(
              insetPadding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: PdfViewerDialogContent(path: generatedPdf!.path),
            ),
      );
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

  List<PurchaseItem> _getPurchaseItems() {
  return itemControllers.map((controllers) {
    final type = controllers["productCategory"]!.text.trim();
    final qtyText = controllers["quantity"]!.text.trim();
    final priceText = controllers["price"]!.text.trim();

    if (type.isNotEmpty && qtyText.isNotEmpty && priceText.isNotEmpty) {
      final qty = int.tryParse(qtyText) ?? 0;
      final price = double.tryParse(priceText) ?? 0.0;
      final category = CategoryService().getCategoryByLabel(type);
      print("category ${category.discount}");
      return PurchaseItem(
        productCategory: type,
        productName: type,
        quantity: qty,
        price: price,
        discount: category.discount,
        total: price * qty,
      );
    } else {
      return null;
    }
  }).whereType<PurchaseItem>().toList();
}


@override
Widget build(BuildContext context) {
  final purchaseItems = _getPurchaseItems();

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
              color: inputLabelColor,
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
            purchases: purchaseItems, // Computation done outside
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
