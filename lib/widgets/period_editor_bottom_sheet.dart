/// PERIOD EDITOR BOTTOM SHEET
///
/// Bottom sheet modal for editing period dates and blood flow information
/// Accessible from home screen, calendar, and any other view

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/period_editor_model.dart';
import '../models/smart_prediction_model.dart';
import '../services/period_editor_provider.dart';
import '../widgets/blood_flow_visualization.dart';

class PeriodEditorBottomSheet extends StatefulWidget {
  /// Date being edited
  final DateTime? selectedDate;

  /// Latest prediction for comparison
  final SmartCyclePrediction? prediction;

  /// Callback when editing is done
  final VoidCallback? onEditComplete;

  const PeriodEditorBottomSheet({
    Key? key,
    this.selectedDate,
    this.prediction,
    this.onEditComplete,
  }) : super(key: key);

  /// Show the bottom sheet
  static Future<void> show(
    BuildContext context, {
    DateTime? selectedDate,
    SmartCyclePrediction? prediction,
    VoidCallback? onEditComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PeriodEditorBottomSheet(
        selectedDate: selectedDate,
        prediction: prediction,
        onEditComplete: onEditComplete,
      ),
    );
  }

  @override
  State<PeriodEditorBottomSheet> createState() =>
      _PeriodEditorBottomSheetState();
}

class _PeriodEditorBottomSheetState extends State<PeriodEditorBottomSheet> {
  late DateTime _selectedDate;
  late bool _hadBleeding;
  late BloodFlowIntensity _flowIntensity;
  late int _painLevel;
  late TextEditingController _notesController;
  int _currentStep = 0; // For step-by-step editing

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _hadBleeding = false;
    _flowIntensity = BloodFlowIntensity.none;
    _painLevel = 0;
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PeriodEditorProvider>(
      builder: (context, provider, _) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header with drag handle
                  _buildHeader(),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Prediction comparison (if available)
                            if (widget.prediction != null)
                              _buildPredictionComparison(),

                            const SizedBox(height: 24),

                            // Step indicator
                            _buildStepIndicator(),

                            const SizedBox(height: 24),

                            // Step content
                            _buildStepContent(provider),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom action buttons
                  _buildActionButtons(context, provider),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ======== UI BUILDERS ========

  Widget _buildHeader() {
    return Column(
      children: [
        // Drag handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Edit Period Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }

  Widget _buildPredictionComparison() {
    final diffDays = _selectedDate
        .difference(widget.prediction!.nextPeriodDate)
        .inDays;
    final isEarly = diffDays < 0;
    final isLate = diffDays > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prediction Comparison',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Predicted',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateFormat(widget.prediction!.nextPeriodDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isEarly
                      ? Colors.blue.shade50
                      : (isLate ? Colors.orange.shade50 : Colors.green.shade50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isEarly
                      ? '• $diffDays days early'
                      : (isLate ? '• +$diffDays days late' : '• On time!'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isEarly
                        ? Colors.blue
                        : (isLate ? Colors.orange : Colors.green),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Your Date',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateFormat(_selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Confidence: ${(widget.prediction!.confidenceScore * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;

        return Expanded(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive || isCompleted
                      ? Colors.redAccent
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isCompleted ? '✓' : '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isCompleted ? 20 : 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ['Date', 'Bleeding', 'Pain'][index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive || isCompleted
                      ? Colors.redAccent
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(PeriodEditorProvider provider) {
    switch (_currentStep) {
      case 0:
        return _buildDateStepContent();
      case 1:
        return _buildBleedingStepContent();
      case 2:
        return _buildPainStepContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDateStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'When did your period start?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Date',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dateFormat(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.redAccent),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Quick select buttons
        const Text(
          'Quick Select:',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildQuickSelectButton('Today', DateTime.now()),
            const SizedBox(width: 8),
            _buildQuickSelectButton(
              'Yesterday',
              DateTime.now().subtract(const Duration(days: 1)),
            ),
            const SizedBox(width: 8),
            _buildQuickSelectButton(
              '2 days ago',
              DateTime.now().subtract(const Duration(days: 2)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBleedingStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blood Flow Intensity',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        BloodFlowIntensitySelector(
          selectedIntensity: _hadBleeding
              ? _flowIntensity
              : BloodFlowIntensity.none,
          onIntensitySelected: (intensity) {
            setState(() {
              _flowIntensity = intensity;
              _hadBleeding = intensity != BloodFlowIntensity.none;
            });
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Track your flow intensity each day for better predictions',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPainStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pain Level',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pain Level: $_painLevel/10',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _painLevelLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _painColorByLevel(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: _painLevel.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: _painColorByLevel(),
                onChanged: (value) {
                  setState(() {
                    _painLevel = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('None', style: TextStyle(fontSize: 10)),
                  Text('Moderate', style: TextStyle(fontSize: 10)),
                  Text('Severe', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Add Notes (Optional)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any additional notes about your period...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    PeriodEditorProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                if (_currentStep < 2) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  // Save the data
                  await provider.updateDailyPeriodEdit(
                    date: _selectedDate,
                    hadBleeding: _hadBleeding,
                    flowIntensity: _flowIntensity,
                    painLevel: _painLevel,
                    notes: _notesController.text.isEmpty
                        ? null
                        : _notesController.text,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    widget.onEditComplete?.call();
                  }
                }
              },
              child: Text(
                _currentStep < 2 ? 'Next' : 'Save',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectButton(String label, DateTime date) {
    final isSelected =
        _selectedDate.day == date.day &&
        _selectedDate.month == date.month &&
        _selectedDate.year == date.year;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.redAccent : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.redAccent : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  // ======== HELPERS ========

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _dateFormat(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _painLevelLabel() {
    if (_painLevel == 0) return 'None';
    if (_painLevel <= 3) return 'Mild';
    if (_painLevel <= 6) return 'Moderate';
    if (_painLevel <= 8) return 'Severe';
    return 'Very Severe';
  }

  Color _painColorByLevel() {
    if (_painLevel == 0) return Colors.green;
    if (_painLevel <= 3) return Colors.yellow;
    if (_painLevel <= 6) return Colors.orange;
    return Colors.red;
  }
}
