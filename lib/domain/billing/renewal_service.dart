import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/db/database_provider.dart';
import 'billing_math.dart';

final renewalServiceProvider = Provider<RenewalService>(
  (ref) => RenewalService(ref.watch(databaseProvider)),
);

class RenewalService {
  RenewalService(this._db);

  final AppDatabase _db;

  Future<int> rollForward(DateTime today) {
    final normalizedToday = dateOnlyUtc(today);
    final todayText = _formatDateOnly(normalizedToday);

    return _db.transaction(() async {
      final rows = await _db.subscriptionsDao.renewalCandidates(todayText);
      var updated = 0;

      for (final row in rows) {
        final nextBill = _parseDateOnly(row.nextBillDate);
        final trialEnd = row.trialEndDate == null
            ? null
            : _parseDateOnly(row.trialEndDate!);
        final shouldRollForward = nextBill.isBefore(normalizedToday);
        final shouldClearTrial =
            trialEnd != null && !trialEnd.isAfter(normalizedToday);

        if (!shouldRollForward && !shouldClearTrial) {
          continue;
        }

        final newNextBillDate = shouldRollForward
            ? _formatDateOnly(
                nextBillOnOrAfter(
                  _parseDateOnly(row.firstBillDate),
                  row.cycleUnit,
                  row.cycleCount,
                  normalizedToday,
                ),
              )
            : null;

        updated += await _db.subscriptionsDao.updateBillingState(
          id: row.id,
          nextBillDate: newNextBillDate,
          clearTrialEndDate: shouldClearTrial,
        );
      }

      return updated;
    });
  }
}

DateTime _parseDateOnly(String value) {
  final parts = value.split('-');
  if (parts.length != 3) {
    throw FormatException('Expected yyyy-mm-dd date', value);
  }

  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

String _formatDateOnly(DateTime value) {
  final date = dateOnlyUtc(value);
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
