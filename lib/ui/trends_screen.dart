import 'package:flutter/material.dart';
import 'package:ppg_core/ppg_core.dart';

import '../data/database.dart';
import '../data/session_codec.dart';
import '../design/page_scaffold.dart';
import '../design/pulse_trace.dart';
import '../design/tokens.dart';
import '../state/app_scope.dart';

/// Heart rate and the two pressures across recorded sessions.
///
/// Only sessions that passed the quality gate are plotted. Plotting an
/// unusable capture next to a clean one would make the line mean nothing.
class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final colors = context.colors;

    return StreamBuilder<List<Session>>(
      stream: scope.database.watchSessions(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <Session>[];
        final usable = all
            .where((s) => s.qualityBand != QualityBand.poor)
            .toList()
            .reversed
            .toList();

        if (usable.length < 2) {
          return PageScaffold(
            eyebrow: 'Trends',
            title: 'Over time',
            subtitle: 'At least two usable readings are needed.',
            child: EmptyState(
              title: 'Not enough readings',
              body: all.isEmpty
                  ? 'Take a few readings first. Trends only appear once there '
                      'is something to compare.'
                  : 'You have ${all.length} reading(s) but fewer than two '
                      'passed the quality gate, so a trend would be noise.',
            ),
          );
        }

        final hr = usable.map((s) => s.fusedBpm).toList();
        final sbp = usable
            .where((s) => s.systolic != null)
            .map((s) => s.systolic!)
            .toList();
        final dbp = usable
            .where((s) => s.diastolic != null)
            .map((s) => s.diastolic!)
            .toList();

        return PageScaffold(
          eyebrow: 'Trends',
          title: 'Over time',
          subtitle:
              '${usable.length} usable readings, oldest to newest. '
              '${all.length - usable.length} excluded by the quality gate.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Section(
                title: 'Heart rate',
                note: 'bpm',
                child: TrendLine(
                  points: hr,
                  unit: 'bpm',
                  color: colors.artery,
                  name: 'Heart rate',
                ),
              ),
              const Rule(),
              Section(
                title: 'Systolic',
                note: 'mmHg, model estimate',
                child: TrendLine(
                  points: sbp,
                  unit: 'mmHg',
                  color: colors.slate,
                  name: 'Systolic estimate',
                ),
              ),
              const SizedBox(height: Gap.lg),
              Section(
                title: 'Diastolic',
                note: 'mmHg, model estimate',
                child: TrendLine(
                  points: dbp,
                  unit: 'mmHg',
                  color: colors.slate,
                  name: 'Diastolic estimate',
                ),
              ),
              const Rule(),
              Section(
                title: 'Summary',
                child: Column(
                  children: <Widget>[
                    StatRow(
                      label: 'Readings plotted',
                      value: '${usable.length}',
                    ),
                    StatRow(
                      label: 'Heart rate, mean',
                      value: _mean(hr).toStringAsFixed(1),
                      unit: 'bpm',
                    ),
                    StatRow(
                      label: 'Heart rate, range',
                      value:
                          '${hr.reduce((a, b) => a < b ? a : b).toStringAsFixed(0)} to ${hr.reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}',
                      unit: 'bpm',
                    ),
                    if (sbp.isNotEmpty)
                      StatRow(
                        label: 'Systolic, mean',
                        value: _mean(sbp).toStringAsFixed(1),
                        unit: 'mmHg',
                      ),
                  ],
                ),
              ),
              const Rule(),
              Text(
                'Blood pressure here is computed from heart rate, age, weight '
                'and height by the paper\'s equations. If the heart rate '
                'trends one way, the pressure trends the other, because that '
                'is what the model does. It is not a measurement of your '
                'arteries.',
                style: bodyStyle(context, color: colors.muted),
              ),
            ],
          ),
        );
      },
    );
  }

  static double _mean(List<double> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
}
