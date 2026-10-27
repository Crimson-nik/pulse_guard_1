import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// The live pulse trace and the stored signal view.
///
/// Hand drawn on purpose. A charting package would bring its own visual
/// language, and this needs to look like a pen recording, not a dashboard.
class PulseTrace extends StatelessWidget {
  const PulseTrace({
    super.key,
    required this.values,
    this.height = 120,
    this.color,
    this.baseline = true,
    this.semanticLabel,
  });

  final List<double> values;
  final double height;
  final Color? color;
  final bool baseline;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: semanticLabel ?? 'Pulse trace, ${values.length} samples',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _TracePainter(
            values: values,
            color: color ?? colors.artery,
            hairline: colors.hairline,
            baseline: baseline,
          ),
        ),
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({
    required this.values,
    required this.color,
    required this.hairline,
    required this.baseline,
  });

  final List<double> values;
  final Color color;
  final Color hairline;
  final bool baseline;

  @override
  void paint(Canvas canvas, Size size) {
    if (baseline) {
      final rule = Paint()
        ..color = hairline
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        rule,
      );
    }
    if (values.length < 2) return;

    var lo = values.first;
    var hi = values.first;
    for (final v in values) {
      lo = math.min(lo, v);
      hi = math.max(hi, v);
    }
    final span = (hi - lo).abs() < 1e-9 ? 1.0 : hi - lo;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final normalised = (values[i] - lo) / span;
      final y = size.height - (normalised * (size.height - 8) + 4);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TracePainter old) =>
      old.values != values || old.color != color;
}

/// A single line across a series, with the top and bottom of the scale
/// printed in a left gutter.
///
/// The labels sit outside the plot on the axis they describe. Putting the
/// minimum at the right-hand end instead would put a number next to the newest
/// reading, where it reads as that reading's value.
class TrendLine extends StatelessWidget {
  const TrendLine({
    super.key,
    required this.points,
    this.height = 72,
    this.color,
    required this.unit,
    this.name = 'Reading',
  });

  final List<double> points;
  final double height;
  final Color? color;

  /// Names the scale for the screen-reader summary. The unit is printed by the
  /// caller in the section header, next to the title it belongs to.
  final String unit;

  /// Used for the screen-reader summary, not drawn.
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (points.length < 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.md),
        child: Text(
          'Two readings are needed before a trend means anything.',
          style: bodyStyle(context, color: colors.muted),
        ),
      );
    }
    final lo = points.reduce(math.min);
    final hi = points.reduce(math.max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 34,
                height: height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(hi.toStringAsFixed(0),
                        style: labelStyle(context, color: colors.ink)
                            .copyWith(fontFeatures: tabularFigures)),
                    Text(lo.toStringAsFixed(0),
                        style: labelStyle(context, color: colors.muted)
                            .copyWith(fontFeatures: tabularFigures)),
                  ],
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: PulseTrace(
                  values: points,
                  height: height,
                  color: color ?? colors.slate,
                  baseline: false,
                  semanticLabel:
                      '$name from ${lo.toStringAsFixed(0)} to ${hi.toStringAsFixed(0)} $unit',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
