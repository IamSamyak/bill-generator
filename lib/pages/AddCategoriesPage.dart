import 'package:flutter/material.dart';

class OperateCategories extends StatelessWidget {
  const OperateCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add horizontal padding around the button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle add category action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A66BE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // Less rounded
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Categories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Category Card: T-shirt
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCategoryCard(
            icon: Icons.checkroom,
            label: 'T-shirt',
            onEdit: () {
              // Handle edit
            },
            onDelete: () {
              // Handle delete
            },
          ),
        ),
        const SizedBox(height: 12),

        // Category Card: Jeans
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCategoryCard(
            icon: Icons.checkroom,
            label: 'Jeans',
            onEdit: () {
              // Handle edit
            },
            onDelete: () {
              // Handle delete
            },
          ),
        ),
      ],
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
