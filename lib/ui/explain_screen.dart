import 'package:flutter/material.dart';
import 'package:ppg_core/ppg_core.dart';

import '../data/database.dart';
import '../data/session_codec.dart';
import '../design/format.dart';
import '../design/page_scaffold.dart';
import '../design/tokens.dart';
import '../measure/camera_bias.dart';
import '../state/app_scope.dart';

/// Every number on the result screen, opened up.
///
/// This screen exists because the app's claim is that the reading can be
/// traced to the paper's equations. If it cannot be shown here, the claim is
/// just marketing.
class ExplainScreen extends StatelessWidget {
  const ExplainScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return StreamBuilder<Session?>(
      stream: scope.database.watchSession(sessionId),
      builder: (context, snapshot) {
        final session = snapshot.data;
        if (session == null) {
          return const PageScaffold(
            title: 'Explain',
            child: SizedBox.shrink(),
          );
        }
        return _Body(session: session);
      },
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.session});

  final Session session;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  /// The stored capture re-run, so the displayed bin index is the one the
  /// analysis actually used rather than a guess derived from the rate.
  late final Measurement _run = const SessionCodec().replay(
    widget.session,
    widget.session.mode.startsWith('robust')
        ? AnalysisMode.robust
        : AnalysisMode.paper,
  );

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final colors = context.colors;
    final peak = _run.redBpm;
    final n = _run.redPeak.fftLength;
    final k = _run.redPeak.bin;

    return PageScaffold(
      eyebrow: 'Explain',
      title: 'Where the numbers come from',
      subtitle: DateFormatLine.format(session.startedAt),
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Section(
            title: 'One · frames to a rate',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Each camera frame becomes one average red value and one '
                  'average green value. Those two arrays are transformed, the '
                  'largest bin inside 35 to 210 bpm is taken, and Eq. (2) '
                  'converts it.',
                  style: bodyStyle(context),
                ),
                const SizedBox(height: Gap.md),
                _Equation(
                  lines: <String>[
                    'HR = ceil( k × FPS × 60 / N )',
                    '   = ceil( $k × ${session.fps.toStringAsFixed(2)} × 60 / $n )',
                    '   = $peak bpm',
                  ],
                ),
                const SizedBox(height: Gap.md),
                Text(
                  'k is the winning bin, N is the transform length after zero '
                  'padding to a power of two, FPS is measured from the frame '
                  'timestamps rather than assumed.',
                  style: bodyStyle(context, color: colors.muted),
                ),
              ],
            ),
          ),
          const Rule(),
          Section(
            title: 'Two · two colours, one answer',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StatRow(label: 'Red channel', value: '${session.redBpm}', unit: 'bpm'),
                StatRow(
                    label: 'Green channel', value: '${session.greenBpm}', unit: 'bpm'),
                StatRow(
                  label: 'Average, Eq. (2) line 18',
                  value: _run.rawHeartRate.toStringAsFixed(1),
                  unit: 'bpm',
                  emphasis: _run.cameraBiasBpm == 0,
                ),
                if (_run.cameraBiasBpm > 0) ...<Widget>[
                  StatRow(
                    label: 'Camera bias correction',
                    value: '+${_run.cameraBiasBpm}',
                    unit: 'bpm',
                  ),
                  StatRow(
                    label: 'Heart rate used',
                    value: session.fusedBpm.toStringAsFixed(1),
                    unit: 'bpm',
                    emphasis: true,
                  ),
                ],
                const SizedBox(height: Gap.sm),
                Text(
                  'The paper averages the two without checking whether they '
                  'agree. They sample different depths of the same finger, so '
                  'a wide gap is a warning about the capture, not a property '
                  'of your heart.',
                  style: bodyStyle(context, color: colors.muted),
                ),
                if (_run.cameraBiasBpm > 0) ...<Widget>[
                  const SizedBox(height: Gap.sm),
                  Text(
                    'The camera under-reads below '
                    '${cameraBiasThresholdBpm.toStringAsFixed(0)} bpm on this '
                    'device, so the app adds a seeded ${_run.cameraBiasBpm} '
                    'bpm before the pressure equations. The channel rates and '
                    'the transform above are the uncorrected camera values.',
                    style: bodyStyle(context, color: colors.muted),
                  ),
                ],
              ],
            ),
          ),
          const Rule(),
          Section(
            title: 'Three · the rejected counter',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Algorithm 1 compares each frame with the mean of the four '
                  'before it, raises a flag on the way up, and counts '
                  'crossings.',
                  style: bodyStyle(context),
                ),
                const SizedBox(height: Gap.md),
                _Equation(
                  lines: <String>[
                    'peaks = ${session.peakCount}',
                    'HR    = peaks × 2 = ${session.slidingBpm} bpm',
                  ],
                ),
                const SizedBox(height: Gap.md),
                Text(
                  'On this capture that is '
                  '${session.slidingBpm - session.redBpm >= 0 ? '+' : ''}'
                  '${session.slidingBpm - session.redBpm} bpm against the '
                  'transform. The paper reports 60 percent of its readings '
                  'wrong for this reason.',
                  style: bodyStyle(context, color: colors.muted),
                ),
              ],
            ),
          ),
          const Rule(),
          Section(
            title: 'Four · rate to pressure',
            note: 'Eqs. (3) to (8)',
            child: session.hasBloodPressure
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _Equation(
                        lines: <String>[
                          'ET  = 364.5 − 1.23 × ${session.fusedBpm.toStringAsFixed(0)} = ${session.ejectionTimeMs!.toStringAsFixed(1)} ms',
                          'BSA = 0.007184 × ${session.weightKg.toStringAsFixed(0)}^0.425 × ${session.heightCm.toStringAsFixed(0)}^0.725 = ${session.bsaM2!.toStringAsFixed(3)} m²',
                          'SV  = −6.6 + 0.25(ET−35) − 0.62·HR + 40.4·BSA − 0.51·${session.ageYears} = ${session.strokeVolumeMl!.toStringAsFixed(1)} mL',
                          'PP  = SV / (0.013W − 0.007·Age − 0.004·HR + 1.307) = ${session.pulsePressure!.toStringAsFixed(1)} mmHg',
                          'SBP = 83.25 + ⅔·PP = ${session.systolic!.toStringAsFixed(1)} mmHg',
                          'DBP = 83.25 − ⅓·PP = ${session.diastolic!.toStringAsFixed(1)} mmHg',
                        ],
                      ),
                      const SizedBox(height: Gap.md),
                      Text(
                        'Height and weight are the profile values stored with '
                        'this reading, so the same session always reproduces '
                        'the same numbers.',
                        style: bodyStyle(context, color: colors.muted),
                      ),
                    ],
                  )
                : Text(
                    bpRefusalReason(heartRate: session.fusedBpm),
                    style: bodyStyle(context, color: colors.warn),
                  ),
          ),
          const Rule(),
          Section(
            title: 'What this cannot tell you',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'The heart rate is a single dominant frequency from thirty '
                  'seconds of one finger. It says nothing about rhythm, '
                  'arrhythmia, or whether a beat was missed. The pressure '
                  'chain is a published model with a fixed mean pressure, not '
                  'a calibration to you, and it was never compared with a '
                  'cuff in the paper. Neither number replaces a measurement '
                  'by a clinician.',
                  style: bodyStyle(context),
                ),
                const SizedBox(height: Gap.md),
                Text(
                  'Sharma, A., Tanwar, R. S., Singh, Y., Sharma, A., Daudra, '
                  'S., Singal, G., Gadekallu, T. R., Pancholi, S. Heart rate '
                  'and blood pressure measurement based on photoplethysmogram '
                  'signal using fast Fourier transform. Computers and '
                  'Electrical Engineering 101 (2022) 108057.',
                  style: bodyStyle(context, color: colors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Equation extends StatelessWidget {
  const _Equation({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.hairline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                line,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12.5,
                  height: 1.5,
                  color: colors.ink,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
