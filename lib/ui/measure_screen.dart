import 'package:flutter/material.dart';
import 'package:ppg_core/ppg_core.dart';

import '../design/page_scaffold.dart';
import '../design/pulse_trace.dart';
import '../design/tokens.dart';
import '../measure/capture_controller.dart';
import '../measure/frame_source.dart';
import '../state/app_scope.dart';
import 'result_screen.dart';

/// One thirty second capture, with the trace and the quality metrics live so
/// the user can correct a bad finger placement instead of finding out after.
class MeasureScreen extends StatefulWidget {
  const MeasureScreen({super.key, this.forceSynthetic = false});

  /// Used by the Validation screen and by anyone without a working camera.
  final bool forceSynthetic;

  @override
  State<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends State<MeasureScreen> {
  CaptureController? _controller;
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= CaptureController(
      database: AppScope.of(context).database,
    )..addListener(_onChanged);
  }

  void _onChanged() {
    final controller = _controller!;
    if (controller.phase == CapturePhase.ready && !_navigated) {
      _navigated = true;
      final id = controller.savedSessionId;
      if (id <= 0) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => ResultScreen(sessionId: id)),
        );
      });
    }
  }

  Future<void> _start({bool synthetic = false}) async {
    final profile = AppScope.of(context).profile.value;
    final controller = _controller!;
    controller.profile = profile;
    _navigated = false;
    final source = synthetic
        ? SyntheticFrameSource(heartRate: 72, fps: 30, seconds: 30)
        : LiveFrameSource();
    await controller.begin(source, profile.mode);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    final colors = context.colors;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return PageScaffold(
          eyebrow: 'Capture',
          title: switch (controller.phase) {
            CapturePhase.capturing => 'Measuring',
            CapturePhase.analysing => 'Working it out',
            CapturePhase.ready => 'Done',
            CapturePhase.failed => 'Capture stopped',
            _ => 'Measure',
          },
          onBack: () async {
            await controller.cancel();
            if (context.mounted) Navigator.of(context).pop();
          },
          subtitle: 'Thirty seconds at rest, fingertip on the lens and flash.',
          scrollable: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: Gap.md),
                if (controller.phase == CapturePhase.capturing)
                  _CapturingView(controller: controller)
                else if (controller.phase == CapturePhase.analysing)
                  const _Working()
                else if (controller.phase == CapturePhase.failed)
                  _FailedView(
                    message: controller.failure ?? 'The capture failed.',
                    onRetry: () => _start(),
                    onSynthetic: () => _start(synthetic: true),
                  )
                else if (controller.phase == CapturePhase.preparing)
                  const _Preparing()
                else
                  _IdleView(
                    onStart: () => _start(),
                    onSynthetic: () => _start(synthetic: true),
                  ),
                const SizedBox(height: Gap.xl),
                Text(
                  widget.forceSynthetic
                      ? 'Synthetic capture. The numbers describe a generated '
                          'waveform, not a person.'
                      : 'Hold the phone still. A moving finger changes the '
                          'frame averages through shading rather than blood, '
                          'which is the one failure this method cannot detect.',
                  style: bodyStyle(context, color: colors.muted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onStart, required this.onSynthetic});

  final VoidCallback onStart;
  final VoidCallback onSynthetic;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Rest for a minute first, then sit still and place the pad of an '
          'index finger over the rear camera and the flash. Cover both '
          'completely and press gently: too hard and the blood stops moving '
          'under the sensor.',
          style: bodyStyle(context),
        ),
        const SizedBox(height: Gap.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onStart,
            child: const Text('Start 30 second capture'),
          ),
        ),
        const SizedBox(height: Gap.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onSynthetic,
            child: const Text('Run a synthetic capture'),
          ),
        ),
        const SizedBox(height: Gap.sm),
        Text(
          'The synthetic option generates a known 72 bpm waveform. Use it to '
          'check that the app behaves, never as a reading of yourself.',
          style: bodyStyle(context, color: colors.muted),
        ),
      ],
    );
  }
}

class _Preparing extends StatelessWidget {
  const _Preparing();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Starting the camera and the torch.', style: bodyStyle(context)),
        const SizedBox(height: Gap.lg),
        const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}

class _Working extends StatelessWidget {
  const _Working();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Transforming the red and green arrays and running the pressure '
          'equations.',
          style: bodyStyle(context),
        ),
        const SizedBox(height: Gap.lg),
        const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}

class _CapturingView extends StatelessWidget {
  const _CapturingView({required this.controller});

  final CaptureController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final quality = controller.liveQuality;
    final seconds = controller.remainingSeconds.ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              '$seconds',
              style: readingStyle(context, color: colors.ink),
            ),
            const SizedBox(width: Gap.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('seconds left',
                  style: bodyStyle(context, color: colors.muted)),
            ),
          ],
        ),
        const SizedBox(height: Gap.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: controller.progress,
            minHeight: 3,
            backgroundColor: colors.hairline,
            valueColor: AlwaysStoppedAnimation<Color>(colors.artery),
          ),
        ),
        const SizedBox(height: Gap.xl),
        Section(
          title: 'Red channel',
          note: '${controller.red.length} frames',
          child: PulseTrace(
            values: controller.traceRed,
            height: 140,
            semanticLabel: 'Live red channel trace',
          ),
        ),
        const SizedBox(height: Gap.lg),
        Section(
          title: 'Green channel',
          child: PulseTrace(
            values: controller.traceGreen,
            height: 80,
            color: colors.slate,
            semanticLabel: 'Live green channel trace',
          ),
        ),
        const Rule(),
        StatRow(
          label: 'Pulse strength',
          value: quality == null
              ? 'measuring'
              : '${quality.perfusionIndex.toStringAsFixed(1)} %',
        ),
        StatRow(
          label: 'Frame rate',
          value: quality == null
              ? 'measuring'
              : quality.measuredFps.toStringAsFixed(1),
          unit: 'fps',
        ),
        if (quality != null && quality.band != QualityBand.good)
          Padding(
            padding: const EdgeInsets.only(top: Gap.sm),
            child: Text(
              quality.advice,
              style: bodyStyle(context, color: colors.warn),
            ),
          ),
        const SizedBox(height: Gap.xl),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => controller.finish(),
            child: const Text('Stop and analyse now'),
          ),
        ),
      ],
    );
  }
}

class _FailedView extends StatelessWidget {
  const _FailedView({
    required this.message,
    required this.onRetry,
    required this.onSynthetic,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSynthetic;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            border: Border.all(color: colors.artery),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(message, style: bodyStyle(context)),
        ),
        const SizedBox(height: Gap.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ),
        const SizedBox(height: Gap.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onSynthetic,
            child: const Text('Run a synthetic capture instead'),
          ),
        ),
      ],
    );
  }
}
