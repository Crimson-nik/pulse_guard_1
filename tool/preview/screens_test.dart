// Renders each screen to a PNG for the documentation.
//
// Not part of the app and not part of `flutter test` (it lives outside
// test/). Run it from the repository root with:
//
//   flutter test tool/preview/screens_test.dart --update-goldens
//
// Real Roboto and Material Icons are loaded first, otherwise the text renders
// as placeholder boxes.

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ppg_core/ppg_core.dart';
import 'package:ppg_lab/data/database.dart';
import 'package:ppg_lab/data/session_codec.dart';
import 'package:ppg_lab/data/user_profile.dart';
import 'package:ppg_lab/design/theme.dart';
import 'package:ppg_lab/state/app_scope.dart';
import 'package:ppg_lab/ui/explain_screen.dart';
import 'package:ppg_lab/ui/home_screen.dart';
import 'package:ppg_lab/ui/journal_screen.dart';
import 'package:ppg_lab/ui/measure_screen.dart';
import 'package:ppg_lab/ui/result_screen.dart';
import 'package:ppg_lab/ui/session_screen.dart';
import 'package:ppg_lab/ui/settings_screen.dart';
import 'package:ppg_lab/ui/trends_screen.dart';
import 'package:ppg_lab/ui/validation_screen.dart';

/// Relative to the repository root, which is the working directory of a
/// `flutter test` run started from there.
const _fontDir = '.toolchain/flutter/bin/cache/artifacts/material_fonts';

/// Roboto Mono is a project asset rather than part of the toolchain.
const _assetFontDir = 'assets/fonts';

Future<void> _loadFont(String family, List<String> files,
    {String dir = _fontDir}) async {
  final loader = FontLoader(family);
  var loaded = 0;
  for (final file in files) {
    final path = '$dir/$file';
    if (!File(path).existsSync()) continue;
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
    loaded++;
  }
  await loader.load();
  if (loaded == 0) {
    throw StateError('No font files found under $dir. Run from the '
        'repository root so the toolchain path resolves.');
  }
}

void main() {
  late AppDatabase database;
  late ProfileController profile;
  var newestSession = 0;

  setUpAll(() async {
    await _loadFont('Roboto', <String>[
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
    ]);
    await _loadFont('MaterialIcons', <String>['MaterialIcons-Regular.otf']);
    await _loadFont(
      'RobotoMono',
      <String>['RobotoMono-Regular.ttf', 'RobotoMono-Medium.ttf'],
      dir: _assetFontDir,
    );
  });

  Future<void> seed() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    profile = ProfileController(database, const UserProfile());
    const codec = SessionCodec();
    final now = DateTime.now();
    const rates = <double>[62, 72, 88];
    for (var i = 0; i < rates.length; i++) {
      final capture = synthesiseCapture(heartRate: rates[i], seed: 5 + i);
      final measurement = analyseCapture(
        red: capture.red,
        green: capture.green,
        timestampsMs: capture.timestampsMs,
        mode: AnalysisMode.paper,
        ageYears: 25,
        weightKg: 70,
        heightCm: 175,
      );
      newestSession = await database.insertSession(
        codec.toRow(
          measurement: measurement,
          red: capture.red,
          green: capture.green,
          timestamps: capture.timestampsMs,
          startedAt: now.subtract(Duration(hours: 3 - i)),
          ageYears: 25,
          weightKg: 70,
          heightCm: 175,
        ),
      );
    }
  }

  Widget harness(Widget child) {
    return AppScope(
      database: database,
      profile: profile,
      themeMode: ThemeMode.light,
      onThemeModeChanged: (_) {},
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        home: child,
      ),
    );
  }

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Widget Function() screen,
  ) async {
    await seed();
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness(screen()));
    // Three pumps: one for the first frame, one for the drift stream to
    // deliver, one to settle layout after the data arrives.
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/$name.png'),
    );

    // Tear the tree down, let the query store's flush timer fire, then close
    // the database. Skipping the pump leaves a pending timer and the test
    // binding fails the run.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await database.close().timeout(
          const Duration(seconds: 5),
          onTimeout: () => stderr.writeln('warning: database close timed out'),
        );
  }

  testWidgets('today', (tester) async {
    await shoot(tester, 'home', () => const HomeScreen());
  });

  testWidgets('journal', (tester) async {
    await shoot(tester, 'journal', () => const JournalScreen());
  });

  testWidgets('result', (tester) async {
    await shoot(tester, 'result', () => ResultScreen(sessionId: newestSession));
  });

  testWidgets('explain', (tester) async {
    await shoot(
        tester, 'explain', () => ExplainScreen(sessionId: newestSession));
  });

  testWidgets('session', (tester) async {
    await shoot(
        tester, 'session', () => SessionScreen(sessionId: newestSession));
  });

  testWidgets('trends', (tester) async {
    await shoot(tester, 'trends', () => const TrendsScreen());
  });

  testWidgets('measure', (tester) async {
    await shoot(tester, 'measure', () => const MeasureScreen());
  });

  testWidgets('validation', (tester) async {
    await shoot(tester, 'validation', () => const ValidationScreen());
  });

  testWidgets('settings', (tester) async {
    await shoot(tester, 'settings', () => const SettingsScreen());
  });
}
