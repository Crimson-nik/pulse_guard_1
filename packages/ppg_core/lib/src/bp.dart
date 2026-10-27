import 'dart:math' as math;

/// Blood pressure chain from Alg. 3 and Eqs. (3) to (8).
///
/// Every number this file returns is a model output, not a measurement.
/// The paper never compares it against a cuff, so the app never claims
/// accuracy for it. See docs/decisions.md, D7.

/// Fixed mean pressure term in Eqs. (7) and (8). D3.
const double mapConst = 83.25;

/// Height and weight bounds used to reject impossible input.
const double minHeightCm = 90;
const double maxHeightCm = 250;
const double minWeightKg = 20;
const double maxWeightKg = 300;
const int minAgeYears = 5;
const int maxAgeYears = 110;

/// One blood pressure estimate, with the intermediates kept so the Explain
/// screen can show the chain instead of only the two final numbers.
class BloodPressure {
  const BloodPressure({
    required this.ejectionTimeMs,
    required this.bodySurfaceAreaM2,
    required this.strokeVolumeMl,
    required this.pulsePressure,
    required this.systolic,
    required this.diastolic,
  });

  /// Eq. (3), milliseconds.
  final double ejectionTimeMs;

  /// Eq. (4), square metres.
  final double bodySurfaceAreaM2;

  /// Eq. (5), millilitres.
  final double strokeVolumeMl;

  /// Eq. (6), millimetres of mercury.
  final double pulsePressure;

  /// Eq. (7), millimetres of mercury.
  final double systolic;

  /// Eq. (8), millimetres of mercury.
  final double diastolic;
}

/// Floor for the divisor in Eq. (6).
///
/// That divisor is 0.013 * weight - 0.007 * age - 0.004 * heart rate + 1.307.
/// It shrinks as weight falls and age or heart rate rises, and it crosses
/// zero for profiles like 20 kg, 110 years, 180 bpm. Near the pole the
/// pulse pressure explodes, and past it the sign flips and systolic lands
/// below diastolic. The paper prints no guard, so the raw chain can return
/// impossible numbers. Anything this close to the pole is refused.
const double minPressureDenominator = 0.25;

/// Runs Eqs. (3) to (8) in the printed order.
///
/// Returns null when the inputs fall outside the region where the chain
/// produces a physiologically possible result: negative stroke volume (which
/// happens above roughly 150 bpm), a negative pulse pressure, or a divisor
/// near its pole. The caller is expected to say so rather than print a
/// number. See docs/decisions.md, D7.
///
/// [weightKg] and [heightCm] feed Du Bois directly: the formula is defined
/// on centimetres and kilograms and yields square metres, which is why the
/// "millimeters squared" comment in Alg. 3 cannot be what the code did. D6.
BloodPressure? estimateBloodPressure({
  required double heartRate,
  required int ageYears,
  required double weightKg,
  required double heightCm,
}) {
  final et = 364.5 - 1.23 * heartRate;
  final bsa = 0.007184 * _pow(weightKg, 0.425) * _pow(heightCm, 0.725);
  final sv = -6.6 +
      (0.25 * (et - 35.0)) -
      (0.62 * heartRate) +
      (40.4 * bsa) -
      (0.51 * ageYears);
  final divisor =
      (0.013 * weightKg - 0.007 * ageYears - 0.004 * heartRate) + 1.307;
  if (sv <= 0 || divisor < minPressureDenominator) return null;
  final pp = sv / divisor;
  if (pp <= 0) return null;
  return BloodPressure(
    ejectionTimeMs: et,
    bodySurfaceAreaM2: bsa,
    strokeVolumeMl: sv,
    pulsePressure: pp,
    systolic: mapConst + (2.0 / 3.0) * pp,
    diastolic: mapConst - (1.0 / 3.0) * pp,
  );
}

/// Why a blood pressure estimate was refused, in the words the app shows.
String bpRefusalReason({required double heartRate}) {
  if (heartRate > 150) {
    return 'The paper model only stays physically meaningful below about '
        '150 bpm. This reading is too fast for it.';
  }
  return 'This profile falls outside the range where the paper model gives '
      'a possible result.';
}

/// True when the input sits in a range where the model still means anything.
///
/// The formula divides by a term that shrinks as weight rises and heart rate
/// falls, so an unrealistic profile can return a negative pulse pressure.
/// Rejecting that outright is better than showing a number with no meaning.
String? validateProfile({
  required int ageYears,
  required double weightKg,
  required double heightCm,
}) {
  if (ageYears < minAgeYears || ageYears > maxAgeYears) {
    return 'Age must be between $minAgeYears and $maxAgeYears years.';
  }
  if (weightKg < minWeightKg || weightKg > maxWeightKg) {
    return 'Weight must be between ${minWeightKg.toInt()} and '
        '${maxWeightKg.toInt()} kg.';
  }
  if (heightCm < minHeightCm || heightCm > maxHeightCm) {
    return 'Height must be between ${minHeightCm.toInt()} and '
        '${maxHeightCm.toInt()} cm.';
  }
  return null;
}

/// Positive-base power. Dart and Python both delegate to the platform libm,
/// so the fixtures can compare at full double precision.
double _pow(double base, double exponent) =>
    math.pow(base, exponent).toDouble();
