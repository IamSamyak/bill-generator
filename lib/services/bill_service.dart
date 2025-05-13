import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'company_profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillService {
  final String projectId = dotenv.env['PROJECT_ID'] ?? '';
  final String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
  final CompanyProfileService _service = CompanyProfileService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> fetchBills({
  String payStatusFilter = 'All',
}) async {
  try {
    // Query Firestore and order by 'billDate' in descending order
    QuerySnapshot querySnapshot = await _firestore
        .collection('bills')
        .orderBy('billDate', descending: true)
        .get();

    List<Map<String, dynamic>> bills = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      var purchaseList = (data['purchaseList'] ?? []).map<Map<String, dynamic>>((item) {
        return {
          'productCategory': item['productCategory'] ?? '',
          'productName': item['productName'] ?? '',
          'price': item['price'] ?? 0.0,
          'quantity': item['quantity'] ?? 0,
          'total': item['total'] ?? 0.0,
        };
      }).toList();

      String formattedDate = '';
      if (data['billDate'] != null) {
        DateTime parsedDate = DateTime.tryParse(data['billDate']) ?? DateTime.now();
        formattedDate = '${parsedDate.year}-${parsedDate.month}-${parsedDate.day}';
      }

      if (payStatusFilter == 'All' || data['payStatus'] == payStatusFilter) {
        bills.add({
          'customerName': data['customerName'] ?? '',
          'mobileNumber': data['mobileNumber'] ?? '',
          'date': formattedDate,
          'payStatus': data['payStatus'] ?? '',
          'paymentMethod': data['paymentMethod'] ?? '',
          'amount': data['totalAmount'] ?? 0.0,
          'purchaseList': purchaseList,
        });
      }
    }

    return bills;
  } catch (e) {
    throw Exception('Failed to fetch bills: $e');
  }
}


  Future<List<Map<String, dynamic>>> searchBillsByCustomerName({
    required String customerName,
  }) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('bills')
              .where('customerName', isEqualTo: customerName)
              .get();

      List<Map<String, dynamic>> bills = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        var purchaseList =
            (data['purchaseList'] ?? []).map<Map<String, dynamic>>((item) {
              return {
                'productCategory': item['productCategory'] ?? '',
                'productName': item['productName'] ?? '',
                'price': item['price'] ?? 0.0,
                'quantity': item['quantity'] ?? 0,
                'total': item['total'] ?? 0.0,
              };
            }).toList();

        String formattedDate = '';
        if (data['billDate'] != null) {
          DateTime parsedDate =
              DateTime.tryParse(data['billDate']) ?? DateTime.now();
          formattedDate =
              '${parsedDate.year}-${parsedDate.month}-${parsedDate.day}';
        }

        bills.add({
          'customerName': data['customerName'] ?? '',
          'mobileNumber': data['mobileNumber'] ?? '',
          'date': formattedDate,
          'paymentMethod': data['paymentMethod'] ?? '',
          'amount': data['totalAmount'] ?? 0.0,
          'purchaseList': purchaseList,
        });
      }

      return bills;
    } catch (e) {
      throw Exception('Failed to fetch bills: $e');
    }
  }

  Future<bool> uploadBillToFirebase(Map<String, dynamic> billData) async {
    try {
      // Convert purchaseList to Firestore-compatible format
      List<Map<String, dynamic>> purchaseList =
          (billData['purchaseList'] ?? []).map<Map<String, dynamic>>((item) {
            return {
              'productCategory': item['productCategory'] ?? '',
              'productName': item['productName'] ?? '',
              'price': item['price'] ?? 0.0,
              'quantity': item['quantity'] ?? 0,
              'total': item['total'] ?? 0.0,
            };
          }).toList();

      // Prepare Firestore document data
      Map<String, dynamic> firestoreData = {
        'customerName': billData['customerName'] ?? '',
        'mobileNumber': billData['mobileNumber'] ?? '',
        'billDate': billData['billDate'] ?? '',
        'payStatus': billData['payStatus'] ?? '',
        'paymentMethod': billData['paymentMethod'] ?? '',
        'totalAmount': billData['totalAmount'] ?? 0.0,
        'purchaseList': purchaseList,
      };

      // Upload data to Firestore
      await _firestore.collection('bills').add(firestoreData);

      return true;
    } catch (e) {
      print("Error uploading bill: $e");
      return false;
    }
  }

  Future<File?> generatePdfAndSave(Map<String, dynamic> billData) async {
    final pdf = pw.Document();

    final DateTime now = DateTime.now();
    final String billDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String billTime = DateFormat('hh:mm a').format(now);

    final shopDetails = await _service.fetchShopDetails();
    print('shopdetails are $shopDetails');
    final String shopName = shopDetails?['shopName'] ?? "Shop Name";
    final String shopAddress = shopDetails?['address'] ?? "Address";
    final String shopMobile = shopDetails?['mobileNumber'] ?? "Phone";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(68 * PdfPageFormat.mm, 90 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    shopName,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    "$shopAddress\nPhone: $shopMobile",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text(
                    "RECEIPT",
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Receipt No: #1001",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      "Bill Date: $billDate",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    "Bill Time: $billTime",
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ),
                pw.SizedBox(height: 6),

                // ==== Table Header ====
                pw.Table(
                  border: pw.TableBorder(
                    top: pw.BorderSide(width: 1, color: PdfColors.black),
                    bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                    3: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'DESCRIPTION',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'QTY',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'PRICE',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'TOTAL',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ==== Item Rows ====
                pw.Table(
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                    3: pw.FlexColumnWidth(1),
                  },
                  children: [
                    ...billData["purchaseList"].map<pw.TableRow>((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(
                              item["productCategory"].toString(),
                              style: pw.TextStyle(fontSize: 8),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(
                              item["quantity"].toString(),
                              style: pw.TextStyle(fontSize: 8),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(
                              item["price"].toString(),
                              style: pw.TextStyle(fontSize: 8),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(
                              (item["price"] * item["quantity"]).toString(),
                              style: pw.TextStyle(fontSize: 8),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.SizedBox(height: 6),

                // ==== Summary Table ====
                pw.Table(
                  border: pw.TableBorder(
                    top: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Subtotal',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '${billData["totalAmount"]}',
                            style: pw.TextStyle(fontSize: 8),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Discount',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '${billData["discount"]}',
                            style: pw.TextStyle(fontSize: 8),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ==== Total Row with Top & Bottom Border ====
                pw.Table(
                  border: pw.TableBorder(
                    top: pw.BorderSide(width: 1, color: PdfColors.black),
                    bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Total',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '${billData["netAmount"]}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    "THANK YOU FOR SHOPPING!",
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return null;
      final filePath =
          '${dir.path}/bill_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      print("❌ Error saving PDF: $e");
      return null;
    }
  }
}
