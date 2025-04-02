import 'package:flutter/material.dart';
import 'package:bill_generator/widgets/filter_buttons_history_page.dart';
class FilterRow extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final bool isDescending;
  final VoidCallback onSortToggle;

  const FilterRow({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.isDescending,
    required this.onSortToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: filters.map((filter) => FilterButton(filter: filter, isSelected: filter == selectedFilter, onTap: onFilterSelected)).toList(),
          ),
          IconButton(
            onPressed: onSortToggle,
            icon: Icon(
              isDescending ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.black54,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}