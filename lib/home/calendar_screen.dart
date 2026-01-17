import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' show TableCalendar, HeaderStyle, CalendarBuilders, isSameDay;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cycle_algorithm.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> with WidgetsBindingObserver {
  bool isMonth = true;
  DateTime focusedDay = DateTime(2026, 1);
  DateTime selectedDay = DateTime(2026, 1, 14);
  
  // Cycle data from Firestore
  DateTime? lastPeriodDate;
  int cycleLength = 28;
  int periodDuration = 5;
  bool isLoadingData = true;
  bool hasShownTodayPrompt = false;

  late CycleAlgorithm? cycleAlgo;

  final List<String> months = const [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserCycleData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndShowPredictionPrompt();
    }
  }

  Future<void> _loadUserCycleData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (mounted && docSnapshot.exists) {
          final data = docSnapshot.data();
          setState(() {
            lastPeriodDate = (data?['lastPeriodDate'] as Timestamp?)?.toDate();
            cycleLength = data?['cycleLength'] ?? 28;
            periodDuration = data?['periodDuration'] ?? 5;
            isLoadingData = false;

            // Initialize cycle algorithm
            if (lastPeriodDate != null) {
              cycleAlgo = CycleAlgorithm(
                lastPeriod: lastPeriodDate!,
                cycleLength: cycleLength,
                periodLength: periodDuration,
              );
            }
          });

          // Check if we should show prediction prompt
          _checkAndShowPredictionPrompt();
        } else if (mounted) {
          setState(() => isLoadingData = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingData = false);
      }
    }
  }

  void _checkAndShowPredictionPrompt() {
    if (!hasShownTodayPrompt && cycleAlgo != null) {
      final today = DateTime.now();
      final nextPeriod = cycleAlgo!.getNextPeriodDate();
      
      // Check if today is near predicted period start (within 3 days)
      final daysUntilPeriod = nextPeriod.difference(today).inDays;
      
      if (daysUntilPeriod >= -1 && daysUntilPeriod <= 1) {
        hasShownTodayPrompt = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showPredictionAccuracyPrompt();
          }
        });
      }
    }
  }

  void _showPredictionAccuracyPrompt() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quick check-in 🌸',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Did your period start today as predicted?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showAccuracyConfirmation(true);
                      },
                      child: const Text(
                        'Yes, correct',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showAccuracyConfirmation(false);
                      },
                      child: const Text(
                        'No, different',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccuracyConfirmation(bool isAccurate) {
    final message = isAccurate
        ? "Good to hear! We'll keep things accurate for you 🤍"
        : "Thanks! We'll use this to improve your predictions.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (!isAccurate) {
      // Open update period modal
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showUpdatePeriodModal();
        }
      });
    }
  }

  void _showUpdatePeriodModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => _UpdatePeriodBottomSheet(
        onComplete: (newLastPeriod, newCycleLength, newPeriodDuration) {
          _updateCycleData(newLastPeriod, newCycleLength, newPeriodDuration);
        },
      ),
    );
  }

  Future<void> _updateCycleData(
    DateTime lastPeriod,
    int newCycleLength,
    int newPeriodDuration,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'lastPeriodDate': Timestamp.fromDate(lastPeriod),
          'cycleLength': newCycleLength,
          'periodDuration': newPeriodDuration,
          'lastUpdatedDate': Timestamp.now(),
        });

        setState(() {
          lastPeriodDate = lastPeriod;
          cycleLength = newCycleLength;
          periodDuration = newPeriodDuration;
          cycleAlgo = CycleAlgorithm(
            lastPeriod: lastPeriod,
            cycleLength: newCycleLength,
            periodLength: newPeriodDuration,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your cycle data has been updated 💗'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.black87,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingData) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: _monthYearToggle(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  isMonth ? _monthCalendar() : _yearCalendar(),
                  const SizedBox(height: 8),
                  _editPeriodButton(),
                  const SizedBox(height: 8),
                  if (cycleAlgo != null) _bottomCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUpdatePeriodModal,
        backgroundColor: Colors.pinkAccent,
        label: const Text('+ Add period', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _monthYearToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleItem("Month", isMonth, () {
            setState(() => isMonth = true);
          }),
          _toggleItem("Year", !isMonth, () {
            setState(() => isMonth = false);
          }),
        ],
      ),
    );
  }

  Widget _toggleItem(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _monthCalendar() {
    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2030),
      selectedDayPredicate: (d) => isSameDay(d, selectedDay),
      onDaySelected: (selected, focused) {
        setState(() {
          selectedDay = selected;
          focusedDay = focused;
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (_, day, __) => _dayCell(day),
        todayBuilder: (_, day, __) => _todayCell(day),
        selectedBuilder: (_, day, __) => _selectedCell(day),
      ),
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
    );
  }

  Widget _yearCalendar() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (_, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                focusedDay = DateTime(focusedDay.year, index + 1);
                isMonth = true;
              });
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  months[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dayCell(DateTime day) {
    if (cycleAlgo == null) {
      return Center(
        child: Text("${day.day}"),
      );
    }

    final isPeriod = cycleAlgo!.isPeriodDay(day);
    final isFertile = cycleAlgo!.isFertileDay(day);
    final isOvulation = cycleAlgo!.isOvulationDay(day);

    Color? bgColor;
    Color? textColor;
    BorderRadiusGeometry? borderRadius;

    if (isPeriod) {
      bgColor = const Color(0xFFFFE0E6); // Soft menstrual red
      textColor = Colors.pink.shade700;
    } else if (isOvulation) {
      bgColor = const Color(0xFFC8E6C9); // Deep fertile green
      textColor = Colors.green.shade800;
      borderRadius = BorderRadius.circular(12);
    } else if (isFertile) {
      bgColor = const Color(0xFFF1F8E9); // Light fertile green
      textColor = Colors.green.shade700;
    }

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _todayCell(DateTime day) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE8D5E6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.pinkAccent, width: 2),
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _selectedCell(DateTime day) {
    if (cycleAlgo == null) {
      return _todayCell(day);
    }

    final isPeriod = cycleAlgo!.isPeriodDay(day);
    final isFertile = cycleAlgo!.isFertileDay(day);
    final isOvulation = cycleAlgo!.isOvulationDay(day);

    Color? bgColor;
    Color? textColor;

    if (isPeriod) {
      bgColor = Colors.pink.shade300;
      textColor = Colors.white;
    } else if (isOvulation) {
      bgColor = Colors.green.shade600;
      textColor = Colors.white;
    } else if (isFertile) {
      bgColor = Colors.green.shade400;
      textColor = Colors.white;
    } else {
      bgColor = const Color(0xFFE8D5E6);
      textColor = Colors.black87;
    }

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _editPeriodButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 222, 120, 154),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: _showUpdatePeriodModal,
      child: const Text("Edit period dates"),
    );
  }

  Widget _bottomCard() {
    final today = DateTime.now();
    final nextPeriod = cycleAlgo!.getNextPeriodDate();
    final daysUntilPeriod = nextPeriod.difference(today).inDays;
    
    String cycleInfo;
    if (daysUntilPeriod < 0) {
      cycleInfo = "Period is due · ${(-daysUntilPeriod)} days ago";
    } else if (daysUntilPeriod == 0) {
      cycleInfo = "Period starts today! 🌸";
    } else {
      cycleInfo = "Period in $daysUntilPeriod days";
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cycleInfo,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "Cycle: $cycleLength days · Period: $periodDuration days",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          Icon(Icons.info_outline, color: Colors.pinkAccent)
        ],
      ),
    );
  }
}

class _UpdatePeriodBottomSheet extends StatefulWidget {
  final Function(DateTime, int, int) onComplete;

  const _UpdatePeriodBottomSheet({required this.onComplete});

  @override
  State<_UpdatePeriodBottomSheet> createState() => _UpdatePeriodBottomSheetState();
}

class _UpdatePeriodBottomSheetState extends State<_UpdatePeriodBottomSheet>
    with SingleTickerProviderStateMixin {
  int currentStep = 0;
  DateTime? lastPeriodDate;
  int cycleLength = 28;
  int periodDuration = 5;
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final List<String> quickCycleLengths = ['21', '24', '27', '28', '30', '32'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep == 0 && lastPeriodDate == null) {
      _showSnackBar('Please select your period start date');
      return;
    }

    if (currentStep < 2) {
      _animationController.reset();
      setState(() => currentStep++);
      _animationController.forward();
    } else {
      _completeUpdate();
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      _animationController.reset();
      setState(() => currentStep--);
      _animationController.forward();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _completeUpdate() async {
    if (lastPeriodDate == null) return;

    setState(() => isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context);
      widget.onComplete(lastPeriodDate!, cycleLength, periodDuration);
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentStep == 0)
                _buildHeader(
                  title: "Let's update your cycle 🤍",
                  subtitle: "Takes less than 15 seconds",
                )
              else
                _buildProgressHeader(currentStep),
              const SizedBox(height: 24),
              if (currentStep == 0) _buildStep1()
              else if (currentStep == 1) _buildStep2()
              else if (currentStep == 2) _buildStep3(),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
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
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(int step) {
    final titles = [
      'When did your period start?',
      'How long is your cycle usually?',
      'How many days does your period last?',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[step],
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (step + 1) / 3,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
          minHeight: 3,
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: lastPeriodDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 90)),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.pinkAccent,
                  onPrimary: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => lastPeriodDate = picked);
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
                  'Period start date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastPeriodDate != null
                      ? '${lastPeriodDate!.day}/${lastPeriodDate!.month}/${lastPeriodDate!.year}'
                      : 'Select a date',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: lastPeriodDate != null ? Colors.black87 : Colors.grey.shade500,
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

  Widget _buildStep2() {
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
        const SizedBox(height: 20),
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

  Widget _buildStep3() {
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: isLoading ? null : _nextStep,
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
                    currentStep == 2 ? 'Complete' : 'Let\'s go',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _previousStep,
            child: Text(
              currentStep == 0 ? 'Close' : 'Go back',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
