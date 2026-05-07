import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized backend configuration for Supabase and Firebase.
///
/// Replace the placeholder values below with your actual credentials
/// from your Supabase and Firebase dashboards.
class SupabaseConfig {
  SupabaseConfig._();

  // ── Supabase ────────────────────────────────────────────────
  /// Your Supabase project URL (e.g. https://xxxx.supabase.co)
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Your Supabase anon/public key
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Table name for sensor readings
  static const String sensorReadingsTable = 'sensor_readings';

  // ── Firebase ────────────────────────────────────────────────
  /// Firebase Realtime Database URL
  static String get firebaseDatabaseUrl => dotenv.env['FIREBASE_DATABASE_URL'] ?? '';

  /// Firebase path template for latest reading
  /// Usage: '$firebaseLatestPath/$deviceId/latest'
  static const String firebaseDevicesPath = 'devices';
}
