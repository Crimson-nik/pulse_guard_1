import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ppg_core/ppg_core.dart';

import '../data/database.dart';
import '../data/session_codec.dart';
import '../design/page_scaffold.dart';
import '../design/tokens.dart';
import '../state/app_scope.dart';
import 'journal_screen.dart';
import 'measure_screen.dart';
import 'session_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final colors = context.colors;
    final today = DateFormat('EEEE d MMMM').format(DateTime.now());

    return PageScaffold(
      eyebrow: 'PPG Lab',
      title: 'Today',
      subtitle: today,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListenableBuilder(
            listenable: scope.profile,
            builder: (context, _) {
              final error = scope.profile.value.validationError;
              if (error == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: Gap.lg),
                child: Container(
                  padding: const EdgeInsets.all(Gap.lg),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.warn),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$error Blood pressure will not be shown until this is '
                    'fixed in Settings.',
                    style: bodyStyle(context),
                  ),
                ),
              );
            },
          ),
          StreamBuilder<List<Session>>(
            stream: scope.database.watchSessions(),
            builder: (context, snapshot) {
              final sessions = snapshot.data ?? const <Session>[];
              final latest = sessions.isEmpty ? null : sessions.first;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _LatestReading(session: latest),
                  const SizedBox(height: Gap.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const MeasureScreen(),
                        ),
                      ),
                      child: const Text('Take a reading'),
                    ),
                  ),
                  if (sessions.length > 1) ...<Widget>[
                    const Rule(),
                    Section(
                      title: 'Recent',
                      note: '${sessions.length} total',
                      child: Column(
                        children: <Widget>[
                          for (final session in sessions.take(3))
                            _RecentRow(session: session),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const Rule(),
          Text(
            'Method: FFT peak of the red and green frame averages, after '
            'Sharma et al., Computers and Electrical Engineering 101 (2022) '
            '108057. Reproduced for study. This app is not a medical device '
            'and its blood pressure is a model estimate, not a measurement.',
            style: bodyStyle(context, color: colors.muted),
          ),
        ],
      ),
    );
  }
}

class _LatestReading extends StatelessWidget {
  const _LatestReading({required this.session});

  final Session? session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = session;
    if (s == null) {
      return EmptyState(
        title: 'No readings yet',
        body: 'A capture takes thirty seconds. Sit down, rest for a minute, '
            'then cover the rear camera and flash with the pad of your index '
            'finger.',
        action: OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const JournalScreen()),
          ),
          child: const Text('Open the journal'),
        ),
      );
    }
    final quality = s.qualityBand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              s.fusedBpm.toStringAsFixed(0),
              style: readingStyle(context),
            ),
            const SizedBox(width: Gap.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'bpm',
                style: bodyStyle(context, color: colors.muted),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Tag(
                text: switch (quality) {
                  QualityBand.good => 'usable',
                  QualityBand.fair => 'fair',
                  QualityBand.poor => 'unusable',
                },
                color: quality == QualityBand.poor
                    ? colors.artery
                    : colors.slate,
              ),
            ),
          ],
        ),
        const SizedBox(height: Gap.sm),
        Text(
          '${DateFormat('d MMM, HH:mm').format(s.startedAt)}  ·  '
          '${s.hasBloodPressure ? '${s.systolic!.round()}/${s.diastolic!.round()} mmHg model estimate' : 'no blood pressure'}',
          style: bodyStyle(context, color: colors.muted),
        ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SessionScreen(sessionId: session.id),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.md),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 64,
              child: Text(
                DateFormat('HH:mm').format(session.startedAt),
                style: bodyStyle(context, color: colors.muted)
                    .copyWith(fontFeatures: tabularFigures),
              ),
            ),
            Expanded(
              child: Text(
                '${session.fusedBpm.toStringAsFixed(0)} bpm',
                style: bodyStyle(context).copyWith(
                  fontFeatures: tabularFigures,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              session.bloodPressureText,
              style: bodyStyle(context, color: colors.muted)
                  .copyWith(fontFeatures: tabularFigures),
            ),
            const SizedBox(width: Gap.sm),
            Icon(Icons.chevron_right, size: 18, color: colors.muted),
          ],
        ),
      ),
    );
  }
}
