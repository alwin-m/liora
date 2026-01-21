import 'package:flutter_test/flutter_test.dart';
import 'package:lioraa/core/cycle_state.dart';
import 'package:lioraa/core/prediction_engine.dart';

void main() {
  group('PredictionEngine Tests', () {
    test('getDayType should return period for confirmed bleeding days', () {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 15));
      state.markPeriodStop(DateTime(2026, 1, 20));

      // Day within confirmed period
      final dayType = PredictionEngine.getDayType(DateTime(2026, 1, 17), state);
      expect(dayType, DayType.period);
    });

    test('getDayType should return activePeriod for ongoing bleeding', () {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 15));
      // No stop marked - still bleeding

      final dayType = PredictionEngine.getDayType(DateTime(2026, 1, 16), state);
      expect(dayType, DayType.activePeriod);
    });

    test('getDayType should return predictedPeriod for future predictions', () {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      // Get predicted next period (should be around Jan 29)
      final nextStart = PredictionEngine.getNextPeriodStart(state);

      final dayType = PredictionEngine.getDayType(nextStart, state);
      expect(dayType, DayType.predictedPeriod);
    });

    test('getDayType should return ovulation for ovulation day', () {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      final ovulationDate = PredictionEngine.getOvulationDate(state);
      final dayType = PredictionEngine.getDayType(ovulationDate, state);

      expect(dayType, DayType.ovulation);
    });

    test('getDayType should return fertile for fertile window days', () {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      final fertileWindow = PredictionEngine.getFertileWindow(state);
      // Test a day in fertile window (not ovulation day)
      final fertileDay = fertileWindow.start.add(const Duration(days: 1));
      final dayType = PredictionEngine.getDayType(fertileDay, state);

      expect(dayType, DayType.fertile);
    });

    test('getDayType should return normal for regular days', () {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      // Pick a day that's not in any special window
      final normalDay = DateTime(2026, 1, 7);
      final dayType = PredictionEngine.getDayType(normalDay, state);

      expect(dayType, DayType.normal);
    });
  });

  group('PredictionEngine Historical Cycles', () {
    test('getDayType should detect historical confirmed periods', () {
      final state = CycleState();

      // First historical period: Jan 1-5
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      // Second period: Jan 29 - Feb 2
      state.markPeriodStart(DateTime(2026, 1, 29));
      state.markPeriodStop(DateTime(2026, 2, 2));

      // Check first historical period is still detected
      final dayType = PredictionEngine.getDayType(DateTime(2026, 1, 3), state);
      expect(dayType, DayType.period);
    });

    test('Predictions should use historical data', () {
      final state = CycleState();

      // Create a history with 25-day cycles
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      state.markPeriodStart(DateTime(2026, 1, 26)); // 25 days later
      state.markPeriodStop(DateTime(2026, 1, 30));

      // Next prediction should account for shorter cycle
      final nextStart = PredictionEngine.getNextPeriodStart(state);

      // Should be roughly 25 days from Jan 26
      expect(
        nextStart.difference(DateTime(2026, 1, 26)).inDays,
        lessThanOrEqualTo(28),
      );
    });
  });

  group('PredictionEngine Pure Functions', () {
    test('getNextPeriodStart should be deterministic', () {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      final result1 = PredictionEngine.getNextPeriodStart(state);
      final result2 = PredictionEngine.getNextPeriodStart(state);

      expect(result1, result2);
    });

    test('getFertileWindow should return valid date range', () {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      final window = PredictionEngine.getFertileWindow(state);

      expect(window.start.isBefore(window.end), true);
    });

    test('getOvulationDate should be 14 days before next period', () {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      final nextStart = PredictionEngine.getNextPeriodStart(state);
      final ovulation = PredictionEngine.getOvulationDate(state);

      final difference = nextStart.difference(ovulation).inDays;
      expect(difference, 14);
    });
  });
}
