import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatsBar extends StatelessWidget {
  final int totalNotes;
  final int pinnedNotes;
  final int favoriteNotes;

  const StatsBar({
    super.key,
    required this.totalNotes,
    required this.pinnedNotes,
    required this.favoriteNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withAlpha(150),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            icon: Icons.note_rounded,
            value: totalNotes.toString(),
            label: 'Notes',
            color: AppTheme.neonCyan,
          ),
          _buildDivider(),
          _buildStat(
            icon: Icons.push_pin_rounded,
            value: pinnedNotes.toString(),
            label: 'Pinned',
            color: AppTheme.neonGreen,
          ),
          _buildDivider(),
          _buildStat(
            icon: Icons.favorite_rounded,
            value: favoriteNotes.toString(),
            label: 'Favorites',
            color: AppTheme.neonPink,
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppTheme.glassBorder,
    );
  }
}
