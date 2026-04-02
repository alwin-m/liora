import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/cycle_session.dart';
import '../core/advanced_cycle_profile.dart';

class PersonalizedDietSheet extends StatefulWidget {
  final VoidCallback onUpdated;
  const PersonalizedDietSheet({super.key, required this.onUpdated});

  @override
  State<PersonalizedDietSheet> createState() => _PersonalizedDietSheetState();
}

class _PersonalizedDietSheetState extends State<PersonalizedDietSheet> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late double weight;
  late double height;
  late int age;
  late String region;
  DateTime? dateOfBirth;
  List<String> selectedDeficiencies = [];

  final List<String> vitaminOptions = [
    "Vitamin A", "Vitamin B", "Vitamin C", "Vitamin D", "Vitamin E",
    "Iron", "Calcium", "Zinc", "Magnesium"
  ];

  final List<Map<String, String>> regionOptions = [
    {"id": "Kerala", "name": "India (Kerala) 🍛", "desc": "Rice, Appam, Fish & Spicy items"},
    {"id": "USA", "name": "United States 🇺🇸", "desc": "Whole grains, Salmon, Salads"},
    {"id": "Germany", "name": "Germany (EU) 🥨", "desc": "Rye bread, Sauerkraut, Potatoes"},
    {"id": "Global", "name": "Global / Standard 🌍", "desc": "Mediterranean / General health"},
  ];

  @override
  void initState() {
    super.initState();
    final profile = CycleSession.algorithm.profile;
    weight = profile.weight;
    height = profile.height;
    age = profile.age;
    region = profile.region;
    dateOfBirth = profile.dateOfBirth;
    selectedDeficiencies = List.from(profile.deficiencies);
  }

  void _updateDefaultsBasedOnAge(int newAge) {
    if (newAge < 18) {
      height = 160.0;
      weight = 50.0;
    } else if (newAge < 30) {
      height = 163.0;
      weight = 58.0;
    } else if (newAge < 50) {
      height = 164.0;
      weight = 65.0;
    } else {
      height = 162.0;
      weight = 68.0;
    }
  }

  double get currentBMI {
    if (height <= 0) return 0;
    final hMeter = height / 100;
    return weight / (hMeter * hMeter);
  }

  String get bmiCategory {
    final b = currentBMI;
    if (b < 18.5) return "Underweight";
    if (b < 25) return "Normal";
    if (b < 30) return "Overweight";
    return "Obese";
  }

  Color get bmiColor {
    final b = currentBMI;
    if (b >= 18.5 && b < 25) return Colors.green;
    if (b >= 25 && b < 30) return Colors.orange;
    return Colors.red;
  }

  Future<void> _selectDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE67598),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateOfBirth = picked;
        final now = DateTime.now();
        int newAge = now.year - picked.year;
        if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) {
          newAge--;
        }
        age = newAge;
        _updateDefaultsBasedOnAge(age);
      });
    }
  }

  void _save() async {
    final old = CycleSession.algorithm.profile;
    
    int bmiCat = 1;
    final b = currentBMI;
    if (b < 18.5) bmiCat = 0;
    else if (b > 25) bmiCat = 2;

    final updated = AdvancedCycleProfile(
      lastPeriodDate: old.lastPeriodDate,
      averageCycleLength: old.averageCycleLength,
      averagePeriodLength: old.averagePeriodLength,
      dateOfBirth: dateOfBirth,
      age: age,
      isRegularCycle: old.isRegularCycle,
      weight: weight,
      height: height,
      deficiencies: selectedDeficiencies,
      stressLevel: old.stressLevel,
      painLevel: old.painLevel,
      pmsSeverity: old.pmsSeverity,
      flowIntensity: old.flowIntensity,
      ovulationSymptoms: old.ovulationSymptoms,
      sleepQuality: old.sleepQuality,
      exerciseLevel: old.exerciseLevel,
      bmiCategory: bmiCat,
      hasPCOS: old.hasPCOS,
      hasThyroid: old.hasThyroid,
      onHormonalMedication: old.onHormonalMedication,
      recentlyPregnant: old.recentlyPregnant,
      breastfeeding: old.breastfeeding,
      region: region,
    );

    await CycleSession.saveToLocalStorage(updated);
    widget.onUpdated();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 15),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _biometricsPage(),
                _deficienciesPage(),
                _regionPage(),
              ],
            ),
          ),

          const SizedBox(height: 20),
          
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: TextButton(
                    onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: const Text("Back", style: TextStyle(color: Colors.grey)),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _currentPage < 2 
                      ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                      : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67598),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == 0 ? "Next: Lifestyle" : (_currentPage == 1 ? "Next: Region" : "Save Nutrition Profile"), 
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _biometricsPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personalize Your Nutrition 🥗",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Based on your body metrics, we'll suggest the best nutrition techniques for your cycle.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 32),
          
          // Age / DOB Selection
          const Text("Age & Date of Birth", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selectDOB,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFFE67598)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateOfBirth == null ? "Select Date of Birth" : DateFormat('MMMM dd, yyyy').format(dateOfBirth!),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text("You are $age years old", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          _inputSlider("Your Weight (kg)", weight, 30, 150, (v) => setState(() => weight = v)),
          const SizedBox(height: 24),
          _inputSlider("Your Height (cm)", height, 100, 220, (v) => setState(() => height = v)),
          
          const SizedBox(height: 32),
          
          // BMI Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bmiColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bmiColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("BMI Status", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      bmiCategory,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: bmiColor),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bmiColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentBMI.toStringAsFixed(1),
                    style: TextStyle(fontWeight: FontWeight.bold, color: bmiColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deficienciesPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nutrient Deficiencies 🧬",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Do you have any known vitamin or mineral deficiencies? This helps us refine your diet plan.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 24),
          
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: vitaminOptions.map((v) {
              final isSelected = selectedDeficiencies.contains(v);
              return FilterChip(
                label: Text(v),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedDeficiencies.add(v);
                    } else {
                      selectedDeficiencies.remove(v);
                    }
                  });
                },
                selectedColor: const Color(0xFFE67598).withOpacity(0.2),
                checkmarkColor: const Color(0xFFE67598),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFFE67598) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFE67598) : Colors.grey.shade300,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          const Text("Iron Level Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _itemTile("High Iron", selectedDeficiencies.contains("High Iron")),
          _itemTile("Low Iron (Anaemic)", selectedDeficiencies.contains("Low Iron (Anaemic)")),
          _itemTile("Normal Iron", selectedDeficiencies.contains("Normal Iron")),
        ],
      ),
    );
  }

  Widget _itemTile(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Remove other iron levels
          selectedDeficiencies.removeWhere((e) => e.contains("Iron") && e != "Iron");
          if (!isSelected) {
            selectedDeficiencies.add(label);
          } else {
            selectedDeficiencies.remove(label);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE67598).withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFE67598) : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFFE67598) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _regionPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Your Region 🗺️",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll adjust your diet plan based on local food availability and culinary traditions.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 24),
          
          ...regionOptions.map((opt) {
            final isSelected = region == opt["id"];
            return GestureDetector(
              onTap: () => setState(() => region = opt["id"]!),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE67598).withOpacity(0.05) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE67598) : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt["name"]!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? const Color(0xFFE67598) : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opt["desc"]!,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFFE67598))
                    else
                      Icon(Icons.circle_outlined, color: Colors.grey.shade300),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _inputSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text("${value.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67598))),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: const Color(0xFFE67598),
            inactiveTrackColor: Colors.grey.shade100,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 3),
          ),
          child: Slider(
            min: min,
            max: max,
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

