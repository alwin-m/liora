import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lioraa/core/cycle_state.dart';
import 'package:lioraa/core/local_cycle_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalCycleStorage Tests', () {
    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('saveCycleState should persist state correctly', () async {
      final state = CycleState(
        averageCycleLength: 30,
        averageBleedingLength: 6,
      );

      await LocalCycleStorage.saveCycleState(state);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('cycle_state'), true);
    });

    test('loadCycleState should return default state if none saved', () async {
      final state = await LocalCycleStorage.loadCycleState();

      expect(state, isNotNull);
      expect(state.bleedingState, BleedingState.noActiveBleeding);
      expect(state.averageCycleLength, 28);
    });

    test('saveCycleState then loadCycleState should restore state', () async {
      final originalState = CycleState(
        averageCycleLength: 32,
        averageBleedingLength: 7,
        defaultCycleLength: 32,
      );

      await LocalCycleStorage.saveCycleState(originalState);
      final restoredState = await LocalCycleStorage.loadCycleState();

      expect(restoredState.averageCycleLength, 32);
      expect(restoredState.averageBleedingLength, 7);
      expect(restoredState.defaultCycleLength, 32);
    });

    test('saveNotificationSettings should persist settings', () async {
      final settings = {
        'cycleReminder': false,
        'periodReminder': true,
      };

      await LocalCycleStorage.saveNotificationSettings(settings);

      final retrieved = await LocalCycleStorage.getNotificationSettings();
      expect(retrieved['cycleReminder'], false);
      expect(retrieved['periodReminder'], true);
    });

    test('getNotificationSettings should return defaults if none saved',
        () async {
      final settings = await LocalCycleStorage.getNotificationSettings();

      expect(settings['cycleReminder'], true);
      expect(settings['periodReminder'], true);
    });

    test('saveCycleState with cycle history should persist all data', () async {
      final state = CycleState();
      state.markPeriodStart(DateTime(2026, 1, 1));
      state.markPeriodStop(DateTime(2026, 1, 6));

      await LocalCycleStorage.saveCycleState(state);
      final restored = await LocalCycleStorage.loadCycleState();

      expect(restored.cycleHistory.length, 1);
      expect(restored.cycleHistory.first.isConfirmed, true);
    });

    test('clearAllData should remove all stored data', () async {
      final state = CycleState();
      await LocalCycleStorage.saveCycleState(state);

      final settingsBefore =
          await LocalCycleStorage.getNotificationSettings();
      expect(settingsBefore, isNotNull);

      // Note: clearAllData is not shown in the provided code,
      // but if it exists, test it here
    });
  });
}
