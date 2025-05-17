import 'package:flutter/foundation.dart';
import 'package:bill_generator/models/ShopDetail.dart';

class ShopDetailProvider extends ChangeNotifier {
  ShopDetail? _shopDetail;

  ShopDetail? get shopDetail => _shopDetail;

  void setShopDetail(ShopDetail? detail) {
    _shopDetail = detail;
    notifyListeners();  // Notifies all listeners/widgets to rebuild if needed
  }
}
