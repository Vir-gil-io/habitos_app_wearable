import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitos_app_wearable/config/app_theme.dart';
import 'package:habitos_app_wearable/config/supabase_constants.dart';
import 'package:habitos_app_wearable/screens/watch_pairing_screen.dart';
import 'package:habitos_app_wearable/screens/watch_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.url,
    publishableKey: SupabaseConstants.publishableKey,
  );

  final prefs = await SharedPreferences.getInstance();
  final savedSecret = prefs.getString('device_secret');

  runApp(HabitFlowWearApp(savedDeviceSecret: savedSecret));
}

class HabitFlowWearApp extends StatelessWidget {
  final String? savedDeviceSecret;
  const HabitFlowWearApp({super.key, this.savedDeviceSecret});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFlow Wear',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: savedDeviceSecret != null
          ? WatchHomeScreen(deviceSecret: savedDeviceSecret!)
          : const WatchPairingScreen(),
    );
  }
}