import 'package:flutter/material.dart';
import '../constants.dart'; // Import the constants file

class HomePage extends StatelessWidget {
  final Function(String) onNavigate;
  final String shopName;

  const HomePage({
    super.key,
    required this.onNavigate,
    required this.shopName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 24,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Transform.translate(
                offset: const Offset(4, 0),
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.8,
                    child: Image.asset(
                      'assets/images/HomeScreenDoodle.png',
                      height: 360,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              shopName,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: headingFontColor,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Generate a bill for your customer",
              style: TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => onNavigate('CreateBill'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "CREATE BILL",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
