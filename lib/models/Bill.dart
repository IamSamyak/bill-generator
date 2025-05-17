import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Timestamp

class Bill {
  final String receiptId;
  final String customerName;
  final String mobileNumber;
  final DateTime date;
  final String payStatus;
  final String paymentMethod;
  final double amount;
  final List<PurchaseItem> purchaseList;

  Bill({
    required this.receiptId,
    required this.customerName,
    required this.mobileNumber,
    required this.date,
    required this.payStatus,
    required this.paymentMethod,
    required this.amount,
    required this.purchaseList,
  });

  factory Bill.fromFirestore(Map<String, dynamic> data, String documentId) {
    final dynamic billDateField = data['billDate'];

    DateTime parsedDate;

    if (billDateField is Timestamp) {
      parsedDate = billDateField.toDate();
    } else if (billDateField is String) {
      parsedDate = DateTime.tryParse(billDateField) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    List<PurchaseItem> purchaseItems = (data['purchaseList'] ?? [])
        .map<PurchaseItem>((item) => PurchaseItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();

    return Bill(
      receiptId: documentId,
      customerName: data['customerName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      date: parsedDate,
      payStatus: data['payStatus'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      amount: (data['totalAmount'] ?? 0.0).toDouble(),
      purchaseList: purchaseItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'billDate': Timestamp.fromDate(date),
      'payStatus': payStatus,
      'paymentMethod': paymentMethod,
      'totalAmount': amount,
      'purchaseList': purchaseList.map((p) => p.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'Bill('
        'receiptId: $receiptId, '
        'customerName: $customerName, '
        'mobileNumber: $mobileNumber, '
        'date: ${date.toIso8601String()}, '
        'payStatus: $payStatus, '
        'paymentMethod: $paymentMethod, '
        'amount: $amount, '
        'purchaseList: $purchaseList'
        ')';
  }
}

class PurchaseItem {
  final String productCategory;
  final String productName;
  final double price;
  final int quantity;
  final double total;

  PurchaseItem({
    required this.productCategory,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    return PurchaseItem(
      productCategory: map['productCategory'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      total: (map['total'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productCategory': productCategory,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  @override
  String toString() {
    return 'PurchaseItem('
        'productCategory: $productCategory, '
        'productName: $productName, '
        'price: $price, '
        'quantity: $quantity, '
        'total: $total'
        ')';
  }
}

class WeeklyBillReport {
  final List<Bill> bills;
  final Map<String, double> weeklyRevenue; // e.g. "2025-W20" : 1234.56
  final double totalRevenue;
  final int totalPaidBills;
  final int totalPendingBills;

  WeeklyBillReport({
    required this.bills,
    required this.weeklyRevenue,
    required this.totalRevenue,
    required this.totalPaidBills,
    required this.totalPendingBills,
  });

  @override
  String toString() {
    return 'WeeklyBillReport('
           'totalRevenue: $totalRevenue, '
           'totalPaidBills: $totalPaidBills, '
           'totalPendingBills: $totalPendingBills, '
           'weeklyRevenue: $weeklyRevenue, '
           'bills: ${bills.map((bill) => bill.toString()).toList()}'
           ')';
  }
}
