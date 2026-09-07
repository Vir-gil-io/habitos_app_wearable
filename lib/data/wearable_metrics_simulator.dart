import 'dart:async';
import 'dart:math';

class SimulatedMetrics {
  final int steps;
  final double calories;
  final double distanceKm;
  final int activeMinutes;

  const SimulatedMetrics({
    required this.steps,
    required this.calories,
    required this.distanceKm,
    required this.activeMinutes,
  });
}

class WearableMetricsSimulator {
  final void Function(SimulatedMetrics metrics) onTick;
  final Future<void> Function(SimulatedMetrics metrics) onSync;

  WearableMetricsSimulator({required this.onTick, required this.onSync});

  Timer? _timer;
  final _rand = Random();

  int _steps = 0;
  double _calories = 0;
  double _distanceKm = 0;
  int _activeMinutes = 0;

  bool get isRunning => _timer != null;

  /// Cada tick representa ~1 minuto de actividad simulada de forma
  /// acelerada (cada 3 segundos reales), para poder demostrar la
  /// conexión sin esperar horas.
  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    final stepIncrement = 15 + _rand.nextInt(30); // 15–44 pasos por tick

    _steps += stepIncrement;
    _distanceKm += stepIncrement * 0.0008; // ~0.8 m por paso
    _calories += stepIncrement * 0.045;    // ~0.045 kcal por paso
    _activeMinutes += 1;

    final metrics = SimulatedMetrics(
      steps: _steps,
      calories: double.parse(_calories.toStringAsFixed(1)),
      distanceKm: double.parse(_distanceKm.toStringAsFixed(3)),
      activeMinutes: _activeMinutes,
    );

    onTick(metrics);
    onSync(metrics); // fire-and-forget → persiste en Supabase
  }

  void dispose() => stop();
}