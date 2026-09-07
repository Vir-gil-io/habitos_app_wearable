import 'package:flutter/material.dart';
import 'package:habitos_app_wearable/config/app_theme.dart';
import 'package:habitos_app_wearable/data/wearable_metrics_simulator.dart';
import 'package:habitos_app_wearable/widgets/round_safe_area.dart';

class ActivityPage extends StatelessWidget {
  final SimulatedMetrics metrics;
  final bool isRunning;
  final VoidCallback onToggle;

  const ActivityPage({
    super.key,
    required this.metrics,
    required this.isRunning,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return RoundSafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_walk_rounded, color: AppTheme.primary, size: 18),
          const SizedBox(height: 4),
          Text(
            '${metrics.steps}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text('pasos', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniStat(value: '${metrics.calories.toStringAsFixed(0)}', label: 'cal'),
              const SizedBox(width: 10),
              _MiniStat(value: metrics.distanceKm.toStringAsFixed(2), label: 'km'),
              const SizedBox(width: 10),
              _MiniStat(value: '${metrics.activeMinutes}', label: 'min'),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isRunning
                    ? AppTheme.pending.withValues(alpha: 0.15)
                    : AppTheme.completed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isRunning ? AppTheme.pending : AppTheme.completed,
                ),
              ),
              child: Text(
                isRunning ? 'Detener' : 'Simular actividad',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isRunning ? AppTheme.pending : AppTheme.completed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 8, color: AppTheme.textSecondary)),
      ],
    );
  }
}