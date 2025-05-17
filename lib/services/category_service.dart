import '../models/Category.dart';

class CategoryService {
  static const String _basePath = 'assets/images/categories/';

  List<Category> getCategories() {
    final labels = [
      'Tshirt',
      'Jeans',
      'Shirt',
      'UnderWear',
      'InnerWear',
    ];

    return labels.map((label) {
      final imagePath = '$_basePath$label.png';

      return Category(label: label, imagePath: imagePath);
    }).toList();
  }
}
