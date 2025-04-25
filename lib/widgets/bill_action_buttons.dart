import 'package:flutter/material.dart';

class BillActionButtons extends StatelessWidget {
  final VoidCallback onGeneratePressed;
  final VoidCallback onSharePressed;

  const BillActionButtons({
    Key? key,
    required this.onGeneratePressed,
    required this.onSharePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onGeneratePressed,
          icon: const Icon(Icons.receipt_long, color: Colors.white),
          label: const Text(
            "Generate Bill",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1864c3),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onSharePressed,
          icon: const Icon(Icons.share, color: Colors.white),
          label: const Text(
            "Share on WhatsApp",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
