// lib/models/shop_detail.dart

class ShopDetail {
  final String shopName;
  final String mobileNumber;
  final String address;
  final String logo;

  ShopDetail({
    required this.shopName,
    required this.mobileNumber,
    required this.address,
    required this.logo,
  });

  factory ShopDetail.fromMap(Map<String, dynamic> map) {
    return ShopDetail(
      shopName: map['shopName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      address: map['address'] ?? '',
      logo: map['logo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopName': shopName,
      'mobileNumber': mobileNumber,
      'address': address,
      'logo': logo,
    };
  }

  @override
  String toString() {
    return 'ShopDetail(shopName: $shopName, mobileNumber: $mobileNumber, address: $address, logo: $logo)';
  }
}
