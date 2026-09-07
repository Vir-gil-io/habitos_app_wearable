import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:habitos_app_wearable/config/app_theme.dart';
import 'package:habitos_app_wearable/data/pairing_repository.dart';
import 'package:habitos_app_wearable/screens/watch_home_screen.dart';

class WatchPairingScreen extends StatefulWidget {
  const WatchPairingScreen({super.key});

  @override
  State<WatchPairingScreen> createState() => _WatchPairingScreenState();
}

class _WatchPairingScreenState extends State<WatchPairingScreen> {
  final _repo = PairingRepository(Supabase.instance.client);
  String? _deviceSecret;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startPairing();
  }

  Future<void> _startPairing() async {
    try {
      final result = await _repo.requestPairing();
      setState(() => _deviceSecret = result.deviceSecret);
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    } catch (e) {
      setState(() => _error = 'Error: $e'); // ← temporal para diagnóstico
    }
  }

  Future<void> _poll() async {
    final secret = _deviceSecret;
    if (secret == null) return;

    try {
      final status = await _repo.checkStatus(secret);
      if (status.claimed) {
        _pollTimer?.cancel();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_secret', secret);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => WatchHomeScreen(deviceSecret: secret),
            ),
          );
        }
      }
    } catch (_) {
      // reintenta en el próximo tick
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                const Text('HabitFlow',
                    style: TextStyle(color: AppTheme.primary,
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
                if (_error != null)
                  Text(_error!,
                      style: const TextStyle(color: AppTheme.pending, fontSize: 10),
                      textAlign: TextAlign.center)
                else if (_deviceSecret == null)
                  const CircularProgressIndicator(
                      color: AppTheme.primary, strokeWidth: 2)
                else ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QrImageView(
                      data: _deviceSecret!,
                      version: QrVersions.auto,
                      size: 110,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Escanea con HabitFlow\nen tu teléfono',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}