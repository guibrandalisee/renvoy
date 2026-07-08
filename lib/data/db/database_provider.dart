import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final subscriptionsDaoProvider = Provider<SubscriptionsDao>(
  (ref) => ref.watch(databaseProvider).subscriptionsDao,
);

final groupsDaoProvider = Provider<GroupsDao>(
  (ref) => ref.watch(databaseProvider).groupsDao,
);

final priceHistoryDaoProvider = Provider<PriceHistoryDao>(
  (ref) => ref.watch(databaseProvider).priceHistoryDao,
);

final reminderRulesDaoProvider = Provider<ReminderRulesDao>(
  (ref) => ref.watch(databaseProvider).reminderRulesDao,
);

final settingsDaoProvider = Provider<SettingsDao>(
  (ref) => ref.watch(databaseProvider).settingsDao,
);
