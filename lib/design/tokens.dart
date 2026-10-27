import 'package:flutter/material.dart';

/// Design tokens. One place for colour, spacing, radius and type, so a screen
/// never invents its own value.
///
/// The palette is a warm paper ground with near black ink and a single
/// arterial red reserved for the measurement itself and for things that are
/// wrong. Contrast ratios against the paper ground: ink 18.0:1, muted 6.3:1,
/// artery 7.4:1, slate 9.1:1. All clear WCAG AA for body text; three clear
/// AAA.
class PpgColors extends ThemeExtension<PpgColors> {
  const PpgColors({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.hairline,
    required this.artery,
    required this.slate,
    required this.warn,
  });

  final Color paper;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color hairline;
  final Color artery;
  final Color slate;
  final Color warn;

  static const light = PpgColors(
    paper: Color(0xFFFBFAF8),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF14110F),
    muted: Color(0xFF625C56),
    hairline: Color(0xFFE4DFD9),
    artery: Color(0xFFA11D21),
    slate: Color(0xFF2C4A52),
    warn: Color(0xFF8A5A00),
  );

  static const dark = PpgColors(
    paper: Color(0xFF121110),
    surface: Color(0xFF1B1918),
    ink: Color(0xFFF4F1ED),
    muted: Color(0xFFA9A29B),
    hairline: Color(0xFF2E2B29),
    artery: Color(0xFFE9787B),
    slate: Color(0xFF9CBFCA),
    warn: Color(0xFFD8A24A),
  );

  @override
  PpgColors copyWith({
    Color? paper,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? hairline,
    Color? artery,
    Color? slate,
    Color? warn,
  }) {
    return PpgColors(
      paper: paper ?? this.paper,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      hairline: hairline ?? this.hairline,
      artery: artery ?? this.artery,
      slate: slate ?? this.slate,
      warn: warn ?? this.warn,
    );
  }

  @override
  PpgColors lerp(ThemeExtension<PpgColors>? other, double t) {
    if (other is! PpgColors) return this;
    return PpgColors(
      paper: Color.lerp(paper, other.paper, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      artery: Color.lerp(artery, other.artery, t)!,
      slate: Color.lerp(slate, other.slate, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
    );
  }
}

/// Spacing scale. Every gap in the app is one of these.
class Gap {
  const Gap._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 48;
}

/// Tabular figures make a changing number hold its width, which matters when
/// a reading updates in place.
const List<FontFeature> tabularFigures = <FontFeature>[
  FontFeature.tabularFigures(),
];

TextStyle readingStyle(BuildContext context, {Color? color}) {
  final c = context.colors;
  return TextStyle(
    fontSize: 64,
    height: 1.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.5,
    color: color ?? c.artery,
    fontFeatures: tabularFigures,
  );
}

TextStyle secondaryReadingStyle(BuildContext context) {
  final c = context.colors;
  return TextStyle(
    fontSize: 34,
    height: 1.1,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    color: c.ink,
    fontFeatures: tabularFigures,
  );
}

TextStyle sectionTitleStyle(BuildContext context) {
  return TextStyle(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: context.colors.ink,
  );
}

TextStyle labelStyle(BuildContext context, {Color? color}) {
  return TextStyle(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
    color: color ?? context.colors.muted,
  );
}

TextStyle bodyStyle(BuildContext context, {Color? color}) {
  return TextStyle(
    fontSize: 15,
    height: 1.55,
    color: color ?? context.colors.ink,
  );
}

extension PpgContext on BuildContext {
  PpgColors get colors => Theme.of(this).extension<PpgColors>()!;

  TextStyle get labelText => labelStyle(this);
  TextStyle get bodyText => bodyStyle(this);
  TextStyle get sectionTitle => sectionTitleStyle(this);
}
