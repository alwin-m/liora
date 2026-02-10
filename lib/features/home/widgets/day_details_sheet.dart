import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/liora_theme.dart';
import '../../../core/engine/prediction_engine.dart';
import '../../cycle/providers/cycle_provider.dart';

/// Bottom sheet for viewing and editing day details
class DayDetailsSheet extends StatefulWidget {
  const DayDetailsSheet({super.key});

  @override
  State<DayDetailsSheet> createState() => _DayDetailsSheetState();
}

class _DayDetailsSheetState extends State<DayDetailsSheet> {
  final _notesController = TextEditingController();
  String? _selectedMood;
  String? _selectedFlow;
  List<String> _selectedSymptoms = [];

  static const List<Map<String, String>> _moods = [
    {'id': 'happy', 'emoji': '😊', 'label': 'Happy'},
    {'id': 'calm', 'emoji': '😌', 'label': 'Calm'},
    {'id': 'tired', 'emoji': '😴', 'label': 'Tired'},
    {'id': 'anxious', 'emoji': '😰', 'label': 'Anxious'},
    {'id': 'irritable', 'emoji': '😤', 'label': 'Irritable'},
    {'id': 'sad', 'emoji': '😢', 'label': 'Sad'},
  ];

  static const List<Map<String, String>> _flowLevels = [
    {'id': 'spotting', 'label': 'Spotting', 'icon': '💧'},
    {'id': 'light', 'label': 'Light', 'icon': '💧💧'},
    {'id': 'medium', 'label': 'Medium', 'icon': '💧💧💧'},
    {'id': 'heavy', 'label': 'Heavy', 'icon': '💧💧💧💧'},
  ];

  static const List<Map<String, String>> _symptoms = [
    {'id': 'cramps', 'emoji': '😣', 'label': 'Cramps'},
    {'id': 'headache', 'emoji': '🤕', 'label': 'Headache'},
    {'id': 'bloating', 'emoji': '🫃', 'label': 'Bloating'},
    {'id': 'fatigue', 'emoji': '😴', 'label': 'Fatigue'},
    {'id': 'breast_tenderness', 'emoji': '💔', 'label': 'Tender breasts'},
    {'id': 'acne', 'emoji': '🔴', 'label': 'Acne'},
    {'id': 'backache', 'emoji': '🔙', 'label': 'Backache'},
    {'id': 'nausea', 'emoji': '🤢', 'label': 'Nausea'},
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = context.read<CycleProvider>();
    final info = provider.getSelectedDayInfo();

    _selectedMood = info.mood;
    _selectedFlow = info.flowIntensity;
    _selectedSymptoms = List.from(info.symptoms);
    _notesController.text = info.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final selectedDate = provider.selectedDate;
        final dayType = provider.getDayType(selectedDate);
        final isPeriodDay = provider.isSelectedDayPeriod();

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(LioraRadius.xxl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LioraColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              _buildHeader(selectedDate, dayType),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(LioraSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period toggle
                      _buildPeriodToggle(isPeriodDay, provider),

                      const SizedBox(height: LioraSpacing.lg),

                      // Flow intensity (only if period day)
                      if (isPeriodDay) ...[
                        _buildFlowSelector(),
                        const SizedBox(height: LioraSpacing.lg),
                      ],

                      // Mood selector
                      _buildMoodSelector(provider),

                      const SizedBox(height: LioraSpacing.lg),

                      // Symptoms
                      _buildSymptomsSelector(provider),

                      const SizedBox(height: LioraSpacing.lg),

                      // Notes
                      _buildNotesInput(provider),

                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom +
                              LioraSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(DateTime date, DayType dayType) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LioraSpacing.lg,
        vertical: LioraSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: LioraColors.divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE').format(date),
                style: LioraTextStyles.h3,
              ),
              Text(
                DateFormat('MMMM d, y').format(date),
                style: LioraTextStyles.bodyMedium,
              ),
            ],
          ),
          _buildDayTypeChip(dayType),
        ],
      ),
    );
  }

  Widget _buildDayTypeChip(DayType dayType) {
    String label;
    Color color;

    switch (dayType) {
      case DayType.period:
        label = 'Period';
        color = LioraColors.periodDay;
        break;
      case DayType.predictedPeriod:
        label = 'Predicted';
        color = LioraColors.predictedPeriod;
        break;
      case DayType.fertile:
        label = 'Fertile';
        color = LioraColors.fertileWindow;
        break;
      case DayType.ovulation:
        label = 'Ovulation';
        color = LioraColors.ovulationDay;
        break;
      case DayType.normal:
        return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LioraSpacing.md,
        vertical: LioraSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(LioraRadius.round),
      ),
      child: Text(
        label,
        style: LioraTextStyles.labelSmall.copyWith(
          color: dayType == DayType.period || dayType == DayType.ovulation
              ? Colors.white
              : LioraColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(bool isPeriod, CycleProvider provider) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        await provider.togglePeriodDay(provider.selectedDate);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(LioraSpacing.md),
        decoration: BoxDecoration(
          gradient: isPeriod
              ? const LinearGradient(
                  colors: [LioraColors.periodDay, LioraColors.accentRose],
                )
              : null,
          color: isPeriod ? null : LioraColors.inputBackground,
          borderRadius: BorderRadius.circular(LioraRadius.large),
          border: isPeriod ? null : Border.all(color: LioraColors.inputBorder),
        ),
        child: Row(
          children: [
            Text(
              isPeriod ? '🌸' : '○',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: LioraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPeriod ? 'Period day' : 'Mark as period day',
                    style: LioraTextStyles.label.copyWith(
                      color: isPeriod ? Colors.white : LioraColors.textPrimary,
                    ),
                  ),
                  Text(
                    isPeriod ? 'Tap to remove' : 'Tap to mark this day',
                    style: LioraTextStyles.bodySmall.copyWith(
                      color: isPeriod ? Colors.white70 : LioraColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isPeriod ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isPeriod ? Colors.white : LioraColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Flow', style: LioraTextStyles.label),
        const SizedBox(height: LioraSpacing.sm),
        Row(
          children: _flowLevels.map((flow) {
            final isSelected = _selectedFlow == flow['id'];

            return Expanded(
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedFlow = flow['id']);
                  await context
                      .read<CycleProvider>()
                      .logFlowIntensity(flow['id']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(vertical: LioraSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? LioraColors.accentRose
                        : LioraColors.inputBackground,
                    borderRadius: BorderRadius.circular(LioraRadius.medium),
                    border: Border.all(
                      color: isSelected
                          ? LioraColors.accentRose
                          : LioraColors.inputBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        flow['icon']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flow['label']!,
                        style: LioraTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : LioraColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodSelector(CycleProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How are you feeling?', style: LioraTextStyles.label),
        const SizedBox(height: LioraSpacing.sm),
        Wrap(
          spacing: LioraSpacing.sm,
          runSpacing: LioraSpacing.sm,
          children: _moods.map((mood) {
            final isSelected = _selectedMood == mood['id'];

            return GestureDetector(
              onTap: () async {
                HapticFeedback.selectionClick();
                setState(() => _selectedMood = mood['id']);
                await provider.logMood(mood['id']!);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: LioraSpacing.md,
                  vertical: LioraSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? LioraColors.accentRose
                      : LioraColors.inputBackground,
                  borderRadius: BorderRadius.circular(LioraRadius.round),
                  border: Border.all(
                    color: isSelected
                        ? LioraColors.accentRose
                        : LioraColors.inputBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mood['emoji']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      mood['label']!,
                      style: LioraTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : LioraColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomsSelector(CycleProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Symptoms', style: LioraTextStyles.label),
        const SizedBox(height: LioraSpacing.sm),
        Wrap(
          spacing: LioraSpacing.sm,
          runSpacing: LioraSpacing.sm,
          children: _symptoms.map((symptom) {
            final isSelected = _selectedSymptoms.contains(symptom['id']);

            return GestureDetector(
              onTap: () async {
                HapticFeedback.selectionClick();
                setState(() {
                  if (isSelected) {
                    _selectedSymptoms.remove(symptom['id']);
                  } else {
                    _selectedSymptoms.add(symptom['id']!);
                  }
                });
                await provider.logSymptoms(_selectedSymptoms);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: LioraSpacing.md,
                  vertical: LioraSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? LioraColors.primaryPink
                      : LioraColors.inputBackground,
                  borderRadius: BorderRadius.circular(LioraRadius.round),
                  border: Border.all(
                    color: isSelected
                        ? LioraColors.accentRose
                        : LioraColors.inputBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(symptom['emoji']!,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      symptom['label']!,
                      style: LioraTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? LioraColors.deepRose
                            : LioraColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesInput(CycleProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes', style: LioraTextStyles.label),
        const SizedBox(height: LioraSpacing.sm),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: LioraTextStyles.bodyMedium,
          onChanged: (value) {
            provider.logNotes(value);
          },
          decoration: InputDecoration(
            hintText: 'Add any notes for this day...',
            filled: true,
            fillColor: LioraColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LioraRadius.large),
              borderSide: const BorderSide(color: LioraColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LioraRadius.large),
              borderSide: const BorderSide(color: LioraColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LioraRadius.large),
              borderSide:
                  const BorderSide(color: LioraColors.accentRose, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
