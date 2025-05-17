import 'package:bill_generator/models/ShopDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'shopDetails';
  final String _document = 'shopDetail';

  /// Fetch shop details
  Future<ShopDetail?> fetchShopDetails() async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(_document).get();

      if (docSnapshot.exists) {
        return ShopDetail.fromMap(docSnapshot.data()!);
      }
    } catch (e) {
      print('Error fetching shop details: $e');
    }

    return null;
  }

  Future<bool> uploadShopDetails({required ShopDetail shopDetail}) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(_document)
          .set(shopDetail.toMap());
      return true;
    } catch (e) {
      print('Error uploading shop details: $e');
      return false;
    }
  }
}
