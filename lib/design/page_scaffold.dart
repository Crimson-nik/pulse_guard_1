import 'package:flutter/material.dart';

import 'tokens.dart';

/// The one page frame every screen uses: a small eyebrow label, a title, an
/// optional line of context, a hairline, then content.
///
/// No app bar, no elevated surfaces. This is meant to read like a printed
/// report rather than a dashboard.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.onBack,
    this.actions = const <Widget>[],
    this.bottom,
    required this.child,
    this.scrollable = true,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget? bottom;
  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.lg, Gap.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (onBack != null)
                Padding(
                  padding: const EdgeInsets.only(right: Gap.sm),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back, size: 22),
                      tooltip: 'Back',
                      color: colors.ink,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              if (eyebrow != null)
                Expanded(
                  child: Text(
                    eyebrow!.toUpperCase(),
                    style: labelStyle(context, color: colors.muted),
                  ),
                )
              else
                const Spacer(),
              ...actions,
            ],
          ),
          const SizedBox(height: Gap.sm),
          Text(title, style: sectionTitleStyle(context).copyWith(fontSize: 30)),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: Gap.sm),
            Text(
              subtitle!,
              style: bodyStyle(context, color: colors.muted),
            ),
          ],
          const SizedBox(height: Gap.lg),
          Container(height: 1, color: colors.hairline),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: colors.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            header,
            Expanded(
              child: scrollable
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(
                        Gap.xl,
                        Gap.xl,
                        Gap.xl,
                        Gap.huge,
                      ),
                      children: <Widget>[child],
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Gap.xl,
                        Gap.xl,
                        Gap.xl,
                        0,
                      ),
                      child: child,
                    ),
            ),
            ?bottom,
          ],
        ),
      ),
    );
  }
}

/// A titled block with an optional trailing note.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    this.note,
    required this.child,
  });

  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(title.toUpperCase(), style: labelStyle(context)),
            const Spacer(),
            if (note case final String text)
              Text(
                text,
                style: labelStyle(context, color: colors.muted),
              ),
          ],
        ),
        const SizedBox(height: Gap.md),
        child,
      ],
    );
  }
}

class Rule extends StatelessWidget {
  const Rule({super.key, this.inset = 0});
  final double inset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Gap.lg, horizontal: inset),
      child: Container(height: 1, color: context.colors.hairline),
    );
  }
}

/// Label on the left, value on the right, hairline between rows.
class StatRow extends StatelessWidget {
  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.emphasis = false,
    this.color,
  });

  final String label;
  final String value;
  final String? unit;
  final bool emphasis;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: bodyStyle(context, color: colors.muted),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasis ? 22 : 16,
              fontWeight: emphasis ? FontWeight.w600 : FontWeight.w500,
              color: color ?? colors.ink,
              fontFeatures: tabularFigures,
            ),
          ),
          if (unit != null) ...<Widget>[
            const SizedBox(width: Gap.xs),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                unit!,
                style: labelStyle(context, color: colors.muted)
                    .copyWith(letterSpacing: 0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A small rectangular tag. Words carry the meaning; colour only reinforces.
class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.text,
    this.color,
    this.filled = false,
  });

  final String text;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = color ?? colors.slate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? tint.withValues(alpha: 0.12) : Colors.transparent,
        border: Border.all(color: tint.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text.toUpperCase(),
        style: labelStyle(context, color: tint).copyWith(fontSize: 10.5),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });

  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: bodyStyle(context).copyWith(
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: Gap.sm),
          Text(body, style: bodyStyle(context, color: colors.muted)),
          if (action != null) ...<Widget>[
            const SizedBox(height: Gap.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
