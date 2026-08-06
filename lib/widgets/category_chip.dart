import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

class CategoryChipBar extends StatelessWidget {
  final NoteCategory? selectedCategory;
  final ValueChanged<NoteCategory?> onSelected;

  const CategoryChipBar({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(null, 'All', '🗂️'),
          ...NoteCategory.values.map(
            (cat) => _buildChip(cat, cat.label, cat.emoji),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(NoteCategory? category, String label, String emoji) {
    final isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelected(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.neonCyan.withAlpha(30)
                : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.neonCyan : AppTheme.glassBorder,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? AppTheme.neonGlow(AppTheme.neonCyan, intensity: 0.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.neonCyan
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
