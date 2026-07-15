import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../core/formatters.dart';
import '../../domain/models/enums.dart';
import '../db/database.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(plugin: FlutterLocalNotificationsAdapter());
}, name: 'notificationServiceProvider');

abstract interface class NotificationsPlugin {
  Future<bool?> initialize(InitializationSettings settings);

  Future<void> createAndroidNotificationChannel(
    AndroidNotificationChannel channel,
  );

  Future<bool?> requestAndroidNotificationsPermission();

  Future<bool?> requestDarwinPermissions();

  Future<void> cancelAll();

  Future<void> zonedSchedule(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDate,
    NotificationDetails details,
    AndroidScheduleMode androidScheduleMode,
  );
}

class FlutterLocalNotificationsAdapter implements NotificationsPlugin {
  FlutterLocalNotificationsAdapter({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<bool?> initialize(InitializationSettings settings) {
    return _plugin.initialize(settings);
  }

  @override
  Future<void> createAndroidNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  @override
  Future<bool?> requestAndroidNotificationsPermission() {
    return _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        Future.value(false);
  }

  @override
  Future<bool?> requestDarwinPermissions() async {
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final mac = await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return ios ?? mac ?? false;
  }

  @override
  Future<void> cancelAll() {
    return _plugin.cancelAll();
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDate,
    NotificationDetails details,
    AndroidScheduleMode androidScheduleMode,
  ) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: androidScheduleMode,
    );
  }
}

class NotificationStrings {
  const NotificationStrings({
    required this.renewalTitle,
    required this.renewalBody,
    required this.trialTitle,
    required this.trialBody,
    required this.today,
    required this.inDays,
  });

  final String renewalTitle;
  final String Function(String name, String when, String price) renewalBody;
  final String trialTitle;
  final String Function(String name, String when) trialBody;
  final String today;
  final String Function(int days) inDays;
}

class NotificationService {
  NotificationService({
    required NotificationsPlugin plugin,
    tz.Location? location,
    DateTime Function()? now,
    Future<TimezoneInfo> Function()? getLocalTimezone,
  }) : _plugin = plugin,
       _location = location ?? tz.UTC,
       _now = now ?? DateTime.now,
       _getLocalTimezone = getLocalTimezone ?? FlutterTimezone.getLocalTimezone;

  static const channelId = 'renewals';
  static const channelName = 'Renewal reminders';

  final NotificationsPlugin _plugin;
  final DateTime Function() _now;
  final Future<TimezoneInfo> Function() _getLocalTimezone;
  tz.Location _location;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    try {
      tz.initializeTimeZones();
      try {
        final timezone = await _getLocalTimezone();
        _location = tz.getLocation(timezone.identifier);
      } catch (_) {
        _location = tz.UTC;
      }
      tz.setLocalLocation(_location);

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
          macOS: darwinSettings,
        ),
      );
      await _plugin.createAndroidNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          importance: Importance.high,
        ),
      );
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      final android = await _plugin.requestAndroidNotificationsPermission();
      final darwin = await _plugin.requestDarwinPermissions();
      return android == true || darwin == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> rescheduleAll({
    required List<Subscription> activeSubs,
    required Map<String, List<int>> perSubDays,
    required List<int> globalDays,
    required NotificationStrings strings,
  }) async {
    await _guarded(_plugin.cancelAll);
    for (final subscription in activeSubs) {
      if (subscription.status != SubscriptionStatus.active) {
        continue;
      }
      final effectiveDays = perSubDays.containsKey(subscription.id)
          ? perSubDays[subscription.id]!
          : globalDays;
      if (!_trialEndsOnNextBillDate(subscription)) {
        for (final daysBefore in effectiveDays) {
          await _scheduleRenewal(subscription, daysBefore, strings);
        }
      }
      await _scheduleTrial(subscription, 3, strings);
      await _scheduleTrial(subscription, 0, strings);
    }
  }

  static int stableNotificationId(String key) {
    var hash = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  Future<void> _scheduleRenewal(
    Subscription subscription,
    int daysBefore,
    NotificationStrings strings,
  ) async {
    final nextBillDate = _parseDate(subscription.nextBillDate);
    if (nextBillDate == null) {
      return;
    }
    final scheduled = _scheduledAt(nextBillDate, daysBefore);
    if (!_isFuture(scheduled)) {
      return;
    }
    final when = _whenDelivered(daysBefore, strings);
    final price = Money.format(subscription.priceMinor, subscription.currency);
    await _schedule(
      id: stableNotificationId('${subscription.id}:$daysBefore'),
      title: strings.renewalTitle,
      body: strings.renewalBody(subscription.name, when, price),
      scheduled: scheduled,
    );
  }

  Future<void> _scheduleTrial(
    Subscription subscription,
    int daysBefore,
    NotificationStrings strings,
  ) async {
    final trialEndText = subscription.trialEndDate;
    if (trialEndText == null) {
      return;
    }
    final trialEndDate = _parseDate(trialEndText);
    if (trialEndDate == null || !_isDateFuture(trialEndDate)) {
      return;
    }
    final scheduled = _scheduledAt(trialEndDate, daysBefore);
    if (!_isFuture(scheduled)) {
      return;
    }
    await _schedule(
      id: stableNotificationId('${subscription.id}:trial:$daysBefore'),
      title: strings.trialTitle,
      body: strings.trialBody(
        subscription.name,
        _whenDelivered(daysBefore, strings),
      ),
      scheduled: scheduled,
    );
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduled,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  tz.TZDateTime _scheduledAt(DateTime date, int daysBefore) {
    final reminderDate = date.subtract(Duration(days: daysBefore));
    return tz.TZDateTime(
      _location,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
    );
  }

  String _whenDelivered(int daysBefore, NotificationStrings strings) {
    if (daysBefore <= 0) {
      return strings.today;
    }
    return strings.inDays(daysBefore);
  }

  bool _trialEndsOnNextBillDate(Subscription subscription) {
    final trialEndText = subscription.trialEndDate;
    if (trialEndText == null) {
      return false;
    }
    final trialEndDate = _parseDate(trialEndText);
    final nextBillDate = _parseDate(subscription.nextBillDate);
    return trialEndDate != null &&
        nextBillDate != null &&
        _isDateFuture(trialEndDate) &&
        trialEndDate == nextBillDate;
  }

  bool _isFuture(tz.TZDateTime scheduled) {
    return scheduled.isAfter(tz.TZDateTime.from(_now(), _location));
  }

  bool _isDateFuture(DateTime date) {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(date.year, date.month, date.day).isAfter(today);
  }

  Future<void> _guarded(Future<void> Function() callback) async {
    try {
      await callback();
    } catch (_) {}
  }
}

DateTime? _parseDate(String value) {
  try {
    final parts = value.split('-').map(int.parse).toList();
    if (parts.length != 3) {
      return null;
    }
    return DateTime(parts[0], parts[1], parts[2]);
  } catch (_) {
    return null;
  }
}
