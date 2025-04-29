import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;

class BillService {
  final String projectId = dotenv.env['PROJECT_ID'] ?? '';
  final String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';

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
  final PdfDocument document = PdfDocument();
  final DateTime now = DateTime.now();
  final String billDate =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  // Create a page with reduced width (80mm width ~ 226.77 points)
  final PdfPage page = document.pages.add();
  final PdfGraphics graphics = page.graphics;
  final Size pageSize = Size(220, 350);  // Reduced width and adjusted height
  // page.graphics. = pageSize;

  // Define fonts
  final PdfFont titleFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    16,
    style: PdfFontStyle.bold,
  );
  final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 8);
  final PdfFont boldFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    9,
    style: PdfFontStyle.bold,
  );

  double y = 0;

  // Header - Centered (Updated for bold and centered address)
  final Size textSize = titleFont.measureString("AKASH MEN'S WEAR");
  final double centerX = (pageSize.width - textSize.width) / 2;
  graphics.drawString(
    "AKASH MEN'S WEAR",
    titleFont,
    bounds: Rect.fromLTWH(centerX, y, pageSize.width, 20),
  );
  y += 25;

  // Updated to make address bold and centered
  final PdfFont centerBoldFont = PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold);
  final Size addressSize = centerBoldFont.measureString("123 Main Road, Kolkata - 700001\nPhone: +91-9876543210");
  final double addressX = (pageSize.width - addressSize.width) / 2;
  graphics.drawString(
    "123 Main Road, Kolkata - 700001\nPhone: +91-9876543210",
    centerBoldFont,
    bounds: Rect.fromLTWH(addressX, y, pageSize.width, 30),
  );
  y += 35;

  // Receipt Title - Centered (Bold)
  final Size receiptTitleSize = boldFont.measureString("RECEIPT");
  final double receiptCenterX = (pageSize.width - receiptTitleSize.width) / 2;
  graphics.drawString(
    "RECEIPT",
    boldFont,
    bounds: Rect.fromLTWH(receiptCenterX, y, pageSize.width, 15),
  );
  y += 20;

  // Receipt Details
  graphics.drawString(
    "Receipt No: #1001",
    normalFont,
    bounds: Rect.fromLTWH(0, y, 100, 15),
  );
  graphics.drawString(
    billDate,
    normalFont,
    bounds: Rect.fromLTWH(120, y, 100, 15),
  );
  y += 20;

  // Create Grid with Item, Qty, Price
  final PdfGrid grid = PdfGrid();
  grid.columns.add(count: 3);
  grid.headers.add(1);

  grid.headers[0].cells[0].value = "Item";
  grid.headers[0].cells[1].value = "Qty";
  grid.headers[0].cells[2].value = "Price";
  grid.headers[0].style.font = boldFont;

  // Add purchase data
  for (var item in billData["purchaseList"]) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = item["productCategory"].toString();
    row.cells[1].value = item["quantity"].toString();
    row.cells[2].value = item["price"].toString();

    // Remove horizontal lines for individual items
    for (int i = 0; i < grid.columns.count; i++) {
      row.cells[i].style.borders.bottom = PdfPens.transparent;
    }
  }

  // Totals (no horizontal lines between subtotal, discount, and total)
  final PdfGridRow subtotalRow = grid.rows.add();
  subtotalRow.cells[0].value = "Subtotal";
  subtotalRow.cells[1].value = "";
  subtotalRow.cells[2].value = billData["totalAmount"].toString();

  final PdfGridRow discountRow = grid.rows.add();
  discountRow.cells[0].value = "Discount";
  discountRow.cells[1].value = "";
  discountRow.cells[2].value = billData["discount"].toString();

  final PdfGridRow totalRow = grid.rows.add();
  totalRow.cells[0].value = "Total";
  totalRow.cells[1].value = "";
  totalRow.cells[2].value = billData["netAmount"].toString();
  totalRow.style.font = boldFont;

  // Apply padding and font
  grid.style.font = normalFont;
  grid.style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);

  // Remove vertical borders
  for (int i = 0; i < grid.columns.count; i++) {
    final List<PdfGridRow> allRows = [grid.headers[0]];
    for (int j = 0; j < grid.rows.count; j++) {
      allRows.add(grid.rows[j]);
    }
    for (PdfGridRow row in allRows) {
      row.cells[i].style.borders.left = PdfPens.transparent;
      row.cells[i].style.borders.right = PdfPens.transparent;
    }
  }

  // Remove horizontal lines for totals
  for (int i = 0; i < grid.rows.count; i++) {
    final PdfGridRow row = grid.rows[i];
    if (i == grid.rows.count - 1 || i == grid.rows.count - 2 || i == grid.rows.count - 3) {
      // Do not remove horizontal lines for subtotal, discount, and total
      continue;
    }
    for (int j = 0; j < grid.columns.count; j++) {
      row.cells[j].style.borders.bottom = PdfPens.transparent;
    }
  }

  // Draw grid
  grid.draw(
    page: page,
    bounds: Rect.fromLTWH(0, y, pageSize.width, pageSize.height - y - 20),  // Reduced bottom spacing
  );

  final Size footerSize = boldFont.measureString("THANK YOU FOR SHOPPING!");
  final double footerCenterX = (pageSize.width - footerSize.width) / 2;
  graphics.drawString(
    "THANK YOU FOR SHOPPING!",
    boldFont,
    bounds: Rect.fromLTWH(footerCenterX, pageSize.height - 20, pageSize.width, 15),
  );

  // Save and return
  try {
    final dir = await getExternalStorageDirectory();
    if (dir == null) return null;

    final filePath =
        '${dir.path}/bill_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);

    await file.writeAsBytes(await document.save());
    document.dispose();
    return file;
  } catch (e) {
    print("❌ Error saving PDF: $e");
    return null;
  }
}

/* generatePdfAndSave(Map<String, dynamic> billData) async {
  final pdf = pw.Document();
  final DateTime now = DateTime.now();
  final String billDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  final String billTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(68 * PdfPageFormat.mm, 150 * PdfPageFormat.mm), // Set width to 75mm
      build: (pw.Context context) {
        return pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "AKASH MEN'S WEAR",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  "123 Main Road, Kolkata - 700001\nPhone: +91-9876543210",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                "RECEIPT",
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text(
                    "Receipt No: #1001 ",
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    "Bill Date: $billDate",
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              // Separator above the purchase list
              pw.Container(
                width: double.infinity,
                height: 1,
                color: PdfColors.black,
              ),
              pw.SizedBox(height: 4),
              // Table with data
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.symmetric(
                    horizontal: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                ),
                child: pw.Table.fromTextArray(
                  headers: ["Item", "Qty", "Price"],
                  data: billData["purchaseList"].map<List<String>>((item) {
                    return [
                      item["productCategory"].toString(),
                      item["quantity"].toString(),
                      item["price"].toString(),
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: pw.TextStyle(fontSize: 8),
                  cellAlignment: pw.Alignment.centerLeft,
                  border: pw.TableBorder(
                    top: pw.BorderSide.none,
                    bottom: pw.BorderSide.none,
                    left: pw.BorderSide.none,
                    right: pw.BorderSide.none,
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2.5),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1.5),
                  },
                ),
              ),
              pw.SizedBox(height: 4),
              // Subtotal, Discount, and Total aligned properly
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Subtotal:", style: pw.TextStyle(fontSize: 8)),
                  pw.Text("${billData["totalAmount"]}", style: pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Discount:", style: pw.TextStyle(fontSize: 8)),
                  pw.Text("${billData["discount"]}", style: pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total:", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text("${billData["netAmount"]}", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
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
} */


}
