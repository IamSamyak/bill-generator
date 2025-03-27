import 'package:flutter/material.dart';

class EditDetailsPage extends StatefulWidget {
  final VoidCallback onBack;
  const EditDetailsPage({super.key,required this.onBack});

  @override
  State<EditDetailsPage> createState() => _EditDetailsPageState();
}

class _EditDetailsPageState extends State<EditDetailsPage> {
  final TextEditingController _nameController = TextEditingController(text: "John Doe");
  final TextEditingController _phoneController = TextEditingController(text: "9876543210");
  final TextEditingController _addressController = TextEditingController(text: "123, Flutter Street, Dart City");

  void _saveDetails() {
    // Mock save logic
    String name = _nameController.text;
    String phone = _phoneController.text;
    String address = _addressController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Details saved for $name')),
    );

    // You can add real saving logic here (e.g., save to shared preferences or backend)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Owner Details"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Owner Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveDetails,
              icon: const Icon(Icons.save),
              label: const Text("Save"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
