import 'dart:math' as math;

/// A generated pulse, used for demonstrations and for the recovery check on
/// the Validation screen.
///
/// The shape is a cardiac fundamental plus a dicrotic harmonic plus slow
/// drift, which is the same shape the Python fixtures use. It is not a model
/// of a finger; it is a signal with a known answer, which is what a check
/// needs.
class SyntheticCapture {
  const SyntheticCapture({
    required this.red,
    required this.green,
    required this.timestampsMs,
    required this.heartRate,
    required this.fps,
  });

  final List<double> red;
  final List<double> green;
  final List<int> timestampsMs;
  final double heartRate;
  final double fps;
}

SyntheticCapture synthesiseCapture({
  double heartRate = 72,
  double fps = 30,
  double seconds = 30,
  double noise = 0.8,
  double dicrotic = 0.35,
  int seed = 11,
}) {
  final rng = math.Random(seed);
  final total = (fps * seconds).round();
  final f0 = heartRate / 60.0;
  final red = List<double>.filled(total, 0);
  final green = List<double>.filled(total, 0);
  final stamps = List<int>.filled(total, 0);

  double jitter() => (rng.nextDouble() + rng.nextDouble() - 1.0);

  for (var i = 0; i < total; i++) {
    final t = i / fps;
    final base = 200 + 18 * math.sin(2 * math.pi * f0 * t);
    final notch = 18 * dicrotic * math.sin(2 * math.pi * 2 * f0 * t + 0.6);
    final drift = 3 * math.sin(2 * math.pi * 0.08 * t);
    red[i] = base + notch + drift + noise * jitter();
    green[i] = 0.55 * base + 0.8 * notch + drift + noise * jitter();
    stamps[i] = (i * 1000 / fps).round();
  }

  return SyntheticCapture(
    red: red,
    green: green,
    timestampsMs: stamps,
    heartRate: heartRate,
    fps: fps,
  );
}
