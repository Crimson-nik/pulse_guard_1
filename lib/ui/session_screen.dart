import 'package:flutter/material.dart';
import 'package:ppg_core/ppg_core.dart';

import '../data/database.dart';
import '../data/session_codec.dart';
import '../design/format.dart';
import '../design/page_scaffold.dart';
import '../design/pulse_trace.dart';
import '../design/tokens.dart';
import '../state/app_scope.dart';

/// One stored session, including its raw signal and a re-run through both
/// pipelines. This is the screen that makes a stored reading auditable.
class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  static const _codec = SessionCodec();

  bool _showSignal = false;
  Measurement? _paperRun;
  Measurement? _robustRun;

  void _replay(Session session) {
    setState(() {
      _paperRun = _codec.replay(session, AnalysisMode.paper);
      _robustRun = _codec.replay(session, AnalysisMode.robust);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return StreamBuilder<Session?>(
      stream: scope.database.watchSession(widget.sessionId),
      builder: (context, snapshot) {
        final session = snapshot.data;
        if (session == null) {
          return PageScaffold(
            title: 'Session',
            onBack: () => Navigator.of(context).pop(),
            child: const SizedBox.shrink(),
          );
        }
        return _body(context, session, scope);
      },
    );
  }

  Widget _body(BuildContext context, Session session, AppScope scope) {
    final colors = context.colors;
    final red = _codec.decodeChannel(session.redSamples);
    final green = _codec.decodeChannel(session.greenSamples);

    return PageScaffold(
      eyebrow: 'Session',
      title: '${session.fusedBpm.toStringAsFixed(0)} bpm',
      subtitle: DateFormatLine.format(session.startedAt),
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Tag(
                text: session.mode == 'robust' ? 'robust mode' : 'paper mode',
                color: colors.slate,
              ),
              const SizedBox(width: Gap.sm),
              Tag(
                text: switch (session.qualityBand) {
                  QualityBand.good => 'usable',
                  QualityBand.fair => 'fair',
                  QualityBand.poor => 'unusable',
                },
                color: session.qualityBand == QualityBand.poor
                    ? colors.artery
                    : colors.slate,
              ),
            ],
          ),
          const Rule(),
          Section(
            title: 'Reading',
            child: Column(
              children: <Widget>[
                StatRow(label: 'Heart rate', value: session.fusedBpm.toStringAsFixed(1), unit: 'bpm', emphasis: true),
                StatRow(label: 'Red channel', value: '${session.redBpm}', unit: 'bpm'),
                StatRow(label: 'Green channel', value: '${session.greenBpm}', unit: 'bpm'),
                StatRow(label: 'Sliding average', value: '${session.slidingBpm}', unit: 'bpm'),
                StatRow(
                  label: 'Blood pressure',
                  value: session.bloodPressureText,
                  unit: session.hasBloodPressure ? 'mmHg' : null,
                  emphasis: true,
                ),
              ],
            ),
          ),
          const Rule(),
          Section(
            title: 'Capture',
            child: Column(
              children: <Widget>[
                StatRow(label: 'Frames', value: '${session.frames}'),
                StatRow(label: 'Duration', value: (session.durationMs / 1000).toStringAsFixed(1), unit: 's'),
                StatRow(label: 'Measured frame rate', value: session.fps.toStringAsFixed(2), unit: 'fps'),
                StatRow(label: 'Pulse strength', value: session.perfusionIndex.toStringAsFixed(2), unit: '%'),
                StatRow(label: 'Clipped', value: (session.clippedFraction * 100).toStringAsFixed(2), unit: '%'),
                StatRow(label: 'Frame jitter', value: (session.fpsJitter * 100).toStringAsFixed(1), unit: '%'),
                StatRow(label: 'Profile', value: '${session.ageYears} y · ${session.weightKg.toStringAsFixed(0)} kg · ${session.heightCm.toStringAsFixed(0)} cm'),
              ],
            ),
          ),
          const Rule(),
          Section(
            title: 'Stored signal',
            note: '${red.length} samples',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_showSignal) ...<Widget>[
                  PulseTrace(values: red, height: 120, semanticLabel: 'Stored red channel'),
                  const SizedBox(height: Gap.md),
                  PulseTrace(values: green, height: 80, color: colors.slate, semanticLabel: 'Stored green channel'),
                ] else
                  Text(
                    'The raw per frame averages were saved with this reading. '
                    'They are what makes a re-run possible.',
                    style: bodyStyle(context, color: colors.muted),
                  ),
                const SizedBox(height: Gap.md),
                TextButton(
                  onPressed: () => setState(() => _showSignal = !_showSignal),
                  child: Text(_showSignal ? 'Hide signal' : 'Show signal'),
                ),
              ],
            ),
          ),
          const Rule(),
          Section(
            title: 'Re-run both pipelines',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'The stored arrays are analysed again, once with the paper '
                  'path and once with the robust path.',
                  style: bodyStyle(context),
                ),
                const SizedBox(height: Gap.md),
                if (_paperRun != null && _robustRun != null)
                  _Comparison(paper: _paperRun!, robust: _robustRun!)
                else
                  OutlinedButton(
                    onPressed: () => _replay(session),
                    child: const Text('Re-run now'),
                  ),
              ],
            ),
          ),
          const Rule(),
          Section(
            title: 'Danger zone',
            child: OutlinedButton(
              onPressed: () => _confirmDelete(context, scope, session.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.artery,
                side: BorderSide(color: colors.artery),
              ),
              child: const Text('Delete this reading'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppScope scope,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: const Text('Delete this reading?'),
        content: Text(
          'The reading and its raw signal are removed from this device. This '
          'cannot be undone.',
          style: bodyStyle(context),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await scope.database.deleteSession(id);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.paper, required this.robust});

  final Measurement paper;
  final Measurement robust;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget cell(String text, {bool head = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: Gap.sm, horizontal: Gap.sm),
          child: Text(
            text,
            style: head
                ? labelStyle(context)
                : bodyStyle(context).copyWith(fontFeatures: tabularFigures),
            textAlign: head ? TextAlign.left : TextAlign.right,
          ),
        );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(flex: 2, child: cell('', head: true)),
              Expanded(child: cell('PAPER', head: true)),
              Expanded(child: cell('ROBUST', head: true)),
            ],
          ),
          Container(height: 1, color: colors.hairline),
          _row(context, 'Heart rate', cell,
              paper.fusedHeartRate.toStringAsFixed(1),
              robust.fusedHeartRate.toStringAsFixed(1)),
          _row(context, 'Red', cell, '${paper.redBpm}', '${robust.redBpm}'),
          _row(context, 'Green', cell, '${paper.greenBpm}', '${robust.greenBpm}'),
          _row(context, 'Peak bin', cell, '${paper.redPeak.bin}', '${robust.redPeak.bin}'),
          _row(context, 'Difference', cell,
              '${(paper.fusedHeartRate - robust.fusedHeartRate).abs().toStringAsFixed(1)} bpm', ''),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    Widget Function(String, {bool head}) cell,
    String a,
    String b,
  ) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.sm, horizontal: Gap.sm),
            child: Text(label, style: bodyStyle(context, color: context.colors.muted)),
          ),
        ),
        Expanded(child: cell(a)),
        Expanded(child: cell(b)),
      ],
    );
  }
}
