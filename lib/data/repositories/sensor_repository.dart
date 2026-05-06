import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sensor_reading.dart';
import 'supabase_data_repository.dart';
import 'firebase_data_repository.dart';

/// Which backend is currently serving data.
enum DataSource { supabase, firebase, none }

/// Orchestrates data access: tries Supabase first, falls back to Firebase.
class SensorRepository {
  final SupabaseDataRepository _supabaseRepo;
  final FirebaseDataRepository? _firebaseRepo;

  DataSource _activeSource = DataSource.none;

  SensorRepository({
    required SupabaseDataRepository supabaseRepo,
    FirebaseDataRepository? firebaseRepo,
  })  : _supabaseRepo = supabaseRepo,
        _firebaseRepo = firebaseRepo;

  /// Which backend is currently active.
  DataSource get activeSource => _activeSource;

  /// Fetch the latest reading with automatic fallback.
  Future<SensorReading?> getLatestReading(String deviceId) async {
    // Try Supabase first
    try {
      final reading = await _supabaseRepo
          .getLatestReading(deviceId)
          .timeout(const Duration(seconds: 10));
      _activeSource = DataSource.supabase;
      return reading;
    } catch (e) {
      debugPrint('[SensorRepository] Supabase failed: $e — trying Firebase');
    }

    // Fallback to Firebase
    if (_firebaseRepo != null) {
      try {
        final reading = await _firebaseRepo!
            .getLatestReading(deviceId)
            .timeout(const Duration(seconds: 10));
        _activeSource = DataSource.firebase;
        return reading;
      } catch (e) {
        debugPrint('[SensorRepository] Firebase also failed: $e');
      }
    }
    
    _activeSource = DataSource.none;
    return null;
  }

  /// Stream the latest reading with automatic fallback.
  ///
  /// Tries Supabase Realtime first; if it errors, switches to Firebase.
  Stream<SensorReading> streamLatestReading(String deviceId) {
    late StreamController<SensorReading> controller;
    StreamSubscription<SensorReading>? subscription;

    controller = StreamController<SensorReading>(
      onListen: () {
        // Start with Supabase
        _activeSource = DataSource.supabase;
        subscription = _supabaseRepo.streamLatestReading(deviceId).listen(
          (reading) {
            _activeSource = DataSource.supabase;
            controller.add(reading);
          },
          onError: (error) {
            debugPrint(
              '[SensorRepository] Supabase stream error: $error — switching to Firebase',
            );
            subscription?.cancel();

            // Switch to Firebase if available
            if (_firebaseRepo != null) {
              _activeSource = DataSource.firebase;
              subscription = _firebaseRepo!.streamLatestReading(deviceId).listen(
                (reading) {
                  _activeSource = DataSource.firebase;
                  controller.add(reading);
                },
                onError: (fbError) {
                  debugPrint(
                    '[SensorRepository] Firebase stream error: $fbError',
                  );
                  _activeSource = DataSource.none;
                  controller.addError(fbError);
                },
              );
            } else {
              _activeSource = DataSource.none;
              controller.addError(error);
            }
          },
        );
      },
      onCancel: () {
        subscription?.cancel();
      },
    );

    return controller.stream;
  }

  /// Fetch historical readings with fallback.
  Future<List<SensorReading>> getReadings(
    String deviceId, {
    required DateTime from,
    required DateTime to,
  }) async {
    // Try Supabase first
    try {
      final readings = await _supabaseRepo
          .getReadings(deviceId, from: from, to: to)
          .timeout(const Duration(seconds: 15));
      _activeSource = DataSource.supabase;
      return readings;
    } catch (e) {
      debugPrint('[SensorRepository] Supabase history failed: $e');
    }

    // Fallback to Firebase
    if (_firebaseRepo != null) {
      try {
        final readings = await _firebaseRepo!
            .getReadings(deviceId, from: from, to: to)
            .timeout(const Duration(seconds: 15));
        _activeSource = DataSource.firebase;
        return readings;
      } catch (e) {
        debugPrint('[SensorRepository] Firebase history also failed: $e');
      }
    }
    
    _activeSource = DataSource.none;
    return [];
  }
}
