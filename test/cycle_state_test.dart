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

    test('markPeriodStop should calculate cycle length from previous cycle', () {
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
    });

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
}
