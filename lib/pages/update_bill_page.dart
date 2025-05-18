import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import '../widgets/bill_action_buttons.dart';
import '../widgets/order_summary.dart';
import '../widgets/customer_input_form.dart';
import '../widgets/item_input_row.dart';
import '../services/bill_service.dart';
import '../widgets/pdf_viewer_modal.dart';
import 'package:bill_generator/models/Bill.dart';

class UpdateBillPage extends StatefulWidget {
  final Bill bill;

  const UpdateBillPage({Key? key, required this.bill}) : super(key: key);

  @override
  _UpdateBillPageState createState() => _UpdateBillPageState();
}

class _UpdateBillPageState extends State<UpdateBillPage> {
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late String _payStatus;
  bool _billUploadSuccess = false;
  String _receiptIdForBill = "";
  List<Map<String, TextEditingController>> itemControllers = [];
  final BillService _billService = BillService();
  File? generatedPdf;

  double finalAmount = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bill.customerName);
    _mobileController = TextEditingController(text: widget.bill.mobileNumber);
    _payStatus = widget.bill.payStatus;
    _populateItemsFromBill(widget.bill.purchaseList);
  }

  void _populateItemsFromBill(List<PurchaseItem> items) {
    itemControllers.clear();
    for (var item in items) {
      final productCategory = TextEditingController(text: item.productCategory);
      final quantity = TextEditingController(text: item.quantity.toString());
      final price = TextEditingController(text: item.price.toString());

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
    }

    if (itemControllers.isEmpty) {
      _addItemControllers();
    }
    setState(() {});
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

  void _resetData() {
    _nameController.clear();
    _mobileController.clear();
    _payStatus = 'Paid';
    _populateItemsFromBill([]);
    finalAmount = 0;
    _billUploadSuccess = false;
    _receiptIdForBill = "";
    generatedPdf = null;
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
              productName: type,
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
    double total = validItems.fold(0, (sum, item) => sum + item.total);
    double discount = total * 0.10;
    finalAmount = total - discount;

    final updatedBill = Bill(
      receiptId: widget.bill.receiptId,
      customerName: _nameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      date: DateTime.now(),
      payStatus: _payStatus,
      paymentMethod: "Cash",
      amount: finalAmount,
      purchaseList: validItems,
    );

    String receiptId = await _billService.uploadBillToFirebase(updatedBill);
    setState(() {
      _billUploadSuccess = (receiptId != "");
      _receiptIdForBill = receiptId;
    });

    generatedPdf = await _billService.generatePdfAndSave(
      updatedBill,
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
    finalAmount = total - discount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Bill'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
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
              const SizedBox(height: 16),
              // Items Label + Reset IconButton (Yellow Refresh Icon)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Items",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _resetData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700], // Yellowish color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Reset",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color white for contrast
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // List of items
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
              // Add Item + IconButton below last item
              const SizedBox(height: 8),
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
                    radius: 18,
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
              const SizedBox(height: 20),
              BillActionButtons(
                onGeneratePressed: _viewPdf,
                onSharePressed: _shareOnWhatsApp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
