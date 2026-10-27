import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/user_profile.dart';
import 'design/theme.dart';
import 'state/app_scope.dart';
import 'ui/shell.dart';

/// Root of the app. Owns the database, the profile and the display
/// preference, and nothing else. Every screen below reads from AppScope.
class PpgLabApp extends StatefulWidget {
  const PpgLabApp({super.key, required this.database});

  final AppDatabase database;

  @override
  State<PpgLabApp> createState() => _PpgLabAppState();
}

class _PpgLabAppState extends State<PpgLabApp> {
  ProfileController? _profile;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final row = await widget.database.loadProfile();
    final storedTheme = await widget.database.readSetting('themeMode');
    if (!mounted) return;
    setState(() {
      _profile = ProfileController(widget.database, UserProfile.fromRow(row));
      _themeMode = switch (storedTheme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    });
  }

  Future<void> _setTheme(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await widget.database.writeSetting('themeMode', mode.name);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    if (profile == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        home: const Scaffold(body: SizedBox.shrink()),
      );
    }
    return AppScope(
      database: widget.database,
      profile: profile,
      themeMode: _themeMode,
      onThemeModeChanged: _setTheme,
      child: MaterialApp(
        title: 'PPG Lab',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: _themeMode,
        home: const ShellScreen(),
      ),
    );
  }
}
