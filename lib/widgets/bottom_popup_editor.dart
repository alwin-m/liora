import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/smart_prediction_model.dart';
import '../core/cycle_algorithm.dart';
import 'liquid_cube_visualization.dart';

class SmartBottomPopupEditor extends StatefulWidget {
  final DateTime date;
  final Function(DailyLogEntry) onSave;

  const SmartBottomPopupEditor({
    super.key,
    required this.date,
    required this.onSave,
  });

  @override
  State<SmartBottomPopupEditor> createState() => _SmartBottomPopupEditorState();
}

class _SmartBottomPopupEditorState extends State<SmartBottomPopupEditor> {
  FlowLevel _selectedFlow = FlowLevel.none;
  int _painLevel = 0;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(45),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 40,
                offset: const Offset(0, 15),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAirPodsHeader(),
              const SizedBox(height: 32),
              _buildFlowSelector(),
              const SizedBox(height: 32),
              _buildPainSlider(),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirPodsHeader() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Personalize Log",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2D1B4D),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${widget.date.day} ${_getMonthName(widget.date.month)}",
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFlowSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _flowItem(FlowLevel.none, "None"),
        _flowItem(FlowLevel.light, "Light"),
        _flowItem(FlowLevel.medium, "Med"),
        _flowItem(FlowLevel.heavy, "Heavy"),
      ],
    );
  }

  Widget _flowItem(FlowLevel level, String label) {
    final isSelected = _selectedFlow == level;
    return GestureDetector(
      onTap: () => setState(() => _selectedFlow = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE67598).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            LiquidCubeVisualization(
              flowLevel: level,
              size: 44,
              dayType: DayType.period,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                color: isSelected ? const Color(0xFFE67598) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPainSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Pain Sensitivity", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D1B4D))),
            Text("${_painLevel}/10", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE67598))),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFFE67598),
            inactiveTrackColor: const Color(0xFFE67598).withOpacity(0.1),
            thumbColor: const Color(0xFFE67598),
            overlayColor: const Color(0xFFE67598).withOpacity(0.1),
            trackHeight: 6,
          ),
          child: Slider(
            value: _painLevel.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (v) => setState(() => _painLevel = v.toInt()),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        widget.onSave(DailyLogEntry(
          date: widget.date,
          flowLevel: _selectedFlow,
          painLevel: _painLevel,
          periodStatus: PeriodStatus.active,
          isUserEdit: true,
        ));
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF2D1B4D),
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: const Text(
          "Personalize System",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _getMonthName(int m) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[m - 1];
  }
}
