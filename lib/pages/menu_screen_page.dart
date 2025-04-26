import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({Key? key}) : super(key: key);

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  File? _pickedImage;

  final TextEditingController _ownerNameController = TextEditingController(text: 'John Doe');
  final TextEditingController _mobileNumberController = TextEditingController(text: '+91 9876543210');
  final TextEditingController _addressController = TextEditingController(text: '123, Blue Street, Flutter City, Wonderland');

  final String defaultLogoUrl = 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'; // different logo

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Logo with "+" icon
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 180, // Landscape format (width > height)
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                          image: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : NetworkImage(defaultLogoUrl) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Tap on logo to change",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),

            // Owner Name
            _buildLabel('Owner Name'),
            const SizedBox(height: 8),
            _buildTextField(_ownerNameController),

            const SizedBox(height: 20),

            // Mobile Number
            _buildLabel('Mobile Number'),
            const SizedBox(height: 8),
            _buildTextField(_mobileNumberController, keyboardType: TextInputType.phone),

            const SizedBox(height: 20),

            // Address
            _buildLabel('Address'),
            const SizedBox(height: 8),
            _buildTextField(_addressController, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6), // changed to 6
        ),
      ),
    );
  }
}
