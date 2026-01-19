import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirstTimeSetup extends StatefulWidget {
  final Function onComplete;
  const FirstTimeSetup({super.key, required this.onComplete});

  @override
  State<FirstTimeSetup> createState() => _FirstTimeSetupState();
}

class _FirstTimeSetupState extends State<FirstTimeSetup> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  
  int currentStep = 0;
  DateTime? dateOfBirth;
  DateTime? lastPeriodDate;
  int cycleLength = 28;
  int periodDuration = 5;
  bool isLoading = false;

  final List<String> quickCycleLengths = ['22', '23', '24', '25', '26', '27', '28', '29', '30', '31'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (currentStep == 0 && dateOfBirth == null) {
      _showSnackBar('Please select your date of birth');
      return;
    }
    if (currentStep == 1 && lastPeriodDate == null) {
      _showSnackBar('Please select your last period date');
      return;
    }

    if (currentStep < 3) {
      _animationController.reset();
      setState(() => currentStep++);
      _animationController.forward();
    } else {
      _saveDataAndComplete();
    }
  }

  void _goBack() {
    if (currentStep > 0) {
      _animationController.reset();
      setState(() => currentStep--);
      _animationController.forward();
    }
  }

  Future<void> _saveDataAndComplete() async {
    setState(() => isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
          'lastPeriodDate': Timestamp.fromDate(lastPeriodDate!),
          'cycleLength': cycleLength,
          'periodDuration': periodDuration,
          'setupCompleted': true,
          'setupDate': Timestamp.now(),
        });
      }
      
      if (mounted) {
        setState(() => isLoading = false);
        // Show completion state
        _showCompletionState();
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error saving data: $e');
    }
  }

  void _showCompletionState() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.pinkAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You\'re all set ✨',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We\'ve personalized your calendar based on your answers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onComplete();
                  },
                  child: const Text(
                    'Explore Your Calendar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                if (currentStep == 0)
                  _buildHeader(
                    title: "Let's know about you in 13 seconds 💗",
                    subtitle: "We'll ask just a few simple questions to personalize your cycle calendar.",
                  )
                else
                  _buildProgressHeader(currentStep),
                
                const SizedBox(height: 24),

                // Question content
                if (currentStep == 0) _buildStep1()
                else if (currentStep == 1) _buildStep2()
                else if (currentStep == 2) _buildStep3()
                else if (currentStep == 3) _buildStep4(),

                const SizedBox(height: 32),

                // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required String title, required String subtitle}) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(int step) {
    final titles = [
      'When were you born?',
      'When did your last menstrual cycle start?',
      'About how many days are there between your cycles?',
      'How long do your periods usually last?',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[step],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (step + 1) / 4,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        _buildDatePicker(
          label: 'Date of Birth',
          selectedDate: dateOfBirth,
          onDateSelected: (date) => setState(() => dateOfBirth = date),
        ),
        if (dateOfBirth != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'So, you\'re ${_calculateAge(dateOfBirth!)} years old 🌸',
              style: TextStyle(
                fontSize: 14,
                color: Colors.pink.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    return _buildDatePicker(
      label: 'Last Menstrual Cycle Start Date',
      selectedDate: lastPeriodDate,
      onDateSelected: (date) => setState(() => lastPeriodDate = date),
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        Text(
          'Most people are between 21–35 days. Just choose what feels right.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickCycleLengths.map((length) {
            final isSelected = cycleLength == int.parse(length);
            return GestureDetector(
              onTap: () => setState(() => cycleLength = int.parse(length)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pinkAccent : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: Colors.pinkAccent, width: 2)
                      : null,
                ),
                child: Text(
                  '$length days',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          'Or use the slider below:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: cycleLength.toDouble(),
          min: 21,
          max: 35,
          divisions: 14,
          activeColor: Colors.pinkAccent,
          inactiveColor: Colors.grey.shade200,
          onChanged: (value) => setState(() => cycleLength = value.toInt()),
        ),
        Center(
          child: Text(
            '$cycleLength days',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        Text(
          'Every body is different — all answers are okay.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(9, (index) {
            final days = index + 2;
            final isSelected = periodDuration == days;
            return GestureDetector(
              onTap: () => setState(() => periodDuration = days),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pinkAccent : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: Colors.pinkAccent, width: 2)
                      : null,
                ),
                child: Text(
                  days == 10 ? '10+' : '$days',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1980),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.pinkAccent,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black87,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : 'Select a date',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selectedDate != null ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const Icon(Icons.calendar_today, color: Colors.pinkAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isLoading ? null : _goToNextStep,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    currentStep == 3 ? 'Complete Setup' : 'Let\'s go',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        if (currentStep > 0)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _goBack,
              child: const Text(
                'Go back',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        if (currentStep == 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Skip for now',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
