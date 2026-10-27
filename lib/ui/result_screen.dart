import 'package:flutter/material.dart';
import 'package:ppg_core/ppg_core.dart';

import '../data/database.dart';
import '../data/session_codec.dart';
import '../design/format.dart';
import '../design/page_scaffold.dart';
import '../design/tokens.dart';
import '../state/app_scope.dart';
import 'explain_screen.dart';

/// The reading, the trust verdict, and the evidence behind it.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.sessionId});

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
            title: 'Reading',
            onBack: null,
            child: SizedBox.shrink(),
          );
        }
        return _Body(session: session);
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final band = session.qualityBand;
    final bp = session.hasBloodPressure;
    final gap = (session.redBpm - session.greenBpm).abs();
    final advice = switch (band) {
      QualityBand.good => 'The capture looks usable.',
      QualityBand.fair =>
        'The capture is usable but not clean. A retake would be better.',
      QualityBand.poor =>
        'This capture does not meet the quality gate. Treat the number as '
            'unreliable and retake it.',
    };

    return PageScaffold(
      eyebrow: 'Reading',
      title: 'Heart rate',
      subtitle: DateFormatLine.format(session.startedAt),
      scrollable: true,
      bottom: _BottomBar(sessionId: session.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                session.fusedBpm.toStringAsFixed(0),
                style: readingStyle(context),
              ),
              const SizedBox(width: Gap.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('bpm',
                    style: bodyStyle(context, color: colors.muted)),
              ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          Row(
            children: <Widget>[
              Tag(
                text: session.mode == 'robust' ? 'robust mode' : 'paper mode',
                color: colors.slate,
              ),
              const SizedBox(width: Gap.sm),
              Tag(
                text: switch (band) {
                  QualityBand.good => 'usable',
                  QualityBand.fair => 'fair',
                  QualityBand.poor => 'unusable',
                },
                color: band == QualityBand.poor ? colors.artery : colors.slate,
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(advice, style: bodyStyle(context)),
          const Rule(),
          Section(
            title: 'Blood pressure',
            note: 'model estimate',
            child: bp
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${session.systolic!.round()}/${session.diastolic!.round()}',
                        style: secondaryReadingStyle(context),
                      ),
                      const SizedBox(height: Gap.xs),
                      Text('mmHg, systolic over diastolic',
                          style: bodyStyle(context, color: colors.muted)),
                      const SizedBox(height: Gap.md),
                      Text(
                        'Computed from the heart rate above with Eqs. (3) to '
                        '(8) of the paper. Nothing here was compared with a '
                        'cuff, so this is a model output, not a measurement.',
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
            title: 'Evidence',
            child: Column(
              children: <Widget>[
                StatRow(
                  label: 'Red channel',
                  value: '${session.redBpm}',
                  unit: 'bpm',
                ),
                StatRow(
                  label: 'Green channel',
                  value: '${session.greenBpm}',
                  unit: 'bpm',
                ),
                StatRow(
                  label: 'Channel disagreement',
                  value: gap.toString(),
                  unit: 'bpm',
                  color: gap >= 4 ? colors.warn : null,
                ),
                StatRow(
                  label: 'Frames',
                  value: '${session.frames}',
                ),
                StatRow(
                  label: 'Measured frame rate',
                  value: session.fps.toStringAsFixed(1),
                  unit: 'fps',
                ),
                StatRow(
                  label: 'Pulse strength',
                  value: session.perfusionIndex.toStringAsFixed(1),
                  unit: '%',
                ),
                StatRow(
                  label: 'Clipped pixels',
                  value: (session.clippedFraction * 100).toStringAsFixed(1),
                  unit: '%',
                  color: session.clippedFraction > 0.15 ? colors.warn : null,
                ),
                if (session.note.isNotEmpty)
                  StatRow(label: 'Note', value: session.note),
              ],
            ),
          ),
          const Rule(),
          Section(
            title: 'The method the paper rejected',
            note: 'sliding average',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${session.slidingBpm} bpm from ${session.peakCount} peaks '
                  'counted in ${session.frames} frames.',
                  style: bodyStyle(context),
                ),
                const SizedBox(height: Gap.sm),
                Text(
                  gap >= 4
                      ? 'The two methods disagree by a lot, which usually '
                          'means the capture is not clean.'
                      : 'Shown because the paper\'s most useful finding is '
                          'that this counter fails: it counts the second bump '
                          'of each pulse as a separate heartbeat.',
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.paper,
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.md, Gap.xl, Gap.md),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExplainScreen(sessionId: sessionId),
                    ),
                  ),
                  child: const Text('Explain'),
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

