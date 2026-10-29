import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ppg_core/ppg_core.dart';

import '../data/database.dart';
import '../data/session_codec.dart';
import '../data/user_profile.dart';
import 'camera_bias.dart';
import 'frame_source.dart';
import 'ppg_channel.dart';

enum CapturePhase { idle, preparing, capturing, analysing, ready, failed }

/// Runs one capture and hands back one measurement.
///
/// This is the only mutable state in the app. Screens read it and nothing
/// else holds a copy of the numbers, so there is one answer to "what is the
/// current reading" at any moment.
class CaptureController extends ChangeNotifier {
  CaptureController({
    required this.database,
    this.duration = const Duration(seconds: 30),
    this.traceWindow = 240,
  });

  final AppDatabase database;
  final Duration duration;

  /// How many recent samples the live trace draws.
  final int traceWindow;

  static const codec = SessionCodec();

  CapturePhase phase = CapturePhase.idle;
  String? failure;
  FrameSource? source;

  final List<double> red = <double>[];
  final List<double> green = <double>[];
  final List<int> timestamps = <int>[];

  Measurement? measurement;
  int savedSessionId = -1;
  bool savedAsUnusable = false;

  /// True once a capture has produced enough data to be analysed at all.
  bool get hasData => red.length >= 32;

  double get elapsedMs =>
      timestamps.isEmpty ? 0 : timestamps.last.toDouble();

  double get progress =>
      (elapsedMs / duration.inMilliseconds).clamp(0.0, 1.0).toDouble();

  double get remainingSeconds {
    final left = duration.inMilliseconds - elapsedMs;
    return (left / 1000).clamp(0, double.infinity).toDouble();
  }

  List<double> get traceRed => red.length <= traceWindow
      ? red
      : red.sublist(red.length - traceWindow);

  List<double> get traceGreen => green.length <= traceWindow
      ? green
      : green.sublist(green.length - traceWindow);

  SignalQuality? get liveQuality {
    if (timestamps.length < 30) return null;
    return assessQuality(red: red, timestampsMs: timestamps);
  }

  StreamSubscription<PpgFrame>? _subscription;
  Timer? _ticker;
  bool _finishing = false;

  Future<void> begin(FrameSource frameSource, AnalysisMode mode) async {
    _reset();
    _mode = mode;
    source = frameSource;
    phase = CapturePhase.preparing;
    notifyListeners();

    if (frameSource is LiveFrameSource) {
      final channel = PpgChannel();
      final hasFlash = await channel.hasFlash();
      if (!hasFlash) {
        _fail('This device reports no camera flash. The method needs the '
            'torch against the skin.');
        return;
      }
      final granted = await channel.requestPermission();
      if (!granted) {
        _fail('Camera permission is required to read your pulse.');
        return;
      }
    }

    try {
      await frameSource.start();
    } catch (error) {
      _fail('The camera did not start: $error');
      return;
    }

    phase = CapturePhase.capturing;
    notifyListeners();

    _subscription = frameSource.frames.listen(
      _onFrame,
      onError: (Object error) {
        _fail('The camera stream stopped: $error');
      },
      onDone: () {
        if (phase == CapturePhase.capturing) {
          finish();
        }
      },
    );

    _ticker = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (phase != CapturePhase.capturing) return;
      if (elapsedMs >= duration.inMilliseconds) {
        finish();
      } else {
        notifyListeners();
      }
    });
  }

  void _onFrame(PpgFrame frame) {
    if (phase != CapturePhase.capturing) return;
    red.add(frame.red);
    green.add(frame.green);
    timestamps.add(frame.tMs);
  }

  /// Ends the capture early or on time and analyses whatever arrived.
  Future<void> finish() async {
    if (_finishing || phase != CapturePhase.capturing) return;
    _finishing = true;
    _ticker?.cancel();
    await _subscription?.cancel();
    _subscription = null;
    await source?.stop();

    if (!hasData) {
      _fail('No frames arrived. Check that the camera is not in use by '
          'another app, then try again.');
      return;
    }

    phase = CapturePhase.analysing;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);

    final raw = analyseCapture(
      red: red,
      green: green,
      timestampsMs: timestamps,
      mode: _mode,
      ageYears: _profile.ageYears,
      weightKg: _profile.weightKg,
      heightCm: _profile.heightCm,
    );
    // Synthetic and replayed sources must stay pure paper output. Only a
    // live camera carries the under-read that the correction covers.
    final result = (source?.isReal ?? false)
        ? correctCameraBias(
            raw: raw,
            timestampsMs: timestamps,
            ageYears: _profile.ageYears,
            weightKg: _profile.weightKg,
            heightCm: _profile.heightCm,
          )
        : raw;
    measurement = result;
    await _persist(result);
    phase = CapturePhase.ready;
    _finishing = false;
    notifyListeners();
  }

  AnalysisMode _mode = AnalysisMode.paper;

  UserProfile _profile = const UserProfile();

  /// The profile is passed in rather than looked up so the controller stays
  /// testable without a database read.
  set profile(UserProfile value) => _profile = value;

  Future<void> _persist(Measurement result) async {
    savedAsUnusable = result.quality.band == QualityBand.poor;
    try {
      savedSessionId = await database.insertSession(
        codec.toRow(
          measurement: result,
          red: red,
          green: green,
          timestamps: timestamps,
          startedAt: DateTime.now().subtract(
            Duration(milliseconds: elapsedMs.round()),
          ),
          ageYears: _profile.ageYears,
          weightKg: _profile.weightKg,
          heightCm: _profile.heightCm,
        ),
      );
    } catch (error) {
      failure = 'The reading was computed but could not be saved: $error';
      notifyListeners();
    }
  }

  Future<void> cancel() async {
    _ticker?.cancel();
    await _subscription?.cancel();
    _subscription = null;
    await source?.stop();
    _reset();
    notifyListeners();
  }

  void _fail(String message) {
    _ticker?.cancel();
    _subscription?.cancel();
    _subscription = null;
    phase = CapturePhase.failed;
    failure = message;
    _finishing = false;
    notifyListeners();
  }

  void _reset() {
    red.clear();
    green.clear();
    timestamps.clear();
    measurement = null;
    savedSessionId = -1;
    savedAsUnusable = false;
    failure = null;
    _finishing = false;
    phase = CapturePhase.idle;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
