import 'dart:convert';
import 'dart:io';

import 'package:ppg_core/ppg_core.dart';
import 'package:test/test.dart';

/// Cross language check. The expectations in the fixture file were produced
/// by tools/pyref/ppg_reference.py, a separate Python implementation of the
/// same paper. If these pass, the Dart port has not drifted.
void main() {
  final data =
      jsonDecode(File('test/fixtures/paper_fixtures.json').readAsStringSync())
          as Map<String, dynamic>;
  final cases = (data['cases'] as List).cast<Map<String, dynamic>>();

  List<double> channel(Map<String, dynamic> c, String key) =>
      (c[key] as List).map((e) => (e as num).toDouble()).toList();

  for (final c in cases) {
    final name = c['name'] as String;
    final fps = (c['fps'] as num).toDouble();
    final expected = c['expected'] as Map<String, dynamic>;
    final red = channel(c, 'red');
    final green = channel(c, 'green');

    group(name, () {
      test('sliding peak count matches the reference', () {
        expect(countPeaksSliding(red), expected['peakCount']);
        expect(heartRateFromPeaks(red), expected['slidingBpm']);
      });

      test('red channel peak bin matches the reference', () {
        final peak = findPeakBin(red, fps);
        expect(peak.bin, expected['redBin']);
        expect(peak.fftLength, expected['redFftLen']);
        expect(peak.bpm, expected['redBpm']);
        expect(peak.hertz, closeTo((expected['redPeakHz'] as num).toDouble(), 1e-9));
      });

      test('green channel peak bin matches the reference', () {
        final peak = findPeakBin(green, fps);
        expect(peak.bin, expected['greenBin']);
        expect(peak.fftLength, expected['greenFftLen']);
        expect(peak.bpm, expected['greenBpm']);
      });

      test('fused heart rate matches the reference', () {
        expect(heartRateFromRgb(red, green, fps),
            (expected['fusedBpm'] as num).toDouble());
      });
    });
  }

  test('golden blood pressure chain', () {
    final golden = data['goldenBp'] as Map<String, dynamic>;
    final bp = estimateBloodPressure(
      heartRate: (golden['heartRate'] as num).toDouble(),
      ageYears: golden['age'] as int,
      weightKg: (golden['weightKg'] as num).toDouble(),
      heightCm: (golden['heightCm'] as num).toDouble(),
    );
    expect(bp, isNotNull);
    final value = bp!;
    expect(value.ejectionTimeMs, closeTo((golden['ejectionTimeMs'] as num).toDouble(), 1e-6));
    expect(value.bodySurfaceAreaM2, closeTo((golden['bsaM2'] as num).toDouble(), 1e-6));
    expect(value.strokeVolumeMl, closeTo((golden['strokeVolumeMl'] as num).toDouble(), 1e-6));
    expect(value.pulsePressure, closeTo((golden['pulsePressure'] as num).toDouble(), 1e-6));
    expect(value.systolic, closeTo((golden['systolic'] as num).toDouble(), 1e-6));
    expect(value.diastolic, closeTo((golden['diastolic'] as num).toDouble(), 1e-6));
  });
}
