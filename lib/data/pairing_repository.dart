import 'package:supabase_flutter/supabase_flutter.dart';

class PairingRequestResult {
  final String deviceSecret;
  final DateTime expiresAt;
  const PairingRequestResult({required this.deviceSecret, required this.expiresAt});
}

class PairingStatus {
  final bool claimed;
  final String? userName;
  const PairingStatus({required this.claimed, this.userName});
}

class PairingRepository {
  final SupabaseClient _client;
  PairingRepository(this._client);

  Future<PairingRequestResult> requestPairing() async {
    final rows = await _client.rpc('request_pairing');
    final row = (rows as List).first as Map<String, dynamic>;
    return PairingRequestResult(
      deviceSecret: row['device_secret'] as String,
      expiresAt: DateTime.parse(row['expires_at'] as String),
    );
  }

  Future<PairingStatus> checkStatus(String deviceSecret) async {
    final rows = await _client.rpc('check_pairing_status', params: {
      'p_device_secret': deviceSecret,
    });
    final row = (rows as List).first as Map<String, dynamic>;
    return PairingStatus(
      claimed: row['claimed'] as bool? ?? false,
      userName: row['user_name'] as String?,
    );
  }
}