import 'package:flutter/material.dart';
import '../core/constants.dart';

class CategoryChipBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryChipBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = AppConstants.categories[i];
          final isSelected = cat == selected;
          return FilterChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) => onSelected(cat),
            selectedColor: AppConstants.accent,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            backgroundColor: Theme.of(context).cardColor,
            side: BorderSide(
              color: isSelected ? AppConstants.accent : Colors.grey.withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }
}
