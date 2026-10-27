import 'dart:math' as math;

import 'fft.dart';

/// Fidelity constants. Each one is justified in docs/decisions.md.
const int fftLenMin = 256; // D1
const double hrMinBpm = 35.0; // D2
const double hrMaxBpm = 210.0; // D2
const int slidingWindow = 4; // Alg. 1, "last 4 frames"

/// Result of locating the dominant bin of a spectrum.
class PeakBin {
  const PeakBin({
    required this.bin,
    required this.fftLength,
    required this.fps,
  });

  /// Index k of the winning bin.
  final int bin;

  /// N in Eq. (2), after zero padding.
  final int fftLength;

  /// Frames per second, measured, not assumed.
  final double fps;

  /// The bin centre in Hz: k * fps / N.
  double get hertz => bin * fps / fftLength;

  /// Eq. (2) with f read as the bin index: ceil(f * FPS * 60 / N).
  ///
  /// The operation order is deliberately identical to the Python reference
  /// so that both produce the same integer on the same data.
  int get bpm => (bin * fps * 60.0 / fftLength).ceil().toInt();
}

/// Zero padded FFT length for a capture of [frames] frames.
int fftLength(int frames) {
  var n = fftLenMin;
  while (n < frames) {
    n <<= 1;
  }
  return n;
}

/// Bins of allowed heart rate, inclusive of the lower bound.
///
/// The paper says analysis "has been started after 35" with a unit that
/// cannot be Hz (35 Hz would be 2100 bpm). Reading it as 35 bpm gives the
/// physiologic floor the sentence intends. D2.
int bandLowBin(int n, double fps) =>
    math.max(1, (hrMinBpm / 60.0 * n / fps).ceil());

int bandHighBin(int n, double fps) =>
    math.min(n ~/ 2, (hrMaxBpm / 60.0 * n / fps).floor());

/// Locates the largest magnitude bin inside the allowed band.
///
/// Ties go to the lower bin, matching a strict greater-than scan.
PeakBin findPeakBin(List<double> signal, double fps) {
  final n = fftLength(signal.length);
  final mags = realSpectrum(_meanRemoved(signal));
  final lo = bandLowBin(n, fps);
  final hi = bandHighBin(n, fps);
  var bestK = lo;
  var best = -1.0;
  for (var k = lo; k <= hi; k++) {
    if (mags[k] > best) {
      best = mags[k];
      bestK = k;
    }
  }
  return PeakBin(bin: bestK, fftLength: n, fps: fps);
}

/// Removes the channel mean before the transform.
///
/// The paper never mentions this step and does not need it, because a DFT of
/// exactly N samples puts a constant entirely in bin 0 and the band limit
/// already excludes bin 0. Zero padding to a power of two breaks that: the
/// padding leaves a step at the end of the buffer whose leakage reaches into
/// the band and, on raw pixel values around 200, outranks the pulse peak
/// itself. Subtracting the mean first shrinks that step to the size of the
/// ripple and costs nothing, since no bin above 0 is changed by it.
List<double> _meanRemoved(List<double> x) {
  if (x.isEmpty) return x;
  var sum = 0.0;
  for (final v in x) {
    sum += v;
  }
  final mean = sum / x.length;
  return [for (final v in x) v - mean];
}

/// Alg. 2 lines 14 to 17 for one channel.
int heartRateFromChannel(List<double> signal, double fps) =>
    findPeakBin(signal, fps).bpm;

/// Alg. 2 line 18: average of the red and green estimates.
///
/// The result keeps the .5 that the average can introduce. The paper calls
/// the field "beats", so nothing here rounds it again.
double heartRateFromRgb(List<double> red, List<double> green, double fps) =>
    (heartRateFromChannel(green, fps) + heartRateFromChannel(red, fps)) / 2.0;

/// Alg. 1: 4 frame mean, flag, count. Returns the raw peak count.
///
/// Line 12 of the pseudocode sums four frames and calls the sum an average.
/// The prose says "the average is calculated for the last 4 frames", so the
/// mean is what runs here. Both readings are covered in docs/decisions.md,
/// deviation D5.
int countPeaksSliding(List<double> red, {int window = slidingWindow}) {
  var count = 0;
  var flag = 0;
  for (var i = window; i < red.length; i++) {
    final mean =
        (red[i] + red[i - 1] + red[i - 2] + red[i - 3]) / window;
    if (red[i] > mean && flag == 0) {
      count++;
      flag = 1;
    } else if (red[i] <= mean && flag == 1) {
      flag = 0;
    }
  }
  return count;
}

/// Alg. 1 line 24: thirty seconds of peaks doubled into a per minute rate.
int heartRateFromPeaks(List<double> red, {int window = slidingWindow}) =>
    countPeaksSliding(red, window: window) * 2;
