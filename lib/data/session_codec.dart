import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:ppg_core/ppg_core.dart';

import '../data/database.dart';
import '../measure/camera_bias.dart';

/// Converts between the analysis objects and the stored rows.
///
/// Only this file knows the storage shape. Screens work with [Session] rows
/// and [Measurement] values, never with blobs.
class SessionCodec {
  const SessionCodec();

  /// Float32 keeps a full capture near 7 KB and loses nothing that matters:
  /// the camera averages are 8 bit quantities to begin with.
  Uint8List encodeChannel(List<double> values) {
    final out = Float32List(values.length);
    for (var i = 0; i < values.length; i++) {
      out[i] = values[i];
    }
    return out.buffer.asUint8List(out.offsetInBytes, out.lengthInBytes);
  }

  Uint8List encodeTimestamps(List<int> values) {
    final out = Int32List(values.length);
    for (var i = 0; i < values.length; i++) {
      out[i] = values[i];
    }
    return out.buffer.asUint8List(out.offsetInBytes, out.lengthInBytes);
  }

  List<double> decodeChannel(Uint8List blob) {
    final typed = blob.buffer.asFloat32List(blob.offsetInBytes, blob.length ~/ 4);
    return List<double>.from(typed);
  }

  List<int> decodeTimestamps(Uint8List blob) {
    final typed = blob.buffer.asInt32List(blob.offsetInBytes, blob.length ~/ 4);
    return List<int>.from(typed);
  }

  /// Re-runs a stored capture through either pipeline.
  ///
  /// A session recorded with the camera bias correction stores that fact in
  /// [Session.mode]; the offset is recovered from the stored rate, so the
  /// stored reading and the re-run agree.
  Measurement replay(Session session, AnalysisMode mode) {
    final timestamps = decodeTimestamps(session.timestampMs);
    final raw = analyseCapture(
      red: decodeChannel(session.redSamples),
      green: decodeChannel(session.greenSamples),
      timestampsMs: timestamps,
      mode: mode,
      ageYears: session.ageYears,
      weightKg: session.weightKg,
      heightCm: session.heightCm,
    );
    if (!session.cameraCorrected) return raw;
    return applyCameraBias(
      raw: raw,
      offsetBpm: session.cameraBiasBpm.round(),
      ageYears: session.ageYears,
      weightKg: session.weightKg,
      heightCm: session.heightCm,
    );
  }

  SessionsCompanion toRow({
    required Measurement measurement,
    required List<double> red,
    required List<double> green,
    required List<int> timestamps,
    required DateTime startedAt,
    required int ageYears,
    required double weightKg,
    required double heightCm,
    String note = '',
  }) {
    final bp = measurement.bloodPressure;
    return SessionsCompanion.insert(
      startedAt: startedAt,
      durationMs:
          timestamps.isEmpty ? 0 : timestamps.last - timestamps.first,
      frames: measurement.frames,
      fps: measurement.fps,
      mode: measurement.cameraBiasBpm > 0
          ? '${measurement.mode.name}+camera'
          : measurement.mode.name,
      fusedBpm: measurement.fusedHeartRate,
      redBpm: measurement.redBpm,
      greenBpm: measurement.greenBpm,
      peakCount: measurement.peakCount,
      slidingBpm: measurement.slidingBpm,
      perfusionIndex: measurement.quality.perfusionIndex,
      clippedFraction: measurement.quality.clippedFraction,
      fpsJitter: measurement.quality.fpsJitter,
      ageYears: ageYears,
      weightKg: weightKg,
      heightCm: heightCm,
      ejectionTimeMs: Value(bp?.ejectionTimeMs),
      bsaM2: Value(bp?.bodySurfaceAreaM2),
      strokeVolumeMl: Value(bp?.strokeVolumeMl),
      pulsePressure: Value(bp?.pulsePressure),
      systolic: Value(bp?.systolic),
      diastolic: Value(bp?.diastolic),
      verdict: measurement.quality.band.name,
      note: Value(note),
      redSamples: encodeChannel(red),
      greenSamples: encodeChannel(green),
      timestampMs: encodeTimestamps(timestamps),
    );
  }
}

extension SessionVerdict on Session {
  bool get hasBloodPressure => systolic != null && diastolic != null;

  /// True when this capture stored the camera bias correction.
  bool get cameraCorrected => mode.contains('+camera');

  /// The fused rate before the camera correction, in bpm.
  double get measuredBpm => (redBpm + greenBpm) / 2.0;

  /// The offset stored in this session, or zero when none was applied.
  double get cameraBiasBpm => cameraCorrected ? fusedBpm - measuredBpm : 0;

  QualityBand get qualityBand => switch (verdict) {
        'good' => QualityBand.good,
        'fair' => QualityBand.fair,
        _ => QualityBand.poor,
      };

  String get heartRateText => '${fusedBpm.toStringAsFixed(0)} bpm';

  String get bloodPressureText =>
      hasBloodPressure ? '${systolic!.round()}/${diastolic!.round()}' : 'Not available';
}
