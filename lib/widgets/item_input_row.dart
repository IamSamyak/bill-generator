import 'package:flutter/material.dart';

class ItemInputRow extends StatefulWidget {
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
  _ItemInputRowState createState() => _ItemInputRowState();
}

class _ItemInputRowState extends State<ItemInputRow> {
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
                  items: const [
                    DropdownMenuItem(value: "Shirt", child: Text("Shirt")),
                    DropdownMenuItem(value: "Pant", child: Text("Pant")),
                  ],
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
        ],
      ),
    );
  }
}
