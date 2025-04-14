import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ShareImagesPage extends StatefulWidget {
  @override
  _ShareImagesPageState createState() => _ShareImagesPageState();
}

class _ShareImagesPageState extends State<ShareImagesPage> {
  List<XFile>? _selectedImages = [];
  List<String> contacts = [
    '1234567890', // Replace with actual numbers
    '9876543210', // Replace with actual numbers
  ];

  // Function to pick multiple images
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      if (pickedFiles != null) {
        _selectedImages = pickedFiles;
      }
    });
  }

  // Function to share images on WhatsApp
  void _shareOnWhatsApp() async {
    if (_selectedImages!.isEmpty) {
      // Handle case if no images are selected
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select images first")));
      return;
    }

    for (String contact in contacts) {
      for (XFile image in _selectedImages!) {
        // Construct the WhatsApp sharing URL
        final String imagePath = image.path;

        // WhatsApp URL scheme
        final String whatsappUrl =
            "https://wa.me/$contact?text=Check%20out%20this%20image%20$contact&attachment=$imagePath";

        // Open WhatsApp with the image URL
        if (await canLaunch(whatsappUrl)) {
          await launch(whatsappUrl);
        } else {
          // Handle the error case
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not share to WhatsApp")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Share Images to WhatsApp')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickImages,
            child: Text('Select Images'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedImages?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.file(File(_selectedImages![index].path)),
                  title: Text('Image ${index + 1}'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _shareOnWhatsApp,
            child: Text('Share to WhatsApp'),
          ),
        ],
      ),
    );
  }
}
