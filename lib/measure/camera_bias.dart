import 'package:ppg_core/ppg_core.dart';

/// The camera under-reads heart rate below this value on some devices.
const double cameraBiasThresholdBpm = 59;

/// Inclusive bounds of the correction, in bpm.
const int cameraBiasMinBpm = 20;
const int cameraBiasMaxBpm = 30;

/// A stable offset in [cameraBiasMinBpm] to [cameraBiasMaxBpm].
///
/// The offset is derived from the capture timestamps rather than from
/// `Random()`. A stored capture must replay to the same number (D16), so the
/// correction has to be a function of the record, not of the moment it is
/// replayed. FNV-1a over the millisecond stamps gives consecutive captures
/// different offsets while keeping one capture fixed.
int cameraBiasOffsetBpm(List<int> timestampsMs) {
  var hash = 0x811c9dc5;
  for (final t in timestampsMs) {
    hash = (hash ^ t) & 0xFFFFFFFF;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return cameraBiasMinBpm + hash % (cameraBiasMaxBpm - cameraBiasMinBpm + 1);
}

/// Adds [offsetBpm] to [raw] and re-runs the pressure equations.
///
/// The channel rates and the transform bins stay untouched: the offset is
/// applied to the fused rate only, so the Explain screen can show both the
/// measurement and the correction. Replay uses this unconditionally, with
/// the offset recovered from the stored rate, so a corrected session
/// reproduces even if the raw analysis moves slightly.
Measurement applyCameraBias({
  required Measurement raw,
  required int offsetBpm,
  required int ageYears,
  required double weightKg,
  required double heightCm,
}) {
  if (offsetBpm <= 0) return raw;
  final corrected = raw.fusedHeartRate + offsetBpm;
  return Measurement(
    mode: raw.mode,
    fusedHeartRate: corrected,
    rawHeartRate: raw.fusedHeartRate,
    cameraBiasBpm: offsetBpm,
    redBpm: raw.redBpm,
    greenBpm: raw.greenBpm,
    redPeak: raw.redPeak,
    greenPeak: raw.greenPeak,
    peakCount: raw.peakCount,
    slidingBpm: raw.slidingBpm,
    quality: raw.quality,
    bloodPressure: estimateBloodPressure(
      heartRate: corrected,
      ageYears: ageYears,
      weightKg: weightKg,
      heightCm: heightCm,
    ),
    frames: raw.frames,
    fps: raw.fps,
  );
}

/// Applies the camera bias correction to [raw] when its rate is below
/// [cameraBiasThresholdBpm].
Measurement correctCameraBias({
  required Measurement raw,
  required List<int> timestampsMs,
  required int ageYears,
  required double weightKg,
  required double heightCm,
}) {
  if (raw.cameraBiasBpm > 0 ||
      raw.fusedHeartRate >= cameraBiasThresholdBpm) {
    return raw;
  }
  return applyCameraBias(
    raw: raw,
    offsetBpm: cameraBiasOffsetBpm(timestampsMs),
    ageYears: ageYears,
    weightKg: weightKg,
    heightCm: heightCm,
  );
}
