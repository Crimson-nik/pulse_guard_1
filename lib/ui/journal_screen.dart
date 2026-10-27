import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ppg_core/ppg_core.dart';

import '../data/database.dart';
import '../data/session_codec.dart';
import '../design/page_scaffold.dart';
import '../design/tokens.dart';
import '../state/app_scope.dart';
import 'session_screen.dart';

/// Every capture, newest first.
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final colors = context.colors;

    return StreamBuilder<List<Session>>(
      stream: scope.database.watchSessions(),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? const <Session>[];
        return PageScaffold(
          eyebrow: 'Journal',
          title: 'Readings',
          subtitle: sessions.isEmpty
              ? 'Nothing recorded yet.'
              : '${sessions.length} recorded, newest first.',
          child: sessions.isEmpty
              ? EmptyState(
                  title: 'No captures yet',
                  body: 'Take a reading from the Today tab. Each one is kept '
                      'with its own raw signal, so it can be re-analysed '
                      'later.',
                  action: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Today'),
                  ),
                )
              : Column(
                  children: <Widget>[
                    for (var i = 0; i < sessions.length; i++) ...<Widget>[
                      if (i == 0 ||
                          !_sameDay(
                              sessions[i - 1].startedAt, sessions[i].startedAt))
                        Padding(
                          padding: EdgeInsets.only(
                            top: i == 0 ? 0 : Gap.xl,
                            bottom: Gap.sm,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              DateFormat('EEEE d MMMM').format(
                                sessions[i].startedAt,
                              ).toUpperCase(),
                              style: labelStyle(context),
                            ),
                          ),
                        ),
                      _JournalRow(session: sessions[i]),
                      if (i < sessions.length - 1)
                        Container(height: 1, color: colors.hairline),
                    ],
                  ],
                ),
        );
      },
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _JournalRow extends StatelessWidget {
  const _JournalRow({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final band = session.qualityBand;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SessionScreen(sessionId: session.id),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 56,
              child: Text(
                DateFormat('HH:mm').format(session.startedAt),
                style: bodyStyle(context, color: colors.muted)
                    .copyWith(fontFeatures: tabularFigures),
              ),
            ),
            const SizedBox(width: Gap.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        session.fusedBpm.toStringAsFixed(0),
                        style: bodyStyle(context).copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                      const SizedBox(width: Gap.xs),
                      Text('bpm',
                          style: bodyStyle(context, color: colors.muted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.hasBloodPressure
                        ? '${session.systolic!.round()}/${session.diastolic!.round()} mmHg model estimate'
                        : 'no blood pressure',
                    style: bodyStyle(context, color: colors.muted)
                        .copyWith(fontFeatures: tabularFigures),
                  ),
                ],
              ),
            ),
            if (band != QualityBand.good)
              Tag(
                text: band == QualityBand.poor ? 'unusable' : 'fair',
                color: band == QualityBand.poor ? colors.artery : colors.slate,
              ),
            const SizedBox(width: Gap.sm),
            Icon(Icons.chevron_right, size: 18, color: colors.muted),
          ],
        ),
      ),
    );
  }
}
