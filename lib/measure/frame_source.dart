import 'dart:async';
import 'dart:math' as math;

import 'ppg_channel.dart';

/// Where frames come from.
///
/// Three implementations: the camera, a stored session replayed, and a
/// synthetic pulse. The last two exist because this app has to be testable
/// and demonstrable on a machine with no camera, and because the Validation
/// screen needs to re-run real recordings through both pipelines.
abstract class FrameSource {
  Stream<PpgFrame> get frames;
  Future<void> start();
  Future<void> stop();
  String get label;
  bool get isReal;
}

/// The rear camera through CameraX.
class LiveFrameSource implements FrameSource {
  LiveFrameSource([PpgChannel? channel]) : _channel = channel ?? PpgChannel();

  final PpgChannel _channel;

  @override
  String get label => 'Camera';

  @override
  bool get isReal => true;

  @override
  Stream<PpgFrame> get frames => _channel.frames();

  @override
  Future<void> start() => _channel.start();

  @override
  Future<void> stop() async {
    await _channel.stop();
    await _channel.setTorch(false);
  }
}

/// A recorded capture, replayed at its original timing.
class ReplayFrameSource implements FrameSource {
  ReplayFrameSource({
    required this.red,
    required this.green,
    required this.timestampsMs,
  });

  final List<double> red;
  final List<double> green;
  final List<int> timestampsMs;

  @override
  String get label => 'Replay';

  @override
  bool get isReal => false;

  @override
  Stream<PpgFrame> get frames async* {
    for (var i = 0; i < red.length; i++) {
      yield PpgFrame(red: red[i], green: green[i], tMs: timestampsMs[i]);
    }
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

/// A generated pulse, for demonstration and for the widget tests.
///
/// It is not a model of a finger. It is the same two harmonic shape used by
/// the Python fixtures, with a little noise, so that a synthetic run and a
/// fixture run produce the same kind of number.
class SyntheticFrameSource implements FrameSource {
  SyntheticFrameSource({
    this.heartRate = 72,
    this.fps = 30,
    this.seconds = 30,
    this.noise = 0.8,
    this.seed = 11,
  });

  final double heartRate;
  final double fps;
  final double seconds;
  final double noise;
  final int seed;

  Timer? _timer;
  var _index = 0;

  @override
  String get label => 'Synthetic';

  @override
  bool get isReal => false;

  @override
  Stream<PpgFrame> get frames {
    final controller = StreamController<PpgFrame>();
    final rng = math.Random(seed);
    final total = (fps * seconds).round();
    final f0 = heartRate / 60.0;
    final started = DateTime.now();

    controller.onListen = () {
      _timer = Timer.periodic(
        Duration(microseconds: (1000000 / fps).round()),
        (timer) {
          if (_index >= total || controller.isClosed) {
            timer.cancel();
            controller.close();
            return;
          }
          final t = _index / fps;
          final base = 200 + 18 * math.sin(2 * math.pi * f0 * t);
          final notch = 18 * 0.35 * math.sin(2 * math.pi * 2 * f0 * t + 0.6);
          final drift = 3 * math.sin(2 * math.pi * 0.08 * t);
          controller.add(
            PpgFrame(
              red: base + notch + drift + noise * (rng.nextDouble() - 0.5),
              green: 0.55 * base +
                  0.8 * notch +
                  drift +
                  noise * (rng.nextDouble() - 0.5),
              tMs: DateTime.now().difference(started).inMilliseconds,
            ),
          );
          _index++;
        },
      );
    };

    controller.onCancel = () {
      _timer?.cancel();
      _timer = null;
    };
    return controller.stream;
  }

  @override
  Future<void> start() async {
    _index = 0;
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }
}
