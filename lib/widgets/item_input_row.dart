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
            child: TextField(
              controller: productCategoryController,
              decoration: const InputDecoration(
                labelText: "Item Type",
                border: OutlineInputBorder(),
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
