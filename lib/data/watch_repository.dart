import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habitos_app_wearable/data/watch_habit.dart';
import 'package:habitos_app_wearable/data/watch_reminder.dart';

class WatchRepository {
  final SupabaseClient _client;
  final String deviceSecret;

  WatchRepository(this._client, this.deviceSecret);

  Future<List<WatchHabit>> getTodayHabits() async {
    try {
      final rows = await _client.rpc('watch_get_habits', params: {
        'p_device_secret': deviceSecret,
      });
      return (rows as List)
          .map((r) => WatchHabit.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> getGlobalStreak() async {
    try {
      final result = await _client.rpc('watch_get_streak', params: {
        'p_device_secret': deviceSecret,
      });
      return result as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<List<WatchReminder>> getUpcomingReminders() async {
    try {
      final rows = await _client.rpc('watch_get_reminders', params: {
        'p_device_secret': deviceSecret,
      });
      return (rows as List)
          .map((r) => WatchReminder.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertActivity({
    required int steps,
    required double calories,
    required double distanceKm,
    required int activeMinutes,
  }) async {
    try {
      await _client.rpc('watch_upsert_activity', params: {
        'p_device_secret': deviceSecret,
        'p_steps': steps,
        'p_calories': calories,
        'p_distance_km': distanceKm,
        'p_active_minutes': activeMinutes,
      });
    } catch (_) {
      // Silencioso — el próximo tick reintenta
    }
  }
}