// lib/models/shop_detail.dart

class ShopDetail {
  final String shopName;
  final String mobileNumber;
  final String address;

  ShopDetail({
    required this.shopName,
    required this.mobileNumber,
    required this.address,
  });

  factory ShopDetail.fromMap(Map<String, dynamic> map) {
    return ShopDetail(
      shopName: map['shopName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      address: map['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopName': shopName,
      'mobileNumber': mobileNumber,
      'address': address,
    };
  }

  @override
  String toString() {
    return 'ShopDetail(shopName: $shopName, mobileNumber: $mobileNumber, address: $address)';
  }
}
