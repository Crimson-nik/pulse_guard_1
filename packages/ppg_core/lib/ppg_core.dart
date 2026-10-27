/// Paper reproduction core for Sharma et al., Computers and Electrical
/// Engineering 101 (2022) 108057.
///
/// Pure Dart so that the maths can be tested without a device. The Flutter
/// app imports this package and adds nothing to the numbers.
library;

export 'src/analysis.dart';
export 'src/bp.dart';
export 'src/fft.dart' show fftInPlace, nextPowerOfTwo, realSpectrum;
export 'src/paper.dart';
export 'src/quality.dart';
export 'src/robust.dart';
export 'src/synthetic.dart';
