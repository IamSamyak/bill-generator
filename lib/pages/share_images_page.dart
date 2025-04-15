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
    '+91-9309587724',
    '+91-8975480920',
  ];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles;
      });
    }
  }

  void _shareOnWhatsApp() async {
    if (_selectedImages == null || _selectedImages!.isEmpty) {
      showSnackBar("Please select images first");
      return;
    }

    for (String contact in contacts) {
      for (XFile image in _selectedImages!) {
        final String imagePath = image.path;

        // WhatsApp sharing (you might need to use a platform channel or share_plus plugin for actual file share)
        final String whatsappUrl =
            "https://wa.me/$contact?text=Check%20out%20this%20image";

        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(Uri.parse(whatsappUrl));
        } else {
          showSnackBar("Could not open WhatsApp");
        }
      }
    }
  }

  void showSnackBar(String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: MediaQuery.of(context).size.width * 0.2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(message, style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(Duration(seconds: 2), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Custom Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.image, size: 30, color: Colors.green),
              Text(
                'Share Images',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.wechat_sharp, size: 30, color: Colors.green),
            ],
          ),
          SizedBox(height: 16),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.photo_library),
                label: Text('Select Images'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              ElevatedButton.icon(
                onPressed: _shareOnWhatsApp,
                icon: Icon(Icons.send),
                label: Text('Share'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Grid view of selected images
          Expanded(
            child: _selectedImages == null || _selectedImages!.isEmpty
                ? Center(child: Text("No images selected"))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _selectedImages!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_selectedImages![index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
