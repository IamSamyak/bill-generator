import 'package:flutter/material.dart';

class ItemInputRow extends StatelessWidget {
  final TextEditingController productCategoryController;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  const ItemInputRow({
    Key? key,
    required this.productCategoryController,
    required this.quantityController,
    required this.priceController,
  }) : super(key: key);

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
                  value: productCategoryController.text.isEmpty
                      ? null
                      : productCategoryController.text,
                  items: const [
                    DropdownMenuItem(value: "Shirt", child: Text("Shirt")),
                    DropdownMenuItem(value: "Pant", child: Text("Pant")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      productCategoryController.text = value;
                    }
                  },
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
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
              controller: quantityController,
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
              controller: priceController,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}
