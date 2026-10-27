import 'dart:async';

import 'package:flutter/services.dart';

/// One sample: the mean red and mean green of a single camera frame.
class PpgFrame {
  const PpgFrame({required this.red, required this.green, required this.tMs});

  final double red;
  final double green;

  /// Milliseconds since the capture started, from the camera side clock.
  final int tMs;
}

/// The Kotlin side of the camera. Everything here is a thin wrapper; the
/// judgement about what the numbers mean lives in `ppg_core`.
class PpgChannel {
  static const MethodChannel _methods = MethodChannel('app.ppglab/camera');
  static const EventChannel _stream = EventChannel('app.ppglab/frames');

  Stream<PpgFrame>? _frames;

  Future<bool> hasFlash() async {
    try {
      return await _methods.invokeMethod<bool>('hasFlash') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      return await _methods.invokeMethod<bool>('requestPermission') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> start() async {
    await _methods.invokeMethod<void>('start');
  }

  Future<void> stop() async {
    try {
      await _methods.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Stopping something that never started is not an error.
    }
  }

  Future<void> setTorch(bool on) async {
    try {
      await _methods.invokeMethod<void>('torch', {'on': on});
    } on MissingPluginException {
      // Ignored off device.
    }
  }

  Stream<PpgFrame> frames() {
    return _frames ??= _stream.receiveBroadcastStream().map((event) {
      final map = (event as Map).cast<Object?, Object?>();
      return PpgFrame(
        red: (map['r'] as num).toDouble(),
        green: (map['g'] as num).toDouble(),
        tMs: (map['t'] as num).toInt(),
      );
    });
  }
}
