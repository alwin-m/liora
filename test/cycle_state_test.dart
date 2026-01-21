import 'package:flutter_test/flutter_test.dart';
import 'package:lioraa/core/cycle_state.dart';

void main() {
  group('CycleState Tests', () {
    test('Initial state should be valid', () {
      final state = CycleState();

      expect(state.bleedingState, BleedingState.noActiveBleeding);
      expect(state.averageCycleLength, 28);
      expect(state.averageBleedingLength, 5);
      expect(state.cycleHistory.isEmpty, true);
    });

    test('markPeriodStart should set active bleeding state', () {
      final state = CycleState();
      final startDate = DateTime(2026, 1, 15);

      state.markPeriodStart(startDate);

      expect(state.bleedingState, BleedingState.activeBleeding);
      expect(state.bleedingStartDate, startDate);
      expect(state.bleedingEndDate, isNull);
      expect(state.cycleHistory.length, 1);
      expect(state.cycleHistory.first.isConfirmed, false);
    });

    test('markPeriodStop should finalize cycle and update averages', () {
      final state = CycleState();
      final startDate = DateTime(2026, 1, 15);
      final stopDate = DateTime(2026, 1, 20); // 6 days

      state.markPeriodStart(startDate);
      state.markPeriodStop(stopDate);

      expect(state.bleedingState, BleedingState.noActiveBleeding);
      expect(state.bleedingEndDate, stopDate);
      expect(state.cycleHistory.first.isConfirmed, true);
      expect(state.cycleHistory.first.bleedingLength, 6);
    });

    test(
      'markPeriodStop should calculate cycle length from previous cycle',
      () {
        final state = CycleState();

        // First cycle: Jan 1-6 (5 days bleeding)
        state.markPeriodStart(DateTime(2026, 1, 1));
        state.markPeriodStop(DateTime(2026, 1, 6));

        // Second cycle: Jan 29 - Feb 3 (28 days apart)
        state.markPeriodStart(DateTime(2026, 1, 29));
        state.markPeriodStop(DateTime(2026, 2, 3));

        final secondCycle = state.cycleHistory[1];
        expect(secondCycle.cycleLength, 28);
        expect(secondCycle.bleedingLength, 6);
        expect(secondCycle.isConfirmed, true);
      },
    );

    test('Weighted averages should be calculated correctly', () {
      final state = CycleState();

      // Add 4 confirmed cycles
      for (int i = 0; i < 4; i++) {
        final startDate = DateTime(2026, 1, 1).add(Duration(days: i * 28));
        final stopDate = startDate.add(const Duration(days: 4));

        state.markPeriodStart(startDate);
        state.markPeriodStop(stopDate);
      }

      // Should have weighted averages calculated
      expect(state.averageCycleLength, greaterThan(0));
      expect(state.averageBleedingLength, greaterThan(0));
      expect(state.cycleHistory.length, 4);
    });

    test('fromJson should restore state correctly', () {
      final original = CycleState(
        bleedingState: BleedingState.noActiveBleeding,
        averageCycleLength: 30,
        averageBleedingLength: 6,
      );

      final json = original.toJson();
      final restored = CycleState.fromJson(json);

      expect(restored.averageCycleLength, 30);
      expect(restored.averageBleedingLength, 6);
      expect(restored.bleedingState, BleedingState.noActiveBleeding);
    });

    test('toJson should produce valid JSON', () {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 15));

      final json = state.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json.containsKey('bleedingState'), true);
      expect(json.containsKey('cycleHistory'), true);
      expect(json.containsKey('averageCycleLength'), true);
    });

    test('getLastConfirmedCycle should return null if none confirmed', () {
      final state = CycleState();
      expect(state.getLastConfirmedCycle(), isNull);
    });

    test('getLastConfirmedCycle should return latest confirmed cycle', () {
      final state = CycleState();

      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));

      final lastCycle = state.getLastConfirmedCycle();
      expect(lastCycle, isNotNull);
      expect(lastCycle!.isConfirmed, true);
    });
  });

  // ==================== NEW TESTS FOR ENHANCED FEATURES ====================

  group('CycleState Enhanced Features', () {
    test('isActiveBleeding getter should reflect bleeding state', () {
      final state = CycleState();

      expect(state.isActiveBleeding, false);

      state.markPeriodStart(DateTime(2026, 1, 15));
      expect(state.isActiveBleeding, true);

      state.markPeriodStop(DateTime(2026, 1, 20));
      expect(state.isActiveBleeding, false);
    });

    test('confirmedCycles getter should return only confirmed cycles', () {
      final state = CycleState();

      // First cycle - complete
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));

      // Second cycle - incomplete (no stop)
      state.markPeriodStart(DateTime(2026, 1, 29));

      expect(state.cycleHistory.length, 2);
      expect(state.confirmedCycles.length, 1);
    });

    test('getHistoricalBleedingRanges should return confirmed ranges', () {
      final state = CycleState();

      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));

      state.markPeriodStart(DateTime(2026, 1, 29));
      state.markPeriodStop(DateTime(2026, 2, 3));

      final ranges = state.getHistoricalBleedingRanges();
      expect(ranges.length, 2);
      expect(ranges[0].start, DateTime(2026, 1, 1));
      expect(ranges[0].end, DateTime(2026, 1, 6));
    });
  });

  group('CycleState Edge Cases', () {
    test('Short cycle (18 days) should be handled', () {
      final state = CycleState();

      // First cycle
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 4));

      // Second cycle - only 18 days later
      state.markPeriodStart(DateTime(2026, 1, 19));
      state.markPeriodStop(DateTime(2026, 1, 22));

      final secondCycle = state.cycleHistory[1];
      expect(secondCycle.cycleLength, 18);
      expect(state.averageCycleLength, greaterThanOrEqualTo(18));
    });

    test('Long cycle (40+ days) should be handled', () {
      final state = CycleState();

      // First cycle
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));

      // Second cycle - 42 days later
      state.markPeriodStart(DateTime(2026, 2, 12));
      state.markPeriodStop(DateTime(2026, 2, 17));

      final secondCycle = state.cycleHistory[1];
      expect(secondCycle.cycleLength, 42);
      expect(state.averageCycleLength, lessThanOrEqualTo(45));
    });

    test('Period starts earlier than predicted should accept reality', () {
      final state = CycleState();

      // First cycle
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5)); // 5 days

      // Predicted: Jan 29 (28 days later)
      // Actual: Jan 17 (16 days later - early!)
      state.markPeriodStart(DateTime(2026, 1, 17));
      state.markPeriodStop(DateTime(2026, 1, 21));

      final secondCycle = state.cycleHistory[1];
      expect(secondCycle.cycleLength, 16);
      expect(secondCycle.isConfirmed, true);

      // System accepts reality without arguing
      expect(state.confirmedCycles.length, 2);
    });

    test(
      'Period stops earlier than predicted should update bleeding average',
      () {
        final state = CycleState(defaultBleedingLength: 5);

        // Period starts
        state.markPeriodStart(DateTime(2026, 1, 15));

        // Period stops after only 3 days (shorter than default 5)
        state.markPeriodStop(DateTime(2026, 1, 17));

        final cycle = state.cycleHistory.first;
        expect(cycle.bleedingLength, 3);
      },
    );

    test('Two periods in same month should be allowed', () {
      final state = CycleState();

      // First period in January
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      // Second period in same January (very short cycle)
      state.markPeriodStart(DateTime(2026, 1, 19));
      state.markPeriodStop(DateTime(2026, 1, 23));

      expect(state.confirmedCycles.length, 2);
      expect(state.cycleHistory[1].cycleLength, 18);
    });
  });

  group('Weighted Average Calculation', () {
    test('Simple average for 3 or fewer cycles', () {
      final state = CycleState();

      // One cycle: 28 days, 5 days bleeding
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 5));

      // One confirmed cycle
      expect(state.averageCycleLength, 28); // Default since first cycle
      expect(state.averageBleedingLength, 5);
    });

    test('Weighted average prioritizes recent cycles', () {
      final state = CycleState();

      // Old cycles: 30 days each
      for (int i = 0; i < 3; i++) {
        final startDate = DateTime(2025, 1, 1).add(Duration(days: i * 30));
        state.markPeriodStart(startDate);
        state.markPeriodStop(startDate.add(const Duration(days: 5)));
      }

      // Recent cycles: 25 days each
      for (int i = 0; i < 3; i++) {
        final startDate = DateTime(2025, 4, 1).add(Duration(days: i * 25));
        state.markPeriodStart(startDate);
        state.markPeriodStop(startDate.add(const Duration(days: 4)));
      }

      // Average should lean towards 25 due to 60% weight on recent
      expect(state.averageCycleLength, lessThan(28));
    });
  });
}
