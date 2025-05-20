import '../models/Category.dart';

class CategoryService {
  static const String _basePath = 'assets/images/categories/';

  final List<String> _labels = ['Tshirt', 'Jeans', 'Shirt', 'UnderWear', 'InnerWear'];

  List<Category> getCategories() {
    return _labels.map((label) {
      int discount = (label == 'Tshirt' || label == 'Jeans' || label == 'Shirt') ? 10 : 0;
      return Category(label: label, discount: discount, imagePath: '$_basePath$label.png');
    }).toList();
  }

  Category getCategoryByLabel(String label) {
    return getCategories().firstWhere(
      (cat) => cat.label.toLowerCase() == label.toLowerCase(),
      orElse: () => Category(
        label: label,
        discount: 0,
      ),
    );
  }
}
