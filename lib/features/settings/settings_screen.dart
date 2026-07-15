import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:renvoy/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/app_colors.dart';
import '../../core/haptics.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/currency_picker_sheet.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_bar_fade.dart';
import '../../data/backup/backup_service.dart';
import '../../data/db/database_provider.dart';
import '../../data/db/settings_keys.dart';
import '../../data/notifications/reminder_scheduler.dart';
import '../home/home_providers.dart';

final _settingsValueProvider = StreamProvider.family<String?, String>((
  ref,
  key,
) {
  return ref.watch(settingsDaoProvider).watchValue(key);
});

final _packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final packageInfo = ref.watch(_packageInfoProvider).valueOrNull;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.viewPaddingOf(context).top + 24,
                    20,
                    0,
                  ),
                  child: Text(
                    l10n.navSettings,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              _Section(
                label: l10n.settingsGeneral,
                children: [
                  _SettingRow(
                    label: l10n.settingsCurrency,
                    value:
                        ref.watch(defaultCurrencyProvider).valueOrNull ?? 'USD',
                    onPressed: () => _pickCurrency(context, ref),
                  ),
                  _SettingRow(
                    label: l10n.settingsLanguage,
                    value: _languageLabel(
                      l10n,
                      ref
                              .watch(
                                _settingsValueProvider(
                                  SettingsKeys.localeOverride,
                                ),
                              )
                              .valueOrNull ??
                          'system',
                    ),
                    onPressed: () => _pickLanguage(context, ref),
                  ),
                  _SettingRow(
                    label: l10n.settingsTheme,
                    value: _themeLabel(
                      l10n,
                      ref
                              .watch(
                                _settingsValueProvider(SettingsKeys.themeMode),
                              )
                              .valueOrNull ??
                          'system',
                    ),
                    onPressed: () => _pickTheme(context, ref),
                  ),
                  _SettingRow(
                    label: l10n.settingsFirstDay,
                    value: _firstDayLabel(
                      l10n,
                      ref
                              .watch(
                                _settingsValueProvider(
                                  SettingsKeys.firstDayOfWeek,
                                ),
                              )
                              .valueOrNull ??
                          '1',
                    ),
                    onPressed: () => _pickFirstDay(context, ref),
                  ),
                ],
              ),
              _Section(
                label: l10n.settingsReminders,
                children: [
                  _SettingRow(
                    label: l10n.settingsDefaultReminders,
                    value: _reminderSummary(
                      l10n,
                      _parseReminderDays(
                        ref
                            .watch(
                              _settingsValueProvider(
                                SettingsKeys.defaultReminderDays,
                              ),
                            )
                            .valueOrNull,
                      ),
                    ),
                    onPressed: () => _pickDefaultReminders(context, ref),
                  ),
                ],
              ),
              _Section(
                label: l10n.settingsData,
                children: [
                  _SettingRow(
                    label: l10n.settingsExportBackup,
                    value: 'JSON',
                    onPressed: () => _exportBackup(context, ref),
                  ),
                  _SettingRow(
                    label: l10n.settingsImportBackup,
                    value: '',
                    onPressed: () => _importBackup(context, ref),
                  ),
                  _SettingRow(
                    label: l10n.settingsExportCsv,
                    value: 'CSV',
                    onPressed: () => _exportCsv(context, ref),
                  ),
                ],
              ),
              _Section(
                label: l10n.settingsAbout,
                children: [
                  _SettingRow(
                    label: l10n.settingsVersion,
                    value: packageInfo == null
                        ? ''
                        : '${packageInfo.version} (${packageInfo.buildNumber})',
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          const StatusBarFade(),
        ],
      ),
    );
  }

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref) async {
    final selected = ref.read(defaultCurrencyProvider).valueOrNull ?? 'USD';
    final picked = await showCurrencyPickerSheet(
      context: context,
      selected: selected,
    );
    if (picked == null) {
      return;
    }
    await ref
        .read(settingsDaoProvider)
        .setValue(SettingsKeys.defaultCurrency, picked);
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final selected =
        ref
            .read(_settingsValueProvider(SettingsKeys.localeOverride))
            .valueOrNull ??
        'system';
    final picked = await _showRadioSheet<String>(
      context: context,
      title: l10n.settingsLanguage,
      selected: selected,
      options: [
        _Option('system', l10n.settingsSystem),
        _Option('en', l10n.settingsEnglish),
        _Option('es', l10n.settingsSpanish),
        _Option('pt', l10n.settingsPortugueseBrazil),
      ],
    );
    if (picked != null) {
      await ref
          .read(settingsDaoProvider)
          .setValue(SettingsKeys.localeOverride, picked);
      await ref.read(reminderSchedulerProvider).resync();
    }
  }

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final selected =
        ref.read(_settingsValueProvider(SettingsKeys.themeMode)).valueOrNull ??
        'system';
    final picked = await _showRadioSheet<String>(
      context: context,
      title: l10n.settingsTheme,
      selected: selected,
      options: [
        _Option('system', l10n.settingsSystem),
        _Option('light', l10n.settingsLight),
        _Option('dark', l10n.settingsDark),
      ],
    );
    if (picked != null) {
      await ref
          .read(settingsDaoProvider)
          .setValue(SettingsKeys.themeMode, picked);
    }
  }

  Future<void> _pickFirstDay(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final selected =
        ref
            .read(_settingsValueProvider(SettingsKeys.firstDayOfWeek))
            .valueOrNull ??
        '1';
    final picked = await _showRadioSheet<String>(
      context: context,
      title: l10n.settingsFirstDay,
      selected: selected,
      options: [
        _Option('1', l10n.settingsMonday),
        _Option('7', l10n.settingsSunday),
      ],
    );
    if (picked != null) {
      await ref
          .read(settingsDaoProvider)
          .setValue(SettingsKeys.firstDayOfWeek, picked);
    }
  }

  Future<void> _pickDefaultReminders(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = _parseReminderDays(
      ref
          .read(_settingsValueProvider(SettingsKeys.defaultReminderDays))
          .valueOrNull,
    );
    final picked = await showAppSheet<Set<int>>(
      context: context,
      title: l10n.settingsDefaultReminders,
      child: _ReminderPicker(selectedDays: selected),
    );
    if (picked == null) {
      return;
    }
    final days = picked.toList()..sort();
    await ref
        .read(settingsDaoProvider)
        .setValue(SettingsKeys.defaultReminderDays, days.join(','));
    await ref.read(reminderRulesDaoProvider).replaceGlobal(days);
    await ref.read(reminderSchedulerProvider).resync(l10n: l10n);
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final json = await ref.read(backupServiceProvider).exportJson();
      final file = await _writeTempFile('renvoy-backup.json', json);
      await SharePlus.instance.share(
        ShareParams(
          title: l10n.settingsExportBackup,
          files: [XFile(file.path, mimeType: 'application/json')],
        ),
      );
      await Haptics.success();
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, l10n.exportError);
      }
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      final path = picked?.files.single.path;
      if (path == null) {
        return;
      }
      final source = await File(path).readAsString();
      final service = ref.read(backupServiceProvider);
      final preview = await service.previewImport(source);
      if (!context.mounted) {
        return;
      }
      final confirmed = await showConfirmDialog(
        context: context,
        title: l10n.settingsImportBackup,
        message: l10n.importConfirm(preview.subscriptions, preview.groups),
        confirmLabel: l10n.settingsImportBackup,
        cancelLabel: l10n.keep,
      );
      if (!confirmed) {
        return;
      }
      await service.importJson(source);
      await ref.read(reminderSchedulerProvider).resync(l10n: l10n);
      if (context.mounted) {
        _showSnack(context, l10n.importSuccess);
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, l10n.importError);
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final csv = await ref
          .read(backupServiceProvider)
          .exportSubscriptionsCsv();
      final file = await _writeTempFile('renvoy-subscriptions.csv', csv);
      await SharePlus.instance.share(
        ShareParams(
          title: l10n.settingsExportCsv,
          files: [XFile(file.path, mimeType: 'text/csv')],
        ),
      );
      await Haptics.success();
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, l10n.exportError);
      }
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  children[index],
                  if (index != children.length - 1)
                    Container(height: 1, color: colors.border),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value, this.onPressed});

  final String label;
  final String value;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
            ),
          ),
          if (value.isNotEmpty)
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
            ),
          if (onPressed != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 16, color: colors.textMuted),
          ],
        ],
      ),
    );

    if (onPressed == null) {
      return content;
    }
    return Pressable(
      onPressed: onPressed,
      haptic: HapticType.light,
      child: content,
    );
  }
}

class _Option<T> {
  const _Option(this.value, this.label);

  final T value;
  final String label;
}

Future<T?> _showRadioSheet<T>({
  required BuildContext context,
  required String title,
  required T selected,
  required List<_Option<T>> options,
}) {
  return showAppSheet<T>(
    context: context,
    title: title,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        for (final option in options)
          _RadioRow<T>(
            option: option,
            selected: selected,
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(option.value),
          ),
      ],
    ),
  );
}

class _RadioRow<T> extends StatelessWidget {
  const _RadioRow({
    required this.option,
    required this.selected,
    required this.onPressed,
  });

  final _Option<T> option;
  final T selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSelected = option.value == selected;
    return Pressable(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected ? colors.accent : colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderPicker extends StatefulWidget {
  const _ReminderPicker({required this.selectedDays});

  final Set<int> selectedDays;

  @override
  State<_ReminderPicker> createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<_ReminderPicker> {
  late final Set<int> _selectedDays = {...widget.selectedDays};

  static const _options = [0, 1, 3, 7, 14];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final days in _options)
              _ChoiceChip(
                label: days == 0
                    ? l10n.reminderSameDay
                    : l10n.reminderDaysBefore(days),
                selected: _selectedDays.contains(days),
                onPressed: () {
                  Haptics.selection();
                  setState(() {
                    if (_selectedDays.contains(days)) {
                      _selectedDays.remove(days);
                    } else {
                      _selectedDays.add(days);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: l10n.save,
          onPressed: () => Navigator.of(context).pop(_selectedDays),
        ),
        SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.accentSoft : colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? colors.accent : colors.border),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? colors.accent : colors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

String _languageLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'en' => l10n.settingsEnglish,
    'es' => l10n.settingsSpanish,
    'pt' => l10n.settingsPortugueseBrazil,
    _ => l10n.settingsSystem,
  };
}

String _themeLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'light' => l10n.settingsLight,
    'dark' => l10n.settingsDark,
    _ => l10n.settingsSystem,
  };
}

String _firstDayLabel(AppLocalizations l10n, String value) {
  return value == '7' ? l10n.settingsSunday : l10n.settingsMonday;
}

String _reminderSummary(AppLocalizations l10n, Set<int> days) {
  if (days.isEmpty) {
    return l10n.reminderNoRules;
  }
  return l10n.reminderRuleCount(days.length);
}

Set<int> _parseReminderDays(String? value) {
  return (value ?? '3,0')
      .split(',')
      .map((part) => int.tryParse(part.trim()))
      .whereType<int>()
      .toSet();
}

Future<File> _writeTempFile(String name, String contents) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$name');
  return file.writeAsString(contents);
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
