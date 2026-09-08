class WatchReminder {
  final String id;
  final String title;
  final DateTime date;
  final String? timeOfDay;
  final String? description;
  final String category;

  const WatchReminder({
    required this.id,
    required this.title,
    required this.date,
    this.timeOfDay,
    this.description,
    this.category = 'other',
  });

  factory WatchReminder.fromJson(Map<String, dynamic> json) => WatchReminder(
        id: json['id'] as String,
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        timeOfDay: json['time_of_day'] as String?,
        description: json['description'] as String?,
        category: json['category'] as String? ?? 'other',
      );
}