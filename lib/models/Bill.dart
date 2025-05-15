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

  factory Bill.fromFirestore(Map<String, dynamic> data,String documentId) {
    DateTime parsedDate =
        DateTime.tryParse(data['billDate'] ?? '') ?? DateTime.now();


    List<PurchaseItem> purchaseItems = (data['purchaseList'] ?? [])
        .map<PurchaseItem>((item) => PurchaseItem.fromMap(item))
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
      'date': date,
      'payStatus': payStatus,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'purchaseList': purchaseList.map((p) => p.toMap()).toList(),
    };
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
}
