
class AdvancedCycleProfile {
  final DateTime lastPeriodDate;
  final int averageCycleLength;
  final int averagePeriodLength;

  // ================= BIO FACTORS =================
  final DateTime? dateOfBirth; 
  final int age;
  final bool isRegularCycle;
  final double weight;      // in kg
  final double height;      // in cm

  // ================= DEFICIENCIES =================
  final List<String> deficiencies; // e.g., ["Iron", "Vitamin B"]

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
    this.dateOfBirth,
    required this.age,
    required this.isRegularCycle,
    this.weight = 60.0,
    this.height = 163.0,
    this.deficiencies = const [],
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

  // ================= COMPUTED =================
  int get calculatedAge {
    if (dateOfBirth == null) return age;
    final now = DateTime.now();
    int currentAge = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      currentAge--;
    }
    return currentAge;
  }

  double get bmi {
    if (height <= 0) return 0;
    final hMeter = height / 100;
    return weight / (hMeter * hMeter);
  }

  String get bmiStatus {
    final b = bmi;
    if (b < 18.5) return "Underweight";
    if (b < 25) return "Normal";
    if (b < 30) return "Overweight";
    return "Obese";
  }

  // ================= TO MAP (LOCAL STORAGE) =================
  Map<String, dynamic> toMap() {
    return {
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'averageCycleLength': averageCycleLength,
      'averagePeriodLength': averagePeriodLength,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'age': age,
      'isRegularCycle': isRegularCycle,
      'weight': weight,
      'height': height,
      'deficiencies': deficiencies,
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
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      age: map['age'],
      isRegularCycle: map['isRegularCycle'],
      weight: map['weight']?.toDouble() ?? 60.0,
      height: map['height']?.toDouble() ?? 163.0,
      deficiencies: List<String>.from(map['deficiencies'] ?? []),
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

  AdvancedCycleProfile copyWith({
    DateTime? lastPeriodDate,
    int? averageCycleLength,
    int? averagePeriodLength,
    DateTime? dateOfBirth,
    int? age,
    bool? isRegularCycle,
    double? weight,
    double? height,
    List<String>? deficiencies,
    int? stressLevel,
    int? painLevel,
    int? pmsSeverity,
    int? flowIntensity,
    bool? ovulationSymptoms,
    int? sleepQuality,
    int? exerciseLevel,
    int? bmiCategory,
    bool? hasPCOS,
    bool? hasThyroid,
    bool? onHormonalMedication,
    bool? recentlyPregnant,
    bool? breastfeeding,
  }) {
    return AdvancedCycleProfile(
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      isRegularCycle: isRegularCycle ?? this.isRegularCycle,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      deficiencies: deficiencies ?? this.deficiencies,
      stressLevel: stressLevel ?? this.stressLevel,
      painLevel: painLevel ?? this.painLevel,
      pmsSeverity: pmsSeverity ?? this.pmsSeverity,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      ovulationSymptoms: ovulationSymptoms ?? this.ovulationSymptoms,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      exerciseLevel: exerciseLevel ?? this.exerciseLevel,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      hasPCOS: hasPCOS ?? this.hasPCOS,
      hasThyroid: hasThyroid ?? this.hasThyroid,
      onHormonalMedication: onHormonalMedication ?? this.onHormonalMedication,
      recentlyPregnant: recentlyPregnant ?? this.recentlyPregnant,
      breastfeeding: breastfeeding ?? this.breastfeeding,
    );
  }
}