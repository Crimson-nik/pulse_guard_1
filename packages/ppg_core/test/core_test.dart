import 'dart:math' as math;

import 'package:ppg_core/ppg_core.dart';
import 'package:test/test.dart';

void main() {
  group('fft', () {
    test('nextPowerOfTwo rounds up', () {
      expect(nextPowerOfTwo(1), 1);
      expect(nextPowerOfTwo(256), 256);
      expect(nextPowerOfTwo(257), 512);
      expect(nextPowerOfTwo(900), 1024);
    });

    test('recovers the frequency of a pure tone', () {
      const fps = 30.0;
      const hz = 1.2;
      final x = List<double>.generate(
        900,
        (i) => math.sin(2 * math.pi * hz * i / fps),
      );
      final peak = findPeakBin(x, fps);
      expect(peak.bin, 41); // 1.2 * 1024 / 30 = 40.96
      expect(peak.hertz, closeTo(hz, 0.03));
      expect(peak.bpm, 73); // ceil(1.2011 * 60) = 73
    });

    test('ignores a large DC offset', () {
      const fps = 30.0;
      final x = List<double>.generate(
        900,
        (i) => 200.0 + 5.0 * math.sin(2 * math.pi * 1.0 * i / fps),
      );
      expect(findPeakBin(x, fps).bpm, closeTo(60, 2));
    });

    test('a positive and negative image of the same tone agree', () {
      const fps = 30.0;
      final x = List<double>.generate(
        600,
        (i) => math.sin(2 * math.pi * 1.5 * i / fps),
      );
      final inv = x.map((v) => -v).toList();
      expect(findPeakBin(x, fps).bin, findPeakBin(inv, fps).bin);
    });

    test('rejects a signal below the band floor', () {
      const fps = 30.0;
      // 0.4 Hz is 24 bpm, under the paper's 35 bpm floor.
      final x = List<double>.generate(
        1800,
        (i) => math.sin(2 * math.pi * 0.4 * i / fps),
      );
      expect(findPeakBin(x, fps).bpm, greaterThanOrEqualTo(35));
    });
  });

  group('sliding average', () {
    test('counts one peak per above-mean excursion, not per frame', () {
      // Ten frames up, ten down, twice.
      final red = <double>[
        ...List.filled(10, 100.0),
        ...List.generate(10, (i) => 100.0 + i * 5.0),
        ...List.filled(10, 100.0),
        ...List.generate(10, (i) => 100.0 + i * 5.0),
        ...List.filled(10, 100.0),
      ];
      expect(countPeaksSliding(red), 2);
      expect(heartRateFromPeaks(red), 4);
    });

    test('counts twice when the dicrotic notch is strong enough', () {
      const fps = 30.0;
      final x = List<double>.generate(900, (i) {
        final t = i / fps;
        return 200 +
            18 * math.sin(2 * math.pi * 1.2 * t) +
            25 * math.sin(2 * math.pi * 2.4 * t + 0.6);
      });
      // 1.2 Hz is 72 bpm. The notch doubles it, which is exactly the
      // failure the paper reports at 60 percent of readings.
      expect(heartRateFromPeaks(x), closeTo(144, 6));
    });

    test('a short window is handled without reading out of bounds', () {
      expect(countPeaksSliding([1, 2, 3]), 0);
      expect(countPeaksSliding(const []), 0);
    });
  });

  group('quality', () {
    test('flags a flat signal as poor', () {
      final flat = List<double>.filled(900, 128.0);
      final ts = List<int>.generate(900, (i) => i * 33);
      final q = assessQuality(red: flat, timestampsMs: ts);
      expect(q.band, QualityBand.poor);
      expect(q.perfusionIndex, lessThan(0.5));
    });

    test('accepts a clean pulse', () {
      const fps = 30.0;
      final red = List<double>.generate(
        900,
        (i) => 120 + 6 * math.sin(2 * math.pi * 1.2 * i / fps),
      );
      final ts = List<int>.generate(900, (i) => (i * 1000 / fps).round());
      final q = assessQuality(red: red, timestampsMs: ts);
      expect(q.band, QualityBand.good);
      expect(q.measuredFps, closeTo(30, 0.2));
    });
  });

  group('robust mode', () {
    test('detrend removes a straight line', () {
      final x = List<double>.generate(100, (i) => 5.0 + 0.3 * i);
      final d = detrend(x);
      for (final v in d) {
        expect(v, closeTo(0, 1e-9));
      }
    });

    test('resampling onto the measured rate keeps the length sane', () {
      final x = List<double>.generate(90, (i) => i.toDouble());
      final ts = List<int>.generate(90, (i) => (i * 1000 / 30).round());
      final r = resampleUniform(x, ts, 30);
      expect(r.length, closeTo(90, 2));
    });
  });
}
