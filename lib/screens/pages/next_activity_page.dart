import 'package:flutter/material.dart';
import 'package:habitos_app_wearable/config/app_theme.dart';
import 'package:habitos_app_wearable/data/watch_habit.dart';
import 'package:habitos_app_wearable/data/watch_reminder.dart';
import 'package:habitos_app_wearable/widgets/round_safe_area.dart';

class NextActivityPage extends StatelessWidget {
  final List<WatchHabit> habits;
  final List<WatchReminder> reminders;

  const NextActivityPage({super.key, required this.habits, required this.reminders});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = habits.where((h) => !h.isCompleted && h.scheduledTime != null).toList()
      ..sort((a, b) => a.scheduledTime!.compareTo(b.scheduledTime!));

    final next = upcoming.where((h) {
      final t = h.scheduledTime!;
      final today = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      return !today.isBefore(now);
    }).toList();

    final nextHabit = next.isNotEmpty ? next.first : (upcoming.isNotEmpty ? upcoming.first : null);

    return RoundSafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_active_outlined, color: AppTheme.primary, size: 20),
          const SizedBox(height: 6),
          const Text('Siguiente', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          Text(
            nextHabit?.name ?? 'Sin pendientes',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (nextHabit?.scheduledTime != null) ...[
            const SizedBox(height: 2),
            Text(
              _formatTime(nextHabit!.scheduledTime!),
              style: const TextStyle(fontSize: 11, color: AppTheme.primary),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}