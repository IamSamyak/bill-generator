import 'package:flutter/material.dart';
import '../models/Category.dart';
import '../services/category_service.dart';

class ItemInputRow extends StatefulWidget {
  final TextEditingController productCategoryController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final VoidCallback onRemove;
  final bool showRemoveIcon;

  const ItemInputRow({
    super.key,
    required this.productCategoryController,
    required this.quantityController,
    required this.priceController,
    required this.onRemove,
    this.showRemoveIcon = false,
  });

  @override
  _ItemInputRowState createState() => _ItemInputRowState();
}

class _ItemInputRowState extends State<ItemInputRow> {
  late List<Category> categories;
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    categories = CategoryService().getCategories();

    // Try to find matching category, otherwise set to null manually
    selectedCategory =
        categories.any(
              (cat) => cat.label == widget.productCategoryController.text,
            )
            ? categories.firstWhere(
              (cat) => cat.label == widget.productCategoryController.text,
            )
            : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Item Type",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Category>(
                  value: selectedCategory,
                  items:
                      categories.map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(
                            category.label,
                          ), // Show text in dropdown list
                        );
                      }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return categories.map<Widget>((category) {
                      return category.imagePath != null
                          ? Image.asset(
                            category.imagePath!,
                            width: 32,
                            height: 32,
                          )
                          : const Icon(Icons.image_not_supported);
                    }).toList(); // Show image when dropdown is closed
                  },
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                        widget.productCategoryController.text = value.label;
                      });
                    }
                  },
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  elevation: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: widget.quantityController,
              decoration: const InputDecoration(
                labelText: "Qty",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: widget.priceController,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 8),
          if (widget.showRemoveIcon)
            GestureDetector(
              onTap: widget.onRemove,
              child: const CircleAvatar(
                backgroundColor: Color(0xFFD32F2F),
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
