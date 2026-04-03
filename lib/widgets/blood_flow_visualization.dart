/// BLOOD FLOW VISUALIZATION WIDGETS
///
/// Animated cube visualization system for showing blood flow intensity
/// Used in calendar, history, and period editor views

import 'package:flutter/material.dart';
import '../models/period_editor_model.dart';

// ============================================================================
// BLOOD FLOW CUBE WIDGET
// ============================================================================

/// Single animated cube representing blood flow for one day
class BloodFlowCube extends StatefulWidget {
  /// Blood flow intensity for this day
  final BloodFlowIntensity intensity;

  /// Day of month
  final int day;

  /// Whether this is today
  final bool isToday;

  /// Whether selected
  final bool isSelected;

  /// Tap callback
  final VoidCallback? onTap;

  /// Size of cube
  final double size;

  const BloodFlowCube({
    Key? key,
    required this.intensity,
    required this.day,
    this.isToday = false,
    this.isSelected = false,
    this.onTap,
    this.size = 32.0,
  }) : super(key: key);

  @override
  State<BloodFlowCube> createState() => _BloodFlowCubeState();
}

class _BloodFlowCubeState extends State<BloodFlowCube>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fillAnimation = Tween<double>(
      begin: 0,
      end: widget.intensity.toPercentage() / 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(BloodFlowCube oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intensity != widget.intensity) {
      _fillAnimation = Tween<double>(
        begin: _fillAnimation.value,
        end: widget.intensity.toPercentage() / 100,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _fillAnimation,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.isToday ? Colors.redAccent : Colors.grey.shade300,
                width: widget.isToday ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade100,
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                // Blood fill (liquid-like animation)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: widget.size * _fillAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getColorForIntensity(
                        widget.intensity,
                      ).withOpacity(0.85),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                // Day number
                Center(
                  child: Text(
                    '${widget.day}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _fillAnimation.value > 0.5
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getColorForIntensity(BloodFlowIntensity intensity) {
    switch (intensity) {
      case BloodFlowIntensity.none:
        return Colors.white;
      case BloodFlowIntensity.spotting:
        return const Color(0xFFFFB0B0);
      case BloodFlowIntensity.light:
        return const Color(0xFFFF6B6B);
      case BloodFlowIntensity.medium:
        return const Color(0xFFE63946);
      case BloodFlowIntensity.heavy:
        return const Color(0xFF8B0000);
    }
  }
}

// ============================================================================
// BLOOD FLOW CALENDAR VIEW
// ============================================================================

/// Calendar-like grid showing blood flow for entire month
class BloodFlowCalendarView extends StatefulWidget {
  /// Days in current month
  final int daysInMonth;

  /// Function to get intensity for day
  final BloodFlowIntensity Function(int day) getIntensityForDay;

  /// Current day
  final int currentDay;

  /// Tap callback with day number
  final Function(int day)? onDayTapped;

  /// Size of each cube
  final double cubeSize;

  const BloodFlowCalendarView({
    Key? key,
    required this.daysInMonth,
    required this.getIntensityForDay,
    required this.currentDay,
    this.onDayTapped,
    this.cubeSize = 36,
  }) : super(key: key);

  @override
  State<BloodFlowCalendarView> createState() => _BloodFlowCalendarViewState();
}

class _BloodFlowCalendarViewState extends State<BloodFlowCalendarView> {
  late Set<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = {};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Blood Flow History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('None', BloodFlowIntensity.none),
              _buildLegendItem('Light', BloodFlowIntensity.spotting),
              _buildLegendItem('Medium', BloodFlowIntensity.light),
              _buildLegendItem('Heavy', BloodFlowIntensity.medium),
              _buildLegendItem('V.Heavy', BloodFlowIntensity.heavy),
            ],
          ),
          const SizedBox(height: 16),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: widget.daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final intensity = widget.getIntensityForDay(day);
              final isToday = day == widget.currentDay;
              final isSelected = _selectedDays.contains(day);

              return BloodFlowCube(
                intensity: intensity,
                day: day,
                isToday: isToday,
                isSelected: isSelected,
                size: widget.cubeSize,
                onTap: () {
                  setState(() {
                    if (_selectedDays.contains(day)) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                  });
                  widget.onDayTapped?.call(day);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, BloodFlowIntensity intensity) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getColor(intensity),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getColor(BloodFlowIntensity intensity) {
    switch (intensity) {
      case BloodFlowIntensity.none:
        return Colors.grey.shade100;
      case BloodFlowIntensity.spotting:
        return const Color(0xFFFFB0B0);
      case BloodFlowIntensity.light:
        return const Color(0xFFFF6B6B);
      case BloodFlowIntensity.medium:
        return const Color(0xFFE63946);
      case BloodFlowIntensity.heavy:
        return const Color(0xFF8B0000);
    }
  }
}

// ============================================================================
// BLOOD FLOW INTENSITY SELECTOR
// ============================================================================

/// Interactive widget for selecting blood flow intensity
class BloodFlowIntensitySelector extends StatefulWidget {
  /// Current intensity
  final BloodFlowIntensity selectedIntensity;

  /// Callback when intensity selected
  final Function(BloodFlowIntensity) onIntensitySelected;

  const BloodFlowIntensitySelector({
    Key? key,
    required this.selectedIntensity,
    required this.onIntensitySelected,
  }) : super(key: key);

  @override
  State<BloodFlowIntensitySelector> createState() =>
      _BloodFlowIntensitySelectorState();
}

class _BloodFlowIntensitySelectorState
    extends State<BloodFlowIntensitySelector> {
  late BloodFlowIntensity _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedIntensity;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blood Flow Level',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIntensityButton(BloodFlowIntensity.none, 'None'),
            _buildIntensityButton(BloodFlowIntensity.spotting, 'Spotting'),
            _buildIntensityButton(BloodFlowIntensity.light, 'Light'),
            _buildIntensityButton(BloodFlowIntensity.medium, 'Medium'),
            _buildIntensityButton(BloodFlowIntensity.heavy, 'Heavy'),
          ],
        ),
        const SizedBox(height: 16),
        // Preview cube
        Center(
          child: BloodFlowCube(
            intensity: _selected,
            day: 5,
            size: 80,
            isSelected: true,
          ),
        ),
      ],
    );
  }

  Widget _buildIntensityButton(BloodFlowIntensity intensity, String label) {
    final isSelected = _selected == intensity;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = intensity;
        });
        widget.onIntensitySelected(intensity);
      },
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getColor(intensity),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? Colors.redAccent : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(BloodFlowIntensity intensity) {
    switch (intensity) {
      case BloodFlowIntensity.none:
        return Colors.grey.shade200;
      case BloodFlowIntensity.spotting:
        return const Color(0xFFFFB0B0);
      case BloodFlowIntensity.light:
        return const Color(0xFFFF6B6B);
      case BloodFlowIntensity.medium:
        return const Color(0xFFE63946);
      case BloodFlowIntensity.heavy:
        return const Color(0xFF8B0000);
    }
  }
}

// ============================================================================
// CYCLE STATISTICS WIDGET
// ============================================================================

/// Shows statistics about blood flow and cycle
class CycleStatisticsWidget extends StatelessWidget {
  /// Number of bleeding days
  final int bleedingDays;

  /// Average intensity
  final BloodFlowIntensity averageIntensity;

  /// Cycle length
  final int cycleLength;

  /// Accuracy percentage
  final double accuracyPercent;

  const CycleStatisticsWidget({
    Key? key,
    required this.bleedingDays,
    required this.averageIntensity,
    required this.cycleLength,
    required this.accuracyPercent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cycle Statistics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Bleeding Days',
                '$bleedingDays days',
                Icons.calendar_today,
              ),
              _buildStatItem(
                'Avg. Flow',
                averageIntensity.label(),
                Icons.opacity,
              ),
              _buildStatItem('Cycle Length', '$cycleLength days', Icons.repeat),
              _buildStatItem(
                'Accuracy',
                '${accuracyPercent.toStringAsFixed(0)}%',
                Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.redAccent, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
