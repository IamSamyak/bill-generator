import 'package:flutter/material.dart';

class OperateCategories extends StatelessWidget {
  const OperateCategories({super.key});

  final List<_Category> categories = const [
    _Category(icon: Icons.checkroom, label: 'T-shirt'),
    _Category(icon: Icons.checkroom, label: 'Jeans'),
    _Category(icon: Icons.checkroom, label: 'Shirt'),
    _Category(icon: Icons.checkroom, label: 'NightPant'),
    _Category(icon: Icons.checkroom, label: 'Innerwear'),
    _Category(icon: Icons.ac_unit, label: 'Jacket'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // Add Category Button at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  // Handle add category action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A66BE),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Add Category",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category cards generated dynamically
            ...categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _buildCategoryCard(
                  icon: category.icon,
                  label: category.label,
                  onEdit: () {
                    // Handle edit for category.label
                  },
                  onDelete: () {
                    // Handle delete for category.label
                  },
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String label,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final IconData icon;
  final String label;

  const _Category({required this.icon, required this.label});
}
