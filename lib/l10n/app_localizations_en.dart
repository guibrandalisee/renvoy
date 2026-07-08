// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Renvoy';

  @override
  String get navHome => 'Home';

  @override
  String get navSubscriptions => 'Subscriptions';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navSettings => 'Settings';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonSubtitle => 'This screen is being built.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get monthlySpend => 'Monthly spend';

  @override
  String get toggleMonthly => 'Monthly';

  @override
  String get toggleYearly => 'Yearly';

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active subscriptions',
      one: '1 active subscription',
      zero: '0 active subscriptions',
    );
    return '$_temp0';
  }

  @override
  String get upcomingRenewals => 'Upcoming renewals';

  @override
  String get spendByGroup => 'Spend by group';

  @override
  String get groupOther => 'Other';

  @override
  String get emptyTitle => 'No subscriptions yet';

  @override
  String get emptySubtitle =>
      'Add your first subscription to see your spending at a glance.';

  @override
  String get addSubscription => 'Add subscription';

  @override
  String get trialChip => 'TRIAL';

  @override
  String get cycleDay => '/day';

  @override
  String get cycleWeek => '/week';

  @override
  String get cycleMonth => '/month';

  @override
  String get cycleYear => '/year';

  @override
  String get newSubscription => 'New subscription';

  @override
  String get editSubscription => 'Edit subscription';

  @override
  String get save => 'Save';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'Netflix, Spotify, gym...';

  @override
  String get price => 'Price';

  @override
  String get currency => 'Currency';

  @override
  String get billingCycle => 'Billing cycle';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get quarterly => 'Quarterly';

  @override
  String get semiAnnual => 'Semi-annual';

  @override
  String get yearly => 'Yearly';

  @override
  String get custom => 'Custom';

  @override
  String get every => 'Every';

  @override
  String get days => 'days';

  @override
  String get weeks => 'weeks';

  @override
  String get months => 'months';

  @override
  String get years => 'years';

  @override
  String get firstBillDate => 'First bill date';

  @override
  String get freeTrial => 'Free trial';

  @override
  String get trialEnds => 'Trial ends';

  @override
  String get group => 'Group';

  @override
  String get reminders => 'Reminders';

  @override
  String get reminderDefault => 'Default (3 days, same day)';

  @override
  String get reminderUseDefaults => 'Use defaults';

  @override
  String get reminderSameDay => 'Same day';

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String reminderRuleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rules',
      one: '1 rule',
      zero: 'No reminders',
    );
    return '$_temp0';
  }

  @override
  String get reminderNoRules => 'No reminders';

  @override
  String get notifRenewalTitle => 'Upcoming renewal';

  @override
  String notifRenewalBody(String name, String when, String price) {
    return '$name renews $when — $price';
  }

  @override
  String get notifTrialTitle => 'Trial ending';

  @override
  String notifTrialBody(String name, String when) {
    return '$name trial ends $when';
  }

  @override
  String notifInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'in $_temp0';
  }

  @override
  String get none => 'None';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get paymentMethodHint => 'Nubank credit card...';

  @override
  String get notes => 'Notes';

  @override
  String get url => 'URL';

  @override
  String get urlHint => 'https://...';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search subscriptions';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get paused => 'Paused';

  @override
  String get canceled => 'Canceled';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortNextRenewal => 'Next renewal';

  @override
  String get sortPrice => 'Price';

  @override
  String get sortName => 'Name';

  @override
  String get noResults => 'Nothing found';

  @override
  String get noResultsSubtitle => 'Try a different search or filter.';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage => 'Your changes will be lost.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get noGroup => 'No group';

  @override
  String approxPerMonth(String amount) {
    return '≈ $amount /month';
  }

  @override
  String get pausedNotCounted => 'Paused — not counted in totals';

  @override
  String trialEndsDate(String date) {
    return 'Trial ends $date';
  }

  @override
  String get nextRenewal => 'Next renewal';

  @override
  String get firstBill => 'First bill';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get priceHistory => 'Price history';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get duplicated => 'Duplicated';

  @override
  String get cancelSubscription => 'Cancel subscription';

  @override
  String get cancelSubscriptionMessage =>
      'Keep history, stop counting in totals.';

  @override
  String get delete => 'Delete';

  @override
  String get deleteSubscriptionMessage => 'Delete this subscription?';

  @override
  String get deleted => 'Deleted';

  @override
  String get undo => 'UNDO';

  @override
  String get keep => 'Keep';

  @override
  String get thisMonth => 'This month';

  @override
  String renewalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count renewals',
      one: '1 renewal',
      zero: '0 renewals',
    );
    return '$_temp0';
  }

  @override
  String renewalsOn(String date) {
    return 'Renewals on $date';
  }

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsEmpty => 'No groups yet';

  @override
  String get groupsEmptySubtitle =>
      'Group subscriptions to see spending by category.';

  @override
  String get createGroup => 'Create group';

  @override
  String get editGroup => 'Edit group';

  @override
  String get icon => 'Icon';

  @override
  String get color => 'Color';

  @override
  String get parentGroup => 'Parent group';

  @override
  String get noneTopLevel => 'None (top level)';

  @override
  String groupSummary(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
      zero: '0 subscriptions',
    );
    return '$_temp0 · $amount /mo';
  }

  @override
  String get deleteGroupMessage => 'Delete this group?';

  @override
  String get moveContentsUp => 'Move contents up';

  @override
  String get ungroupSubscriptions => 'Ungroup subscriptions';

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get deleteEverythingMessage =>
      'Delete this group and everything inside it?';

  @override
  String everyCountUnit(int count, String unit) {
    return 'Every $count $unit';
  }

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsPortugueseBrazil => 'Português (Brasil)';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsFirstDay => 'First day of week';

  @override
  String get settingsMonday => 'Monday';

  @override
  String get settingsSunday => 'Sunday';

  @override
  String get settingsReminders => 'Reminders';

  @override
  String get settingsDefaultReminders => 'Default reminders';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsExportBackup => 'Export backup';

  @override
  String get settingsImportBackup => 'Import backup';

  @override
  String get settingsExportCsv => 'Export CSV';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String importConfirm(int subscriptions, int groups) {
    return 'Import $subscriptions subscriptions, $groups groups? This merges with existing data.';
  }

  @override
  String get importError => 'Could not read this backup file.';

  @override
  String get importSuccess => 'Backup imported.';

  @override
  String get exportError => 'Could not export this file.';

  @override
  String get relativeToday => 'today';

  @override
  String get relativeTomorrow => 'tomorrow';

  @override
  String get relativeYesterday => 'yesterday';

  @override
  String relativeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'in $_temp0';
  }

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }
}
