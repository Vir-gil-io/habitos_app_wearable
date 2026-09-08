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
  bool _generating = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startPairing();
  }

  Future<void> _startPairing() async {
    setState(() {
      _generating = true;
      _error = null;
      _deviceSecret = null;
    });

    _pollTimer?.cancel();

    try {
      final result = await _repo.requestPairing();
      if (!mounted) return;
      setState(() {
        _deviceSecret = result.deviceSecret;
        _generating = false;
      });
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo generar el código. Reintenta.';
        _generating = false;
      });
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
          child: SingleChildScrollView(
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

                if (_generating)
                  const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)
                else if (_error != null) ...[
                  Text(_error!,
                      style: const TextStyle(color: AppTheme.pending, fontSize: 10),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  _RetryButton(onTap: _startPairing),
                ] else if (_deviceSecret != null) ...[
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
                  const SizedBox(height: 14),
                  // Botón para regenerar el código, útil si expiró
                  // o si se necesita mostrar uno nuevo en vivo.
                  _RegenerateButton(onTap: _startPairing),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegenerateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RegenerateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 13, color: AppTheme.primary),
            SizedBox(width: 4),
            Text(
              'Nuevo código',
              style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RetryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Reintentar',
          style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}