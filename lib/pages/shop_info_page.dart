import 'package:bill_generator/models/ShopDetail.dart';
import 'package:flutter/material.dart';
import '../services/company_profile_service.dart';
import '../constants.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({Key? key}) : super(key: key);

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  late CompanyProfileService _service;

  // Store existing fetched ShopDetail object
  ShopDetail _existingDetails = ShopDetail(
    shopName: 'John Doe',
    mobileNumber: '+91 9876543210',
    address: '123, Blue Street, Flutter City, Wonderland',
  );

  @override
  void initState() {
    super.initState();

    _service = CompanyProfileService();
    _fetchShopDetails();
  }

  Future<void> _fetchShopDetails() async {
    final ShopDetail? shopDetail = await _service.fetchShopDetails();

    if (shopDetail != null) {
      setState(() {
        _shopNameController.text =
            shopDetail.shopName.isNotEmpty
                ? shopDetail.shopName
                : _existingDetails.shopName;
        _mobileNumberController.text =
            shopDetail.mobileNumber.isNotEmpty
                ? shopDetail.mobileNumber
                : _existingDetails.mobileNumber;
        _addressController.text =
            shopDetail.address.isNotEmpty
                ? shopDetail.address
                : _existingDetails.address;

        _existingDetails = ShopDetail(
          shopName: _shopNameController.text,
          mobileNumber: _mobileNumberController.text,
          address: _addressController.text,
        );
      });
    } else {
      setState(() {
        // Use default if fetch returns null
        _shopNameController.text = _existingDetails.shopName;
        _mobileNumberController.text = _existingDetails.mobileNumber;
        _addressController.text = _existingDetails.address;
        _existingDetails = ShopDetail(
          shopName: _existingDetails.shopName,
          mobileNumber: _existingDetails.mobileNumber,
          address: _existingDetails.address,
        );
      });
    }
  }

  Future<void> _uploadShopDetails() async {
    final shopName =
        _shopNameController.text.trim().isNotEmpty
            ? _shopNameController.text.trim()
            : _existingDetails.shopName;
    final mobileNumber =
        _mobileNumberController.text.trim().isNotEmpty
            ? _mobileNumberController.text.trim()
            : _existingDetails.mobileNumber;
    final address =
        _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : _existingDetails.address;

    final updatedDetails = ShopDetail(
      shopName: shopName,
      mobileNumber: mobileNumber,
      address: address,
    );

    final success = await _service.uploadShopDetails(
      shopDetail: updatedDetails,
    );

    if (success) {
      setState(() {
        _existingDetails = updatedDetails;
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


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

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
                backgroundColor: const Color(0xFF1864c3),
                minimumSize: const Size.fromHeight(48),
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
        color: inputLabelColor,
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
