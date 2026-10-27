import 'package:drift/drift.dart' show Value;
import 'package:ppg_core/ppg_core.dart';

import 'database.dart';

/// The body parameters Eqs. (3) to (8) need, plus the app's preferences.
///
/// A plain value object, separate from the Drift row, so the capture
/// controller and the tests never need a database to have a profile.
class UserProfile {
  const UserProfile({
    this.ageYears = 25,
    this.weightKg = 70,
    this.heightCm = 175,
    this.mode = AnalysisMode.paper,
    this.showSlidingCrossCheck = true,
  });

  final int ageYears;
  final double weightKg;
  final double heightCm;
  final AnalysisMode mode;
  final bool showSlidingCrossCheck;

  UserProfile copyWith({
    int? ageYears,
    double? weightKg,
    double? heightCm,
    AnalysisMode? mode,
    bool? showSlidingCrossCheck,
  }) {
    return UserProfile(
      ageYears: ageYears ?? this.ageYears,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      mode: mode ?? this.mode,
      showSlidingCrossCheck:
          showSlidingCrossCheck ?? this.showSlidingCrossCheck,
    );
  }

  factory UserProfile.fromRow(Profile row) {
    return UserProfile(
      ageYears: row.ageYears,
      weightKg: row.weightKg,
      heightCm: row.heightCm,
      mode: row.defaultMode == 'robust' ? AnalysisMode.robust : AnalysisMode.paper,
      showSlidingCrossCheck: row.showSlidingCrossCheck,
    );
  }

  ProfilesCompanion toRow() {
    return ProfilesCompanion(
      id: const Value(1),
      ageYears: Value(ageYears),
      weightKg: Value(weightKg),
      heightCm: Value(heightCm),
      defaultMode: Value(mode.name),
      showSlidingCrossCheck: Value(showSlidingCrossCheck),
      updatedAt: Value(DateTime.now()),
    );
  }

  String? get validationError => validateProfile(
        ageYears: ageYears,
        weightKg: weightKg,
        heightCm: heightCm,
      );
}
