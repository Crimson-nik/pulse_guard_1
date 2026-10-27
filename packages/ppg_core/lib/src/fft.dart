import 'dart:math' as math;
import 'dart:typed_data';

/// Smallest power of two that is at least [n].
int nextPowerOfTwo(int n) {
  var p = 1;
  while (p < n) {
    p <<= 1;
  }
  return p;
}

/// In place radix-2 decimation-in-time FFT.
///
/// [re] and [im] must share the same power-of-two length. The paper never
/// specifies an FFT routine, only that a transform happens, so any correct
/// implementation is faithful. This one is used because it is short enough
/// to audit and needs no dependencies.
void fftInPlace(Float64List re, Float64List im) {
  final n = re.length;
  if (n <= 1) return;
  assert(re.length == im.length, 'real and imaginary parts must match');
  assert(n & (n - 1) == 0, 'length must be a power of two');

  for (var i = 1, j = 0; i < n; i++) {
    var bit = n >> 1;
    for (; j & bit != 0; bit >>= 1) {
      j ^= bit;
    }
    j ^= bit;
    if (i < j) {
      final tr = re[i];
      re[i] = re[j];
      re[j] = tr;
      final ti = im[i];
      im[i] = im[j];
      im[j] = ti;
    }
  }

  for (var len = 2; len <= n; len <<= 1) {
    final angle = -2.0 * math.pi / len;
    final wRe = math.cos(angle);
    final wIm = math.sin(angle);
    final half = len >> 1;
    for (var i = 0; i < n; i += len) {
      var curRe = 1.0;
      var curIm = 0.0;
      for (var k = 0; k < half; k++) {
        final a = i + k;
        final b = a + half;
        final vRe = re[b] * curRe - im[b] * curIm;
        final vIm = re[b] * curIm + im[b] * curRe;
        final uRe = re[a];
        final uIm = im[a];
        re[a] = uRe + vRe;
        im[a] = uIm + vIm;
        re[b] = uRe - vRe;
        im[b] = uIm - vIm;
        final nextRe = curRe * wRe - curIm * wIm;
        curIm = curRe * wIm + curIm * wRe;
        curRe = nextRe;
      }
    }
  }
}

/// Zero pads [x] to a power of two and returns the magnitude of the first
/// half of its spectrum, bins 0 to N/2 inclusive.
List<double> realSpectrum(List<double> x) {
  final n = nextPowerOfTwo(math.max(1, x.length));
  final re = Float64List(n);
  final im = Float64List(n);
  for (var i = 0; i < x.length; i++) {
    re[i] = x[i];
  }
  fftInPlace(re, im);
  final half = n ~/ 2;
  final mags = List<double>.filled(half + 1, 0.0);
  for (var k = 0; k <= half; k++) {
    mags[k] = math.sqrt(re[k] * re[k] + im[k] * im[k]);
  }
  return mags;
}
