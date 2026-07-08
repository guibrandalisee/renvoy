import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renvoy/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/color_utils.dart';
import '../../../core/formatters.dart';
import '../../../core/haptics.dart';
import '../../../core/widgets/app_progress.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/currency_picker_sheet.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/db/database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/settings_keys.dart';
import '../../../domain/billing/billing_math.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/group_node.dart';
import '../../home/home_providers.dart';
import 'subscription_form_controller.dart';

final _subscriptionProvider = StreamProvider.family<Subscription?, String>((
  ref,
  id,
) {
  return ref.watch(subscriptionsDaoProvider).watchById(id);
});

class SubscriptionFormScreen extends ConsumerStatefulWidget {
  const SubscriptionFormScreen({this.subscriptionId, super.key});

  final String? subscriptionId;

  @override
  ConsumerState<SubscriptionFormScreen> createState() =>
      _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends ConsumerState<SubscriptionFormScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _customCountController = TextEditingController(text: '1');
  final _paymentController = TextEditingController();
  final _notesController = TextEditingController();
  final _urlController = TextEditingController();

  var _currency = 'USD';
  var _priceMinor = 0;
  var _cycle = _CycleChoice.monthly;
  var _customUnit = CycleUnit.month;
  var _firstBillDate = dateOnlyUtc(DateTime.now());
  DateTime? _trialEndDate;
  String? _groupId;
  bool _useDefaultReminders = true;
  Set<int> _reminderDays = const {0, 3};
  bool _dirty = false;
  bool _saving = false;
  String? _loadedId;
  String? _remindersLoadedFor;

  bool get _isEdit => widget.subscriptionId != null;

  bool get _valid =>
      _nameController.text.trim().isNotEmpty && _priceMinor > 0 && !_saving;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nameController,
      _priceController,
      _customCountController,
      _paymentController,
      _notesController,
      _urlController,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _customCountController.dispose();
    _paymentController.dispose();
    _notesController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
      return;
    }
    setState(() {});
  }

  void _loadFromSubscription(Subscription subscription) {
    if (_loadedId == subscription.id) {
      return;
    }
    _loadedId = subscription.id;
    _nameController.text = subscription.name;
    _priceMinor = subscription.priceMinor;
    _priceController.text = _formatPriceInput(subscription.priceMinor);
    _currency = subscription.currency;
    _cycle = _cycleChoiceFor(subscription.cycleUnit, subscription.cycleCount);
    _customUnit = subscription.cycleUnit;
    _customCountController.text = subscription.cycleCount.toString();
    _firstBillDate = _parseDate(subscription.firstBillDate);
    _trialEndDate = subscription.trialEndDate == null
        ? null
        : _parseDate(subscription.trialEndDate!);
    _groupId = subscription.groupId;
    _paymentController.text = subscription.paymentMethod ?? '';
    _notesController.text = subscription.notes ?? '';
    _urlController.text = subscription.manageUrl ?? '';
    _dirty = false;
    _loadReminderState(subscription.id);
  }

  Future<void> _loadReminderState(String subscriptionId) async {
    if (_remindersLoadedFor == subscriptionId) {
      return;
    }
    _remindersLoadedFor = subscriptionId;
    final settingsDao = ref.read(settingsDaoProvider);
    final mode = await settingsDao.getValue(
      SettingsKeys.subscriptionReminderMode(subscriptionId),
    );
    final rules = await ref
        .read(reminderRulesDaoProvider)
        .watchForSubscription(subscriptionId)
        .first;
    if (!mounted || _loadedId != subscriptionId) {
      return;
    }
    setState(() {
      _useDefaultReminders = mode != 'custom';
      _reminderDays = rules.map((rule) => rule.daysBefore).toSet();
      _dirty = false;
    });
  }

  Future<void> _close() async {
    if (_dirty) {
      final discard = await _confirmDiscard();
      if (!discard || !mounted) {
        return;
      }
    }
    context.pop();
  }

  Future<bool> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context)!;
    return await showAdaptiveDialog<bool>(
          context: context,
          builder: (context) => AlertDialog.adaptive(
            title: Text(l10n.discardChangesTitle),
            content: Text(l10n.discardChangesMessage),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.keepEditing),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.danger,
                  foregroundColor: context.colors.onAccent,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.discard),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _save(Subscription? original) async {
    if (!_valid) {
      return;
    }
    setState(() => _saving = true);
    final customCount = int.tryParse(_customCountController.text) ?? 1;
    final draft = SubscriptionDraft(
      name: _nameController.text,
      priceMinor: _priceMinor,
      currency: _currency,
      cycleUnit: _cycle.unit(_customUnit),
      cycleCount: _cycle.count(customCount),
      firstBillDate: _firstBillDate,
      trialEndDate: _trialEndDate,
      groupId: _groupId,
      paymentMethod: _paymentController.text,
      notes: _notesController.text,
      manageUrl: _urlController.text,
      useDefaultReminders: _useDefaultReminders,
      reminderDays: _reminderDays.toList()..sort((a, b) => b.compareTo(a)),
    );
    await ref
        .read(subscriptionFormControllerProvider)
        .save(draft, original: original);
    await Haptics.success();
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = widget.subscriptionId == null
        ? const AsyncValue<Subscription?>.data(null)
        : ref.watch(_subscriptionProvider(widget.subscriptionId!));
    final defaultCurrency =
        ref.watch(defaultCurrencyProvider).valueOrNull ?? 'USD';
    if (!_isEdit && _loadedId == null && _currency == 'USD') {
      _currency = defaultCurrency;
    }

    return subscriptionAsync.when(
      loading: () => const Scaffold(body: Center(child: AppProgress())),
      error: (_, _) => const Scaffold(body: Center(child: AppProgress())),
      data: (subscription) {
        if (subscription != null) {
          _loadFromSubscription(subscription);
        }
        return _buildForm(subscription);
      },
    );
  }

  Widget _buildForm(Subscription? subscription) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final groups = ref.watch(groupsTreeProvider).valueOrNull ?? const [];
    final selectedGroup = _findGroup(groups, _groupId);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.viewPaddingOf(context).top + 12,
                  20,
                  0,
                ),
                child: Row(
                  children: [
                    Pressable(
                      onPressed: _close,
                      borderRadius: BorderRadius.circular(999),
                      child: _CircleButton(icon: Icons.close),
                    ),
                    Expanded(
                      child: Text(
                        _isEdit ? l10n.editSubscription : l10n.newSubscription,
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40, height: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    MediaQuery.viewInsetsOf(context).bottom + 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LabeledField(
                        label: l10n.name,
                        child: TextFormField(
                          controller: _nameController,
                          autofocus: !_isEdit,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(l10n.nameHint),
                        ),
                      ),
                      _Gap(),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _LabeledField(
                              label: l10n.price,
                              child: TextFormField(
                                controller: _priceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9,.]'),
                                  ),
                                ],
                                decoration: _inputDecoration('0.00'),
                                onChanged: (value) {
                                  setState(() {
                                    _priceMinor = _parseMinorUnits(value);
                                    _dirty = true;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LabeledField(
                              label: l10n.currency,
                              child: _InputPressable(
                                onPressed: _pickCurrency,
                                child: Row(
                                  children: [
                                    Expanded(child: Text(_currency)),
                                    Icon(
                                      Icons.expand_more,
                                      size: 18,
                                      color: colors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _Gap(),
                      _FieldLabel(l10n.billingCycle),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _CycleChoice.values
                            .map(
                              (choice) => _ChoiceChip(
                                label: choice.label(l10n),
                                selected: _cycle == choice,
                                onPressed: () {
                                  Haptics.selection();
                                  setState(() {
                                    _cycle = choice;
                                    _dirty = true;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: _cycle == _CycleChoice.custom
                            ? Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    Text(
                                      l10n.every,
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 64,
                                      child: TextField(
                                        controller: _customCountController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: _inputDecoration('1'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _InputPressable(
                                        onPressed: _pickCycleUnit,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _cycleUnitLabel(_customUnit),
                                              ),
                                            ),
                                            Icon(
                                              Icons.expand_more,
                                              size: 18,
                                              color: colors.textMuted,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      _Gap(),
                      _LabeledField(
                        label: l10n.firstBillDate,
                        child: _DateField(
                          date: _firstBillDate,
                          onPressed: () async {
                            final picked = await _pickDate(_firstBillDate);
                            if (picked != null) {
                              setState(() {
                                _firstBillDate = picked;
                                _dirty = true;
                              });
                            }
                          },
                        ),
                      ),
                      _Gap(),
                      _FreeTrialSwitch(
                        value: _trialEndDate != null,
                        onChanged: (value) {
                          Haptics.selection();
                          setState(() {
                            _trialEndDate = value
                                ? dateOnlyUtc(
                                    DateTime.now().add(const Duration(days: 7)),
                                  )
                                : null;
                            _dirty = true;
                          });
                        },
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: _trialEndDate == null
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _LabeledField(
                                  label: l10n.trialEnds,
                                  child: _DateField(
                                    date: _trialEndDate!,
                                    onPressed: () async {
                                      final picked = await _pickDate(
                                        _trialEndDate!,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _trialEndDate = picked;
                                          _dirty = true;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                      ),
                      _Gap(),
                      _LabeledField(
                        label: l10n.group,
                        child: _InputPressable(
                          onPressed: () => _pickGroup(groups),
                          child: selectedGroup == null
                              ? Text(
                                  l10n.none,
                                  style: TextStyle(color: colors.textMuted),
                                )
                              : _GroupChip(group: selectedGroup),
                        ),
                      ),
                      _Gap(),
                      _LabeledField(
                        label: l10n.reminders,
                        child: _InputPressable(
                          onPressed: _pickReminders,
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 18,
                                color: colors.textMuted,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _reminderSummary(l10n),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.expand_more,
                                size: 18,
                                color: colors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                      _Gap(),
                      _LabeledField(
                        label: l10n.paymentMethod,
                        child: TextFormField(
                          controller: _paymentController,
                          decoration: _inputDecoration(l10n.paymentMethodHint),
                        ),
                      ),
                      _Gap(),
                      _LabeledField(
                        label: l10n.notes,
                        child: TextFormField(
                          controller: _notesController,
                          minLines: 3,
                          maxLines: 3,
                          decoration: _inputDecoration(''),
                        ),
                      ),
                      _Gap(),
                      _LabeledField(
                        label: l10n.url,
                        child: TextFormField(
                          controller: _urlController,
                          keyboardType: TextInputType.url,
                          decoration: _inputDecoration(l10n.urlHint),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                color: colors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Opacity(
                  opacity: _valid ? 1 : 0.5,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _valid ? () => _save(subscription) : null,
                      child: Text(l10n.save),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final colors = context.colors;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colors.surface,
      hintStyle: TextStyle(color: colors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.accent),
      ),
    );
  }

  Future<void> _pickCurrency() async {
    final picked = await showCurrencyPickerSheet(
      context: context,
      selected: _currency,
    );
    if (picked != null) {
      setState(() {
        _currency = picked;
        _dirty = true;
      });
    }
  }

  Future<void> _pickCycleUnit() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showAppSheet<CycleUnit>(
      context: context,
      title: l10n.billingCycle,
      child: _OptionList<CycleUnit>(
        options: const [CycleUnit.day, CycleUnit.week, CycleUnit.month],
        selected: _customUnit,
        label: _cycleUnitLabel,
      ),
    );
    if (picked != null) {
      setState(() {
        _customUnit = picked;
        _dirty = true;
      });
    }
  }

  Future<void> _pickGroup(List<GroupNode> groups) async {
    const noneValue = '__none__';
    final picked = await showAppSheet<String>(
      context: context,
      title: AppLocalizations.of(context)!.group,
      child: _GroupPicker(
        groups: groups,
        selectedId: _groupId,
        noneValue: noneValue,
      ),
    );
    if (picked == null) {
      return;
    }
    final nextGroupId = picked == noneValue ? null : picked;
    if (nextGroupId != _groupId) {
      setState(() {
        _groupId = nextGroupId;
        _dirty = true;
      });
    }
  }

  Future<void> _pickReminders() async {
    final picked = await showAppSheet<_ReminderSelection>(
      context: context,
      title: AppLocalizations.of(context)!.reminders,
      child: _ReminderPicker(
        useDefaults: _useDefaultReminders,
        selectedDays: _reminderDays,
      ),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _useDefaultReminders = picked.useDefaults;
      _reminderDays = picked.daysBefore;
      _dirty = true;
    });
  }

  Future<DateTime?> _pickDate(DateTime initial) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Haptics.light();
    if (!mounted) {
      return null;
    }
    if (Platform.isIOS) {
      var selected = initial;
      return showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (context) => Container(
          height: 300,
          color: context.colors.surfaceElevated,
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Pressable(
                    onPressed: () => Navigator.of(context).pop(selected),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  String _cycleUnitLabel(CycleUnit unit) {
    final l10n = AppLocalizations.of(context)!;
    return switch (unit) {
      CycleUnit.day => l10n.days,
      CycleUnit.week => l10n.weeks,
      CycleUnit.month => l10n.months,
      CycleUnit.year => l10n.years,
    };
  }

  String _reminderSummary(AppLocalizations l10n) {
    if (_useDefaultReminders) {
      return l10n.reminderDefault;
    }
    final count = _reminderDays.length;
    if (count == 0) {
      return l10n.reminderNoRules;
    }
    return l10n.reminderRuleCount(count);
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_FieldLabel(label), const SizedBox(height: 6), child],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
    );
  }
}

class _Gap extends SizedBox {
  const _Gap() : super(height: 12);
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: colors.textPrimary),
    );
  }
}

class _InputPressable extends StatelessWidget {
  const _InputPressable({required this.child, required this.onPressed});

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.centerLeft,
        child: DefaultTextStyle(
          style:
              Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary) ??
              TextStyle(color: colors.textPrimary),
          child: child,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onPressed});

  final DateTime date;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return _InputPressable(
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 18, color: colors.textMuted),
          const SizedBox(width: 10),
          Text(Dates.short(date, l10n.localeName)),
        ],
      ),
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

class _FreeTrialSwitch extends StatelessWidget {
  const _FreeTrialSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.freeTrial,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
          ),
        ),
        Pressable(
          onPressed: () => onChanged(!value),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 28,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value ? colors.accent : colors.surfaceElevated,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: value ? colors.accent : colors.border,
                width: 1,
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: colors.onAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderSelection {
  const _ReminderSelection({
    required this.useDefaults,
    required this.daysBefore,
  });

  final bool useDefaults;
  final Set<int> daysBefore;
}

class _ReminderPicker extends StatefulWidget {
  const _ReminderPicker({
    required this.useDefaults,
    required this.selectedDays,
  });

  final bool useDefaults;
  final Set<int> selectedDays;

  @override
  State<_ReminderPicker> createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<_ReminderPicker> {
  late bool _useDefaults = widget.useDefaults;
  late final Set<int> _selectedDays = {...widget.selectedDays};

  static const _options = [0, 1, 3, 7, 14];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _ToggleRow(
          label: l10n.reminderUseDefaults,
          value: _useDefaults,
          onChanged: (value) {
            Haptics.selection();
            setState(() => _useDefaults = value);
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _useDefaults
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final days in _options)
                        _ChoiceChip(
                          label: _reminderOptionLabel(l10n, days),
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
                ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(
              _ReminderSelection(
                useDefaults: _useDefaults,
                daysBefore: _selectedDays,
              ),
            ),
            child: Text(l10n.save),
          ),
        ),
        SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
          ),
        ),
        Pressable(
          onPressed: () => onChanged(!value),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 28,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value ? colors.accent : colors.surfaceElevated,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: value ? colors.accent : colors.border,
                width: 1,
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: colors.onAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _reminderOptionLabel(AppLocalizations l10n, int daysBefore) {
  return daysBefore == 0
      ? l10n.reminderSameDay
      : l10n.reminderDaysBefore(daysBefore);
}

class _OptionList<T> extends StatelessWidget {
  const _OptionList({
    required this.options,
    required this.selected,
    required this.label,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) label;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        for (final option in options)
          _SheetRow(
            label: label(option),
            selected: option == selected,
            onPressed: () => Navigator.of(context).pop(option),
          ),
      ],
    );
  }
}

class _GroupPicker extends StatelessWidget {
  const _GroupPicker({
    required this.groups,
    required this.selectedId,
    required this.noneValue,
  });

  final List<GroupNode> groups;
  final String? selectedId;
  final String noneValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _SheetRow(
          label: l10n.none,
          selected: selectedId == null,
          onPressed: () => Navigator.of(context).pop(noneValue),
        ),
        for (final node in groups) ...[
          _GroupRow(node: node, selectedId: selectedId, depth: 0),
          for (final child in node.children)
            _GroupRow(node: child, selectedId: selectedId, depth: 1),
        ],
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.node,
    required this.selectedId,
    required this.depth,
  });

  final GroupNode node;
  final String? selectedId;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final group = node.group;
    final groupColor = colorFromHex(group.color) ?? colors.accent;
    return Pressable(
      onPressed: () => Navigator.of(context).pop(group.id),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16 + (depth * 24), 10, 0, 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: groupColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.folder_outlined, size: 16, color: groupColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                group.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
              ),
            ),
            if (group.id == selectedId)
              Icon(Icons.check, size: 18, color: colors.accent),
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
              ),
            ),
            if (selected) Icon(Icons.check, size: 18, color: colors.accent),
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final groupColor = colorFromHex(group.color) ?? context.colors.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: groupColor.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.folder_outlined, size: 14, color: groupColor),
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(group.name)),
      ],
    );
  }
}

enum _CycleChoice { weekly, monthly, quarterly, semiAnnual, yearly, custom }

extension _CycleChoiceX on _CycleChoice {
  String label(AppLocalizations l10n) {
    return switch (this) {
      _CycleChoice.weekly => l10n.weekly,
      _CycleChoice.monthly => l10n.monthly,
      _CycleChoice.quarterly => l10n.quarterly,
      _CycleChoice.semiAnnual => l10n.semiAnnual,
      _CycleChoice.yearly => l10n.yearly,
      _CycleChoice.custom => l10n.custom,
    };
  }

  CycleUnit unit(CycleUnit customUnit) {
    return switch (this) {
      _CycleChoice.weekly => CycleUnit.week,
      _CycleChoice.monthly => CycleUnit.month,
      _CycleChoice.quarterly => CycleUnit.month,
      _CycleChoice.semiAnnual => CycleUnit.month,
      _CycleChoice.yearly => CycleUnit.year,
      _CycleChoice.custom => customUnit,
    };
  }

  int count(int customCount) {
    return switch (this) {
      _CycleChoice.weekly => 1,
      _CycleChoice.monthly => 1,
      _CycleChoice.quarterly => 3,
      _CycleChoice.semiAnnual => 6,
      _CycleChoice.yearly => 1,
      _CycleChoice.custom => customCount < 1 ? 1 : customCount,
    };
  }
}

_CycleChoice _cycleChoiceFor(CycleUnit unit, int count) {
  if (unit == CycleUnit.week && count == 1) {
    return _CycleChoice.weekly;
  }
  if (unit == CycleUnit.month && count == 1) {
    return _CycleChoice.monthly;
  }
  if (unit == CycleUnit.month && count == 3) {
    return _CycleChoice.quarterly;
  }
  if (unit == CycleUnit.month && count == 6) {
    return _CycleChoice.semiAnnual;
  }
  if (unit == CycleUnit.year && count == 1) {
    return _CycleChoice.yearly;
  }
  return _CycleChoice.custom;
}

int _parseMinorUnits(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  final parsed = double.tryParse(normalized);
  if (parsed == null) {
    return 0;
  }
  return (parsed * 100).round();
}

String _formatPriceInput(int minor) {
  return (minor / 100).toStringAsFixed(2);
}

DateTime _parseDate(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime.utc(parts[0], parts[1], parts[2]);
}

Group? _findGroup(List<GroupNode> nodes, String? id) {
  if (id == null) {
    return null;
  }
  for (final node in nodes) {
    if (node.group.id == id) {
      return node.group;
    }
    final child = _findGroup(node.children, id);
    if (child != null) {
      return child;
    }
  }
  return null;
}
