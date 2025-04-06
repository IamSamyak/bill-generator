import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String filter;
  final bool isSelected;
  final ValueChanged<String> onTap;

  const FilterButton({super.key, required this.filter, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color(0xFF8ac5ef) : Colors.white,
          foregroundColor: isSelected ? Colors.black87 : Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => onTap(filter),
        child: Text(filter, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }
}