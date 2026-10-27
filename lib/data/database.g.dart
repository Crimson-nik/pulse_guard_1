// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _framesMeta = const VerificationMeta('frames');
  @override
  late final GeneratedColumn<int> frames = GeneratedColumn<int>(
    'frames',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fpsMeta = const VerificationMeta('fps');
  @override
  late final GeneratedColumn<double> fps = GeneratedColumn<double>(
    'fps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fusedBpmMeta = const VerificationMeta(
    'fusedBpm',
  );
  @override
  late final GeneratedColumn<double> fusedBpm = GeneratedColumn<double>(
    'fused_bpm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _redBpmMeta = const VerificationMeta('redBpm');
  @override
  late final GeneratedColumn<int> redBpm = GeneratedColumn<int>(
    'red_bpm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _greenBpmMeta = const VerificationMeta(
    'greenBpm',
  );
  @override
  late final GeneratedColumn<int> greenBpm = GeneratedColumn<int>(
    'green_bpm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peakCountMeta = const VerificationMeta(
    'peakCount',
  );
  @override
  late final GeneratedColumn<int> peakCount = GeneratedColumn<int>(
    'peak_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slidingBpmMeta = const VerificationMeta(
    'slidingBpm',
  );
  @override
  late final GeneratedColumn<int> slidingBpm = GeneratedColumn<int>(
    'sliding_bpm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _perfusionIndexMeta = const VerificationMeta(
    'perfusionIndex',
  );
  @override
  late final GeneratedColumn<double> perfusionIndex = GeneratedColumn<double>(
    'perfusion_index',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clippedFractionMeta = const VerificationMeta(
    'clippedFraction',
  );
  @override
  late final GeneratedColumn<double> clippedFraction = GeneratedColumn<double>(
    'clipped_fraction',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fpsJitterMeta = const VerificationMeta(
    'fpsJitter',
  );
  @override
  late final GeneratedColumn<double> fpsJitter = GeneratedColumn<double>(
    'fps_jitter',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageYearsMeta = const VerificationMeta(
    'ageYears',
  );
  @override
  late final GeneratedColumn<int> ageYears = GeneratedColumn<int>(
    'age_years',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ejectionTimeMsMeta = const VerificationMeta(
    'ejectionTimeMs',
  );
  @override
  late final GeneratedColumn<double> ejectionTimeMs = GeneratedColumn<double>(
    'ejection_time_ms',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bsaM2Meta = const VerificationMeta('bsaM2');
  @override
  late final GeneratedColumn<double> bsaM2 = GeneratedColumn<double>(
    'bsa_m2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strokeVolumeMlMeta = const VerificationMeta(
    'strokeVolumeMl',
  );
  @override
  late final GeneratedColumn<double> strokeVolumeMl = GeneratedColumn<double>(
    'stroke_volume_ml',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pulsePressureMeta = const VerificationMeta(
    'pulsePressure',
  );
  @override
  late final GeneratedColumn<double> pulsePressure = GeneratedColumn<double>(
    'pulse_pressure',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _systolicMeta = const VerificationMeta(
    'systolic',
  );
  @override
  late final GeneratedColumn<double> systolic = GeneratedColumn<double>(
    'systolic',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diastolicMeta = const VerificationMeta(
    'diastolic',
  );
  @override
  late final GeneratedColumn<double> diastolic = GeneratedColumn<double>(
    'diastolic',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  @override
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _redSamplesMeta = const VerificationMeta(
    'redSamples',
  );
  @override
  late final GeneratedColumn<Uint8List> redSamples = GeneratedColumn<Uint8List>(
    'red_samples',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _greenSamplesMeta = const VerificationMeta(
    'greenSamples',
  );
  @override
  late final GeneratedColumn<Uint8List> greenSamples =
      GeneratedColumn<Uint8List>(
        'green_samples',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<Uint8List> timestampMs =
      GeneratedColumn<Uint8List>(
        'timestamp_ms',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    durationMs,
    frames,
    fps,
    mode,
    fusedBpm,
    redBpm,
    greenBpm,
    peakCount,
    slidingBpm,
    perfusionIndex,
    clippedFraction,
    fpsJitter,
    ageYears,
    weightKg,
    heightCm,
    ejectionTimeMs,
    bsaM2,
    strokeVolumeMl,
    pulsePressure,
    systolic,
    diastolic,
    verdict,
    note,
    redSamples,
    greenSamples,
    timestampMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('frames')) {
      context.handle(
        _framesMeta,
        frames.isAcceptableOrUnknown(data['frames']!, _framesMeta),
      );
    } else if (isInserting) {
      context.missing(_framesMeta);
    }
    if (data.containsKey('fps')) {
      context.handle(
        _fpsMeta,
        fps.isAcceptableOrUnknown(data['fps']!, _fpsMeta),
      );
    } else if (isInserting) {
      context.missing(_fpsMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('fused_bpm')) {
      context.handle(
        _fusedBpmMeta,
        fusedBpm.isAcceptableOrUnknown(data['fused_bpm']!, _fusedBpmMeta),
      );
    } else if (isInserting) {
      context.missing(_fusedBpmMeta);
    }
    if (data.containsKey('red_bpm')) {
      context.handle(
        _redBpmMeta,
        redBpm.isAcceptableOrUnknown(data['red_bpm']!, _redBpmMeta),
      );
    } else if (isInserting) {
      context.missing(_redBpmMeta);
    }
    if (data.containsKey('green_bpm')) {
      context.handle(
        _greenBpmMeta,
        greenBpm.isAcceptableOrUnknown(data['green_bpm']!, _greenBpmMeta),
      );
    } else if (isInserting) {
      context.missing(_greenBpmMeta);
    }
    if (data.containsKey('peak_count')) {
      context.handle(
        _peakCountMeta,
        peakCount.isAcceptableOrUnknown(data['peak_count']!, _peakCountMeta),
      );
    } else if (isInserting) {
      context.missing(_peakCountMeta);
    }
    if (data.containsKey('sliding_bpm')) {
      context.handle(
        _slidingBpmMeta,
        slidingBpm.isAcceptableOrUnknown(data['sliding_bpm']!, _slidingBpmMeta),
      );
    } else if (isInserting) {
      context.missing(_slidingBpmMeta);
    }
    if (data.containsKey('perfusion_index')) {
      context.handle(
        _perfusionIndexMeta,
        perfusionIndex.isAcceptableOrUnknown(
          data['perfusion_index']!,
          _perfusionIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_perfusionIndexMeta);
    }
    if (data.containsKey('clipped_fraction')) {
      context.handle(
        _clippedFractionMeta,
        clippedFraction.isAcceptableOrUnknown(
          data['clipped_fraction']!,
          _clippedFractionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clippedFractionMeta);
    }
    if (data.containsKey('fps_jitter')) {
      context.handle(
        _fpsJitterMeta,
        fpsJitter.isAcceptableOrUnknown(data['fps_jitter']!, _fpsJitterMeta),
      );
    } else if (isInserting) {
      context.missing(_fpsJitterMeta);
    }
    if (data.containsKey('age_years')) {
      context.handle(
        _ageYearsMeta,
        ageYears.isAcceptableOrUnknown(data['age_years']!, _ageYearsMeta),
      );
    } else if (isInserting) {
      context.missing(_ageYearsMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('ejection_time_ms')) {
      context.handle(
        _ejectionTimeMsMeta,
        ejectionTimeMs.isAcceptableOrUnknown(
          data['ejection_time_ms']!,
          _ejectionTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('bsa_m2')) {
      context.handle(
        _bsaM2Meta,
        bsaM2.isAcceptableOrUnknown(data['bsa_m2']!, _bsaM2Meta),
      );
    }
    if (data.containsKey('stroke_volume_ml')) {
      context.handle(
        _strokeVolumeMlMeta,
        strokeVolumeMl.isAcceptableOrUnknown(
          data['stroke_volume_ml']!,
          _strokeVolumeMlMeta,
        ),
      );
    }
    if (data.containsKey('pulse_pressure')) {
      context.handle(
        _pulsePressureMeta,
        pulsePressure.isAcceptableOrUnknown(
          data['pulse_pressure']!,
          _pulsePressureMeta,
        ),
      );
    }
    if (data.containsKey('systolic')) {
      context.handle(
        _systolicMeta,
        systolic.isAcceptableOrUnknown(data['systolic']!, _systolicMeta),
      );
    }
    if (data.containsKey('diastolic')) {
      context.handle(
        _diastolicMeta,
        diastolic.isAcceptableOrUnknown(data['diastolic']!, _diastolicMeta),
      );
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    } else if (isInserting) {
      context.missing(_verdictMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('red_samples')) {
      context.handle(
        _redSamplesMeta,
        redSamples.isAcceptableOrUnknown(data['red_samples']!, _redSamplesMeta),
      );
    } else if (isInserting) {
      context.missing(_redSamplesMeta);
    }
    if (data.containsKey('green_samples')) {
      context.handle(
        _greenSamplesMeta,
        greenSamples.isAcceptableOrUnknown(
          data['green_samples']!,
          _greenSamplesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_greenSamplesMeta);
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      frames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frames'],
      )!,
      fps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fps'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      fusedBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fused_bpm'],
      )!,
      redBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}red_bpm'],
      )!,
      greenBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}green_bpm'],
      )!,
      peakCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peak_count'],
      )!,
      slidingBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sliding_bpm'],
      )!,
      perfusionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}perfusion_index'],
      )!,
      clippedFraction: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}clipped_fraction'],
      )!,
      fpsJitter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fps_jitter'],
      )!,
      ageYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_years'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      ejectionTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ejection_time_ms'],
      ),
      bsaM2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bsa_m2'],
      ),
      strokeVolumeMl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stroke_volume_ml'],
      ),
      pulsePressure: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pulse_pressure'],
      ),
      systolic: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}systolic'],
      ),
      diastolic: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}diastolic'],
      ),
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      redSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}red_samples'],
      )!,
      greenSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}green_samples'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}timestamp_ms'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final DateTime startedAt;
  final int durationMs;
  final int frames;
  final double fps;
  final String mode;
  final double fusedBpm;
  final int redBpm;
  final int greenBpm;
  final int peakCount;
  final int slidingBpm;
  final double perfusionIndex;
  final double clippedFraction;
  final double fpsJitter;
  final int ageYears;
  final double weightKg;
  final double heightCm;
  final double? ejectionTimeMs;
  final double? bsaM2;
  final double? strokeVolumeMl;
  final double? pulsePressure;
  final double? systolic;
  final double? diastolic;
  final String verdict;
  final String note;
  final Uint8List redSamples;
  final Uint8List greenSamples;
  final Uint8List timestampMs;
  const Session({
    required this.id,
    required this.startedAt,
    required this.durationMs,
    required this.frames,
    required this.fps,
    required this.mode,
    required this.fusedBpm,
    required this.redBpm,
    required this.greenBpm,
    required this.peakCount,
    required this.slidingBpm,
    required this.perfusionIndex,
    required this.clippedFraction,
    required this.fpsJitter,
    required this.ageYears,
    required this.weightKg,
    required this.heightCm,
    this.ejectionTimeMs,
    this.bsaM2,
    this.strokeVolumeMl,
    this.pulsePressure,
    this.systolic,
    this.diastolic,
    required this.verdict,
    required this.note,
    required this.redSamples,
    required this.greenSamples,
    required this.timestampMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_ms'] = Variable<int>(durationMs);
    map['frames'] = Variable<int>(frames);
    map['fps'] = Variable<double>(fps);
    map['mode'] = Variable<String>(mode);
    map['fused_bpm'] = Variable<double>(fusedBpm);
    map['red_bpm'] = Variable<int>(redBpm);
    map['green_bpm'] = Variable<int>(greenBpm);
    map['peak_count'] = Variable<int>(peakCount);
    map['sliding_bpm'] = Variable<int>(slidingBpm);
    map['perfusion_index'] = Variable<double>(perfusionIndex);
    map['clipped_fraction'] = Variable<double>(clippedFraction);
    map['fps_jitter'] = Variable<double>(fpsJitter);
    map['age_years'] = Variable<int>(ageYears);
    map['weight_kg'] = Variable<double>(weightKg);
    map['height_cm'] = Variable<double>(heightCm);
    if (!nullToAbsent || ejectionTimeMs != null) {
      map['ejection_time_ms'] = Variable<double>(ejectionTimeMs);
    }
    if (!nullToAbsent || bsaM2 != null) {
      map['bsa_m2'] = Variable<double>(bsaM2);
    }
    if (!nullToAbsent || strokeVolumeMl != null) {
      map['stroke_volume_ml'] = Variable<double>(strokeVolumeMl);
    }
    if (!nullToAbsent || pulsePressure != null) {
      map['pulse_pressure'] = Variable<double>(pulsePressure);
    }
    if (!nullToAbsent || systolic != null) {
      map['systolic'] = Variable<double>(systolic);
    }
    if (!nullToAbsent || diastolic != null) {
      map['diastolic'] = Variable<double>(diastolic);
    }
    map['verdict'] = Variable<String>(verdict);
    map['note'] = Variable<String>(note);
    map['red_samples'] = Variable<Uint8List>(redSamples);
    map['green_samples'] = Variable<Uint8List>(greenSamples);
    map['timestamp_ms'] = Variable<Uint8List>(timestampMs);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      durationMs: Value(durationMs),
      frames: Value(frames),
      fps: Value(fps),
      mode: Value(mode),
      fusedBpm: Value(fusedBpm),
      redBpm: Value(redBpm),
      greenBpm: Value(greenBpm),
      peakCount: Value(peakCount),
      slidingBpm: Value(slidingBpm),
      perfusionIndex: Value(perfusionIndex),
      clippedFraction: Value(clippedFraction),
      fpsJitter: Value(fpsJitter),
      ageYears: Value(ageYears),
      weightKg: Value(weightKg),
      heightCm: Value(heightCm),
      ejectionTimeMs: ejectionTimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(ejectionTimeMs),
      bsaM2: bsaM2 == null && nullToAbsent
          ? const Value.absent()
          : Value(bsaM2),
      strokeVolumeMl: strokeVolumeMl == null && nullToAbsent
          ? const Value.absent()
          : Value(strokeVolumeMl),
      pulsePressure: pulsePressure == null && nullToAbsent
          ? const Value.absent()
          : Value(pulsePressure),
      systolic: systolic == null && nullToAbsent
          ? const Value.absent()
          : Value(systolic),
      diastolic: diastolic == null && nullToAbsent
          ? const Value.absent()
          : Value(diastolic),
      verdict: Value(verdict),
      note: Value(note),
      redSamples: Value(redSamples),
      greenSamples: Value(greenSamples),
      timestampMs: Value(timestampMs),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      frames: serializer.fromJson<int>(json['frames']),
      fps: serializer.fromJson<double>(json['fps']),
      mode: serializer.fromJson<String>(json['mode']),
      fusedBpm: serializer.fromJson<double>(json['fusedBpm']),
      redBpm: serializer.fromJson<int>(json['redBpm']),
      greenBpm: serializer.fromJson<int>(json['greenBpm']),
      peakCount: serializer.fromJson<int>(json['peakCount']),
      slidingBpm: serializer.fromJson<int>(json['slidingBpm']),
      perfusionIndex: serializer.fromJson<double>(json['perfusionIndex']),
      clippedFraction: serializer.fromJson<double>(json['clippedFraction']),
      fpsJitter: serializer.fromJson<double>(json['fpsJitter']),
      ageYears: serializer.fromJson<int>(json['ageYears']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      ejectionTimeMs: serializer.fromJson<double?>(json['ejectionTimeMs']),
      bsaM2: serializer.fromJson<double?>(json['bsaM2']),
      strokeVolumeMl: serializer.fromJson<double?>(json['strokeVolumeMl']),
      pulsePressure: serializer.fromJson<double?>(json['pulsePressure']),
      systolic: serializer.fromJson<double?>(json['systolic']),
      diastolic: serializer.fromJson<double?>(json['diastolic']),
      verdict: serializer.fromJson<String>(json['verdict']),
      note: serializer.fromJson<String>(json['note']),
      redSamples: serializer.fromJson<Uint8List>(json['redSamples']),
      greenSamples: serializer.fromJson<Uint8List>(json['greenSamples']),
      timestampMs: serializer.fromJson<Uint8List>(json['timestampMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'frames': serializer.toJson<int>(frames),
      'fps': serializer.toJson<double>(fps),
      'mode': serializer.toJson<String>(mode),
      'fusedBpm': serializer.toJson<double>(fusedBpm),
      'redBpm': serializer.toJson<int>(redBpm),
      'greenBpm': serializer.toJson<int>(greenBpm),
      'peakCount': serializer.toJson<int>(peakCount),
      'slidingBpm': serializer.toJson<int>(slidingBpm),
      'perfusionIndex': serializer.toJson<double>(perfusionIndex),
      'clippedFraction': serializer.toJson<double>(clippedFraction),
      'fpsJitter': serializer.toJson<double>(fpsJitter),
      'ageYears': serializer.toJson<int>(ageYears),
      'weightKg': serializer.toJson<double>(weightKg),
      'heightCm': serializer.toJson<double>(heightCm),
      'ejectionTimeMs': serializer.toJson<double?>(ejectionTimeMs),
      'bsaM2': serializer.toJson<double?>(bsaM2),
      'strokeVolumeMl': serializer.toJson<double?>(strokeVolumeMl),
      'pulsePressure': serializer.toJson<double?>(pulsePressure),
      'systolic': serializer.toJson<double?>(systolic),
      'diastolic': serializer.toJson<double?>(diastolic),
      'verdict': serializer.toJson<String>(verdict),
      'note': serializer.toJson<String>(note),
      'redSamples': serializer.toJson<Uint8List>(redSamples),
      'greenSamples': serializer.toJson<Uint8List>(greenSamples),
      'timestampMs': serializer.toJson<Uint8List>(timestampMs),
    };
  }

  Session copyWith({
    int? id,
    DateTime? startedAt,
    int? durationMs,
    int? frames,
    double? fps,
    String? mode,
    double? fusedBpm,
    int? redBpm,
    int? greenBpm,
    int? peakCount,
    int? slidingBpm,
    double? perfusionIndex,
    double? clippedFraction,
    double? fpsJitter,
    int? ageYears,
    double? weightKg,
    double? heightCm,
    Value<double?> ejectionTimeMs = const Value.absent(),
    Value<double?> bsaM2 = const Value.absent(),
    Value<double?> strokeVolumeMl = const Value.absent(),
    Value<double?> pulsePressure = const Value.absent(),
    Value<double?> systolic = const Value.absent(),
    Value<double?> diastolic = const Value.absent(),
    String? verdict,
    String? note,
    Uint8List? redSamples,
    Uint8List? greenSamples,
    Uint8List? timestampMs,
  }) => Session(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    durationMs: durationMs ?? this.durationMs,
    frames: frames ?? this.frames,
    fps: fps ?? this.fps,
    mode: mode ?? this.mode,
    fusedBpm: fusedBpm ?? this.fusedBpm,
    redBpm: redBpm ?? this.redBpm,
    greenBpm: greenBpm ?? this.greenBpm,
    peakCount: peakCount ?? this.peakCount,
    slidingBpm: slidingBpm ?? this.slidingBpm,
    perfusionIndex: perfusionIndex ?? this.perfusionIndex,
    clippedFraction: clippedFraction ?? this.clippedFraction,
    fpsJitter: fpsJitter ?? this.fpsJitter,
    ageYears: ageYears ?? this.ageYears,
    weightKg: weightKg ?? this.weightKg,
    heightCm: heightCm ?? this.heightCm,
    ejectionTimeMs: ejectionTimeMs.present
        ? ejectionTimeMs.value
        : this.ejectionTimeMs,
    bsaM2: bsaM2.present ? bsaM2.value : this.bsaM2,
    strokeVolumeMl: strokeVolumeMl.present
        ? strokeVolumeMl.value
        : this.strokeVolumeMl,
    pulsePressure: pulsePressure.present
        ? pulsePressure.value
        : this.pulsePressure,
    systolic: systolic.present ? systolic.value : this.systolic,
    diastolic: diastolic.present ? diastolic.value : this.diastolic,
    verdict: verdict ?? this.verdict,
    note: note ?? this.note,
    redSamples: redSamples ?? this.redSamples,
    greenSamples: greenSamples ?? this.greenSamples,
    timestampMs: timestampMs ?? this.timestampMs,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      frames: data.frames.present ? data.frames.value : this.frames,
      fps: data.fps.present ? data.fps.value : this.fps,
      mode: data.mode.present ? data.mode.value : this.mode,
      fusedBpm: data.fusedBpm.present ? data.fusedBpm.value : this.fusedBpm,
      redBpm: data.redBpm.present ? data.redBpm.value : this.redBpm,
      greenBpm: data.greenBpm.present ? data.greenBpm.value : this.greenBpm,
      peakCount: data.peakCount.present ? data.peakCount.value : this.peakCount,
      slidingBpm: data.slidingBpm.present
          ? data.slidingBpm.value
          : this.slidingBpm,
      perfusionIndex: data.perfusionIndex.present
          ? data.perfusionIndex.value
          : this.perfusionIndex,
      clippedFraction: data.clippedFraction.present
          ? data.clippedFraction.value
          : this.clippedFraction,
      fpsJitter: data.fpsJitter.present ? data.fpsJitter.value : this.fpsJitter,
      ageYears: data.ageYears.present ? data.ageYears.value : this.ageYears,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      ejectionTimeMs: data.ejectionTimeMs.present
          ? data.ejectionTimeMs.value
          : this.ejectionTimeMs,
      bsaM2: data.bsaM2.present ? data.bsaM2.value : this.bsaM2,
      strokeVolumeMl: data.strokeVolumeMl.present
          ? data.strokeVolumeMl.value
          : this.strokeVolumeMl,
      pulsePressure: data.pulsePressure.present
          ? data.pulsePressure.value
          : this.pulsePressure,
      systolic: data.systolic.present ? data.systolic.value : this.systolic,
      diastolic: data.diastolic.present ? data.diastolic.value : this.diastolic,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      note: data.note.present ? data.note.value : this.note,
      redSamples: data.redSamples.present
          ? data.redSamples.value
          : this.redSamples,
      greenSamples: data.greenSamples.present
          ? data.greenSamples.value
          : this.greenSamples,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('frames: $frames, ')
          ..write('fps: $fps, ')
          ..write('mode: $mode, ')
          ..write('fusedBpm: $fusedBpm, ')
          ..write('redBpm: $redBpm, ')
          ..write('greenBpm: $greenBpm, ')
          ..write('peakCount: $peakCount, ')
          ..write('slidingBpm: $slidingBpm, ')
          ..write('perfusionIndex: $perfusionIndex, ')
          ..write('clippedFraction: $clippedFraction, ')
          ..write('fpsJitter: $fpsJitter, ')
          ..write('ageYears: $ageYears, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('ejectionTimeMs: $ejectionTimeMs, ')
          ..write('bsaM2: $bsaM2, ')
          ..write('strokeVolumeMl: $strokeVolumeMl, ')
          ..write('pulsePressure: $pulsePressure, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('verdict: $verdict, ')
          ..write('note: $note, ')
          ..write('redSamples: $redSamples, ')
          ..write('greenSamples: $greenSamples, ')
          ..write('timestampMs: $timestampMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    startedAt,
    durationMs,
    frames,
    fps,
    mode,
    fusedBpm,
    redBpm,
    greenBpm,
    peakCount,
    slidingBpm,
    perfusionIndex,
    clippedFraction,
    fpsJitter,
    ageYears,
    weightKg,
    heightCm,
    ejectionTimeMs,
    bsaM2,
    strokeVolumeMl,
    pulsePressure,
    systolic,
    diastolic,
    verdict,
    note,
    $driftBlobEquality.hash(redSamples),
    $driftBlobEquality.hash(greenSamples),
    $driftBlobEquality.hash(timestampMs),
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.durationMs == this.durationMs &&
          other.frames == this.frames &&
          other.fps == this.fps &&
          other.mode == this.mode &&
          other.fusedBpm == this.fusedBpm &&
          other.redBpm == this.redBpm &&
          other.greenBpm == this.greenBpm &&
          other.peakCount == this.peakCount &&
          other.slidingBpm == this.slidingBpm &&
          other.perfusionIndex == this.perfusionIndex &&
          other.clippedFraction == this.clippedFraction &&
          other.fpsJitter == this.fpsJitter &&
          other.ageYears == this.ageYears &&
          other.weightKg == this.weightKg &&
          other.heightCm == this.heightCm &&
          other.ejectionTimeMs == this.ejectionTimeMs &&
          other.bsaM2 == this.bsaM2 &&
          other.strokeVolumeMl == this.strokeVolumeMl &&
          other.pulsePressure == this.pulsePressure &&
          other.systolic == this.systolic &&
          other.diastolic == this.diastolic &&
          other.verdict == this.verdict &&
          other.note == this.note &&
          $driftBlobEquality.equals(other.redSamples, this.redSamples) &&
          $driftBlobEquality.equals(other.greenSamples, this.greenSamples) &&
          $driftBlobEquality.equals(other.timestampMs, this.timestampMs));
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<int> durationMs;
  final Value<int> frames;
  final Value<double> fps;
  final Value<String> mode;
  final Value<double> fusedBpm;
  final Value<int> redBpm;
  final Value<int> greenBpm;
  final Value<int> peakCount;
  final Value<int> slidingBpm;
  final Value<double> perfusionIndex;
  final Value<double> clippedFraction;
  final Value<double> fpsJitter;
  final Value<int> ageYears;
  final Value<double> weightKg;
  final Value<double> heightCm;
  final Value<double?> ejectionTimeMs;
  final Value<double?> bsaM2;
  final Value<double?> strokeVolumeMl;
  final Value<double?> pulsePressure;
  final Value<double?> systolic;
  final Value<double?> diastolic;
  final Value<String> verdict;
  final Value<String> note;
  final Value<Uint8List> redSamples;
  final Value<Uint8List> greenSamples;
  final Value<Uint8List> timestampMs;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.frames = const Value.absent(),
    this.fps = const Value.absent(),
    this.mode = const Value.absent(),
    this.fusedBpm = const Value.absent(),
    this.redBpm = const Value.absent(),
    this.greenBpm = const Value.absent(),
    this.peakCount = const Value.absent(),
    this.slidingBpm = const Value.absent(),
    this.perfusionIndex = const Value.absent(),
    this.clippedFraction = const Value.absent(),
    this.fpsJitter = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.ejectionTimeMs = const Value.absent(),
    this.bsaM2 = const Value.absent(),
    this.strokeVolumeMl = const Value.absent(),
    this.pulsePressure = const Value.absent(),
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.verdict = const Value.absent(),
    this.note = const Value.absent(),
    this.redSamples = const Value.absent(),
    this.greenSamples = const Value.absent(),
    this.timestampMs = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    required int durationMs,
    required int frames,
    required double fps,
    required String mode,
    required double fusedBpm,
    required int redBpm,
    required int greenBpm,
    required int peakCount,
    required int slidingBpm,
    required double perfusionIndex,
    required double clippedFraction,
    required double fpsJitter,
    required int ageYears,
    required double weightKg,
    required double heightCm,
    this.ejectionTimeMs = const Value.absent(),
    this.bsaM2 = const Value.absent(),
    this.strokeVolumeMl = const Value.absent(),
    this.pulsePressure = const Value.absent(),
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    required String verdict,
    this.note = const Value.absent(),
    required Uint8List redSamples,
    required Uint8List greenSamples,
    required Uint8List timestampMs,
  }) : startedAt = Value(startedAt),
       durationMs = Value(durationMs),
       frames = Value(frames),
       fps = Value(fps),
       mode = Value(mode),
       fusedBpm = Value(fusedBpm),
       redBpm = Value(redBpm),
       greenBpm = Value(greenBpm),
       peakCount = Value(peakCount),
       slidingBpm = Value(slidingBpm),
       perfusionIndex = Value(perfusionIndex),
       clippedFraction = Value(clippedFraction),
       fpsJitter = Value(fpsJitter),
       ageYears = Value(ageYears),
       weightKg = Value(weightKg),
       heightCm = Value(heightCm),
       verdict = Value(verdict),
       redSamples = Value(redSamples),
       greenSamples = Value(greenSamples),
       timestampMs = Value(timestampMs);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<int>? durationMs,
    Expression<int>? frames,
    Expression<double>? fps,
    Expression<String>? mode,
    Expression<double>? fusedBpm,
    Expression<int>? redBpm,
    Expression<int>? greenBpm,
    Expression<int>? peakCount,
    Expression<int>? slidingBpm,
    Expression<double>? perfusionIndex,
    Expression<double>? clippedFraction,
    Expression<double>? fpsJitter,
    Expression<int>? ageYears,
    Expression<double>? weightKg,
    Expression<double>? heightCm,
    Expression<double>? ejectionTimeMs,
    Expression<double>? bsaM2,
    Expression<double>? strokeVolumeMl,
    Expression<double>? pulsePressure,
    Expression<double>? systolic,
    Expression<double>? diastolic,
    Expression<String>? verdict,
    Expression<String>? note,
    Expression<Uint8List>? redSamples,
    Expression<Uint8List>? greenSamples,
    Expression<Uint8List>? timestampMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (frames != null) 'frames': frames,
      if (fps != null) 'fps': fps,
      if (mode != null) 'mode': mode,
      if (fusedBpm != null) 'fused_bpm': fusedBpm,
      if (redBpm != null) 'red_bpm': redBpm,
      if (greenBpm != null) 'green_bpm': greenBpm,
      if (peakCount != null) 'peak_count': peakCount,
      if (slidingBpm != null) 'sliding_bpm': slidingBpm,
      if (perfusionIndex != null) 'perfusion_index': perfusionIndex,
      if (clippedFraction != null) 'clipped_fraction': clippedFraction,
      if (fpsJitter != null) 'fps_jitter': fpsJitter,
      if (ageYears != null) 'age_years': ageYears,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (ejectionTimeMs != null) 'ejection_time_ms': ejectionTimeMs,
      if (bsaM2 != null) 'bsa_m2': bsaM2,
      if (strokeVolumeMl != null) 'stroke_volume_ml': strokeVolumeMl,
      if (pulsePressure != null) 'pulse_pressure': pulsePressure,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (verdict != null) 'verdict': verdict,
      if (note != null) 'note': note,
      if (redSamples != null) 'red_samples': redSamples,
      if (greenSamples != null) 'green_samples': greenSamples,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<int>? durationMs,
    Value<int>? frames,
    Value<double>? fps,
    Value<String>? mode,
    Value<double>? fusedBpm,
    Value<int>? redBpm,
    Value<int>? greenBpm,
    Value<int>? peakCount,
    Value<int>? slidingBpm,
    Value<double>? perfusionIndex,
    Value<double>? clippedFraction,
    Value<double>? fpsJitter,
    Value<int>? ageYears,
    Value<double>? weightKg,
    Value<double>? heightCm,
    Value<double?>? ejectionTimeMs,
    Value<double?>? bsaM2,
    Value<double?>? strokeVolumeMl,
    Value<double?>? pulsePressure,
    Value<double?>? systolic,
    Value<double?>? diastolic,
    Value<String>? verdict,
    Value<String>? note,
    Value<Uint8List>? redSamples,
    Value<Uint8List>? greenSamples,
    Value<Uint8List>? timestampMs,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      durationMs: durationMs ?? this.durationMs,
      frames: frames ?? this.frames,
      fps: fps ?? this.fps,
      mode: mode ?? this.mode,
      fusedBpm: fusedBpm ?? this.fusedBpm,
      redBpm: redBpm ?? this.redBpm,
      greenBpm: greenBpm ?? this.greenBpm,
      peakCount: peakCount ?? this.peakCount,
      slidingBpm: slidingBpm ?? this.slidingBpm,
      perfusionIndex: perfusionIndex ?? this.perfusionIndex,
      clippedFraction: clippedFraction ?? this.clippedFraction,
      fpsJitter: fpsJitter ?? this.fpsJitter,
      ageYears: ageYears ?? this.ageYears,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      ejectionTimeMs: ejectionTimeMs ?? this.ejectionTimeMs,
      bsaM2: bsaM2 ?? this.bsaM2,
      strokeVolumeMl: strokeVolumeMl ?? this.strokeVolumeMl,
      pulsePressure: pulsePressure ?? this.pulsePressure,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      verdict: verdict ?? this.verdict,
      note: note ?? this.note,
      redSamples: redSamples ?? this.redSamples,
      greenSamples: greenSamples ?? this.greenSamples,
      timestampMs: timestampMs ?? this.timestampMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (frames.present) {
      map['frames'] = Variable<int>(frames.value);
    }
    if (fps.present) {
      map['fps'] = Variable<double>(fps.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (fusedBpm.present) {
      map['fused_bpm'] = Variable<double>(fusedBpm.value);
    }
    if (redBpm.present) {
      map['red_bpm'] = Variable<int>(redBpm.value);
    }
    if (greenBpm.present) {
      map['green_bpm'] = Variable<int>(greenBpm.value);
    }
    if (peakCount.present) {
      map['peak_count'] = Variable<int>(peakCount.value);
    }
    if (slidingBpm.present) {
      map['sliding_bpm'] = Variable<int>(slidingBpm.value);
    }
    if (perfusionIndex.present) {
      map['perfusion_index'] = Variable<double>(perfusionIndex.value);
    }
    if (clippedFraction.present) {
      map['clipped_fraction'] = Variable<double>(clippedFraction.value);
    }
    if (fpsJitter.present) {
      map['fps_jitter'] = Variable<double>(fpsJitter.value);
    }
    if (ageYears.present) {
      map['age_years'] = Variable<int>(ageYears.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (ejectionTimeMs.present) {
      map['ejection_time_ms'] = Variable<double>(ejectionTimeMs.value);
    }
    if (bsaM2.present) {
      map['bsa_m2'] = Variable<double>(bsaM2.value);
    }
    if (strokeVolumeMl.present) {
      map['stroke_volume_ml'] = Variable<double>(strokeVolumeMl.value);
    }
    if (pulsePressure.present) {
      map['pulse_pressure'] = Variable<double>(pulsePressure.value);
    }
    if (systolic.present) {
      map['systolic'] = Variable<double>(systolic.value);
    }
    if (diastolic.present) {
      map['diastolic'] = Variable<double>(diastolic.value);
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (redSamples.present) {
      map['red_samples'] = Variable<Uint8List>(redSamples.value);
    }
    if (greenSamples.present) {
      map['green_samples'] = Variable<Uint8List>(greenSamples.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<Uint8List>(timestampMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('frames: $frames, ')
          ..write('fps: $fps, ')
          ..write('mode: $mode, ')
          ..write('fusedBpm: $fusedBpm, ')
          ..write('redBpm: $redBpm, ')
          ..write('greenBpm: $greenBpm, ')
          ..write('peakCount: $peakCount, ')
          ..write('slidingBpm: $slidingBpm, ')
          ..write('perfusionIndex: $perfusionIndex, ')
          ..write('clippedFraction: $clippedFraction, ')
          ..write('fpsJitter: $fpsJitter, ')
          ..write('ageYears: $ageYears, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('ejectionTimeMs: $ejectionTimeMs, ')
          ..write('bsaM2: $bsaM2, ')
          ..write('strokeVolumeMl: $strokeVolumeMl, ')
          ..write('pulsePressure: $pulsePressure, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('verdict: $verdict, ')
          ..write('note: $note, ')
          ..write('redSamples: $redSamples, ')
          ..write('greenSamples: $greenSamples, ')
          ..write('timestampMs: $timestampMs')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _ageYearsMeta = const VerificationMeta(
    'ageYears',
  );
  @override
  late final GeneratedColumn<int> ageYears = GeneratedColumn<int>(
    'age_years',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(25),
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(70),
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(175),
  );
  static const VerificationMeta _defaultModeMeta = const VerificationMeta(
    'defaultMode',
  );
  @override
  late final GeneratedColumn<String> defaultMode = GeneratedColumn<String>(
    'default_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('paper'),
  );
  static const VerificationMeta _showSlidingCrossCheckMeta =
      const VerificationMeta('showSlidingCrossCheck');
  @override
  late final GeneratedColumn<bool> showSlidingCrossCheck =
      GeneratedColumn<bool>(
        'show_sliding_cross_check',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_sliding_cross_check" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ageYears,
    weightKg,
    heightCm,
    defaultMode,
    showSlidingCrossCheck,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('age_years')) {
      context.handle(
        _ageYearsMeta,
        ageYears.isAcceptableOrUnknown(data['age_years']!, _ageYearsMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('default_mode')) {
      context.handle(
        _defaultModeMeta,
        defaultMode.isAcceptableOrUnknown(
          data['default_mode']!,
          _defaultModeMeta,
        ),
      );
    }
    if (data.containsKey('show_sliding_cross_check')) {
      context.handle(
        _showSlidingCrossCheckMeta,
        showSlidingCrossCheck.isAcceptableOrUnknown(
          data['show_sliding_cross_check']!,
          _showSlidingCrossCheckMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ageYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_years'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      defaultMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_mode'],
      )!,
      showSlidingCrossCheck: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_sliding_cross_check'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final int ageYears;
  final double weightKg;
  final double heightCm;
  final String defaultMode;
  final bool showSlidingCrossCheck;
  final DateTime updatedAt;
  const Profile({
    required this.id,
    required this.ageYears,
    required this.weightKg,
    required this.heightCm,
    required this.defaultMode,
    required this.showSlidingCrossCheck,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['age_years'] = Variable<int>(ageYears);
    map['weight_kg'] = Variable<double>(weightKg);
    map['height_cm'] = Variable<double>(heightCm);
    map['default_mode'] = Variable<String>(defaultMode);
    map['show_sliding_cross_check'] = Variable<bool>(showSlidingCrossCheck);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      ageYears: Value(ageYears),
      weightKg: Value(weightKg),
      heightCm: Value(heightCm),
      defaultMode: Value(defaultMode),
      showSlidingCrossCheck: Value(showSlidingCrossCheck),
      updatedAt: Value(updatedAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      ageYears: serializer.fromJson<int>(json['ageYears']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      defaultMode: serializer.fromJson<String>(json['defaultMode']),
      showSlidingCrossCheck: serializer.fromJson<bool>(
        json['showSlidingCrossCheck'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ageYears': serializer.toJson<int>(ageYears),
      'weightKg': serializer.toJson<double>(weightKg),
      'heightCm': serializer.toJson<double>(heightCm),
      'defaultMode': serializer.toJson<String>(defaultMode),
      'showSlidingCrossCheck': serializer.toJson<bool>(showSlidingCrossCheck),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Profile copyWith({
    int? id,
    int? ageYears,
    double? weightKg,
    double? heightCm,
    String? defaultMode,
    bool? showSlidingCrossCheck,
    DateTime? updatedAt,
  }) => Profile(
    id: id ?? this.id,
    ageYears: ageYears ?? this.ageYears,
    weightKg: weightKg ?? this.weightKg,
    heightCm: heightCm ?? this.heightCm,
    defaultMode: defaultMode ?? this.defaultMode,
    showSlidingCrossCheck: showSlidingCrossCheck ?? this.showSlidingCrossCheck,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      ageYears: data.ageYears.present ? data.ageYears.value : this.ageYears,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      defaultMode: data.defaultMode.present
          ? data.defaultMode.value
          : this.defaultMode,
      showSlidingCrossCheck: data.showSlidingCrossCheck.present
          ? data.showSlidingCrossCheck.value
          : this.showSlidingCrossCheck,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('ageYears: $ageYears, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('defaultMode: $defaultMode, ')
          ..write('showSlidingCrossCheck: $showSlidingCrossCheck, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ageYears,
    weightKg,
    heightCm,
    defaultMode,
    showSlidingCrossCheck,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.ageYears == this.ageYears &&
          other.weightKg == this.weightKg &&
          other.heightCm == this.heightCm &&
          other.defaultMode == this.defaultMode &&
          other.showSlidingCrossCheck == this.showSlidingCrossCheck &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<int> ageYears;
  final Value<double> weightKg;
  final Value<double> heightCm;
  final Value<String> defaultMode;
  final Value<bool> showSlidingCrossCheck;
  final Value<DateTime> updatedAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.defaultMode = const Value.absent(),
    this.showSlidingCrossCheck = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.defaultMode = const Value.absent(),
    this.showSlidingCrossCheck = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<int>? ageYears,
    Expression<double>? weightKg,
    Expression<double>? heightCm,
    Expression<String>? defaultMode,
    Expression<bool>? showSlidingCrossCheck,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ageYears != null) 'age_years': ageYears,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (defaultMode != null) 'default_mode': defaultMode,
      if (showSlidingCrossCheck != null)
        'show_sliding_cross_check': showSlidingCrossCheck,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<int>? ageYears,
    Value<double>? weightKg,
    Value<double>? heightCm,
    Value<String>? defaultMode,
    Value<bool>? showSlidingCrossCheck,
    Value<DateTime>? updatedAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      ageYears: ageYears ?? this.ageYears,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      defaultMode: defaultMode ?? this.defaultMode,
      showSlidingCrossCheck:
          showSlidingCrossCheck ?? this.showSlidingCrossCheck,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ageYears.present) {
      map['age_years'] = Variable<int>(ageYears.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (defaultMode.present) {
      map['default_mode'] = Variable<String>(defaultMode.value);
    }
    if (showSlidingCrossCheck.present) {
      map['show_sliding_cross_check'] = Variable<bool>(
        showSlidingCrossCheck.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('ageYears: $ageYears, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('defaultMode: $defaultMode, ')
          ..write('showSlidingCrossCheck: $showSlidingCrossCheck, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    profiles,
    settings,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required DateTime startedAt,
  required int durationMs,
  required int frames,
  required double fps,
  required String mode,
  required double fusedBpm,
  required int redBpm,
  required int greenBpm,
  required int peakCount,
  required int slidingBpm,
  required double perfusionIndex,
  required double clippedFraction,
  required double fpsJitter,
  required int ageYears,
  required double weightKg,
  required double heightCm,
  Value<double?> ejectionTimeMs,
  Value<double?> bsaM2,
  Value<double?> strokeVolumeMl,
  Value<double?> pulsePressure,
  Value<double?> systolic,
  Value<double?> diastolic,
  required String verdict,
  Value<String> note,
  required Uint8List redSamples,
  required Uint8List greenSamples,
  required Uint8List timestampMs,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<int> durationMs,
  Value<int> frames,
  Value<double> fps,
  Value<String> mode,
  Value<double> fusedBpm,
  Value<int> redBpm,
  Value<int> greenBpm,
  Value<int> peakCount,
  Value<int> slidingBpm,
  Value<double> perfusionIndex,
  Value<double> clippedFraction,
  Value<double> fpsJitter,
  Value<int> ageYears,
  Value<double> weightKg,
  Value<double> heightCm,
  Value<double?> ejectionTimeMs,
  Value<double?> bsaM2,
  Value<double?> strokeVolumeMl,
  Value<double?> pulsePressure,
  Value<double?> systolic,
  Value<double?> diastolic,
  Value<String> verdict,
  Value<String> note,
  Value<Uint8List> redSamples,
  Value<Uint8List> greenSamples,
  Value<Uint8List> timestampMs,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frames => $composableBuilder(
    column: $table.frames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fps => $composableBuilder(
    column: $table.fps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fusedBpm => $composableBuilder(
    column: $table.fusedBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get redBpm => $composableBuilder(
    column: $table.redBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get greenBpm => $composableBuilder(
    column: $table.greenBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peakCount => $composableBuilder(
    column: $table.peakCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slidingBpm => $composableBuilder(
    column: $table.slidingBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get perfusionIndex => $composableBuilder(
    column: $table.perfusionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get clippedFraction => $composableBuilder(
    column: $table.clippedFraction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fpsJitter => $composableBuilder(
    column: $table.fpsJitter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ejectionTimeMs => $composableBuilder(
    column: $table.ejectionTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bsaM2 => $composableBuilder(
    column: $table.bsaM2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get strokeVolumeMl => $composableBuilder(
    column: $table.strokeVolumeMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pulsePressure => $composableBuilder(
    column: $table.pulsePressure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get redSamples => $composableBuilder(
    column: $table.redSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get greenSamples => $composableBuilder(
    column: $table.greenSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frames => $composableBuilder(
    column: $table.frames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fps => $composableBuilder(
    column: $table.fps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fusedBpm => $composableBuilder(
    column: $table.fusedBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redBpm => $composableBuilder(
    column: $table.redBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get greenBpm => $composableBuilder(
    column: $table.greenBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peakCount => $composableBuilder(
    column: $table.peakCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slidingBpm => $composableBuilder(
    column: $table.slidingBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get perfusionIndex => $composableBuilder(
    column: $table.perfusionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get clippedFraction => $composableBuilder(
    column: $table.clippedFraction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fpsJitter => $composableBuilder(
    column: $table.fpsJitter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ejectionTimeMs => $composableBuilder(
    column: $table.ejectionTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bsaM2 => $composableBuilder(
    column: $table.bsaM2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get strokeVolumeMl => $composableBuilder(
    column: $table.strokeVolumeMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pulsePressure => $composableBuilder(
    column: $table.pulsePressure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get redSamples => $composableBuilder(
    column: $table.redSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get greenSamples => $composableBuilder(
    column: $table.greenSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frames =>
      $composableBuilder(column: $table.frames, builder: (column) => column);

  GeneratedColumn<double> get fps =>
      $composableBuilder(column: $table.fps, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<double> get fusedBpm =>
      $composableBuilder(column: $table.fusedBpm, builder: (column) => column);

  GeneratedColumn<int> get redBpm =>
      $composableBuilder(column: $table.redBpm, builder: (column) => column);

  GeneratedColumn<int> get greenBpm =>
      $composableBuilder(column: $table.greenBpm, builder: (column) => column);

  GeneratedColumn<int> get peakCount =>
      $composableBuilder(column: $table.peakCount, builder: (column) => column);

  GeneratedColumn<int> get slidingBpm => $composableBuilder(
    column: $table.slidingBpm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get perfusionIndex => $composableBuilder(
    column: $table.perfusionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get clippedFraction => $composableBuilder(
    column: $table.clippedFraction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fpsJitter =>
      $composableBuilder(column: $table.fpsJitter, builder: (column) => column);

  GeneratedColumn<int> get ageYears =>
      $composableBuilder(column: $table.ageYears, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get ejectionTimeMs => $composableBuilder(
    column: $table.ejectionTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bsaM2 =>
      $composableBuilder(column: $table.bsaM2, builder: (column) => column);

  GeneratedColumn<double> get strokeVolumeMl => $composableBuilder(
    column: $table.strokeVolumeMl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pulsePressure => $composableBuilder(
    column: $table.pulsePressure,
    builder: (column) => column,
  );

  GeneratedColumn<double> get systolic =>
      $composableBuilder(column: $table.systolic, builder: (column) => column);

  GeneratedColumn<double> get diastolic =>
      $composableBuilder(column: $table.diastolic, builder: (column) => column);

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<Uint8List> get redSamples => $composableBuilder(
    column: $table.redSamples,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get greenSamples => $composableBuilder(
    column: $table.greenSamples,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> frames = const Value.absent(),
                Value<double> fps = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<double> fusedBpm = const Value.absent(),
                Value<int> redBpm = const Value.absent(),
                Value<int> greenBpm = const Value.absent(),
                Value<int> peakCount = const Value.absent(),
                Value<int> slidingBpm = const Value.absent(),
                Value<double> perfusionIndex = const Value.absent(),
                Value<double> clippedFraction = const Value.absent(),
                Value<double> fpsJitter = const Value.absent(),
                Value<int> ageYears = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double?> ejectionTimeMs = const Value.absent(),
                Value<double?> bsaM2 = const Value.absent(),
                Value<double?> strokeVolumeMl = const Value.absent(),
                Value<double?> pulsePressure = const Value.absent(),
                Value<double?> systolic = const Value.absent(),
                Value<double?> diastolic = const Value.absent(),
                Value<String> verdict = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<Uint8List> redSamples = const Value.absent(),
                Value<Uint8List> greenSamples = const Value.absent(),
                Value<Uint8List> timestampMs = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                startedAt: startedAt,
                durationMs: durationMs,
                frames: frames,
                fps: fps,
                mode: mode,
                fusedBpm: fusedBpm,
                redBpm: redBpm,
                greenBpm: greenBpm,
                peakCount: peakCount,
                slidingBpm: slidingBpm,
                perfusionIndex: perfusionIndex,
                clippedFraction: clippedFraction,
                fpsJitter: fpsJitter,
                ageYears: ageYears,
                weightKg: weightKg,
                heightCm: heightCm,
                ejectionTimeMs: ejectionTimeMs,
                bsaM2: bsaM2,
                strokeVolumeMl: strokeVolumeMl,
                pulsePressure: pulsePressure,
                systolic: systolic,
                diastolic: diastolic,
                verdict: verdict,
                note: note,
                redSamples: redSamples,
                greenSamples: greenSamples,
                timestampMs: timestampMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                required int durationMs,
                required int frames,
                required double fps,
                required String mode,
                required double fusedBpm,
                required int redBpm,
                required int greenBpm,
                required int peakCount,
                required int slidingBpm,
                required double perfusionIndex,
                required double clippedFraction,
                required double fpsJitter,
                required int ageYears,
                required double weightKg,
                required double heightCm,
                Value<double?> ejectionTimeMs = const Value.absent(),
                Value<double?> bsaM2 = const Value.absent(),
                Value<double?> strokeVolumeMl = const Value.absent(),
                Value<double?> pulsePressure = const Value.absent(),
                Value<double?> systolic = const Value.absent(),
                Value<double?> diastolic = const Value.absent(),
                required String verdict,
                Value<String> note = const Value.absent(),
                required Uint8List redSamples,
                required Uint8List greenSamples,
                required Uint8List timestampMs,
              }) => SessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                durationMs: durationMs,
                frames: frames,
                fps: fps,
                mode: mode,
                fusedBpm: fusedBpm,
                redBpm: redBpm,
                greenBpm: greenBpm,
                peakCount: peakCount,
                slidingBpm: slidingBpm,
                perfusionIndex: perfusionIndex,
                clippedFraction: clippedFraction,
                fpsJitter: fpsJitter,
                ageYears: ageYears,
                weightKg: weightKg,
                heightCm: heightCm,
                ejectionTimeMs: ejectionTimeMs,
                bsaM2: bsaM2,
                strokeVolumeMl: strokeVolumeMl,
                pulsePressure: pulsePressure,
                systolic: systolic,
                diastolic: diastolic,
                verdict: verdict,
                note: note,
                redSamples: redSamples,
                greenSamples: greenSamples,
                timestampMs: timestampMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  BaseReferences<_$AppDatabase, $SessionsTable, Session>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<int> ageYears,
  Value<double> weightKg,
  Value<double> heightCm,
  Value<String> defaultMode,
  Value<bool> showSlidingCrossCheck,
  required DateTime updatedAt,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<int> ageYears,
  Value<double> weightKg,
  Value<double> heightCm,
  Value<String> defaultMode,
  Value<bool> showSlidingCrossCheck,
  Value<DateTime> updatedAt,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultMode => $composableBuilder(
    column: $table.defaultMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showSlidingCrossCheck => $composableBuilder(
    column: $table.showSlidingCrossCheck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultMode => $composableBuilder(
    column: $table.defaultMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showSlidingCrossCheck => $composableBuilder(
    column: $table.showSlidingCrossCheck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ageYears =>
      $composableBuilder(column: $table.ageYears, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get defaultMode => $composableBuilder(
    column: $table.defaultMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showSlidingCrossCheck => $composableBuilder(
    column: $table.showSlidingCrossCheck,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ageYears = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<String> defaultMode = const Value.absent(),
                Value<bool> showSlidingCrossCheck = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                ageYears: ageYears,
                weightKg: weightKg,
                heightCm: heightCm,
                defaultMode: defaultMode,
                showSlidingCrossCheck: showSlidingCrossCheck,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ageYears = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<String> defaultMode = const Value.absent(),
                Value<bool> showSlidingCrossCheck = const Value.absent(),
                required DateTime updatedAt,
              }) => ProfilesCompanion.insert(
                id: id,
                ageYears: ageYears,
                weightKg: weightKg,
                heightCm: heightCm,
                defaultMode: defaultMode,
                showSlidingCrossCheck: showSlidingCrossCheck,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, Profile>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
