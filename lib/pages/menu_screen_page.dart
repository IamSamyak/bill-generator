import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/company_profile_service.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({Key? key}) : super(key: key);

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  File? _pickedImage;

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final String defaultLogoUrl =
      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
  late CompanyProfileService _service;

  // Store existing fetched values
  String _existingshopName = 'John Doe';
  String _existingMobileNumber = '+91 9876543210';
  String _existingAddress = '123, Blue Street, Flutter City, Wonderland';
  String _existingLogoUrl = '';

  @override
  void initState() {
    super.initState();

    _service = CompanyProfileService();
    _fetchShopDetails();
  }

  Future<void> _fetchShopDetails() async {
    final data = await _service.fetchShopDetails();

    setState(() {
      _shopNameController.text = data?['shopName'] ?? _existingshopName;
      _mobileNumberController.text =
          data?['mobileNumber'] ?? _existingMobileNumber;
      _addressController.text = data?['address'] ?? _existingAddress;

      _existingshopName = _shopNameController.text;
      _existingMobileNumber = _mobileNumberController.text;
      _existingAddress = _addressController.text;
      _existingLogoUrl = data?['logo'] ?? defaultLogoUrl;
    });
  }

  Future<void> _uploadShopDetails() async {
    final shopName =
        _shopNameController.text.trim().isNotEmpty
            ? _shopNameController.text.trim()
            : _existingshopName;
    final mobileNumber =
        _mobileNumberController.text.trim().isNotEmpty
            ? _mobileNumberController.text.trim()
            : _existingMobileNumber;
    final address =
        _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : _existingAddress;
    final logoUrl =
        _pickedImage != null
            ? 'gs://your-bucket-name/${_pickedImage!.path.split('/').last}'
            : _existingLogoUrl.isNotEmpty
            ? _existingLogoUrl
            : defaultLogoUrl;
            
    final success = await _service.uploadShopDetails(
      shopName: shopName,
      mobileNumber: mobileNumber,
      address: address,
      logoUrl: logoUrl,
    );

    if (success) {
      // Update existing values after upload
      setState(() {
        _existingshopName = shopName;
        _existingMobileNumber = mobileNumber;
        _existingAddress = address;
        _existingLogoUrl = logoUrl;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Profile updated successfully' : 'Failed to upload profile',
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

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
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 180,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                          image:
                              _pickedImage != null
                                  ? FileImage(_pickedImage!)
                                  : NetworkImage(
                                        _existingLogoUrl.isNotEmpty
                                            ? _existingLogoUrl
                                            : defaultLogoUrl,
                                      )
                                      as ImageProvider,
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

            _buildLabel('Owner Name'),
            const SizedBox(height: 8),
            _buildTextField(_shopNameController),

            const SizedBox(height: 20),

            _buildLabel('Mobile Number'),
            const SizedBox(height: 8),
            _buildTextField(
              _mobileNumberController,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 20),

            _buildLabel('Address'),
            const SizedBox(height: 8),
            _buildTextField(_addressController, maxLines: 3),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _uploadShopDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF1864c3,
                ), // Same blue as Generate Bill
                minimumSize: const Size.fromHeight(48), // Same height (48)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Save Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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

  Widget _buildTextField(
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
