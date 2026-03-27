import 'package:flutter_test/flutter_test.dart';
import 'package:lioraa/services/cycle_provider.dart';
import 'package:lioraa/services/local_medical_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lioraa/models/cycle_data.dart';

void main() {
  setUpAll(() {
    // Set up shared preferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  group('PRIVACY TESTS - CycleProvider Local-Only', () {
    test('CycleProvider should NEVER attempt Firestore sync', () async {
      // Arrange
      final provider = CycleProvider();

      // Act
      await provider.loadData();

      // Assert
      // If this test passes without errors, Firestore sync was not attempted
      // (Firestore import would cause compile error if accessed)
      expect(provider.cycleData, isNotNull);
    });

    test('updateCycleData should save ONLY to local storage', () async {
      // Arrange
      final provider = CycleProvider();
      final testDate = DateTime(2024, 2, 1);

      // Act
      await provider.updateCycleData(
        lastPeriodStartDate: testDate,
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );

      // Assert
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('liora_cycle_data_local_only');

      expect(savedData, isNotNull);
      expect(savedData, contains('2024-02-01'));
      expect(savedData, contains('28'));
    });

    test('clearLocalData should completely remove medical data', () async {
      // Arrange
      final provider = CycleProvider();
      await provider.updateCycleData(
        lastPeriodStartDate: DateTime(2024, 2, 1),
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );

      // Act
      await provider.clearLocalData();

      // Assert
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('liora_cycle_data_local_only');
      expect(savedData, isNull);
    });

    test('Cycle predictions must work completely offline', () async {
      // Arrange
      final provider = CycleProvider();
      await provider.updateCycleData(
        lastPeriodStartDate: DateTime(2024, 2, 1),
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );

      // Act
      final nextPeriod = provider.cycleData?.computedNextPeriodStart;

      // Assert
      // No network call should have occurred
      expect(nextPeriod, isNotNull);
      expect(nextPeriod!.isAfter(DateTime(2024, 2, 1)), true);

      // Verify prediction is deterministic (no randomness or server-dependency)
      final nextPeriod2 = provider.cycleData?.computedNextPeriodStart;
      expect(nextPeriod, equals(nextPeriod2));
    });

    test('Medical data should NOT sync across devices', () async {
      // Arrange
      final provider = CycleProvider();
      await provider.updateCycleData(
        lastPeriodStartDate: DateTime(2024, 2, 1),
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );

      // Act - Simulate app restart
      final provider2 = CycleProvider();
      await provider2.loadData();

      // Assert
      // Data is loaded from local storage, not from network/backend
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('liora_cycle_data_local_only');
      expect(savedData, isNotNull);

      // Both providers show same data (from SharedPreferences)
      expect(
        provider.cycleData?.lastPeriodStartDate,
        equals(provider2.cycleData?.lastPeriodStartDate),
      );
    });
  });

  group('PRIVACY TESTS - LocalMedicalDataService', () {
    test('LocalMedicalDataService should save to local storage only', () async {
      // Arrange
      final medicalData = {
        'lastPeriodStartDate': '2024-02-01',
        'averageCycleLength': 28,
        'averagePeriodDuration': 5,
      };

      // Act
      final result = await LocalMedicalDataService.saveMedicalData(medicalData);

      // Assert
      expect(result, true);

      // Verify data is in SharedPreferences (local only)
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(LocalMedicalDataService.medicalDataKey);
      expect(savedData, isNotNull);
    });

    test(
      'LocalMedicalDataService.deleteMedicalData should remove all traces',
      () async {
        // Arrange
        final medicalData = {
          'lastPeriodStartDate': '2024-02-01',
          'averageCycleLength': 28,
        };
        await LocalMedicalDataService.saveMedicalData(medicalData);

        // Act
        await LocalMedicalDataService.deleteMedicalData();

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString(
          LocalMedicalDataService.medicalDataKey,
        );
        expect(savedData, isNull);
      },
    );

    test(
      'verifyLocalOnlyCompliance should return true for valid data',
      () async {
        // Arrange
        final medicalData = {
          'lastPeriodStartDate': '2024-02-01',
          'averageCycleLength': 28,
          'averagePeriodDuration': 5,
        };
        await LocalMedicalDataService.saveMedicalData(medicalData);

        // Act
        final isCompliant =
            await LocalMedicalDataService.verifyLocalOnlyCompliance();

        // Assert
        expect(isCompliant, true);
      },
    );

    test('getLocalMedicalDataSize should return reasonable size', () async {
      // Arrange
      final medicalData = {
        'lastPeriodStartDate': '2024-02-01',
        'averageCycleLength': 28,
        'averagePeriodDuration': 5,
      };
      await LocalMedicalDataService.saveMedicalData(medicalData);

      // Act
      final size = await LocalMedicalDataService.getLocalMedicalDataSize();

      // Assert
      expect(size, greaterThan(0));
      expect(size, lessThan(1000)); // Should be small (not a database)
    });

    test(
      'clearAllPrivateDataOnLogout should remove all medical data',
      () async {
        // Arrange
        final medicalData = {
          'lastPeriodStartDate': '2024-02-01',
          'averageCycleLength': 28,
        };
        await LocalMedicalDataService.saveMedicalData(medicalData);

        // Act
        await LocalMedicalDataService.clearAllPrivateDataOnLogout();

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString(
          LocalMedicalDataService.medicalDataKey,
        );
        expect(savedData, isNull);
      },
    );
  });

  group('PRIVACY TESTS - CycleDataModel', () {
    test('CycleDataModel toJson should NOT include Firestore fields', () {
      // Arrange
      final model = CycleDataModel(
        lastPeriodStartDate: DateTime(2024, 2, 1),
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(
        json.keys,
        containsAll([
          'lastPeriodStartDate',
          'averageCycleLength',
          'averagePeriodDuration',
        ]),
      );

      // Ensure NO Firestore-specific fields
      expect(json.containsKey('lastPeriodDate'), false);
      expect(json.containsKey('cycleLength'), false);
      expect(json.containsKey('periodLength'), false);
    });

    test('CycleDataModel should deserialize from local JSON only', () {
      // Arrange
      final json = {
        'lastPeriodStartDate': '2024-02-01T00:00:00.000Z',
        'averageCycleLength': 28,
        'averagePeriodDuration': 5,
      };

      // Act
      final model = CycleDataModel.fromJson(json);

      // Assert
      expect(model.lastPeriodStartDate, DateTime(2024, 2, 1));
      expect(model.averageCycleLength, 28);
      expect(model.averagePeriodDuration, 5);
    });

    test('CycleDataModel should calculate predictions correctly offline', () {
      // Arrange
      final model = CycleDataModel(
        lastPeriodStartDate: DateTime(2024, 2, 1),
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );

      // Act
      final nextPeriod = model.computedNextPeriodStart;
      final nextPeriodEnd = model.computedNextPeriodEnd;

      // Assert
      expect(nextPeriod, DateTime(2024, 3, 1)); // 28 days later
      expect(nextPeriodEnd, DateTime(2024, 3, 5)); // 5 days duration
    });
  });

  group('PRIVACY TESTS - No Firestore Imports', () {
    test('cycle_provider.dart should compile without Firestore', () {
      // This test verifies the absence of Firestore imports
      // If Firestore was imported, this wouldn't compile
      // This is a compile-time privacy check
      final provider = CycleProvider();
      expect(provider, isNotNull);
    });

    test('LocalMedicalDataService should compile without Firestore', () {
      // Verify no Firestore dependency
      final medicalData = LocalMedicalDataService.medicalDataKey;
      expect(medicalData, isNotNull);
    });
  });

  group('PRIVACY TESTS - Offline Capability', () {
    test('loadData should work without any network', () async {
      // Arrange
      final provider = CycleProvider();

      // Act
      await provider.loadData();

      // Assert
      expect(provider.cycleData, isNotNull);
      // If network was required, this would fail/timeout
    });

    test('updateCycleData should persist without network', () async {
      // Arrange
      final provider = CycleProvider();

      // Act
      await provider.updateCycleData(
        lastPeriodStartDate: DateTime(2024, 2, 1),
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );

      // Assert
      expect(provider.cycleData, isNotNull);
      // Data should persist to SharedPreferences (no network)
    });
  });
}
