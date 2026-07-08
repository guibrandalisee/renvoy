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
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count renewals',
      one: '1 renewal',
      zero: '0 renewals',
    );
    return value;
  }

  @override
  String renewalsOn(String date) => 'Renewals on $date';

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
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
      zero: '0 subscriptions',
    );
    return '$value · $amount /mo';
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
}
