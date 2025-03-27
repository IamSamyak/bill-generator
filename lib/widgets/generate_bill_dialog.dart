import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

class GenerateBillDialog extends StatefulWidget {
  final Function(String name, String mobile) onConfirm;
  final List<Map<String, dynamic>> items;

  const GenerateBillDialog({Key? key, required this.onConfirm, required this.items}) : super(key: key);

  @override
  _GenerateBillDialogState createState() => _GenerateBillDialogState();
}

class _GenerateBillDialogState extends State<GenerateBillDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  Future<void> _generatePDFAndShare(String name, String mobile) async {
    final pdf = pw.Document();
    final DateTime now = DateTime.now();
    final String billDate = "${now.year}-${now.month}-${now.day}";
    final String billTime = "${now.hour}:${now.minute}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Waghmare Stores", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text("Bill Date: $billDate | Time: $billTime", style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ["Item", "Quantity", "Price"],
                data: widget.items.map((item) {
                  return [item["name"], item["quantity"], "₹${item["price"]}"];
                }).toList(),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Thank You!", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final pdfFile = File("${tempDir.path}/bill.pdf");
    await pdfFile.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(pdfFile.path)], text: "Hello $name, here is your bill from Waghmare Stores.");
  }

  void _handleConfirm() {
    String name = nameController.text.trim();
    String mobile = mobileController.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all details")),
      );
      return;
    }

    widget.onConfirm(name, mobile);
    _generatePDFAndShare(name, mobile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        "Customer Details",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Customer Name",
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Mobile Number",
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _handleConfirm,
          child: const Text(
            "Confirm",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
