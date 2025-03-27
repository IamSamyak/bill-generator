import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math'; // Import to generate random colors

class BillItemWidget extends StatelessWidget {
  final Map<String, dynamic> bill;

  const BillItemWidget({super.key, required this.bill});

  // Method to check permission and dial phone number
  void _dialNumber(String contactNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: contactNumber);

    // Check phone call permission
    PermissionStatus status = await Permission.phone.request();
    if (status.isGranted) {
      try {
        debugPrint('Attempting to launch: $telUri');
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri, mode: LaunchMode.externalApplication);
          debugPrint('Launched successfully: $telUri');
        } else {
          debugPrint('Failed to launch: $telUri');
          throw 'Could not launch $contactNumber';
        }
      } catch (e) {
        debugPrint('Error occurred: $e');
      }
    } else {
      debugPrint('Phone permission not granted.');
    }
  }

  // Function to generate a random color
  Color _generateRandomColor() {
    final Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // Red value
      random.nextInt(256), // Green value
      random.nextInt(256), // Blue value
      1.0, // Full opacity
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _dialNumber(bill['contact_number']), // Trigger phone dialing on tap
              child: CircleAvatar(
                backgroundColor: _generateRandomColor(), // Assign random color to background
                child: Text(
                  bill['customer_name'][0],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill['customer_name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('Bill Date: ${bill['date']}'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${bill['amount']}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bill['status'] == 'Paid' ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    bill['status'],
                    style: TextStyle(
                      color: bill['status'] == 'Paid' ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(color: Colors.grey, thickness: 0.7),
      ],
    );
  }
}
