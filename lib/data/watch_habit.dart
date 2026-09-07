class WatchHabit {
  final String name;
  final double currentValue;
  final double goalValue;
  final String unit;
  final DateTime? scheduledTime;

  const WatchHabit({
    required this.name,
    required this.currentValue,
    required this.goalValue,
    required this.unit,
    this.scheduledTime,
  });

  bool get isCompleted => currentValue >= goalValue;
  double get progress => goalValue > 0 ? (currentValue / goalValue).clamp(0.0, 1.0) : 0.0;

  factory WatchHabit.fromJson(Map<String, dynamic> json) => WatchHabit(
        name: json['name'] as String,
        currentValue: (json['current_value'] as num? ?? 0).toDouble(),
        goalValue: (json['goal_value'] as num).toDouble(),
        unit: json['unit'] as String,
        scheduledTime: json['scheduled_time'] != null
            ? DateTime.tryParse(json['scheduled_time'] as String)
            : null,
      );
}