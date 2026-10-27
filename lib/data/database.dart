import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// One capture, with everything needed to recompute it.
///
/// The blood pressure intermediates are stored rather than derived on read so
/// that an old session keeps showing exactly what the user saw, even if the
/// formulas change in a later version. The raw channel arrays are stored as
/// Float32 blobs, about 7 KB for a full capture, which is what makes the
/// Validation screen able to replay a real recording.
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationMs => integer()();
  IntColumn get frames => integer()();
  RealColumn get fps => real()();
  TextColumn get mode => text()();

  RealColumn get fusedBpm => real()();
  IntColumn get redBpm => integer()();
  IntColumn get greenBpm => integer()();
  IntColumn get peakCount => integer()();
  IntColumn get slidingBpm => integer()();

  RealColumn get perfusionIndex => real()();
  RealColumn get clippedFraction => real()();
  RealColumn get fpsJitter => real()();

  IntColumn get ageYears => integer()();
  RealColumn get weightKg => real()();
  RealColumn get heightCm => real()();

  RealColumn get ejectionTimeMs => real().nullable()();
  RealColumn get bsaM2 => real().nullable()();
  RealColumn get strokeVolumeMl => real().nullable()();
  RealColumn get pulsePressure => real().nullable()();
  RealColumn get systolic => real().nullable()();
  RealColumn get diastolic => real().nullable()();

  TextColumn get verdict => text()();
  TextColumn get note => text().withDefault(const Constant(''))();

  BlobColumn get redSamples => blob()();
  BlobColumn get greenSamples => blob()();
  BlobColumn get timestampMs => blob()();
}

/// The user's body parameters, which Eqs. (3) to (8) need. Single row.
class Profiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get ageYears => integer().withDefault(const Constant(25))();
  RealColumn get weightKg => real().withDefault(const Constant(70))();
  RealColumn get heightCm => real().withDefault(const Constant(175))();
  TextColumn get defaultMode => text().withDefault(const Constant('paper'))();
  BoolColumn get showSlidingCrossCheck =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small key value store for app preferences that are not profile data.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Sessions, Profiles, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'ppg_lab'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<Profile> loadProfile() async {
    final rows = await select(profiles).get();
    if (rows.isNotEmpty) return rows.first;
    await into(profiles).insert(
      ProfilesCompanion.insert(
        updatedAt: DateTime.now(),
      ),
    );
    return (await select(profiles).get()).first;
  }

  Future<void> saveProfile(ProfilesCompanion entry) async {
    await (update(profiles)..where((t) => t.id.equals(1))).write(
      entry.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  Stream<List<Session>> watchSessions() =>
      (select(sessions)..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .watch();

  Future<Session?> latestSession() =>
      (select(sessions)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(1))
          .getSingleOrNull();

  Stream<Session?> watchSession(int id) =>
      (select(sessions)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> insertSession(SessionsCompanion entry) =>
      into(sessions).insert(entry);

  Future<void> deleteSession(int id) =>
      (delete(sessions)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllSessions() => delete(sessions).go();

  Future<String?> readSetting(String key) async {
    final row = await (select(settings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> writeSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: value),
    );
  }
}
