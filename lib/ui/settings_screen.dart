import 'package:flutter/material.dart';
import 'package:ppg_core/ppg_core.dart';

import '../design/page_scaffold.dart';
import '../design/tokens.dart';
import '../state/app_scope.dart';

/// Body parameters, method default, appearance and data.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _age;
  late TextEditingController _weight;
  late TextEditingController _height;
  String? _error;
  String? _saved;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    final profile = AppScope.of(context).profile.value;
    _age = TextEditingController(text: '${profile.ageYears}');
    _weight = TextEditingController(text: profile.weightKg.toStringAsFixed(0));
    _height = TextEditingController(text: profile.heightCm.toStringAsFixed(0));
    _initialised = true;
  }

  @override
  void dispose() {
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final scope = AppScope.of(context);
    final age = int.tryParse(_age.text.trim());
    final weight = double.tryParse(_weight.text.trim());
    final height = double.tryParse(_height.text.trim());
    if (age == null || weight == null || height == null) {
      setState(() {
        _error = 'Age, weight and height all need a number.';
        _saved = null;
      });
      return;
    }
    final error = validateProfile(
      ageYears: age,
      weightKg: weight,
      heightCm: height,
    );
    if (error != null) {
      setState(() {
        _error = error;
        _saved = null;
      });
      return;
    }
    await scope.profile.update(
      scope.profile.value.copyWith(
        ageYears: age,
        weightKg: weight,
        heightCm: height,
      ),
    );
    if (!mounted) return;
    setState(() {
      _error = null;
      _saved = 'Saved. New readings use these values.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final colors = context.colors;

    return ListenableBuilder(
      listenable: scope.profile,
      builder: (context, _) {
        final profile = scope.profile.value;
        return PageScaffold(
          eyebrow: 'Settings',
          title: 'Profile and method',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Section(
                title: 'Body parameters',
                note: 'Eqs. (3) to (8)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'The paper takes age, weight and height from the user '
                      'and uses them in the pressure chain. Enter real values: '
                      'every pressure estimate depends on them.',
                      style: bodyStyle(context, color: colors.muted),
                    ),
                    const SizedBox(height: Gap.lg),
                    TextField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age, years',
                      ),
                    ),
                    const SizedBox(height: Gap.md),
                    TextField(
                      controller: _weight,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Weight, kg',
                      ),
                    ),
                    const SizedBox(height: Gap.md),
                    TextField(
                      controller: _height,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Height, cm',
                      ),
                    ),
                    if (_error != null) ...<Widget>[
                      const SizedBox(height: Gap.md),
                      Text(
                        _error!,
                        style: bodyStyle(context, color: colors.artery),
                      ),
                    ],
                    if (_saved != null) ...<Widget>[
                      const SizedBox(height: Gap.md),
                      Text(
                        _saved!,
                        style: bodyStyle(context, color: colors.muted),
                      ),
                    ],
                    const SizedBox(height: Gap.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Save profile'),
                      ),
                    ),
                  ],
                ),
              ),
              const Rule(),
              Section(
                title: 'Default method',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ModeOption(
                      title: 'Paper path',
                      selected: profile.mode == AnalysisMode.paper,
                      description:
                          'Exactly what the paper describes: raw frame '
                          'averages, one transform per channel, ceil to the '
                          'nearest whole beat. This is the default because '
                          'the app is a reproduction.',
                      onTap: () => scope.profile.update(
                        profile.copyWith(mode: AnalysisMode.paper),
                      ),
                    ),
                    const SizedBox(height: Gap.md),
                    _ModeOption(
                      title: 'Robust path',
                      selected: profile.mode == AnalysisMode.robust,
                      description:
                          'Adds what the paper leaves out: drop the first 1.5 '
                          'seconds, remove drift, window before the transform '
                          'and fit the peak instead of rounding up. Readings '
                          'are tagged as robust wherever they appear.',
                      onTap: () => scope.profile.update(
                        profile.copyWith(mode: AnalysisMode.robust),
                      ),
                    ),
                  ],
                ),
              ),
              const Rule(),
              Section(
                title: 'Cross check',
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: profile.showSlidingCrossCheck,
                  activeThumbColor: colors.artery,
                  title: Text('Show the rejected counter', style: bodyStyle(context)),
                  subtitle: Text(
                    'Displays the sliding average answer next to the transform '
                    'answer. The paper\'s central finding is that it fails.',
                    style: bodyStyle(context, color: colors.muted),
                  ),
                  onChanged: (v) => scope.profile.update(
                    profile.copyWith(showSlidingCrossCheck: v),
                  ),
                ),
              ),
              const Rule(),
              Section(
                title: 'Appearance',
                child: Column(
                  children: <Widget>[
                    for (final entry in const <ThemeMode, String>{
                      ThemeMode.system: 'Follow the system',
                      ThemeMode.light: 'Light',
                      ThemeMode.dark: 'Dark',
                    }.entries)
                      InkWell(
                        onTap: () => scope.onThemeModeChanged(entry.key),
                        child: SizedBox(
                          height: 48,
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 24,
                                child: scope.themeMode == entry.key
                                    ? Icon(Icons.check,
                                        size: 16, color: colors.artery)
                                    : null,
                              ),
                              Text(entry.value, style: bodyStyle(context)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Rule(),
              Section(
                title: 'Data',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Readings are stored only on this device. There is no '
                      'account, no sync and no network permission in the app.',
                      style: bodyStyle(context, color: colors.muted),
                    ),
                    const SizedBox(height: Gap.lg),
                    OutlinedButton(
                      onPressed: () => _confirmDeleteAll(context, scope),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.artery,
                        side: BorderSide(color: colors.artery),
                      ),
                      child: const Text('Delete all readings'),
                    ),
                  ],
                ),
              ),
              const Rule(),
              Section(
                title: 'About',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'PPG Lab is a reproduction of Sharma et al., "Heart rate '
                      'and blood pressure measurement based on '
                      'photoplethysmogram signal using fast Fourier transform", '
                      'Computers and Electrical Engineering 101 (2022) 108057.',
                      style: bodyStyle(context),
                    ),
                    const SizedBox(height: Gap.md),
                    Text(
                      'Not a medical device. The heart rate is an estimate from '
                      'thirty seconds of camera frames. The blood pressure is a '
                      'model output computed from that estimate and from the '
                      'profile above, and it has not been validated against a '
                      'cuff. Do not use either number to make a health decision.',
                      style: bodyStyle(context, color: colors.muted),
                    ),
                    const SizedBox(height: Gap.md),
                    Text(
                      'Build 1.0.0 · Android 15 and above · no network access',
                      style: labelStyle(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context, AppScope scope) async {
    final sessions = await scope.database.watchSessions().first;
    final count = sessions.length;
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: const Text('Delete every reading?'),
        content: Text(
          '$count reading(s) will be removed from this device, including '
          'their stored signals. This cannot be undone.',
          style: bodyStyle(context),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await scope.database.deleteAllSessions();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All readings deleted.')),
      );
    }
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? colors.artery : colors.hairline,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (selected)
                  Padding(
                    padding: const EdgeInsets.only(right: Gap.sm),
                    child: Icon(Icons.check, size: 16, color: colors.artery),
                  ),
                Text(
                  title,
                  style: bodyStyle(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.xs),
            Text(description, style: bodyStyle(context, color: colors.muted)),
          ],
        ),
      ),
    );
  }
}
