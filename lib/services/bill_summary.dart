import 'package:bill_generator/models/Bill.dart';

class BillSummary {
  final double subtotal;
  final double totalDiscount;
  final double netAmount;

  BillSummary({
    required this.subtotal,
    required this.totalDiscount,
    required this.netAmount,
  });

  // Factory constructor to calculate from purchase list
  factory BillSummary.fromPurchases(List<PurchaseItem> purchases) {
    double subtotal = 0;
    double totalDiscount = 0;

    for (var item in purchases) {
      final itemTotal = item.price * item.quantity;
      final discountPercent = item.discount.toDouble(); 
      final discountAmount = itemTotal * discountPercent / 100;

      subtotal += itemTotal;
      totalDiscount += discountAmount;
    }

    final netAmount = subtotal - totalDiscount;
    return BillSummary(
      subtotal: subtotal,
      totalDiscount: totalDiscount,
      netAmount: netAmount,
    );
  }
}
