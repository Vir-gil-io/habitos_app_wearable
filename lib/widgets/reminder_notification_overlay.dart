import 'package:flutter/material.dart';
import 'package:habitos_app_wearable/config/app_theme.dart';
import 'package:habitos_app_wearable/data/watch_reminder.dart';

class ReminderNotificationOverlay extends StatelessWidget {
  final WatchReminder reminder;

  const ReminderNotificationOverlay({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _categoryColor(reminder.category).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _categoryIcon(reminder.category),
                  color: _categoryColor(reminder.category),
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'RECORDATORIO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                reminder.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  reminder.description!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
              if (reminder.timeOfDay != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formatTime(reminder.timeOfDay!),
                  style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String raw) {
    final parts = raw.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $period';
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'habit' => Icons.repeat_rounded,
      'exercise' => Icons.fitness_center_rounded,
      'hydration' => Icons.water_drop_rounded,
      'rest' => Icons.bedtime_rounded,
      'productivity' => Icons.school_rounded,
      _ => Icons.notifications_active_rounded,
    };
  }

  Color _categoryColor(String category) {
    return switch (category) {
      'habit' => AppTheme.primary,
      'exercise' => AppTheme.completed,
      'hydration' => const Color(0xFF0984E3),
      'rest' => const Color(0xFF6C5CE7),
      'productivity' => AppTheme.pending,
      _ => AppTheme.textSecondary,
    };
  }
}