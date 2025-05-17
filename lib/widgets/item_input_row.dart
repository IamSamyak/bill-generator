import 'package:flutter/material.dart';
import '../models/Category.dart';
import '../services/category_service.dart'; // Import your service

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
  late final List<Category> categories;

  @override
  void initState() {
    super.initState();
    categories = CategoryService().getCategories();
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
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.productCategoryController.text.isEmpty
                      ? null
                      : widget.productCategoryController.text,
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.label,
                      child: Text(category.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        widget.productCategoryController.text = value;
                      });
                    }
                  },
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  menuWidth: 122,
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
