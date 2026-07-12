import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/settings_keys.dart';
import '../../../data/notifications/reminder_scheduler.dart';
import '../../../domain/billing/billing_math.dart';
import '../../../domain/models/enums.dart';

final subscriptionFormControllerProvider = Provider<SubscriptionFormController>(
  (ref) => SubscriptionFormController(ref),
);

class SubscriptionFormController {
  SubscriptionFormController(this._ref);

  final Ref _ref;

  Future<String> save(SubscriptionDraft draft, {Subscription? original}) async {
    final today = dateOnlyUtc(DateTime.now());
    var nextBillDate = nextBillOnOrAfter(
      draft.firstBillDate,
      draft.cycleUnit,
      draft.cycleCount,
      today,
    );
    if (draft.trialEndDate != null &&
        dateOnlyUtc(draft.trialEndDate!).isAfter(today)) {
      nextBillDate = dateOnlyUtc(draft.trialEndDate!);
    }

    if (original == null) {
      final id = await _ref
          .read(subscriptionsDaoProvider)
          .insert(
            SubscriptionsCompanion.insert(
              id: '',
              createdAt: 0,
              updatedAt: 0,
              name: draft.name.trim(),
              priceMinor: draft.priceMinor,
              currency: draft.currency,
              cycleUnit: draft.cycleUnit,
              cycleCount: Value(draft.cycleCount),
              firstBillDate: _dateToText(draft.firstBillDate),
              nextBillDate: _dateToText(nextBillDate),
              trialEndDate: Value(_nullableDateToText(draft.trialEndDate)),
              status: SubscriptionStatus.active,
              paymentMethod: Value(_emptyToNull(draft.paymentMethod)),
              notes: Value(_emptyToNull(draft.notes)),
              manageUrl: Value(_emptyToNull(draft.manageUrl)),
              groupId: Value(draft.groupId),
              serviceSlug: Value(draft.serviceSlug),
              colorHex: Value(draft.colorHex ?? _colorForName(draft.name)),
              iconName: Value(draft.iconName ?? _iconForName(draft.name)),
            ),
          );
      await _saveReminderRules(id, draft);
      fireAndForgetEnsureNotificationPermission(_ref);
      fireAndForgetReminderResyncFromRef(_ref);
      return id;
    }

    if (original.priceMinor != draft.priceMinor) {
      await _ref
          .read(priceHistoryDaoProvider)
          .insert(
            PriceHistoryCompanion.insert(
              id: '',
              createdAt: 0,
              updatedAt: 0,
              subscriptionId: original.id,
              changedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
              oldPriceMinor: original.priceMinor,
              newPriceMinor: draft.priceMinor,
            ),
          );
    }

    final billingChanged =
        original.cycleUnit != draft.cycleUnit ||
        original.cycleCount != draft.cycleCount ||
        original.firstBillDate != _dateToText(draft.firstBillDate) ||
        original.trialEndDate != _nullableDateToText(draft.trialEndDate);

    await _ref
        .read(subscriptionsDaoProvider)
        .updateSubscription(
          SubscriptionsCompanion(
            id: Value(original.id),
            name: Value(draft.name.trim()),
            priceMinor: Value(draft.priceMinor),
            currency: Value(draft.currency),
            cycleUnit: Value(draft.cycleUnit),
            cycleCount: Value(draft.cycleCount),
            firstBillDate: Value(_dateToText(draft.firstBillDate)),
            nextBillDate: billingChanged
                ? Value(_dateToText(nextBillDate))
                : const Value.absent(),
            trialEndDate: Value(_nullableDateToText(draft.trialEndDate)),
            paymentMethod: Value(_emptyToNull(draft.paymentMethod)),
            notes: Value(_emptyToNull(draft.notes)),
            manageUrl: Value(_emptyToNull(draft.manageUrl)),
            groupId: Value(draft.groupId),
            colorHex: Value(original.colorHex ?? _colorForName(draft.name)),
            iconName: Value(original.iconName ?? _iconForName(draft.name)),
          ),
        );
    await _saveReminderRules(original.id, draft);
    fireAndForgetEnsureNotificationPermission(_ref);
    fireAndForgetReminderResyncFromRef(_ref);
    return original.id;
  }

  Future<void> _saveReminderRules(
    String subscriptionId,
    SubscriptionDraft draft,
  ) async {
    await _ref
        .read(settingsDaoProvider)
        .setValue(
          SettingsKeys.subscriptionReminderMode(subscriptionId),
          draft.useDefaultReminders ? 'default' : 'custom',
        );
    if (!draft.useDefaultReminders) {
      await _ref
          .read(reminderRulesDaoProvider)
          .replaceForSubscription(subscriptionId, draft.reminderDays);
    }
  }
}

class SubscriptionDraft {
  const SubscriptionDraft({
    required this.name,
    required this.priceMinor,
    required this.currency,
    required this.cycleUnit,
    required this.cycleCount,
    required this.firstBillDate,
    required this.trialEndDate,
    required this.groupId,
    required this.paymentMethod,
    required this.notes,
    required this.manageUrl,
    required this.useDefaultReminders,
    required this.reminderDays,
    this.serviceSlug,
    this.colorHex,
    this.iconName,
  });

  final String name;
  final int priceMinor;
  final String currency;
  final CycleUnit cycleUnit;
  final int cycleCount;
  final DateTime firstBillDate;
  final DateTime? trialEndDate;
  final String? groupId;
  final String paymentMethod;
  final String notes;
  final String manageUrl;
  final bool useDefaultReminders;
  final List<int> reminderDays;
  final String? serviceSlug;
  final String? colorHex;
  final String? iconName;
}

String _dateToText(DateTime date) {
  final utc = dateOnlyUtc(date);
  final year = utc.year.toString().padLeft(4, '0');
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String? _nullableDateToText(DateTime? date) {
  return date == null ? null : _dateToText(date);
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _colorForName(String name) {
  const palette = [
    '#7C5CFC',
    '#38BDF8',
    '#34D399',
    '#FBBF24',
    '#F87171',
    '#F472B6',
    '#A78BFA',
    '#22D3EE',
    '#FB923C',
    '#4ADE80',
  ];
  final hash = name.codeUnits.fold<int>(0, (value, unit) => value + unit);
  return palette[hash % palette.length];
}

String _iconForName(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
}
