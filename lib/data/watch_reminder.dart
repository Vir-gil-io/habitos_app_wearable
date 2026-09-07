class WatchReminder {
  final String title;
  final DateTime date;
  final String? timeOfDay;

  const WatchReminder({
    required this.title,
    required this.date,
    this.timeOfDay,
  });

  factory WatchReminder.fromJson(Map<String, dynamic> json) => WatchReminder(
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        timeOfDay: json['time_of_day'] as String?,
      );
}