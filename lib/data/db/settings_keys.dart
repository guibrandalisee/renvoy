abstract final class SettingsKeys {
  static const defaultCurrency = 'defaultCurrency';
  static const themeMode = 'themeMode';
  static const localeOverride = 'localeOverride';
  static const firstDayOfWeek = 'firstDayOfWeek';
  static const defaultReminderDays = 'defaultReminderDays';
  static const notifPermissionAsked = 'notifPermissionAsked';
  static const monthlyEquivalentView = 'monthlyEquivalentView';

  static String subscriptionReminderMode(String subscriptionId) {
    return 'subscriptionReminderMode:$subscriptionId';
  }
}
