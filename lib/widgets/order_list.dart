import 'package:flutter/material.dart';

class OrderList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const OrderList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
      child: DataTable(
        columnSpacing: 20, // Adjust spacing between columns
        headingRowColor: WidgetStateColor.resolveWith(
            (states) => Colors.grey.shade800), // Dark gray header
        border: TableBorder.all(color: Colors.grey.shade500), // Soft gray border
        columns: const [
          DataColumn(
            label: Text(
              "S.No",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              "Item Type",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              "Quantity",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              "Price (₹)",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
        rows: items
            .asMap()
            .entries
            .map(
              (entry) => DataRow(
                color: WidgetStateColor.resolveWith(
                  (states) => entry.key.isEven
                      ? Colors.grey.shade100 // Light gray for even rows
                      : Colors.white, // White for odd rows
                ),
                cells: [
                  DataCell(Text("${entry.key + 1}")),
                  DataCell(Text(entry.value["type"])),
                  DataCell(Text(entry.value["quantity"].toString())),
                  DataCell(
                    Text(
                      "₹${entry.value["price"]}",
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
