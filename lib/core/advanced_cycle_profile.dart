class AdvancedCycleProfile {
  // ================= BASIC CYCLE =================
  final DateTime lastPeriodDate;
  final int averageCycleLength;
  final int averagePeriodLength;

  // ================= BIO FACTORS =================
  final int age;
  final bool isRegularCycle;

  // ================= SYMPTOMS =================
  final int stressLevel;        // 0=low 1=medium 2=high
  final int painLevel;          // 0=low 1=medium 2=severe
  final int pmsSeverity;        // 0=none 1=mild 2=strong
  final int flowIntensity;      // 0=light 1=medium 2=heavy
  final bool ovulationSymptoms; // true if user notices ovulation signs

  // ================= LIFESTYLE =================
  final int sleepQuality;       // 0=poor 1=normal 2=good
  final int exerciseLevel;      // 0=none 1=moderate 2=regular
  final int bmiCategory;        // 0=underweight 1=normal 2=overweight

  // ================= MEDICAL =================
  final bool hasPCOS;
  final bool hasThyroid;
  final bool onHormonalMedication;
  final bool recentlyPregnant;
  final bool breastfeeding;

  // ================= CONSTRUCTOR =================
  const AdvancedCycleProfile({
    required this.lastPeriodDate,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.age,
    required this.isRegularCycle,
    required this.stressLevel,
    required this.painLevel,
    required this.pmsSeverity,
    required this.flowIntensity,
    required this.ovulationSymptoms,
    required this.sleepQuality,
    required this.exerciseLevel,
    required this.bmiCategory,
    required this.hasPCOS,
    required this.hasThyroid,
    required this.onHormonalMedication,
    required this.recentlyPregnant,
    required this.breastfeeding,
  });

  // ================= TO MAP (LOCAL STORAGE) =================
  Map<String, dynamic> toMap() {
    return {
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'averageCycleLength': averageCycleLength,
      'averagePeriodLength': averagePeriodLength,
      'age': age,
      'isRegularCycle': isRegularCycle,
      'stressLevel': stressLevel,
      'painLevel': painLevel,
      'pmsSeverity': pmsSeverity,
      'flowIntensity': flowIntensity,
      'ovulationSymptoms': ovulationSymptoms,
      'sleepQuality': sleepQuality,
      'exerciseLevel': exerciseLevel,
      'bmiCategory': bmiCategory,
      'hasPCOS': hasPCOS,
      'hasThyroid': hasThyroid,
      'onHormonalMedication': onHormonalMedication,
      'recentlyPregnant': recentlyPregnant,
      'breastfeeding': breastfeeding,
    };
  }

  // ================= FROM MAP =================
  factory AdvancedCycleProfile.fromMap(Map<String, dynamic> map) {
    return AdvancedCycleProfile(
      lastPeriodDate: DateTime.parse(map['lastPeriodDate']),
      averageCycleLength: map['averageCycleLength'],
      averagePeriodLength: map['averagePeriodLength'],
      age: map['age'],
      isRegularCycle: map['isRegularCycle'],
      stressLevel: map['stressLevel'],
      painLevel: map['painLevel'],
      pmsSeverity: map['pmsSeverity'],
      flowIntensity: map['flowIntensity'],
      ovulationSymptoms: map['ovulationSymptoms'],
      sleepQuality: map['sleepQuality'],
      exerciseLevel: map['exerciseLevel'],
      bmiCategory: map['bmiCategory'],
      hasPCOS: map['hasPCOS'],
      hasThyroid: map['hasThyroid'],
      onHormonalMedication: map['onHormonalMedication'],
      recentlyPregnant: map['recentlyPregnant'],
      breastfeeding: map['breastfeeding'],
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // ================= FROM JSON =================
  factory AdvancedCycleProfile.fromJson(Map<String, dynamic> json) {
    return AdvancedCycleProfile.fromMap(json);
  }
}