import 'package:flutter/material.dart';
import 'package:ppg_core/ppg_core.dart';

import '../data/database.dart';
import '../data/user_profile.dart';

/// App wide handles: the database, the profile, and the display preference.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.database,
    required this.profile,
    required this.themeMode,
    required this.onThemeModeChanged,
    required super.child,
  });

  final AppDatabase database;
  final ProfileController profile;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      oldWidget.database != database || oldWidget.themeMode != themeMode;
}

/// Holds the user's body parameters and preferences, and writes them back.
class ProfileController extends ChangeNotifier {
  ProfileController(this._database, this._value);

  final AppDatabase _database;
  UserProfile _value;

  UserProfile get value => _value;

  AnalysisMode get mode => _value.mode;

  Future<void> update(UserProfile next) async {
    _value = next;
    notifyListeners();
    await _database.saveProfile(next.toRow());
  }

  Future<void> reload() async {
    final row = await _database.loadProfile();
    _value = UserProfile.fromRow(row);
    notifyListeners();
  }
}
