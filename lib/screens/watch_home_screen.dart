import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habitos_app_wearable/config/app_theme.dart';
import 'package:habitos_app_wearable/data/watch_habit.dart';
import 'package:habitos_app_wearable/data/watch_reminder.dart';
import 'package:habitos_app_wearable/data/watch_repository.dart';
import 'package:habitos_app_wearable/data/wearable_metrics_simulator.dart';
import 'package:habitos_app_wearable/screens/pages/summary_page.dart';
import 'package:habitos_app_wearable/screens/pages/habits_page.dart';
import 'package:habitos_app_wearable/screens/pages/next_activity_page.dart';
import 'package:habitos_app_wearable/screens/pages/activity_page.dart';

class WatchHomeScreen extends StatefulWidget {
  final String deviceSecret;
  const WatchHomeScreen({super.key, required this.deviceSecret});

  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen> {
  late final _repo = WatchRepository(Supabase.instance.client, widget.deviceSecret);

  static const _pageCount = 4;
  static const _initialIndex = _pageCount * 5000;

  late final PageController _pageController =
      PageController(initialPage: _initialIndex);
  int _currentPage = _initialIndex % _pageCount;

  List<WatchHabit> _habits = [];
  List<WatchReminder> _reminders = [];
  int _streak = 0;
  bool _loading = true;

  Timer? _refreshTimer;

  // ── Simulador de actividad ───────────────────────────────────────────────
  late final WearableMetricsSimulator _simulator;
  SimulatedMetrics _liveMetrics = const SimulatedMetrics(
    steps: 0, calories: 0, distanceKm: 0, activeMinutes: 0,
  );
  bool _simRunning = false;

  @override
  void initState() {
    super.initState();
    _simulator = WearableMetricsSimulator(
      onTick: (m) => setState(() => _liveMetrics = m),
      onSync: (m) => _repo.upsertActivity(
        steps: m.steps,
        calories: m.calories,
        distanceKm: m.distanceKm,
        activeMinutes: m.activeMinutes,
      ),
    );
    _load();

    // Refresco silencioso periódico (sin spinner) para reflejar cambios
    // hechos desde el teléfono, sin necesidad de reiniciar la app del reloj.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _silentRefresh(),
    );
  }

  Future<void> _load() async {
    final habits = await _repo.getTodayHabits();
    final streak = await _repo.getGlobalStreak();
    final reminders = await _repo.getUpcomingReminders();
    if (mounted) {
      setState(() {
        _habits = habits;
        _streak = streak;
        _reminders = reminders;
        _loading = false;
      });
    }
  }

  /// Igual que _load, pero sin activar el spinner de carga inicial —
  /// evita parpadeos visuales en cada actualización automática.
  Future<void> _silentRefresh() async {
    final habits = await _repo.getTodayHabits();
    final streak = await _repo.getGlobalStreak();
    final reminders = await _repo.getUpcomingReminders();
    if (mounted) {
      setState(() {
        _habits = habits;
        _streak = streak;
        _reminders = reminders;
      });
    }
  }

  void _toggleSimulation() {
    if (_simRunning) {
      _simulator.stop();
    } else {
      _simulator.start();
    }
    setState(() => _simRunning = !_simRunning);
  }

  @override
  void dispose() {
    _simulator.dispose();
    _refreshTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
        ),
      );
    }

    final pages = [
      SummaryPage(streak: _streak, habits: _habits),
      HabitsPage(habits: _habits),
      NextActivityPage(habits: _habits, reminders: _reminders),
      ActivityPage(
        metrics: _liveMetrics,
        isRunning: _simRunning,
        onToggle: _toggleSimulation,
      ),
    ];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: Stack(
          children: [
            // itemCount null → PageView.builder infinito en ambas direcciones.
            // Al llegar al límite "derecho" (o izquierdo) el índice sigue
            // creciendo/decreciendo y el modulo repite el ciclo de páginas.
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i % _pageCount),
              itemBuilder: (context, i) => pages[i % _pageCount],
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 8 : 5,
                    height: active ? 8 : 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? AppTheme.primary : AppTheme.divider,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}