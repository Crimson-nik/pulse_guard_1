import 'package:flutter/material.dart';
import 'package:ppg_core/ppg_core.dart';

import '../data/database.dart';
import '../data/session_codec.dart';
import '../design/format.dart';
import '../design/page_scaffold.dart';
import '../design/tokens.dart';
import '../state/app_scope.dart';

/// Checks that can be run on the device, at any time, without a reference
/// instrument.
///
/// There are two kinds of claim an app like this can make. One is about
/// plumbing: does the stored capture re-analyse to the same number, do the
/// two pipelines behave as described. That is checkable here. The other is
/// about accuracy against a cuff or a pulse oximeter, which needs a second
/// instrument and a person; `docs/validation.md` describes that protocol.
class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  static const _codec = SessionCodec();

  double _trueRate = 72;
  Measurement? _paper;
  Measurement? _robust;
  Session? _selected;

  void _runSynthetic() {
    final capture = synthesiseCapture(heartRate: _trueRate);
    // Deliberately no camera correction here. This check exists to measure
    // the paper arithmetic; the live camera path is corrected separately.
    final paper = analyseCapture(
      red: capture.red,
      green: capture.green,
      timestampsMs: capture.timestampsMs,
      mode: AnalysisMode.paper,
      ageYears: 25,
      weightKg: 70,
      heightCm: 175,
    );
    final robust = analyseCapture(
      red: capture.red,
      green: capture.green,
      timestampsMs: capture.timestampsMs,
      mode: AnalysisMode.robust,
      ageYears: 25,
      weightKg: 70,
      heightCm: 175,
    );
    setState(() {
      _paper = paper;
      _robust = robust;
      _selected = null;
    });
  }

  void _replayStored(Session session) {
    setState(() {
      _selected = session;
      _paper = _codec.replay(session, AnalysisMode.paper);
      _robust = _codec.replay(session, AnalysisMode.robust);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final colors = context.colors;

    return PageScaffold(
      eyebrow: 'Validation',
      title: 'Check the method on this device',
      subtitle: 'Two checks that need no second instrument, and one that does.',
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Section(
            title: 'One · recovery from a known rate',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'A waveform is generated at a rate you choose, then analysed '
                  'through both pipelines. The true answer is known, so the '
                  'error is real and not estimated. This check runs the paper '
                  'arithmetic without the live camera bias correction.',
                  style: bodyStyle(context),
                ),
                const SizedBox(height: Gap.lg),
                Row(
                  children: <Widget>[
                    Text('True rate', style: bodyStyle(context, color: colors.muted)),
                    const Spacer(),
                    Text(
                      '${_trueRate.round()} bpm',
                      style: bodyStyle(context).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFeatures: tabularFigures,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _trueRate,
                  min: 45,
                  max: 120,
                  divisions: 75,
                  label: '${_trueRate.round()} bpm',
                  activeColor: colors.artery,
                  onChanged: (v) => setState(() => _trueRate = v),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _runSynthetic,
                    child: const Text('Run the recovery check'),
                  ),
                ),
              ],
            ),
          ),
          if (_paper != null && _robust != null && _selected == null) ...<Widget>[
            const SizedBox(height: Gap.lg),
            _ResultBlock(
              trueRate: _trueRate,
              paper: _paper!,
              robust: _robust!,
            ),
          ],
          const Rule(),
          Section(
            title: 'Two · re-run a stored capture',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Pick a recorded session and analyse the saved samples '
                  'again. The paper path should reproduce the stored numbers '
                  'exactly; if it does not, either the code changed or the '
                  'record is not self contained.',
                  style: bodyStyle(context),
                ),
                const SizedBox(height: Gap.md),
                StreamBuilder<List<Session>>(
                  stream: scope.database.watchSessions(),
                  builder: (context, snapshot) {
                    final sessions = snapshot.data ?? const <Session>[];
                    if (sessions.isEmpty) {
                      return Text(
                        'No stored sessions yet.',
                        style: bodyStyle(context, color: colors.muted),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (final s in sessions.take(5))
                          InkWell(
                            onTap: () => _replayStored(s),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: Gap.md),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '${DateFormatLine.format(s.startedAt)}  '
                                      '${s.fusedBpm.toStringAsFixed(0)} bpm',
                                      style: bodyStyle(context).copyWith(
                                        fontFeatures: tabularFigures,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      size: 18, color: colors.muted),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          if (_paper != null && _robust != null && _selected != null) ...<Widget>[
            const SizedBox(height: Gap.lg),
            _ResultBlock(
              trueRate: _selected!.fusedBpm,
              paper: _paper!,
              robust: _robust!,
              stored: _selected,
            ),
          ],
          const Rule(),
          Section(
            title: 'Three · against a second instrument',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'The only check that says anything about accuracy. It needs '
                  'a pulse oximeter or a blood pressure monitor and a still '
                  'person, and it cannot be automated here.',
                  style: bodyStyle(context),
                ),
                const SizedBox(height: Gap.md),
                Text(
                  'Take a cuff reading and an app reading within a minute of '
                  'each other, sat down, arm supported. Do it five times a '
                  'day on three days. Compare the differences, not the '
                  'individual pairs. The protocol in docs/validation.md has '
                  'the exact steps and the arithmetic for the mean difference '
                  'and its spread.',
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

class _ResultBlock extends StatelessWidget {
  const _ResultBlock({
    required this.trueRate,
    required this.paper,
    required this.robust,
    this.stored,
  });

  final double trueRate;
  final Measurement paper;
  final Measurement robust;
  final Session? stored;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final paperError = paper.fusedHeartRate - trueRate;
    final robustError = robust.fusedHeartRate - trueRate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            stored == null
                ? 'Generated at ${trueRate.toStringAsFixed(0)} bpm'
                : 'Stored reading ${stored!.fusedBpm.toStringAsFixed(0)} bpm',
            style: labelStyle(context),
          ),
          const SizedBox(height: Gap.md),
          StatRow(
            label: 'Paper path',
            value: paper.fusedHeartRate.toStringAsFixed(1),
            unit: 'bpm',
          ),
          StatRow(
            label: 'Paper error',
            value:
                '${paperError >= 0 ? '+' : ''}${paperError.toStringAsFixed(1)}',
            unit: 'bpm',
            color: paperError.abs() > 3 ? colors.warn : null,
          ),
          StatRow(
            label: 'Robust path',
            value: robust.fusedHeartRate.toStringAsFixed(1),
            unit: 'bpm',
          ),
          StatRow(
            label: 'Robust error',
            value:
                '${robustError >= 0 ? '+' : ''}${robustError.toStringAsFixed(1)}',
            unit: 'bpm',
            color: robustError.abs() > 3 ? colors.warn : null,
          ),
          StatRow(
            label: 'Peak bin',
            value: '${paper.redPeak.bin} / N ${paper.redPeak.fftLength}',
          ),
          const SizedBox(height: Gap.sm),
          Text(
            'One bin is worth '
            '${(paper.fps * 60 / paper.redPeak.fftLength).toStringAsFixed(2)} '
            'bpm at this frame rate, so an error smaller than that is the '
            'grid, not the method.',
            style: bodyStyle(context, color: colors.muted),
          ),
        ],
      ),
    );
  }
}

