import 'dart:io';
import 'package:bill_generator/main.dart';
import 'package:bill_generator/models/ShopDetail.dart';
import 'package:bill_generator/pages/pdf_viewer_page.dart';
import 'package:bill_generator/services/bill_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/Bill.dart';

class BillItemWidget extends StatelessWidget {
  final Bill bill;
  final BillService _billService = BillService();

  BillItemWidget({super.key, required this.bill});

  Future<void> _viewPdf(BuildContext context) async {
    ShopDetail? shopDetail =
        Provider.of<ShopDetailProvider>(context, listen: false).shopDetail;

    if (shopDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❗ Shop details missing! Cannot generate PDF."),
        ),
      );
      return;
    }
    File? generatedPdf = await _billService.generatePdfAndSave(
      bill,
      bill.receiptId,
      shopDetail,
    );
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
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to store bill")));
    }
  }

  void _dialNumber(String contactNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: contactNumber);

    PermissionStatus status = await Permission.phone.request();
    if (status.isGranted) {
      try {
        debugPrint('Attempting to launch: $telUri');
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri, mode: LaunchMode.externalApplication);
          debugPrint('Launched successfully: $telUri');
        } else {
          debugPrint('Failed to launch: $telUri');
          throw 'Could not launch $contactNumber';
        }
      } catch (e) {
        debugPrint('Error occurred: $e');
      }
    } else {
      debugPrint('Phone permission not granted.');
    }
  }

  Color _generateRandomLightColor() {
    final Random random = Random();
    int red = random.nextInt(156) + 100;
    int green = random.nextInt(156) + 100;
    int blue = random.nextInt(156) + 100;
    return Color.fromRGBO(red, green, blue, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _dialNumber(bill.mobileNumber),
              child: CircleAvatar(
                backgroundColor: _generateRandomLightColor(),
                child: Text(
                  bill.customerName.isNotEmpty ? bill.customerName[0] : '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Bill Date: ${DateFormat('yyyy-MM-dd').format(bill.date)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${bill.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _viewPdf(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'View Bill',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(color: Colors.grey, thickness: 0.7),
      ],
    );
  }
}
