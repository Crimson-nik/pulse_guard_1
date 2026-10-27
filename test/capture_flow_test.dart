import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ppg_core/ppg_core.dart';
import 'package:ppg_lab/data/database.dart';
import 'package:ppg_lab/data/session_codec.dart';
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
