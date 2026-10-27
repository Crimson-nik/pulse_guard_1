import 'dart:math' as math;

/// How much to trust a capture, expressed as raw numbers plus one label.
///
/// Nothing here is part of the paper. The paper reports no quality gate at
/// all, which is one reason a finger can be off the lens and the app still
/// prints a number. These metrics exist so the app can say "retake this"
/// instead of showing a confident wrong value.
enum QualityBand { good, fair, poor }

class SignalQuality {
  const SignalQuality({
    required this.perfusionIndex,
    required this.clippedFraction,
    required this.measuredFps,
    required this.fpsJitter,
    required this.frames,
    required this.durationSeconds,
  });

  /// (p95 - p5) / mean of the red channel, in percent. A finger on a lens
  /// typically gives 1 to 5 percent; ambient light with no finger gives
  /// well under 1.
  final double perfusionIndex;

  /// Share of frames whose mean red value is at or above 250, where the
  /// sensor is saturating and the pulse shape is lost.
  final double clippedFraction;

  /// Frames divided by elapsed time, measured from timestamps.
  final double measuredFps;

  /// Standard deviation of frame intervals divided by the mean interval.
  /// High values mean the capture is not uniformly sampled, which is the
  /// assumption every FFT in this project makes.
  final double fpsJitter;

  final int frames;
  final double durationSeconds;

  QualityBand get band {
    if (frames < 60 || durationSeconds < 5) return QualityBand.poor;
    if (perfusionIndex < 0.5) return QualityBand.poor;
    if (clippedFraction > 0.15) return QualityBand.poor;
    if (perfusionIndex < 1.5) return QualityBand.fair;
    if (clippedFraction > 0.02) return QualityBand.fair;
    if (fpsJitter > 0.25) return QualityBand.fair;
    if (measuredFps < 15) return QualityBand.fair;
    return QualityBand.good;
  }

  /// One sentence, written for the person holding the phone.
  String get advice {
    if (frames < 60 || durationSeconds < 5) {
      return 'The capture stopped early. Hold still for the full 30 seconds.';
    }
    if (perfusionIndex < 0.5) {
      return 'Almost no pulse was visible. Cover the lens and flash fully '
          'with the fingertip, and press gently.';
    }
    if (clippedFraction > 0.15) {
      return 'The image is blown out. Ease the pressure of your fingertip.';
    }
    if (perfusionIndex < 1.5) {
      return 'The pulse is faint. Try the pad of the index finger, not the tip.';
    }
    if (fpsJitter > 0.25) {
      return 'The camera frame rate was uneven. Close other apps and retake.';
    }
    return 'The capture looks usable.';
  }
}

/// Computes quality metrics from one channel and the frame timestamps.
SignalQuality assessQuality({
  required List<double> red,
  required List<int> timestampsMs,
}) {
  if (red.isEmpty || timestampsMs.length != red.length) {
    return const SignalQuality(
      perfusionIndex: 0,
      clippedFraction: 0,
      measuredFps: 0,
      fpsJitter: 0,
      frames: 0,
      durationSeconds: 0,
    );
  }
  final sorted = List<double>.from(red)..sort();
  double percentile(double p) {
    final idx = ((sorted.length - 1) * p).round().clamp(0, sorted.length - 1);
    return sorted[idx];
  }

  final mean = red.reduce((a, b) => a + b) / red.length;
  final ac = percentile(0.95) - percentile(0.05);
  final pi = mean <= 0 ? 0.0 : (ac / mean) * 100.0;

  var clipped = 0;
  for (final v in red) {
    if (v >= 250) clipped++;
  }

  final elapsedMs = timestampsMs.last - timestampsMs.first;
  final duration = elapsedMs <= 0 ? 0.0 : elapsedMs / 1000.0;
  final fps = duration <= 0 ? 0.0 : (red.length - 1) / duration;

  var jitter = 0.0;
  if (red.length > 2) {
    final gaps = <double>[];
    for (var i = 1; i < timestampsMs.length; i++) {
      gaps.add((timestampsMs[i] - timestampsMs[i - 1]).toDouble());
    }
    final gapMean = gaps.reduce((a, b) => a + b) / gaps.length;
    if (gapMean > 0) {
      final variance =
          gaps.map((g) => (g - gapMean) * (g - gapMean)).reduce((a, b) => a + b) /
              gaps.length;
      jitter = math.sqrt(variance) / gapMean;
    }
  }

  return SignalQuality(
    perfusionIndex: pi,
    clippedFraction: red.isEmpty ? 0 : clipped / red.length,
    measuredFps: fps,
    fpsJitter: jitter,
    frames: red.length,
    durationSeconds: duration,
  );
}
