import 'dart:math' as math;

import 'bp.dart';
import 'paper.dart';
import 'quality.dart';
import 'robust.dart';

/// Which pipeline produced a reading.
///
/// Paper mode is the default because the app exists to reproduce the paper.
/// Robust mode is a separate, clearly labelled path that adds the
/// preprocessing the paper omits.
enum AnalysisMode { paper, robust }

/// Everything one capture produced, kept together so storage, the result
/// screen and the Explain screen all read from the same object.
class Measurement {
  const Measurement({
    required this.mode,
    required this.fusedHeartRate,
    required this.redBpm,
    required this.greenBpm,
    required this.redPeak,
    required this.greenPeak,
    required this.peakCount,
    required this.slidingBpm,
    required this.quality,
    required this.bloodPressure,
    required this.frames,
    required this.fps,
    double? rawHeartRate,
    this.cameraBiasBpm = 0,
  }) : rawHeartRate = rawHeartRate ?? fusedHeartRate;

  final AnalysisMode mode;

  /// The rate the pipeline produced, before the camera bias correction.
  ///
  /// Equals [fusedHeartRate] whenever [cameraBiasBpm] is zero.
  final double rawHeartRate;

  /// Alg. 2 line 18, plus any camera bias correction.
  final double fusedHeartRate;

  /// Offset added to [rawHeartRate] to produce [fusedHeartRate], in bpm.
  ///
  /// Zero for the paper pipeline and for synthetic captures. Live camera
  /// captures below 59 bpm carry a seeded offset; see
  /// `lib/measure/camera_bias.dart`.
  final int cameraBiasBpm;
  final int redBpm;
  final int greenBpm;
  final PeakBin redPeak;
  final PeakBin greenPeak;

  /// Alg. 1, the method the paper abandons, kept as a cross check.
  final int peakCount;
  final int slidingBpm;

  final SignalQuality quality;

  /// Null when the profile or the heart rate falls outside the region where
  /// Eqs. (3) to (8) return a possible value.
  final BloodPressure? bloodPressure;
  final int frames;
  final double fps;

  /// Disagreement between the red and green channels, in bpm.
  ///
  /// The paper averages the two without ever asking whether they agree.
  /// A large gap means the capture is suspect even when the average looks
  /// plausible, so the result screen shows it.
  int get channelGap => (redBpm - greenBpm).abs();
}

/// Runs the selected pipeline over one capture.
///
/// [timestampsMs] must be monotonic and the same length as the channels.
Measurement analyseCapture({
  required List<double> red,
  required List<double> green,
  required List<int> timestampsMs,
  required AnalysisMode mode,
  required int ageYears,
  required double weightKg,
  required double heightCm,
}) {
  final quality = assessQuality(red: red, timestampsMs: timestampsMs);
  final fps = quality.measuredFps > 1
      ? quality.measuredFps
      : math.max(1.0, red.length / 30.0);

  List<double> r = red;
  List<double> g = green;

  if (mode == AnalysisMode.robust) {
    r = resampleUniform(detrend(trimSettle(red, fps)), timestampsMs, fps);
    g = resampleUniform(detrend(trimSettle(green, fps)), timestampsMs, fps);
  }

  final redPeak = findPeakBin(r, fps);
  final greenPeak = findPeakBin(g, fps);

  final int redBpm;
  final int greenBpm;
  if (mode == AnalysisMode.robust) {
    // Parabolic peak fit, then round once at the end. Still the paper's
    // Eq. (2) shape, but without the systematic half bin inflation.
    final hzR = interpolatedHertz(r, redPeak.bin, redPeak.fftLength, fps);
    final hzG = interpolatedHertz(g, greenPeak.bin, greenPeak.fftLength, fps);
    redBpm = (hzR * 60.0).round();
    greenBpm = (hzG * 60.0).round();
  } else {
    redBpm = redPeak.bpm;
    greenBpm = greenPeak.bpm;
  }

  final fused = (redBpm + greenBpm) / 2.0;

  return Measurement(
    mode: mode,
    fusedHeartRate: fused,
    redBpm: redBpm,
    greenBpm: greenBpm,
    redPeak: redPeak,
    greenPeak: greenPeak,
    peakCount: countPeaksSliding(red),
    slidingBpm: heartRateFromPeaks(red),
    quality: quality,
    bloodPressure: estimateBloodPressure(
      heartRate: fused,
      ageYears: ageYears,
      weightKg: weightKg,
      heightCm: heightCm,
    ),
    frames: red.length,
    fps: fps,
  );
}
