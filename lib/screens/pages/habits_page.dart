import 'package:flutter/material.dart';
import 'package:habitos_app_wearable/config/app_theme.dart';
import 'package:habitos_app_wearable/data/watch_habit.dart';
import 'package:habitos_app_wearable/widgets/round_safe_area.dart';

class HabitsPage extends StatelessWidget {
  final List<WatchHabit> habits;
  const HabitsPage({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const RoundSafeArea(
        child: Center(
          child: Text('Sin hábitos hoy',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ),
      );
    }

    return RoundSafeArea(
      child: Column(
        children: [
          const Text('Tus hábitos', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary,
          )),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: habits.length.clamp(0, 4),
              itemBuilder: (context, i) => _HabitCard(habit: habits[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final WatchHabit habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Ícono circular de la unidad/categoría (genérico, no hay
          // categoría real en el payload del reloj)
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: (habit.isCompleted ? AppTheme.completed : AppTheme.primary)
                  .withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForUnit(habit.unit),
              size: 13,
              color: habit.isCompleted ? AppTheme.completed : AppTheme.primary,
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: habit.isCompleted ? AppTheme.textSecondary : Colors.white,
                    decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: habit.progress,
                    minHeight: 3,
                    backgroundColor: AppTheme.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      habit.isCompleted ? AppTheme.completed : AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Indicador circular de estado (check / progreso)
          SizedBox(
            width: 18,
            height: 18,
            child: habit.isCompleted
                ? const Icon(Icons.check_circle_rounded,
                    size: 18, color: AppTheme.completed)
                : CircularProgressIndicator(
                    value: habit.progress,
                    strokeWidth: 2,
                    backgroundColor: AppTheme.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
          ),
        ],
      ),
    );
  }

  IconData _iconForUnit(String unit) {
    switch (unit) {
      case 'minutes':
        return Icons.timer_outlined;
      case 'km':
        return Icons.directions_run_rounded;
      case 'liters':
        return Icons.water_drop_rounded;
      case 'steps':
        return Icons.directions_walk_rounded;
      case 'times':
        return Icons.repeat_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }
}