class Category {
  final String label;
  final String? imagePath; 
  final int discount;

  Category({
    required this.label,
    this.imagePath,
    this.discount = 10
  });
}
