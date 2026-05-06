/// Centralized backend configuration for Supabase and Firebase.
///
/// Replace the placeholder values below with your actual credentials
/// from your Supabase and Firebase dashboards.
class SupabaseConfig {
  SupabaseConfig._();

  // ── Supabase ────────────────────────────────────────────────
  /// Your Supabase project URL (e.g. https://xxxx.supabase.co)
  static const String supabaseUrl = 'https://tjzfdpbikmqnwdgxrbvk.supabase.co';

  /// Your Supabase anon/public key
  static const String supabaseAnonKey = 'sb_publishable_f_QWf2kfr7SiMi5v8kwOUw_9Yu7RzVJ';

  /// Table name for sensor readings
  static const String sensorReadingsTable = 'sensor_readings';

  // ── Firebase ────────────────────────────────────────────────
  /// Firebase Realtime Database URL
  static const String firebaseDatabaseUrl =
      'https://watt-4bed4-default-rtdb.firebaseio.com/';

  /// Firebase path template for latest reading
  /// Usage: '$firebaseLatestPath/$deviceId/latest'
  static const String firebaseDevicesPath = 'devices';
}
