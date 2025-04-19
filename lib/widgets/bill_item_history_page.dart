import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart'; // Updated for date formatting
import 'dart:math'; // For generating random colors

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

  // Generate a random light color
  Color _generateRandomLightColor() {
    final Random random = Random();

    int red = random.nextInt(156) + 100;
    int green = random.nextInt(156) + 100;
    int blue = random.nextInt(156) + 100;

    return Color.fromRGBO(red, green, blue, 1.0);
  }

  // Format the date using intl
  String _formatDate(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      debugPrint('Date parsing error: $e');
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Bills: $bill');
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _dialNumber(bill['mobileNumber']),
              child: CircleAvatar(
                backgroundColor: _generateRandomLightColor(),
                child: Text(
                  bill['customerName'][0],
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
                    bill['customerName'],
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  Text(
                    'Bill Date: ${_formatDate(bill['date'])}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
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
                GestureDetector(
                  onTap: () {
                    debugPrint('View bill tapped for: ${bill['customerName']}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'View Bill',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
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
