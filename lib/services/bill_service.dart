import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'company_profile_service.dart';

class BillService {
  final String projectId = dotenv.env['PROJECT_ID'] ?? '';
  final String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
  final CompanyProfileService _service = CompanyProfileService();

  Future<List<Map<String, dynamic>>> fetchBills({
    String payStatusFilter = 'All',
  }) async {
    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/bills?key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<Map<String, dynamic>> bills = [];

      for (var doc in decoded['documents'] ?? []) {
        final fields = doc['fields'];

        var purchaseList =
            (fields['purchaseList']?['arrayValue']?['values'] ?? []).map<
              Map<String, dynamic>
            >((item) {
              var productCategory =
                  item['mapValue']['fields']['productCategory']?['stringValue'] ??
                  '';
              var productName =
                  item['mapValue']['fields']['productName']?['stringValue'] ??
                  '';
              var price =
                  double.tryParse(
                    item['mapValue']['fields']?['price']?['doubleValue']
                            ?.toString() ??
                        '0',
                  ) ??
                  0.0;
              var quantity =
                  int.tryParse(
                    item['mapValue']['fields']['quantity']?['integerValue'] ??
                        '0',
                  ) ??
                  0;
              var total =
                  double.tryParse(
                    item['mapValue']['fields']?['total']?['doubleValue']
                            ?.toString() ??
                        '0',
                  ) ??
                  0.0;

              return {
                'productCategory': productCategory,
                'productName': productName,
                'price': price,
                'quantity': quantity,
                'total': total,
              };
            }).toList();

        final rawDate = fields['billDate']?['stringValue'];
        String formattedDate = '';
        if (rawDate != null) {
          final parsedDate = DateTime.tryParse(rawDate);
          if (parsedDate != null) {
            formattedDate =
                '${parsedDate.year.toString().padLeft(4, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
          }
        }

        final payStatus = fields['payStatus']?['stringValue'] ?? '';

        if (payStatusFilter == 'All' || payStatus == payStatusFilter) {
          bills.add({
            'customerName': fields['customerName']?['stringValue'] ?? '',
            'mobileNumber': fields['mobileNumber']?['stringValue'] ?? '',
            'date': formattedDate,
            'payStatus': payStatus,
            'paymentMethod': fields['paymentMethod']?['stringValue'] ?? '',
            'amount':
                double.tryParse(
                  fields['totalAmount']?['doubleValue']?.toString() ?? '0',
                ) ??
                0.0,
            'purchaseList': purchaseList,
          });
        }
      }

      return bills;
    } else {
      throw Exception('Failed to fetch bills: ${response.body}');
    }
  }

  Future<bool> uploadBillToFirebase(Map<String, dynamic> billData) async {
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
                  "values":
                      value.map((item) {
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

      return response.statusCode == 200;
    } catch (e) {
      print("Error in generateBill: $e");
      return false;
    }
  }

Future<File?> generatePdfAndSave(Map<String, dynamic> billData) async {
  final pdf = pw.Document();

  final DateTime now = DateTime.now();
  final String billDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
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
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
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
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 4),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Receipt No: #1001", style: pw.TextStyle(fontSize: 8)),
                  pw.Text("Bill Date: $billDate", style: pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text("Bill Time: $billTime", style: pw.TextStyle(fontSize: 8)),
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
                        child: pw.Text('DESCRIPTION', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('QTY', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('PRICE', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('TOTAL', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
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
                          child: pw.Text(item["productCategory"].toString(), style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(item["quantity"].toString(), style: pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(item["price"].toString(), style: pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text((item["price"]*item["quantity"]).toString(), style: pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
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
                        child: pw.Text('Subtotal', style: pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${billData["totalAmount"]}', style: pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Discount', style: pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${billData["discount"]}', style: pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
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
                        child: pw.Text('Total', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${billData["netAmount"]}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  "THANK YOU FOR SHOPPING!",
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
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
    final filePath = '${dir.path}/bill_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return file;
  } catch (e) {
    print("❌ Error saving PDF: $e");
    return null;
  }
}
}
