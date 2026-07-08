part of '../database.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Stream<String?> watchValue(String key) {
    final query = select(settings)..where((tbl) => tbl.key.equals(key));
    return query.watchSingleOrNull().map((setting) => setting?.value);
  }

  Future<String?> getValue(String key) {
    final query = select(settings)..where((tbl) => tbl.key.equals(key));
    return query.map((setting) => setting.value).getSingleOrNull();
  }

  Future<void> setValue(String key, String value) {
    return into(
      settings,
    ).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
  }
}
