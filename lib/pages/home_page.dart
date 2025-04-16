import 'package:flutter/material.dart';

// Define the main color as a constant
const Color kMainColor = Color(0xFF1864BF);

class HomePage extends StatelessWidget {
  final Function(String) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 24), // Removed vertical padding
      child: Align(
        alignment: Alignment.topCenter, // Align horizontally centered at top
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // Horizontal centering
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Transform.scale(
                scale: 0.8,
                child: Image.asset(
                  'assets/temp.png',
                  fit: BoxFit.contain,
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
              "Generate bill for your customer",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => onNavigate('CreateBill'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kMainColor,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Generate Bill",
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
