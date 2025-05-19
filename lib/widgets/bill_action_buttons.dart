import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          icon: SvgPicture.asset(
            'assets/svgs/printer.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),

          label: const Text(
            "Generate Bill",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
