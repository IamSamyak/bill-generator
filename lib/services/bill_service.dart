import 'package:bill_generator/models/Bill.dart';
import 'package:bill_generator/models/ShopDetail.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'company_profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillService {
  final CompanyProfileService _companyProfileService = CompanyProfileService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? lastDocument;

  Future<List<Bill>> fetchBills({
    String payStatusFilter = 'All',
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('bills')
          .orderBy('billDate', descending: true)
          .limit(limit);

      // Apply filter in query, only if payStatus is NOT "All"
      if (payStatusFilter != 'All') {
        query = query.where('payStatus', isEqualTo: payStatusFilter);
      }

      if (lastDocument != null) {
        print("Fetching bills after document ID: ${lastDocument.id}");
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot querySnapshot = await query.get();

      // Update last document for pagination
      this.lastDocument =
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

      List<Bill> bills =
          querySnapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Bill.fromFirestore(data, doc.id);
          }).toList();

      print("Fetched ${bills.length} bills.");

      return bills;
    } catch (e) {
      print("Error fetching bills: $e");
      throw Exception('Failed to fetch bills: $e');
    }
  }

  Future<WeeklyBillReport> getBillsFromLast7Days() async {
    try {
      DateTime now = DateTime.now();
      DateTime sevenDaysAgo = now.subtract(const Duration(days: 6));

      // Use Timestamp for querying dates
      Timestamp startTimestamp = Timestamp.fromDate(
        DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day),
      );
      Timestamp endTimestamp = Timestamp.fromDate(
        DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
      );

      QuerySnapshot querySnapshot =
          await _firestore
              .collection('bills')
              .where('billDate', isGreaterThanOrEqualTo: startTimestamp)
              .where('billDate', isLessThanOrEqualTo: endTimestamp)
              .orderBy('billDate')
              .get();

      List<Bill> bills = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        bills.add(Bill.fromFirestore(data, doc.id));
      }

      // Initialize last 7 days with 0.0
      Map<String, double> weeklyRevenue = {};
      for (int i = 0; i < 7; i++) {
        DateTime date = now.subtract(Duration(days: i));
        String key = DateFormat('yyyy-MM-dd').format(date);
        weeklyRevenue[key] = 0.0;
      }

      // Sum up revenues by date string
      for (var bill in bills) {
        String dateStr = DateFormat('yyyy-MM-dd').format(bill.date);
        if (weeklyRevenue.containsKey(dateStr)) {
          weeklyRevenue[dateStr] = (weeklyRevenue[dateStr] ?? 0) + bill.amount;
        }
      }

      double totalRevenue = weeklyRevenue.values.fold(
        0,
        (sum, value) => sum + value,
      );
      int totalPaidBills =
          bills.where((bill) => bill.payStatus == "Paid").length;
      int totalPendingBills =
          bills.where((bill) => bill.payStatus == "Unpaid").length;

      return WeeklyBillReport(
        bills: bills,
        weeklyRevenue: Map.fromEntries(
          weeklyRevenue.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)),
        ),
        totalRevenue: totalRevenue,
        totalPaidBills: totalPaidBills,
        totalPendingBills: totalPendingBills,
      );
    } catch (e) {
      throw Exception('Failed to fetch bills from last 7 days: $e');
    }
  }

  Future<List<Bill>> searchBillsWithinDateRange({
    required DateTimeRange dateRange,
    String payStatusFilter = 'All',
  }) async {
    try {
      // Convert the date range to Timestamps for querying Firestore
      Timestamp startTimestamp = Timestamp.fromDate(
        DateTime(
          dateRange.start.year,
          dateRange.start.month,
          dateRange.start.day,
        ),
      );
      Timestamp endTimestamp = Timestamp.fromDate(
        DateTime(
          dateRange.end.year,
          dateRange.end.month,
          dateRange.end.day,
          23,
          59,
          59,
          999,
        ),
      );

      QuerySnapshot querySnapshot =
          await _firestore
              .collection('bills')
              .where('billDate', isGreaterThanOrEqualTo: startTimestamp)
              .where('billDate', isLessThanOrEqualTo: endTimestamp)
              .orderBy('billDate', descending: true)
              .get();

      List<Bill> bills = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        if (payStatusFilter == 'All' || data['payStatus'] == payStatusFilter) {
          bills.add(Bill.fromFirestore(data, doc.id));
        }
      }

      return bills;
    } catch (e) {
      throw Exception('Failed to search bills in date range: $e');
    }
  }

  Future<List<Bill>> searchBillsByReceiptId({required String receiptId}) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('bills').doc(receiptId).get();

      if (!docSnapshot.exists) {
        return [];
      }

      var data = docSnapshot.data() as Map<String, dynamic>;
      return [Bill.fromFirestore(data, docSnapshot.id)];
    } catch (e) {
      throw Exception('Failed to fetch bill by receiptId: $e');
    }
  }

  Future<List<Bill>> searchBillsByCustomerName({
    required String customerName,
  }) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('bills')
              .where('customerName', isEqualTo: customerName)
              .get();

      List<Bill> bills = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        bills.add(Bill.fromFirestore(data, doc.id));
      }

      return bills;
    } catch (e) {
      throw Exception('Failed to fetch bills by customer name: $e');
    }
  }

  Future<String> uploadBillToFirebase(Bill bill) async {
    try {
      // Step 1: Generate a unique receipt ID with daily counter
      String receiptId = await _generateReceiptId();

      // Step 2: Prepare Firestore document data from Bill instance
      Map<String, dynamic> firestoreData = {
        'receiptId': receiptId,
        'customerName': bill.customerName,
        'mobileNumber': bill.mobileNumber,
        'billDate': Timestamp.fromDate(
          bill.date,
        ), // Store as Firestore Timestamp
        'payStatus': bill.payStatus,
        'paymentMethod': bill.paymentMethod,
        'totalAmount': bill.amount,
        'purchaseList': bill.purchaseList.map((item) => item.toMap()).toList(),
        'timestamp': FieldValue.serverTimestamp(), // Optional created time
      };

      // Step 3: Upload data to Firestore under 'bills' collection with doc ID = receiptId
      await _firestore.collection('bills').doc(receiptId).set(firestoreData);

      return receiptId;
    } catch (e) {
      print("Error uploading bill: $e");
      return "";
    }
  }

  Future<String> _generateReceiptId() async {
    final now = DateTime.now();
    final datePart =
        "${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final docId = "receipts_$datePart";

    final counterRef = _firestore.collection('counters').doc(docId);

    // Use a transaction to atomically increment the counter
    final newCount = await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int currentCount = 0;
      if (snapshot.exists) {
        currentCount = snapshot.data()?['count'] ?? 0;
      }

      final updatedCount = currentCount + 1;
      transaction.set(counterRef, {
        'count': updatedCount,
      }, SetOptions(merge: true));

      return updatedCount;
    });

    // Format receipt ID: datePart + 4-digit zero-padded count
    final receiptId = "$datePart${newCount.toString().padLeft(4, '0')}";
    return receiptId;
  }

  Future<bool> updateBillToFirebase(Bill bill) async {
    try {
      // Prepare updated data map (similar to upload but no new receiptId generation)
      Map<String, dynamic> firestoreData = {
        'customerName': bill.customerName,
        'mobileNumber': bill.mobileNumber,
        'billDate': bill.date, // updated bill date
        'payStatus': bill.payStatus,
        'paymentMethod': bill.paymentMethod,
        'totalAmount': bill.amount,
        'purchaseList': bill.purchaseList.map((item) => item.toMap()).toList(),
        'timestamp': FieldValue.serverTimestamp(), // update timestamp as well
      };

      // Update the Firestore document identified by receiptId
      await _firestore
          .collection('bills')
          .doc(bill.receiptId)
          .update(firestoreData);

      return true; // indicate success
    } catch (e) {
      print("Error updating bill: $e");
      return false; // indicate failure
    }
  }

  Future<File?> generatePdfAndSave(Bill bill, String receiptId) async {
    final pdf = pw.Document();
    ShopDetail? shopDetail = await _companyProfileService.fetchShopDetails();
    if (shopDetail == null) {
      return null;
    }

    final DateTime now = DateTime.now();
    final String billDate = DateFormat('yyyy-MM-dd').format(bill.date);
    final String billTime = DateFormat('hh:mm a').format(now);

    final String shopName = shopDetail.shopName;
    final String shopAddress = shopDetail.address;
    final String shopMobile = shopDetail.mobileNumber;

    final double discount = bill.amount * 0.10;
    final double netAmount = bill.amount - discount;

    final styleNormal = pw.TextStyle(fontSize: 8);
    final styleBold = pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);
    final styleTitle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
    );
    final styleHeading = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    final styleTotal = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          100 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text(shopName, style: styleTitle)),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    "$shopAddress\nPhone: $shopMobile",
                    textAlign: pw.TextAlign.center,
                    style: styleNormal,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Center(child: pw.Text("RECEIPT", style: styleHeading)),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Receipt #: $receiptId", style: styleNormal),
                    pw.Text("Bill Date: $billDate", style: styleNormal),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text("Bill Time: $billTime", style: styleNormal),
                ),
                pw.SizedBox(height: 6),

                // === Table Header ===
                pw.Table(
                  border: pw.TableBorder(
                    top: pw.BorderSide(width: 0.5, color: PdfColors.black),
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.black),
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
                          child: pw.Text('DESCRIPTION', style: styleBold),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'QTY',
                            style: styleBold,
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'PRICE',
                            style: styleBold,
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'TOTAL',
                            style: styleBold,
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // === Item Rows ===
                pw.Table(
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                    3: pw.FlexColumnWidth(1),
                  },
                  children: [
                    ...bill.purchaseList.map<pw.TableRow>((item) {
                      double price = item.price;
                      int qty = item.quantity;
                      double total = price * qty;

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(
                              item.productCategory,
                              style: styleNormal,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(
                              qty.toString(),
                              style: styleNormal,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(
                              price.toStringAsFixed(2),
                              style: styleNormal,
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(
                              total.toStringAsFixed(2),
                              style: styleNormal,
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.SizedBox(height: 6),

                // === Summary Table ===
                pw.Table(
                  border: pw.TableBorder(
                    top: pw.BorderSide(width: 0.5, color: PdfColors.black),
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
                          child: pw.Text('Subtotal', style: styleNormal),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            bill.amount.toStringAsFixed(2),
                            style: styleNormal,
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Discount (10%)', style: styleNormal),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            discount.toStringAsFixed(2),
                            style: styleNormal,
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // === Total ===
                pw.Table(
                  border: pw.TableBorder(
                    top: pw.BorderSide(width: 0.5, color: PdfColors.black),
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.black),
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
                          child: pw.Text('Total', style: styleTotal),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            netAmount.toStringAsFixed(2),
                            style: styleTotal,
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
                    style: styleHeading,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: receiptId,
                    width: 50,
                    height: 50,
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
