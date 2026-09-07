import 'package:flutter/material.dart';
import 'package:habitos_app_wearable/config/app_theme.dart';
import 'package:habitos_app_wearable/data/watch_habit.dart';
import 'package:habitos_app_wearable/widgets/round_safe_area.dart';

class SummaryPage extends StatelessWidget {
  final int streak;
  final List<WatchHabit> habits;

  const SummaryPage({super.key, required this.streak, required this.habits});

  @override
  Widget build(BuildContext context) {
    final completed = habits.where((h) => h.isCompleted).length;
    final total = habits.length;
    final progress = total > 0 ? completed / total : 0.0;

    return RoundSafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          Text(
            '$streak días',
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.streak,
            ),
          ),
          const Text('Racha actual', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: AppTheme.divider,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.completed),
                ),
                Text(
                  '$completed/$total',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text('Actividades hoy', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}