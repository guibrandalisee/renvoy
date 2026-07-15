import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/notifications/notification_service.dart';
import 'package:renvoy/domain/models/enums.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  const strings = NotificationStrings(
    renewalTitle: 'Upcoming renewal',
    renewalBody: _renewalBody,
    trialTitle: 'Trial ending',
    trialBody: _trialBody,
    today: 'today',
    inDays: _inDays,
  );

  test('rescheduleAll cancels then schedules expected count', () async {
    final plugin = _FakeNotificationsPlugin();
    final service = _service(plugin);

    await service.rescheduleAll(
      activeSubs: [
        _subscription(
          id: 'sub-1',
          nextBillDate: '2026-02-10',
          trialEndDate: '2026-02-12',
        ),
      ],
      perSubDays: const {},
      globalDays: const [3, 0],
      strings: strings,
    );

    expect(plugin.cancelAllCalls, 1);
    expect(plugin.schedules, hasLength(4));
    expect(plugin.schedules.first.title, 'Upcoming renewal');
  });

  test('stable notification id is deterministic and separates rules', () {
    final first = NotificationService.stableNotificationId('sub-1:3');
    final second = NotificationService.stableNotificationId('sub-1:3');
    final different = NotificationService.stableNotificationId('sub-1:0');

    expect(first, second);
    expect(first, isNot(different));
  });

  test('past renewal dates are not scheduled', () async {
    final plugin = _FakeNotificationsPlugin();
    final service = _service(plugin);

    await service.rescheduleAll(
      activeSubs: [_subscription(id: 'sub-1', nextBillDate: '2026-01-01')],
      perSubDays: const {},
      globalDays: const [3, 0],
      strings: strings,
    );

    expect(plugin.cancelAllCalls, 1);
    expect(plugin.schedules, isEmpty);
  });

  test('trial reminders are included', () async {
    final plugin = _FakeNotificationsPlugin();
    final service = _service(plugin);

    await service.rescheduleAll(
      activeSubs: [
        _subscription(
          id: 'sub-1',
          nextBillDate: '2026-03-01',
          trialEndDate: '2026-02-20',
        ),
      ],
      perSubDays: const {},
      globalDays: const [],
      strings: strings,
    );

    expect(plugin.schedules, hasLength(2));
    expect(plugin.schedules.map((schedule) => schedule.title), {
      'Trial ending',
    });
  });

  test('notification body describes the delay on its delivery day', () async {
    final plugin = _FakeNotificationsPlugin();
    final service = _service(plugin);

    await service.rescheduleAll(
      activeSubs: [_subscription(id: 'sub-1', nextBillDate: '2026-02-07')],
      perSubDays: const {},
      globalDays: const [3],
      strings: strings,
    );

    final schedule = plugin.schedules.single;
    expect(schedule.scheduledDate, tz.TZDateTime.utc(2026, 2, 4, 9));
    expect(schedule.body, contains('in 3 days'));
    expect(schedule.body, isNot(contains('in 6 days')));
  });

  test('trial ending on next bill date does not duplicate reminder', () async {
    final plugin = _FakeNotificationsPlugin();
    final service = _service(plugin);

    await service.rescheduleAll(
      activeSubs: [
        _subscription(
          id: 'sub-1',
          nextBillDate: '2026-02-07',
          trialEndDate: '2026-02-07',
        ),
      ],
      perSubDays: const {},
      globalDays: const [3, 0],
      strings: strings,
    );

    expect(plugin.schedules, hasLength(2));
    expect(plugin.schedules.map((schedule) => schedule.title), {
      'Trial ending',
    });
    expect(
      plugin.schedules.map((schedule) => schedule.body),
      containsAll(<String>[
        'Netflix trial ends in 3 days',
        'Netflix trial ends today',
      ]),
    );
  });

  test('per-subscription rules override global rules', () async {
    final plugin = _FakeNotificationsPlugin();
    final service = _service(plugin);

    await service.rescheduleAll(
      activeSubs: [_subscription(id: 'sub-1', nextBillDate: '2026-02-10')],
      perSubDays: const {
        'sub-1': [7],
      },
      globalDays: const [3, 0],
      strings: strings,
    );

    expect(plugin.schedules, hasLength(1));
    expect(
      plugin.schedules.single.id,
      NotificationService.stableNotificationId('sub-1:7'),
    );
  });
}

NotificationService _service(_FakeNotificationsPlugin plugin) {
  return NotificationService(
    plugin: plugin,
    location: tz.UTC,
    now: () => DateTime(2026, 2, 1, 8),
  );
}

String _renewalBody(String name, String when, String price) {
  return '$name renews $when - $price';
}

String _trialBody(String name, String when) {
  return '$name trial ends $when';
}

String _inDays(int days) {
  return 'in $days days';
}

Subscription _subscription({
  required String id,
  required String nextBillDate,
  String? trialEndDate,
  SubscriptionStatus status = SubscriptionStatus.active,
}) {
  return Subscription(
    id: id,
    createdAt: 0,
    updatedAt: 0,
    deletedAt: null,
    dirty: true,
    name: 'Netflix',
    serviceSlug: null,
    priceMinor: 1299,
    currency: 'USD',
    cycleUnit: CycleUnit.month,
    cycleCount: 1,
    firstBillDate: '2026-01-01',
    nextBillDate: nextBillDate,
    trialEndDate: trialEndDate,
    status: status,
    paymentMethod: null,
    notes: null,
    manageUrl: null,
    groupId: null,
    colorHex: null,
    iconName: null,
  );
}

class _FakeNotificationsPlugin implements NotificationsPlugin {
  var cancelAllCalls = 0;
  final schedules = <_Schedule>[];

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
  }

  @override
  Future<void> createAndroidNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {}

  @override
  Future<bool?> initialize(InitializationSettings settings) async {
    return true;
  }

  @override
  Future<bool?> requestAndroidNotificationsPermission() async {
    return true;
  }

  @override
  Future<bool?> requestDarwinPermissions() async {
    return true;
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDate,
    NotificationDetails details,
    AndroidScheduleMode androidScheduleMode,
  ) async {
    schedules.add(
      _Schedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        androidScheduleMode: androidScheduleMode,
      ),
    );
  }
}

class _Schedule {
  const _Schedule({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.androidScheduleMode,
  });

  final int id;
  final String title;
  final String body;
  final tz.TZDateTime scheduledDate;
  final AndroidScheduleMode androidScheduleMode;
}
