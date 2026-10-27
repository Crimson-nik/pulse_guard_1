import 'dart:math' as math;

import 'fft.dart';

/// Opt in preprocessing that the paper does not describe.
///
/// The paper takes raw per frame means straight into an FFT. That works
/// when the capture is clean and fails when the hand moves. Everything in
/// this file is off by default and labelled "robust" in the app, so a
/// reading is always attributable to one of the two pipelines.

/// Drops the first [seconds] of a capture, where the finger is still
/// settling and the torch is ramping up.
List<double> trimSettle(List<double> x, double fps, {double seconds = 1.5}) {
  final drop = math.min(x.length, (seconds * fps).round());
  return x.sublist(drop);
}

/// Removes the least squares straight line, which kills slow drift from
/// finger pressure.
List<double> detrend(List<double> x) {
  final n = x.length;
  if (n < 2) return List<double>.from(x);
  var sumT = 0.0;
  var sumX = 0.0;
  for (var i = 0; i < n; i++) {
    sumT += i;
    sumX += x[i];
  }
  final meanT = sumT / n;
  final meanX = sumX / n;
  var num = 0.0;
  var den = 0.0;
  for (var i = 0; i < n; i++) {
    num += (i - meanT) * (x[i] - meanX);
    den += (i - meanT) * (i - meanT);
  }
  final slope = den == 0 ? 0.0 : num / den;
  return List<double>.generate(n, (i) => x[i] - (meanX + slope * (i - meanT)));
}

/// Hann window, which trades main lobe width for far lower sidelobes.
///
/// It widens the peak by about one bin, so it is only used in robust mode
/// where a parabolic fit recovers the sub bin position.
List<double> hann(List<double> x) {
  final n = x.length;
  if (n < 2) return List<double>.from(x);
  return List<double>.generate(n, (i) {
    final w = 0.5 * (1.0 - math.cos(2.0 * math.pi * i / (n - 1)));
    return x[i] * w;
  });
}

/// Resamples onto a uniform grid using the real timestamps.
///
/// CameraX delivers frames with jitter, sometimes with gaps. The FFT assumes
/// uniform sampling, so the measured times are used to rebuild a uniform
/// series at the mean frame rate. Linear interpolation is enough at 30 fps.
List<double> resampleUniform(
  List<double> x,
  List<int> timestampsMs,
  double targetFps,
) {
  if (x.length < 2 || x.length != timestampsMs.length) {
    return List<double>.from(x);
  }
  final start = timestampsMs.first.toDouble();
  final end = timestampsMs.last.toDouble();
  final span = end - start;
  if (span <= 0 || targetFps <= 0) return List<double>.from(x);
  final count = (span / 1000.0 * targetFps).floor() + 1;
  final out = List<double>.filled(count, 0.0);
  var j = 0;
  for (var i = 0; i < count; i++) {
    final t = start + i * 1000.0 / targetFps;
    while (j < timestampsMs.length - 2 && timestampsMs[j + 1] < t) {
      j++;
    }
    final t0 = timestampsMs[j].toDouble();
    final t1 = timestampsMs[j + 1].toDouble();
    final span01 = t1 - t0;
    final frac = span01 <= 0 ? 0.0 : ((t - t0) / span01).clamp(0.0, 1.0);
    out[i] = x[j] + (x[j + 1] - x[j]) * frac;
  }
  return out;
}

/// Sub bin frequency by fitting a parabola through the peak and its two
/// neighbours. Removes the up to half bin bias that the paper's ceil leaves.
double interpolatedHertz(List<double> signal, int bin, int n, double fps) {
  final mags = realSpectrum(signal);
  if (bin <= 0 || bin >= mags.length - 1) return bin * fps / n;
  final a = mags[bin - 1];
  final b = mags[bin];
  final c = mags[bin + 1];
  final denom = a - 2 * b + c;
  if (denom == 0) return bin * fps / n;
  final delta = 0.5 * (a - c) / denom;
  return (bin + delta.clamp(-0.5, 0.5)) * fps / n;
}
