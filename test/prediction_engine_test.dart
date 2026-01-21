import 'package:flutter_test/flutter_test.dart';
import 'package:lioraa/core/cycle_state.dart';
import 'package:lioraa/core/cycle_history_entry.dart';
import 'package:lioraa/core/prediction_engine.dart';

void main() {
  group('PredictionEngine Tests', () {
    test('getDayType should return normal for empty state', () {
      final state = CycleState();
      final testDate = DateTime(2026, 2, 15);
      
      final dayType = PredictionEngine.getDayType(testDate, state);
      
      expect(dayType, DayType.normal);
    });

    test('getDayType should return period for active bleeding dates', () {
      final state = CycleState();
      final startDate = DateTime(2026, 1, 15);
      final endDate = DateTime(2026, 1, 20);
      
      state.markPeriodStart(startDate);
      state.markPeriodStop(endDate);
      
      // Test days during the period
      for (int i = 0; i <= 5; i++) {
        final testDate = startDate.add(Duration(days: i));
        final dayType = PredictionEngine.getDayType(testDate, state);
        expect(dayType, DayType.period, reason: 'Day $i should be period');
      }
    });

    test('getNextPeriodStart should calculate correctly', () {
      final state = CycleState();
      
      // Add a confirmed cycle
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));
      
      final nextStart = PredictionEngine.getNextPeriodStart(state);
      
      // Should be approximately 28 days after Jan 1
      expect(nextStart.month, 1);
      expect(nextStart.day, greaterThanOrEqualTo(25));
      expect(nextStart.day, lessThanOrEqualTo(31));
    });

    test('getNextPeriodEnd should calculate correctly', () {
      final state = CycleState();
      
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));
      
      final nextEnd = PredictionEngine.getNextPeriodEnd(state);
      final nextStart = PredictionEngine.getNextPeriodStart(state);
      
      // End should be after start
      expect(nextEnd.isAfter(nextStart), true);
      
      // Should be approximately 5 days after start
      final diff = nextEnd.difference(nextStart).inDays;
      expect(diff, greaterThanOrEqualTo(4));
      expect(diff, lessThanOrEqualTo(6));
    });

    test('getOvulationDate should be 14 days before next period start', () {
      final state = CycleState();
      
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));
      
      final ovulationDate = PredictionEngine.getOvulationDate(state);
      final nextStart = PredictionEngine.getNextPeriodStart(state);
      
      // Ovulation should be approximately 14 days before next period
      final diff = nextStart.difference(ovulationDate).inDays;
      expect(diff, greaterThanOrEqualTo(13));
      expect(diff, lessThanOrEqualTo(15));
    });

    test('getFertileWindow should span 5 days before ovulation', () {
      final state = CycleState();
      
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));
      
      final fertileWindow = PredictionEngine.getFertileWindow(state);
      final ovulationDate = PredictionEngine.getOvulationDate(state);
      
      // Window start should be 5 days before ovulation
      final daysBefore = ovulationDate.difference(fertileWindow.start).inDays;
      expect(daysBefore, greaterThanOrEqualTo(4));
      expect(daysBefore, lessThanOrEqualTo(6));
      
      // Window end should be on or after ovulation
      expect(fertileWindow.end.isAfter(ovulationDate) || 
             fertileWindow.end.isAtSameMomentAs(ovulationDate), true);
    });

    test('getDayType should prioritize confirmed period over predictions', () {
      final state = CycleState();
      
      // Mark period
      final startDate = DateTime(2026, 1, 15);
      final endDate = DateTime(2026, 1, 20);
      
      state.markPeriodStart(startDate);
      state.markPeriodStop(endDate);
      
      // Get day type for confirmed period
      final dayType = PredictionEngine.getDayType(startDate, state);
      
      // Should be period, not predicted
      expect(dayType, DayType.period);
    });

    test('getDayType should return ovulation for predicted ovulation date', () {
      final state = CycleState();
      
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));
      
      final ovulationDate = PredictionEngine.getOvulationDate(state);
      final dayType = PredictionEngine.getDayType(ovulationDate, state);
      
      expect(dayType, DayType.ovulation);
    });

    test('getDayType should return fertile for fertile window dates', () {
      final state = CycleState();
      
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));
      
      final fertileWindow = PredictionEngine.getFertileWindow(state);
      final testDate = fertileWindow.start.add(const Duration(days: 1));
      final dayType = PredictionEngine.getDayType(testDate, state);
      
      expect(dayType, DayType.fertile);
    });
  });
}
