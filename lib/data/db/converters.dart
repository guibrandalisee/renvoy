import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';

class CycleUnitConverter extends TypeConverter<CycleUnit, String> {
  const CycleUnitConverter();

  @override
  CycleUnit fromSql(String fromDb) => CycleUnit.fromDb(fromDb);

  @override
  String toSql(CycleUnit value) => value.toDb;
}

class SubscriptionStatusConverter
    extends TypeConverter<SubscriptionStatus, String> {
  const SubscriptionStatusConverter();

  @override
  SubscriptionStatus fromSql(String fromDb) =>
      SubscriptionStatus.fromDb(fromDb);

  @override
  String toSql(SubscriptionStatus value) => value.toDb;
}
