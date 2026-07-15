import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../domain/models/enums.dart';
import '../db/database_provider.dart';
import '../db/settings_keys.dart';
import 'notification_service.dart';

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(ref);
}, name: 'reminderSchedulerProvider');

class ReminderScheduler {
  ReminderScheduler(this._ref);

  static const _customMode = 'custom';

  final Ref _ref;

  Future<void> ensurePermission() async {
    final settingsDao = _ref.read(settingsDaoProvider);
    final asked = await settingsDao.getValue(SettingsKeys.notifPermissionAsked);
    if (asked == 'true') {
      return;
    }
    await settingsDao.setValue(SettingsKeys.notifPermissionAsked, 'true');
    await _ref.read(notificationServiceProvider).requestPermission();
  }

  Future<void> resync({AppLocalizations? l10n}) async {
    try {
      final resolvedL10n = l10n ?? await _fallbackL10n();
      await _ref
          .read(notificationServiceProvider)
          .init(channelName: resolvedL10n.notifChannelName);
      final subscriptions = await _ref
          .read(subscriptionsDaoProvider)
          .watchAll(status: SubscriptionStatus.active)
          .first;
      final activeSubs = subscriptions
          .where(
            (subscription) => subscription.status == SubscriptionStatus.active,
          )
          .toList();
      final globalRules = await _ref
          .read(reminderRulesDaoProvider)
          .watchGlobal()
          .first;
      final settingsDao = _ref.read(settingsDaoProvider);
      final globalDays = globalRules.isNotEmpty
          ? globalRules.map((rule) => rule.daysBefore).toList()
          : _parseDays(
              await settingsDao.getValue(SettingsKeys.defaultReminderDays),
            );
      final perSubDays = <String, List<int>>{};
      for (final subscription in activeSubs) {
        final mode = await settingsDao.getValue(
          SettingsKeys.subscriptionReminderMode(subscription.id),
        );
        if (mode != _customMode) {
          continue;
        }
        final rules = await _ref
            .read(reminderRulesDaoProvider)
            .watchForSubscription(subscription.id)
            .first;
        perSubDays[subscription.id] = rules
            .map((rule) => rule.daysBefore)
            .toList();
      }
      await _ref
          .read(notificationServiceProvider)
          .rescheduleAll(
            activeSubs: activeSubs,
            perSubDays: perSubDays,
            globalDays: globalDays,
            strings: NotificationStringsFactory.fromL10n(resolvedL10n),
          );
    } catch (error, stackTrace) {
      debugPrint('Reminder resync failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<AppLocalizations> _fallbackL10n() async {
    final value = await _ref
        .read(settingsDaoProvider)
        .getValue(SettingsKeys.localeOverride);
    final localeOverride = switch (value) {
      'en' => const Locale('en'),
      'es' => const Locale('es'),
      'pt' => const Locale('pt'),
      _ => null,
    };
    if (localeOverride != null) {
      return lookupAppLocalizations(localeOverride);
    }
    final locale = PlatformDispatcher.instance.locale;
    if (AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    )) {
      return lookupAppLocalizations(locale);
    }
    return lookupAppLocalizations(const Locale('en'));
  }
}

class NotificationStringsFactory {
  const NotificationStringsFactory._();

  static NotificationStrings fromL10n(AppLocalizations l10n) {
    return NotificationStrings(
      renewalTitle: l10n.notifRenewalTitle,
      renewalBody: l10n.notifRenewalBody,
      trialTitle: l10n.notifTrialTitle,
      trialBody: l10n.notifTrialBody,
      today: l10n.reminderSameDay,
      inDays: l10n.notifInDays,
    );
  }
}

void fireAndForgetReminderResync(WidgetRef ref, {AppLocalizations? l10n}) {
  unawaited(
    ref.read(reminderSchedulerProvider).resync(l10n: l10n).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      debugPrint('Reminder resync failed: $error');
      debugPrint('$stackTrace');
    }),
  );
}

void fireAndForgetEnsureNotificationPermission(Ref ref) {
  unawaited(
    ref.read(reminderSchedulerProvider).ensurePermission().catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      debugPrint('Notification permission request failed: $error');
      debugPrint('$stackTrace');
    }),
  );
}

void fireAndForgetReminderResyncFromRef(Ref ref, {AppLocalizations? l10n}) {
  unawaited(
    ref.read(reminderSchedulerProvider).resync(l10n: l10n).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      debugPrint('Reminder resync failed: $error');
      debugPrint('$stackTrace');
    }),
  );
}

List<int> _parseDays(String? value) {
  final parsed =
      (value ?? '3,0')
          .split(',')
          .map((part) => int.tryParse(part.trim()))
          .whereType<int>()
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));
  return parsed;
}
