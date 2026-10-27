import 'package:flutter/material.dart';

import 'tokens.dart';

/// Light is the default. The capture happens in a dark room, but every screen
/// that shows a result is read afterwards in normal light, and a dark
/// instrument panel as the out of the box state would be a style choice
/// rather than a response to the room.
ThemeData buildTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark ? PpgColors.dark : PpgColors.light;
  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    // Roboto is the Android system face; naming it explicitly keeps every
    // style, including button styles set through styleFrom, on the same
    // font instead of falling back to whatever the platform defaults to.
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.artery,
      brightness: brightness,
    ).copyWith(
      surface: colors.paper,
      onSurface: colors.ink,
      primary: colors.artery,
      onPrimary: brightness == Brightness.dark
          ? const Color(0xFF1B1010)
          : Colors.white,
      outline: colors.hairline,
      error: colors.artery,
    ),
    scaffoldBackgroundColor: colors.paper,
  );

  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[colors],
    textTheme: base.textTheme.apply(
      bodyColor: colors.ink,
      displayColor: colors.ink,
    ),
    dividerTheme: DividerThemeData(
      color: colors.hairline,
      thickness: 1,
      space: 1,
    ),
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.paper,
      foregroundColor: colors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.ink,
        foregroundColor: colors.paper,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.ink,
        minimumSize: const Size(0, 52),
        side: BorderSide(color: colors.hairline),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.slate,
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Gap.md,
        vertical: Gap.lg,
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: colors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: colors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: colors.slate, width: 2),
      ),
      labelStyle: TextStyle(color: colors.muted, fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.ink,
      contentTextStyle: TextStyle(color: colors.paper, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
  );
}
