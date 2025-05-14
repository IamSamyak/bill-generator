import 'package:flutter/material.dart';

// Define the main color as a constant
const Color kMainColor = Color(0xFF1864BF);

class HomePage extends StatelessWidget {
  final Function(String) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 24,
      ), // Existing padding
      child: Align(
        alignment: Alignment.topCenter, // Align horizontally centered at top
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // Horizontal centering
          children: [
            Center(
              child: Transform.translate(
                offset: const Offset(4, 0),
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor:
                        0.8, // Adjust this value to crop more or less from bottom
                    child: Image.asset(
                      'assets/HomeScreenDoodle.png',
                      height: 360,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const Text(
              "Akash Men's Wear",
              style: TextStyle(
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
