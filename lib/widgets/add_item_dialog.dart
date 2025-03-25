import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  String? selectedItem;
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Item Type"),
            items: ["Shirt", "Pant", "T-shirt"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedItem = value),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantity"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (selectedItem != null && priceController.text.isNotEmpty && quantityController.text.isNotEmpty) {
              Navigator.pop(context, {
                "type": selectedItem,
                "price": priceController.text,
                "quantity": quantityController.text
              });
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
