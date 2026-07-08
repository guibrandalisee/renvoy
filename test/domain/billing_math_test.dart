import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/domain/billing/billing_math.dart';
import 'package:renvoy/domain/models/enums.dart';

void main() {
  group('addCycle', () {
    test('adds one cycle with calendar clamping', () {
      expect(
        addCycle(_date(2026, 1, 31), CycleUnit.month, 1),
        _date(2026, 2, 28),
      );
      expect(
        addCycle(_date(2024, 1, 31), CycleUnit.month, 1),
        _date(2024, 2, 29),
      );
      expect(
        addCycle(_date(2024, 2, 29), CycleUnit.year, 1),
        _date(2025, 2, 28),
      );
    });

    test('adds day and week cycles by duration', () {
      expect(addCycle(_date(2026, 1, 1), CycleUnit.day, 90), _date(2026, 4, 1));
      expect(
        addCycle(_date(2026, 1, 1), CycleUnit.week, 2),
        _date(2026, 1, 15),
      );
    });
  });

  group('anchored billing dates', () {
    test('monthly bills clamp per target month without drifting', () {
      final firstBill = _date(2026, 1, 31);

      expect(nthBill(firstBill, CycleUnit.month, 1, 1), _date(2026, 2, 28));
      expect(nthBill(firstBill, CycleUnit.month, 1, 2), _date(2026, 3, 31));
      expect(nthBill(firstBill, CycleUnit.month, 1, 3), _date(2026, 4, 30));
    });

    test('monthly bills clamp to leap day in leap years', () {
      expect(
        nthBill(_date(2024, 1, 31), CycleUnit.month, 1, 1),
        _date(2024, 2, 29),
      );
    });

    test('yearly bills clamp leap day and recover in leap years', () {
      final firstBill = _date(2024, 2, 29);

      expect(nthBill(firstBill, CycleUnit.year, 1, 1), _date(2025, 2, 28));
      expect(nthBill(firstBill, CycleUnit.year, 1, 4), _date(2028, 2, 29));
    });

    test('supports weekly, daily, and custom counts', () {
      expect(
        nthBill(_date(2026, 1, 1), CycleUnit.week, 2, 1),
        _date(2026, 1, 15),
      );
      expect(
        nthBill(_date(2026, 1, 31), CycleUnit.month, 3, 1),
        _date(2026, 4, 30),
      );
      expect(
        nthBill(_date(2026, 1, 1), CycleUnit.day, 90, 1),
        _date(2026, 4, 1),
      );
    });
  });

  group('nextBillOnOrAfter', () {
    test('returns today when today is a bill date', () {
      expect(
        nextBillOnOrAfter(
          _date(2026, 1, 31),
          CycleUnit.month,
          1,
          _date(2026, 2, 28),
        ),
        _date(2026, 2, 28),
      );
    });

    test('returns the next bill when today is one day after a bill date', () {
      expect(
        nextBillOnOrAfter(
          _date(2026, 1, 31),
          CycleUnit.month,
          1,
          _date(2026, 3, 1),
        ),
        _date(2026, 3, 31),
      );
    });

    test('computes correctly when first bill is years in the past', () {
      expect(
        nextBillOnOrAfter(
          _date(2016, 1, 31),
          CycleUnit.month,
          1,
          _date(2026, 3, 1),
        ),
        _date(2026, 3, 31),
      );
    });

    test('returns first bill when it is in the future', () {
      expect(
        nextBillOnOrAfter(
          _date(2026, 12, 1),
          CycleUnit.month,
          1,
          _date(2026, 3, 1),
        ),
        _date(2026, 12, 1),
      );
    });
  });

  group('equivalent prices', () {
    test('normalizes yearly price to monthly equivalent', () {
      expect(
        monthlyEquivalentMinor(1299, CycleUnit.year, 1),
        closeTo(108.25, 0.0001),
      );
    });

    test('normalizes weekly price to monthly equivalent', () {
      expect(
        monthlyEquivalentMinor(1000, CycleUnit.week, 1),
        closeTo(4348.214, 0.001),
      );
    });

    test('normalizes every two months to monthly equivalent', () {
      expect(monthlyEquivalentMinor(2000, CycleUnit.month, 2), 1000);
    });

    test('normalizes yearly equivalent from monthly equivalent', () {
      expect(yearlyEquivalentMinor(2000, CycleUnit.month, 2), 12000);
    });
  });

  test('isInTrial is true until but not including trial end date', () {
    expect(isInTrial(_date(2026, 2, 1), _date(2026, 1, 31)), isTrue);
    expect(isInTrial(_date(2026, 2, 1), _date(2026, 2, 1)), isFalse);
    expect(isInTrial(null, _date(2026, 1, 31)), isFalse);
  });

  test('billsBetween counts start inclusive and end exclusive', () {
    expect(
      billsBetween(
        _date(2026, 1, 31),
        CycleUnit.month,
        1,
        _date(2026, 2, 28),
        _date(2026, 4, 30),
      ),
      2,
    );
  });
}

DateTime _date(int year, int month, int day) => DateTime.utc(year, month, day);
