enum CycleUnit {
  day,
  week,
  month,
  year;

  String get toDb => name;

  static CycleUnit fromDb(String value) {
    return switch (value) {
      'day' => CycleUnit.day,
      'week' => CycleUnit.week,
      'month' => CycleUnit.month,
      'year' => CycleUnit.year,
      _ => throw ArgumentError.value(value, 'value', 'Unknown cycle unit'),
    };
  }
}

enum SubscriptionStatus {
  active,
  paused,
  canceled;

  String get toDb => name;

  static SubscriptionStatus fromDb(String value) {
    return switch (value) {
      'active' => SubscriptionStatus.active,
      'paused' => SubscriptionStatus.paused,
      'canceled' => SubscriptionStatus.canceled,
      _ => throw ArgumentError.value(
        value,
        'value',
        'Unknown subscription status',
      ),
    };
  }
}
