import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BillService {
  final String projectId = dotenv.env['PROJECT_ID'] ?? '';
  final String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';

Future<List<Map<String, dynamic>>> fetchBills({String payStatusFilter = 'All'}) async {
  final url = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/bills?key=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final List<Map<String, dynamic>> bills = [];

    for (var doc in decoded['documents'] ?? []) {
      final fields = doc['fields'];

      var purchaseList = (fields['purchaseList']?['arrayValue']?['values'] ?? []).map<Map<String, dynamic>>((item) {
        var productCategory = item['mapValue']['fields']['productCategory']?['stringValue'] ?? '';
        var productName = item['mapValue']['fields']['productName']?['stringValue'] ?? '';
        var price = double.tryParse(item['mapValue']['fields']?['price']?['doubleValue']?.toString() ?? '0') ?? 0.0;
        var quantity = int.tryParse(item['mapValue']['fields']['quantity']?['integerValue'] ?? '0') ?? 0;
        var total = double.tryParse(item['mapValue']['fields']?['total']?['doubleValue']?.toString() ?? '0') ?? 0.0;

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
          formattedDate = '${parsedDate.year.toString().padLeft(4, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
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
          'amount': double.tryParse(fields['totalAmount']?['doubleValue']?.toString() ?? '0') ?? 0.0,
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

      return response.statusCode == 200;
    } catch (e) {
      print("Error in generateBill: $e");
      return false;
    }
  }

  Future<File?> generatePdfAndSave(Map<String, dynamic> billData) async {
    final pdf = pw.Document();
    final DateTime now = DateTime.now();
    final String billDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String billTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 50,
                height: 50,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: PdfColors.grey,
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  "A",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                "Akash Men's Wear",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                "$billDate | $billTime",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.SizedBox(height: 10),

              pw.Text(
                "Name: ${billData["customerName"]}",
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                "Mobile: ${billData["mobileNumber"]}",
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 10),

              pw.Padding(
                padding: pw.EdgeInsets.symmetric(horizontal: 10),
                child: pw.Table.fromTextArray(
                  headers: ["Item", "Qty", "Price"],
                  data:
                      billData["purchaseList"].map<List<String>>((item) {
                        return [
                          item["productCategory"].toString(),
                          item["quantity"].toString(),
                          "${item["price"]}",
                        ];
                      }).toList(),
                  headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.center,
                ),
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 5),

              pw.Text(
                "Order Summary",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                "Total Items: ${billData["purchaseList"].length}",
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                "Total: ${billData["totalAmount"]}",
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                "Discount: ${billData["discount"]}",
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                "Final Amount: ${billData["netAmount"]}",
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

     try {
    final dir = await getExternalStorageDirectory(); // Shareable directory
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
