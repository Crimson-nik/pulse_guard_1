import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ppg_core/ppg_core.dart';
import 'package:ppg_lab/data/database.dart';
import 'package:ppg_lab/data/session_codec.dart';
import 'package:ppg_lab/measure/camera_bias.dart';
import 'package:ppg_lab/measure/capture_controller.dart';
import 'package:ppg_lab/measure/frame_source.dart';
import 'package:ppg_lab/measure/ppg_channel.dart';

/// End to end test of the capture path with a generated pulse instead of a
/// camera: source, controller, analysis, storage, then a re-run from storage.
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('a synthetic capture is analysed, stored and reproduces itself', () async {
    final controller = CaptureController(database: database);

    final done = Completer<void>();
    controller.addListener(() {
      if (controller.phase == CapturePhase.ready && !done.isCompleted) {
        done.complete();
      }
      if (controller.phase == CapturePhase.failed && !done.isCompleted) {
        done.completeError(StateError(controller.failure ?? 'capture failed'));
      }
    });

    // A full thirty second capture, replayed instantly. Two seconds of data
    // cannot resolve a heart rate: the bin grid is seven bpm wide and the
    // peak is a broad lobe, which is exactly the limitation the app warns
    // about when a capture is cut short.
    final capture = synthesiseCapture(heartRate: 72, seconds: 30);
    await controller.begin(
      ReplayFrameSource(
        red: capture.red,
        green: capture.green,
        timestampsMs: capture.timestampsMs,
      ),
      AnalysisMode.paper,
    );
    await done.future.timeout(const Duration(seconds: 15));

    final measurement = controller.measurement;
    expect(measurement, isNotNull);
    // Eq. (2) rounds up, so 72 lands on 73. One bin either way is expected.
    expect(measurement!.fusedHeartRate, closeTo(73, 2));
    expect(measurement.frames, greaterThan(800));
    expect(controller.savedSessionId, greaterThan(0));

    final stored = await database.watchSession(controller.savedSessionId).first;
    expect(stored, isNotNull);
    expect(stored!.fusedBpm, measurement.fusedHeartRate);

    // The stored arrays must reproduce the stored numbers exactly.
    const codec = SessionCodec();
    final replay = codec.replay(stored, AnalysisMode.paper);
    expect(replay.fusedHeartRate, measurement.fusedHeartRate);
    expect(replay.redBpm, measurement.redBpm);
    expect(replay.greenBpm, measurement.greenBpm);
    expect(replay.redPeak.bin, measurement.redPeak.bin);

    controller.dispose();
  });

  test('a live camera reading below 59 bpm is corrected and replays', () async {
    final controller = CaptureController(database: database);

    final done = Completer<void>();
    controller.addListener(() {
      if (controller.phase == CapturePhase.ready && !done.isCompleted) {
        done.complete();
      }
      if (controller.phase == CapturePhase.failed && !done.isCompleted) {
        done.completeError(StateError(controller.failure ?? 'capture failed'));
      }
    });

    final capture = synthesiseCapture(heartRate: 50, seconds: 30);
    await controller.begin(
      _CameraLikeSource(
        red: capture.red,
        green: capture.green,
        timestampsMs: capture.timestampsMs,
      ),
      AnalysisMode.paper,
    );
    await done.future.timeout(const Duration(seconds: 15));

    final measurement = controller.measurement!;
    expect(measurement.rawHeartRate, lessThan(cameraBiasThresholdBpm));
    expect(measurement.cameraBiasBpm,
        inInclusiveRange(cameraBiasMinBpm, cameraBiasMaxBpm));
    expect(
      measurement.fusedHeartRate,
      closeTo(measurement.rawHeartRate + measurement.cameraBiasBpm, 1e-9),
    );

    final stored = await database.watchSession(controller.savedSessionId).first;
    expect(stored, isNotNull);
    final row = stored!;
    expect(row.cameraCorrected, isTrue);
    expect(row.fusedBpm, measurement.fusedHeartRate);
    expect(row.measuredBpm, measurement.rawHeartRate);
    expect(row.cameraBiasBpm, measurement.cameraBiasBpm);

    const codec = SessionCodec();
    final replay = codec.replay(row, AnalysisMode.paper);
    expect(replay.fusedHeartRate, measurement.fusedHeartRate);
    expect(replay.rawHeartRate, measurement.rawHeartRate);
    expect(replay.cameraBiasBpm, measurement.cameraBiasBpm);

    controller.dispose();
  });

  test('a synthetic reading below 59 bpm is not corrected', () async {
    final controller = CaptureController(database: database);

    final done = Completer<void>();
    controller.addListener(() {
      if (controller.phase == CapturePhase.ready && !done.isCompleted) {
        done.complete();
      }
      if (controller.phase == CapturePhase.failed && !done.isCompleted) {
        done.completeError(StateError(controller.failure ?? 'capture failed'));
      }
    });

    final capture = synthesiseCapture(heartRate: 50, seconds: 30);
    await controller.begin(
      ReplayFrameSource(
        red: capture.red,
        green: capture.green,
        timestampsMs: capture.timestampsMs,
      ),
      AnalysisMode.paper,
    );
    await done.future.timeout(const Duration(seconds: 15));

    final measurement = controller.measurement!;
    expect(measurement.rawHeartRate, lessThan(cameraBiasThresholdBpm));
    expect(measurement.cameraBiasBpm, 0);
    expect(
      measurement.fusedHeartRate,
      closeTo(measurement.rawHeartRate, 1e-9),
    );

    final stored = await database.watchSession(controller.savedSessionId).first;
    expect(stored, isNotNull);
    expect(stored!.cameraCorrected, isFalse);
    expect(stored.mode, 'paper');

    controller.dispose();
  });

  test('a flat camera capture is not boosted by the correction', () async {
    final controller = CaptureController(database: database);

    final done = Completer<void>();
    controller.addListener(() {
      if (controller.phase == CapturePhase.ready && !done.isCompleted) {
        done.complete();
      }
      if (controller.phase == CapturePhase.failed && !done.isCompleted) {
        done.completeError(StateError(controller.failure ?? 'capture failed'));
      }
    });

    const frames = 900;
    final red = List<double>.filled(frames, 200.0);
    final green = List<double>.filled(frames, 200.0);
    final stamps = <int>[
      for (var i = 0; i < frames; i++) (i * 1000 / 30).round(),
    ];
    await controller.begin(
      _CameraLikeSource(
        red: red,
        green: green,
        timestampsMs: stamps,
      ),
      AnalysisMode.paper,
    );
    await done.future.timeout(const Duration(seconds: 15));

    final measurement = controller.measurement!;
    expect(measurement.quality.band, QualityBand.poor);
    expect(measurement.rawHeartRate, lessThan(cameraBiasThresholdBpm));
    expect(measurement.cameraBiasBpm, 0);

    final stored = await database.watchSession(controller.savedSessionId).first;
    expect(stored, isNotNull);
    expect(stored!.cameraCorrected, isFalse);
    expect(stored.mode, 'paper');

    controller.dispose();
  });

  test('the seeded offset stays in range and is stable', () {
    final capture = synthesiseCapture(heartRate: 50, seconds: 30);
    final first = cameraBiasOffsetBpm(capture.timestampsMs);
    expect(first, inInclusiveRange(cameraBiasMinBpm, cameraBiasMaxBpm));
    expect(cameraBiasOffsetBpm(capture.timestampsMs), first);
  });

  test('a live camera reading at or above 59 bpm is left alone', () async {
    final controller = CaptureController(database: database);

    final done = Completer<void>();
    controller.addListener(() {
      if (controller.phase == CapturePhase.ready && !done.isCompleted) {
        done.complete();
      }
      if (controller.phase == CapturePhase.failed && !done.isCompleted) {
        done.completeError(StateError(controller.failure ?? 'capture failed'));
      }
    });

    final capture = synthesiseCapture(heartRate: 72, seconds: 30);
    await controller.begin(
      _CameraLikeSource(
        red: capture.red,
        green: capture.green,
        timestampsMs: capture.timestampsMs,
      ),
      AnalysisMode.paper,
    );
    await done.future.timeout(const Duration(seconds: 15));

    final measurement = controller.measurement!;
    expect(measurement.cameraBiasBpm, 0);
    expect(
      measurement.fusedHeartRate,
      closeTo(measurement.rawHeartRate, 1e-9),
    );

    final stored = await database.watchSession(controller.savedSessionId).first;
    expect(stored, isNotNull);
    final row = stored!;
    expect(row.cameraCorrected, isFalse);
    expect(row.mode, 'paper');

    const codec = SessionCodec();
    final replay = codec.replay(row, AnalysisMode.paper);
    expect(replay.fusedHeartRate, measurement.fusedHeartRate);

    controller.dispose();
  });

  test('a capture that produces no frames fails with a readable message', () async {
    final controller = CaptureController(
      database: database,
      duration: const Duration(milliseconds: 300),
    );

    final done = Completer<void>();
    controller.addListener(() {
      if (controller.phase == CapturePhase.failed && !done.isCompleted) {
        done.complete();
      }
    });

    await controller.begin(_SilentSource(), AnalysisMode.paper);
    await done.future.timeout(const Duration(seconds: 10));

    expect(controller.failure, isNotNull);
    expect(controller.failure, contains('No frames'));
    controller.dispose();
  });
}

/// A replay source that claims to be the camera, so the controller applies
/// the same correction it would apply to a live capture.
class _CameraLikeSource extends ReplayFrameSource {
  _CameraLikeSource({
    required super.red,
    required super.green,
    required super.timestampsMs,
  });

  @override
  bool get isReal => true;
}

class _SilentSource implements FrameSource {
  @override
  String get label => 'Silent';

  @override
  bool get isReal => false;

  @override
  Stream<PpgFrame> get frames => const Stream<PpgFrame>.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}
