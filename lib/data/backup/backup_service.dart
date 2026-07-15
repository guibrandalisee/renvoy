import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/enums.dart';
import '../db/database.dart';
import '../db/database_provider.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

class BackupService {
  BackupService(this._db);

  static const format = 'renvoy.backup';
  static const currentVersion = 2;

  final AppDatabase _db;

  Future<String> exportJson() async {
    final subscriptions = await (_db.select(
      _db.subscriptions,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final groups = await (_db.select(
      _db.groups,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final priceHistory = await (_db.select(
      _db.priceHistory,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final reminderRules = await (_db.select(
      _db.reminderRules,
    )..where((tbl) => tbl.deletedAt.isNull())).get();

    return jsonEncode({
      'format': format,
      'version': currentVersion,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'data': {
        'subscriptions': subscriptions
            .map((row) => _jsonRow(row.toJson()))
            .toList(),
        'groups': groups.map((row) => _jsonRow(row.toJson())).toList(),
        'price_history': priceHistory
            .map((row) => _jsonRow(row.toJson()))
            .toList(),
        'reminder_rules': reminderRules
            .map((row) => _jsonRow(row.toJson()))
            .toList(),
      },
    });
  }

  Future<ImportPreview> previewImport(String source) async {
    final data = _parseBackup(source);
    return ImportPreview(
      subscriptions: data.subscriptions.length,
      groups: data.groups.length,
      priceHistory: data.priceHistory.length,
      reminderRules: data.reminderRules.length,
    );
  }

  Future<ImportPreview> importJson(String source) async {
    final data = _parseBackup(source);
    await _db.transaction(() async {
      for (final group in _sortGroups(data.groups)) {
        await _db
            .into(_db.groups)
            .insertOnConflictUpdate(group.toCompanion(false));
      }
      for (final subscription in data.subscriptions) {
        await _db
            .into(_db.subscriptions)
            .insertOnConflictUpdate(subscription.toCompanion(false));
      }
      for (final entry in data.priceHistory) {
        await _db
            .into(_db.priceHistory)
            .insertOnConflictUpdate(entry.toCompanion(false));
      }
      for (final rule in data.reminderRules) {
        await _db
            .into(_db.reminderRules)
            .insertOnConflictUpdate(rule.toCompanion(false));
      }
    });
    return ImportPreview(
      subscriptions: data.subscriptions.length,
      groups: data.groups.length,
      priceHistory: data.priceHistory.length,
      reminderRules: data.reminderRules.length,
    );
  }

  Future<String> exportSubscriptionsCsv() async {
    final subscriptions = await (_db.select(
      _db.subscriptions,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final groups = await (_db.select(
      _db.groups,
    )..where((tbl) => tbl.deletedAt.isNull())).get();
    final groupNames = {for (final group in groups) group.id: group.name};
    return buildSubscriptionsCsv(
      subscriptions,
      groupName: (id) => id == null ? '' : groupNames[id] ?? '',
    );
  }
}

class ImportPreview {
  const ImportPreview({
    required this.subscriptions,
    required this.groups,
    required this.priceHistory,
    required this.reminderRules,
  });

  final int subscriptions;
  final int groups;
  final int priceHistory;
  final int reminderRules;
}

class _BackupData {
  const _BackupData({
    required this.subscriptions,
    required this.groups,
    required this.priceHistory,
    required this.reminderRules,
  });

  final List<Subscription> subscriptions;
  final List<Group> groups;
  final List<PriceHistoryData> priceHistory;
  final List<ReminderRule> reminderRules;
}

_BackupData _parseBackup(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! Map<String, Object?>) {
    throw const FormatException('Backup root must be an object.');
  }
  if (decoded['format'] != BackupService.format) {
    throw const FormatException('Unsupported backup format.');
  }
  final version = decoded['version'];
  if (version is! int || version > BackupService.currentVersion) {
    throw const FormatException('Unsupported backup version.');
  }
  final data = decoded['data'];
  if (data is! Map<String, Object?>) {
    throw const FormatException('Backup data must be an object.');
  }

  return _BackupData(
    subscriptions: _parseRows(
      data['subscriptions'],
      (json) => Subscription.fromJson(_restoreSubscriptionJson(json)),
    ),
    groups: _parseRows(data['groups'], (json) => Group.fromJson(json)),
    priceHistory: _parseRows(
      data['price_history'],
      (json) => PriceHistoryData.fromJson(json),
    ),
    reminderRules: _parseRows(
      data['reminder_rules'],
      (json) => ReminderRule.fromJson(json),
    ),
  );
}

Map<String, dynamic> _jsonRow(Map<String, dynamic> row) {
  return row.map((key, value) {
    if (value is Enum) {
      return MapEntry(key, value.name);
    }
    return MapEntry(key, value);
  });
}

Map<String, dynamic> _restoreSubscriptionJson(Map<String, dynamic> row) {
  final isLegacy = !row.containsKey('startDate');
  final legacyTrialEnd = row['trialEndDate'];
  return {
    ...row,
    if (isLegacy) 'startDate': row['firstBillDate'],
    if (isLegacy && legacyTrialEnd is String) ...{
      'firstBillDate': legacyTrialEnd,
      'nextBillDate': legacyTrialEnd,
    },
    if (row['cycleUnit'] is String)
      'cycleUnit': CycleUnit.values.byName(row['cycleUnit'] as String),
    if (row['status'] is String)
      'status': SubscriptionStatus.values.byName(row['status'] as String),
  };
}

List<T> _parseRows<T>(
  Object? value,
  T Function(Map<String, dynamic> json) parse,
) {
  if (value is! List) {
    throw const FormatException('Backup table must be a list.');
  }
  return value.map((row) {
    if (row is! Map<String, Object?>) {
      throw const FormatException('Backup row must be an object.');
    }
    return parse(Map<String, dynamic>.from(row));
  }).toList();
}

List<Group> _sortGroups(List<Group> groups) {
  final byId = {for (final group in groups) group.id: group};
  final visited = <String>{};
  final sorted = <Group>[];

  void visit(Group group) {
    if (!visited.add(group.id)) {
      return;
    }
    final parentId = group.parentId;
    final parent = parentId == null ? null : byId[parentId];
    if (parent != null) {
      visit(parent);
    }
    sorted.add(group);
  }

  for (final group in groups) {
    visit(group);
  }
  return sorted;
}

String buildSubscriptionsCsv(
  List<Subscription> subscriptions, {
  required String Function(String? groupId) groupName,
}) {
  final rows = <List<String>>[
    [
      'name',
      'price',
      'currency',
      'cycle',
      'subscription_start',
      'first_charge',
      'trial_end',
      'next_renewal',
      'status',
      'group',
      'payment_method',
      'notes',
      'url',
    ],
    for (final subscription in subscriptions)
      [
        subscription.name,
        (subscription.priceMinor / 100).toStringAsFixed(2),
        subscription.currency,
        _cycle(subscription),
        subscription.startDate ?? subscription.firstBillDate,
        subscription.firstBillDate,
        subscription.trialEndDate ?? '',
        subscription.nextBillDate,
        subscription.status.name,
        groupName(subscription.groupId),
        subscription.paymentMethod ?? '',
        subscription.notes ?? '',
        subscription.manageUrl ?? '',
      ],
  ];

  return rows.map((row) => row.map(_csvEscape).join(',')).join('\n');
}

String _cycle(Subscription subscription) {
  final unit = subscription.cycleUnit.name;
  return subscription.cycleCount == 1
      ? unit
      : '${subscription.cycleCount} $unit';
}

String _csvEscape(String value) {
  final escaped = value.replaceAll('"', '""');
  if (escaped.contains(',') ||
      escaped.contains('"') ||
      escaped.contains('\n') ||
      escaped.contains('\r')) {
    return '"$escaped"';
  }
  return escaped;
}
