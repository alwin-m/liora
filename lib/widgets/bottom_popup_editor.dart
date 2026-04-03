import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/smart_prediction_model.dart';
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
  PeriodStatus _status = PeriodStatus.active;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildFlowSelector(),
                const SizedBox(height: 32),
                _buildPainSlider(),
                const SizedBox(height: 40),
                _buildSaveButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Selected Date", style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text(
              "${widget.date.day} ${_getMonth(widget.date.month)}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2D1B4D)),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFlowSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Confirm Flow Level", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D1B4D))),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _flowChip(FlowLevel.none, "None"),
            _flowChip(FlowLevel.light, "Light"),
            _flowChip(FlowLevel.medium, "Medium"),
            _flowChip(FlowLevel.heavy, "Heavy"),
          ],
        ),
      ],
    );
  }

  Widget _flowChip(FlowLevel level, String label) {
    final isSelected = _selectedFlow == level;
    return GestureDetector(
      onTap: () => setState(() => _selectedFlow = level),
      child: Column(
        children: [
          LiquidCubeVisualization(
            flowLevel: level, 
            size: 60,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.red : Colors.grey,
            ),
          ),
        ],
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
            const Text("Pain Intensity", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D1B4D))),
            Text("${_painLevel}/10", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: _painLevel.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: Colors.red,
          inactiveColor: Colors.red.withOpacity(0.1),
          onChanged: (v) => setState(() => _painLevel = v.toInt()),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          final entry = DailyLogEntry(
            date: widget.date,
            flowLevel: _selectedFlow,
            painLevel: _painLevel,
            periodStatus: _status,
            isUserEdit: true,
          );
          widget.onSave(entry);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D1B4D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Text("Save Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  String _getMonth(int m) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[m - 1];
  }
}
