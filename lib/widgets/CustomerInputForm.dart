import 'package:flutter/material.dart';

class CustomerInputForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final String payStatus;
  final ValueChanged<String?> onPayStatusChanged;

  const CustomerInputForm({
    Key? key,
    required this.nameController,
    required this.mobileController,
    required this.payStatus,
    required this.onPayStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Name",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Mobile Number",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        TextField(
          controller: mobileController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        const Text(
          "Payment Status",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        DropdownButtonFormField<String>(
          value: payStatus,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          dropdownColor: Colors.white, 
          items: ['Paid', 'Unpaid'].map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: onPayStatusChanged,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
