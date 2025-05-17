import 'package:flutter/material.dart';

// Define the main color as a constant
const Color kMainColor = Color(0xFF1864BF);

class HomePage extends StatelessWidget {
  final Function(String) onNavigate;
  final String shopName; // Add this line to accept shopName

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
              shopName, // Use the dynamic shopName
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF184373),
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
                backgroundColor: kMainColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 18,
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
