import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Renvoy'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get navSubscriptions;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This screen is being built.'**
  String get comingSoonSubtitle;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @monthlySpend.
  ///
  /// In en, this message translates to:
  /// **'Monthly spend'**
  String get monthlySpend;

  /// No description provided for @toggleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get toggleMonthly;

  /// No description provided for @toggleYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get toggleYearly;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 active subscriptions} =1{1 active subscription} other{{count} active subscriptions}}'**
  String activeCount(int count);

  /// No description provided for @upcomingRenewals.
  ///
  /// In en, this message translates to:
  /// **'Upcoming renewals'**
  String get upcomingRenewals;

  /// No description provided for @spendByGroup.
  ///
  /// In en, this message translates to:
  /// **'Spend by group'**
  String get spendByGroup;

  /// No description provided for @groupOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get groupOther;

  /// No description provided for @noSubgroup.
  ///
  /// In en, this message translates to:
  /// **'No subgroup'**
  String get noSubgroup;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet'**
  String get emptyTitle;

  /// No description provided for @emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first subscription to see your spending at a glance.'**
  String get emptySubtitle;

  /// No description provided for @addSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add subscription'**
  String get addSubscription;

  /// No description provided for @trialChip.
  ///
  /// In en, this message translates to:
  /// **'TRIAL'**
  String get trialChip;

  /// No description provided for @cycleDay.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get cycleDay;

  /// No description provided for @cycleWeek.
  ///
  /// In en, this message translates to:
  /// **'/week'**
  String get cycleWeek;

  /// No description provided for @cycleMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get cycleMonth;

  /// No description provided for @cycleYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get cycleYear;

  /// No description provided for @newSubscription.
  ///
  /// In en, this message translates to:
  /// **'New subscription'**
  String get newSubscription;

  /// No description provided for @editSubscription.
  ///
  /// In en, this message translates to:
  /// **'Edit subscription'**
  String get editSubscription;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Netflix, Spotify, gym...'**
  String get nameHint;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @billingCycle.
  ///
  /// In en, this message translates to:
  /// **'Billing cycle'**
  String get billingCycle;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @quarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get quarterly;

  /// No description provided for @semiAnnual.
  ///
  /// In en, this message translates to:
  /// **'Semi-annual'**
  String get semiAnnual;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @firstBillDate.
  ///
  /// In en, this message translates to:
  /// **'First bill date'**
  String get firstBillDate;

  /// No description provided for @subscriptionStartDate.
  ///
  /// In en, this message translates to:
  /// **'Subscription starts'**
  String get subscriptionStartDate;

  /// No description provided for @freeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get freeTrial;

  /// No description provided for @trialEnds.
  ///
  /// In en, this message translates to:
  /// **'Trial ends'**
  String get trialEnds;

  /// No description provided for @trialEndAndFirstCharge.
  ///
  /// In en, this message translates to:
  /// **'Trial ends · First charge'**
  String get trialEndAndFirstCharge;

  /// No description provided for @trialBillingExplanation.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1-day free trial} other{{count}-day free trial}}. No charge today. Billing starts on {date}, and future renewals follow this date.'**
  String trialBillingExplanation(int count, String date);

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @reminderDefault.
  ///
  /// In en, this message translates to:
  /// **'Default (3 days, same day)'**
  String get reminderDefault;

  /// No description provided for @reminderUseDefaults.
  ///
  /// In en, this message translates to:
  /// **'Use defaults'**
  String get reminderUseDefaults;

  /// No description provided for @reminderSameDay.
  ///
  /// In en, this message translates to:
  /// **'Same day'**
  String get reminderSameDay;

  /// No description provided for @reminderDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String reminderDaysBefore(int count);

  /// No description provided for @reminderRuleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reminders} =1{1 rule} other{{count} rules}}'**
  String reminderRuleCount(int count);

  /// No description provided for @reminderNoRules.
  ///
  /// In en, this message translates to:
  /// **'No reminders'**
  String get reminderNoRules;

  /// No description provided for @notifRenewalTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming renewal'**
  String get notifRenewalTitle;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Renewal reminders'**
  String get notifChannelName;

  /// No description provided for @notifRenewalBody.
  ///
  /// In en, this message translates to:
  /// **'{name} renews {when} — {price}'**
  String notifRenewalBody(String name, String when, String price);

  /// No description provided for @notifTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'Trial ending'**
  String get notifTrialTitle;

  /// No description provided for @notifTrialBody.
  ///
  /// In en, this message translates to:
  /// **'{name} trial ends {when}'**
  String notifTrialBody(String name, String when);

  /// No description provided for @notifInDays.
  ///
  /// In en, this message translates to:
  /// **'in {count, plural, =1{1 day} other{{count} days}}'**
  String notifInDays(int count);

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @paymentMethodHint.
  ///
  /// In en, this message translates to:
  /// **'Nubank credit card...'**
  String get paymentMethodHint;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @urlHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get urlHint;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search subscriptions'**
  String get searchHint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortNextRenewal.
  ///
  /// In en, this message translates to:
  /// **'Next renewal'**
  String get sortNextRenewal;

  /// No description provided for @sortPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sortPrice;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get noResults;

  /// No description provided for @noResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or filter.'**
  String get noResultsSubtitle;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your changes will be lost.'**
  String get discardChangesMessage;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @noGroup.
  ///
  /// In en, this message translates to:
  /// **'No group'**
  String get noGroup;

  /// No description provided for @approxPerMonth.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount} /month'**
  String approxPerMonth(String amount);

  /// No description provided for @pausedNotCounted.
  ///
  /// In en, this message translates to:
  /// **'Paused — not counted in totals'**
  String get pausedNotCounted;

  /// No description provided for @trialEndsDate.
  ///
  /// In en, this message translates to:
  /// **'Trial ends {date}'**
  String trialEndsDate(String date);

  /// No description provided for @nextRenewal.
  ///
  /// In en, this message translates to:
  /// **'Next renewal'**
  String get nextRenewal;

  /// No description provided for @firstBill.
  ///
  /// In en, this message translates to:
  /// **'First bill'**
  String get firstBill;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// No description provided for @priceHistory.
  ///
  /// In en, this message translates to:
  /// **'Price history'**
  String get priceHistory;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @duplicated.
  ///
  /// In en, this message translates to:
  /// **'Duplicated'**
  String get duplicated;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get cancelSubscription;

  /// No description provided for @cancelSubscriptionMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep history, stop counting in totals.'**
  String get cancelSubscriptionMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteSubscriptionMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this subscription?'**
  String get deleteSubscriptionMessage;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @renewalsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 charges} =1{1 charge} other{{count} charges}}'**
  String renewalsCount(int count);

  /// No description provided for @renewalsOn.
  ///
  /// In en, this message translates to:
  /// **'Charges on {date}'**
  String renewalsOn(String date);

  /// No description provided for @groupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// No description provided for @groupsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get groupsEmpty;

  /// No description provided for @groupsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Group subscriptions to see spending by category.'**
  String get groupsEmptySubtitle;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroup;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @parentGroup.
  ///
  /// In en, this message translates to:
  /// **'Parent group'**
  String get parentGroup;

  /// No description provided for @noneTopLevel.
  ///
  /// In en, this message translates to:
  /// **'None (top level)'**
  String get noneTopLevel;

  /// No description provided for @groupSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 subscriptions} =1{1 subscription} other{{count} subscriptions}} · {amount} /mo'**
  String groupSummary(int count, String amount);

  /// No description provided for @deleteGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this group?'**
  String get deleteGroupMessage;

  /// No description provided for @moveContentsUp.
  ///
  /// In en, this message translates to:
  /// **'Move contents up'**
  String get moveContentsUp;

  /// No description provided for @ungroupSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Ungroup subscriptions'**
  String get ungroupSubscriptions;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// No description provided for @deleteEverythingMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this group and everything inside it?'**
  String get deleteEverythingMessage;

  /// No description provided for @everyCountUnit.
  ///
  /// In en, this message translates to:
  /// **'Every {count} {unit}'**
  String everyCountUnit(int count, String unit);

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystem;

  /// No description provided for @settingsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settingsSpanish;

  /// No description provided for @settingsPortugueseBrazil.
  ///
  /// In en, this message translates to:
  /// **'Português (Brasil)'**
  String get settingsPortugueseBrazil;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// No description provided for @settingsFirstDay.
  ///
  /// In en, this message translates to:
  /// **'First day of week'**
  String get settingsFirstDay;

  /// No description provided for @settingsMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get settingsMonday;

  /// No description provided for @settingsSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get settingsSunday;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsReminders;

  /// No description provided for @settingsDefaultReminders.
  ///
  /// In en, this message translates to:
  /// **'Default reminders'**
  String get settingsDefaultReminders;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExportBackup;

  /// No description provided for @settingsImportBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get settingsImportBackup;

  /// No description provided for @settingsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get settingsExportCsv;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @importConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import {subscriptions} subscriptions, {groups} groups? This merges with existing data.'**
  String importConfirm(int subscriptions, int groups);

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Could not read this backup file.'**
  String get importError;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup imported.'**
  String get importSuccess;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Could not export this file.'**
  String get exportError;

  /// No description provided for @relativeToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get relativeToday;

  /// No description provided for @relativeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get relativeTomorrow;

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get relativeYesterday;

  /// No description provided for @relativeInDays.
  ///
  /// In en, this message translates to:
  /// **'in {count, plural, =1{1 day} other{{count} days}}'**
  String relativeInDays(int count);

  /// No description provided for @catalogPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a service'**
  String get catalogPickerTitle;

  /// No description provided for @catalogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search services'**
  String get catalogSearchHint;

  /// No description provided for @catalogCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'Create custom'**
  String get catalogCreateCustom;

  /// No description provided for @catalogCreateCustomNamed.
  ///
  /// In en, this message translates to:
  /// **'Create custom: {name}'**
  String catalogCreateCustomNamed(String name);

  /// No description provided for @catalogUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog unavailable'**
  String get catalogUnavailableTitle;

  /// No description provided for @catalogUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again, or create a custom subscription.'**
  String get catalogUnavailableSubtitle;

  /// No description provided for @catalogTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get catalogTryAgain;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or create a custom subscription.'**
  String get catalogEmptySubtitle;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your overview could not be loaded'**
  String get homeLoadError;

  /// No description provided for @homeLoadErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data is still safe on this device. Try loading it again.'**
  String get homeLoadErrorSubtitle;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String relativeDaysAgo(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
