/// DAILY BLEEDING LOGGER SCREEN
///
/// Allows users to log daily bleeding information
/// This data trains the personalized ML model
/// Users can edit and track their:
///   - Bleeding intensity (1-7 scale)
///   - Duration of bleeding
///   - Color and description
///
/// This unified screen replaces scattered data entry points

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/personalized_cycle_service.dart';
import '../core/app_theme.dart';

class DailyBleedingLoggerScreen extends StatefulWidget {
  final DateTime initialDate;

  const DailyBleedingLoggerScreen({Key? key, DateTime? initialDate})
    : initialDate = initialDate,
      super(key: key);

  @override
  State<DailyBleedingLoggerScreen> createState() =>
      _DailyBleedingLoggerScreenState();
}

class _DailyBleedingLoggerScreenState extends State<DailyBleedingLoggerScreen> {
  late DateTime _selectedDate;
  late int _selectedIntensity;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  String? _selectedColor;
  bool _isSaving = false;
  String? _successMessage;

  final PersonalizedCycleService _cycleService = PersonalizedCycleService();

  final List<String> colorOptions = [
    'Bright Red',
    'Dark Red',
    'Brown',
    'Dark Brown',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedIntensity = 4; // Default: medium
    _descriptionController = TextEditingController();
    _durationController = TextEditingController();
    _selectedColor = null;
    _loadExistingData();
  }

  void _loadExistingData() async {
    // TODO: Load existing data for this date if available
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// Save the bleeding data
  void _saveBleedingData() async {
    if (_selectedIntensity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an intensity level')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      int? durationMinutes;
      if (_durationController.text.isNotEmpty) {
        durationMinutes = int.tryParse(_durationController.text);
      }

      await _cycleService.logDailyBleeding(
        date: _selectedDate,
        intensity: _selectedIntensity,
        durationMinutes: durationMinutes,
        flowDescription: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        color: _selectedColor,
      );

      setState(() {
        _isSaving = false;
        _successMessage =
            '✓ Logged for ${DateFormat('MMM dd').format(_selectedDate)}';
      });

      // Clear form
      _descriptionController.clear();
      _durationController.clear();
      _selectedIntensity = 4;
      _selectedColor = null;

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('📊 Bleeding data saved! Model is learning...'),
          backgroundColor: Colors.green,
        ),
      );

      // Auto-close after success
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Log Bleeding Data'),
        backgroundColor: AppTheme.accentPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: AppTheme.accentPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Daily logs help your personalized model learn your unique patterns',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date picker
            Text('Date', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.accentPurple,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Intensity slider (1-7)
            Text(
              'Bleeding Intensity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                Slider(
                  value: _selectedIntensity.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  onChanged: (value) {
                    setState(() => _selectedIntensity = value.toInt());
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Light (1)',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        'Level: $_selectedIntensity',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentPurple,
                            ),
                      ),
                      Text(
                        'Heavy (7)',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Intensity labels
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildIntensityBadge('Spotting', 1),
                  _buildIntensityBadge('Light', 2),
                  _buildIntensityBadge('Light-Med', 3),
                  _buildIntensityBadge('Medium', 4),
                  _buildIntensityBadge('Med-Heavy', 5),
                  _buildIntensityBadge('Heavy', 6),
                  _buildIntensityBadge('Very Heavy', 7),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Duration
            Text(
              'Duration (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'How many minutes? (leave blank if unsure)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.schedule),
              ),
            ),
            const SizedBox(height: 24),

            // Color picker
            Text(
              'Blood Color (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: colorOptions.map((color) {
                return FilterChip(
                  label: Text(color),
                  selected: _selectedColor == color,
                  onSelected: (selected) {
                    setState(() => _selectedColor = selected ? color : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'Notes (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'E.g., "heavy with clots", "light spotting", etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Success message
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Text(_successMessage!),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveBleedingData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        '💾 Save & Help Model Learn',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧠 How This Helps:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Each log teaches the model your unique patterns\n'
                    '• After ~3 cycles, predictions become personalized\n'
                    '• Model learns your actual vs. expected flow\n'
                    '• Accuracy improves over time\n'
                    '• All data stays on your device',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensityBadge(String label, int level) {
    final isSelected = _selectedIntensity == level;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        backgroundColor: Colors.grey[100],
        selectedColor: AppTheme.accentPurple.withOpacity(0.7),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 11,
        ),
        onSelected: (selected) {
          setState(() => _selectedIntensity = selected ? level : 0);
        },
      ),
    );
  }
}
