import '../models/enums.dart';

const double _averageDaysPerMonth = 365.25 / 12;
const double _averageWeeksPerMonth = 52.17857142857143 / 12;

DateTime addCycle(DateTime date, CycleUnit unit, int count) {
  _checkPositiveCount(count);
  final normalized = dateOnlyUtc(date);

  return switch (unit) {
    CycleUnit.day => normalized.add(Duration(days: count)),
    CycleUnit.week => normalized.add(Duration(days: 7 * count)),
    CycleUnit.month => _addMonths(normalized, count),
    CycleUnit.year => _addYears(normalized, count),
  };
}

DateTime nthBill(DateTime firstBill, CycleUnit unit, int count, int n) {
  _checkPositiveCount(count);
  if (n < 0) {
    throw ArgumentError.value(n, 'n', 'Must be zero or greater');
  }

  final anchor = dateOnlyUtc(firstBill);
  final cycles = count * n;

  return switch (unit) {
    CycleUnit.day => anchor.add(Duration(days: cycles)),
    CycleUnit.week => anchor.add(Duration(days: 7 * cycles)),
    CycleUnit.month => _addMonths(anchor, cycles),
    CycleUnit.year => _addYears(anchor, cycles),
  };
}

DateTime nextBillOnOrAfter(
  DateTime firstBill,
  CycleUnit unit,
  int count,
  DateTime today,
) {
  _checkPositiveCount(count);
  final anchor = dateOnlyUtc(firstBill);
  final target = dateOnlyUtc(today);

  if (!anchor.isBefore(target)) {
    return anchor;
  }

  var n = switch (unit) {
    CycleUnit.day => _ceilDiv(target.difference(anchor).inDays, count),
    CycleUnit.week => _ceilDiv(target.difference(anchor).inDays, 7 * count),
    CycleUnit.month => _monthsBetween(anchor, target) ~/ count,
    CycleUnit.year => (target.year - anchor.year) ~/ count,
  };

  if (n < 0) {
    n = 0;
  }

  while (n > 0 && !nthBill(anchor, unit, count, n - 1).isBefore(target)) {
    n--;
  }
  while (nthBill(anchor, unit, count, n).isBefore(target)) {
    n++;
  }

  return nthBill(anchor, unit, count, n);
}

int billsBetween(
  DateTime firstBill,
  CycleUnit unit,
  int count,
  DateTime startInclusive,
  DateTime endExclusive,
) {
  final start = dateOnlyUtc(startInclusive);
  final end = dateOnlyUtc(endExclusive);
  if (!end.isAfter(start)) {
    return 0;
  }

  final firstInRange = nextBillOnOrAfter(firstBill, unit, count, start);
  if (!firstInRange.isBefore(end)) {
    return 0;
  }

  final firstIndex = _billIndex(firstBill, unit, count, firstInRange);
  final endIndex = _billIndex(
    firstBill,
    unit,
    count,
    nextBillOnOrAfter(firstBill, unit, count, end),
  );

  return endIndex - firstIndex;
}

double monthlyEquivalentMinor(int priceMinor, CycleUnit unit, int count) {
  _checkPositiveCount(count);

  final cyclesPerMonth = switch (unit) {
    // 365.25 days / 12 months.
    CycleUnit.day => _averageDaysPerMonth / count,
    // 52.178571 weeks / 12 months.
    CycleUnit.week => _averageWeeksPerMonth / count,
    CycleUnit.month => 1 / count,
    CycleUnit.year => 1 / (12 * count),
  };

  return priceMinor * cyclesPerMonth;
}

double yearlyEquivalentMinor(int priceMinor, CycleUnit unit, int count) {
  return monthlyEquivalentMinor(priceMinor, unit, count) * 12;
}

bool isInTrial(DateTime? trialEndDate, DateTime today) {
  return trialEndDate != null &&
      dateOnlyUtc(today).isBefore(dateOnlyUtc(trialEndDate));
}

DateTime dateOnlyUtc(DateTime value) {
  final utc = value.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day);
}

DateTime _addMonths(DateTime date, int months) {
  final monthIndex = date.year * 12 + (date.month - 1) + months;
  final year = _floorDiv(monthIndex, 12);
  final month = monthIndex - year * 12 + 1;
  final lastDay = _lastDayOfMonth(year, month);
  final day = date.day > lastDay ? lastDay : date.day;

  return DateTime.utc(year, month, day);
}

DateTime _addYears(DateTime date, int years) {
  final year = date.year + years;
  final lastDay = _lastDayOfMonth(year, date.month);
  final day = date.day > lastDay ? lastDay : date.day;

  return DateTime.utc(year, date.month, day);
}

int _billIndex(DateTime firstBill, CycleUnit unit, int count, DateTime bill) {
  var low = 0;
  var high = switch (unit) {
    CycleUnit.day =>
      bill.difference(dateOnlyUtc(firstBill)).inDays ~/ count + 1,
    CycleUnit.week =>
      bill.difference(dateOnlyUtc(firstBill)).inDays ~/ (7 * count) + 1,
    CycleUnit.month =>
      _monthsBetween(dateOnlyUtc(firstBill), bill) ~/ count + 1,
    CycleUnit.year => (bill.year - dateOnlyUtc(firstBill).year) ~/ count + 1,
  };

  while (low <= high) {
    final mid = low + ((high - low) ~/ 2);
    final candidate = nthBill(firstBill, unit, count, mid);
    if (candidate == bill) {
      return mid;
    }
    if (candidate.isBefore(bill)) {
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }

  return low;
}

int _ceilDiv(int a, int b) => (a + b - 1) ~/ b;

int _floorDiv(int a, int b) {
  final quotient = a ~/ b;
  final remainder = a % b;
  return remainder == 0 || a >= 0 ? quotient : quotient - 1;
}

int _monthsBetween(DateTime start, DateTime end) {
  return (end.year - start.year) * 12 + end.month - start.month;
}

int _lastDayOfMonth(int year, int month) {
  return DateTime.utc(year, month + 1, 0).day;
}

void _checkPositiveCount(int count) {
  if (count <= 0) {
    throw ArgumentError.value(count, 'count', 'Must be greater than zero');
  }
}
