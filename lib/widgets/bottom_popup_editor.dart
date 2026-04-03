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
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        padding: EdgeInsets.fromLTRB(32, 40, 32, MediaQuery.of(context).padding.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 48),
            _buildFlowSection(),
            const SizedBox(height: 40),
            _buildPainSection(),
            const SizedBox(height: 48),
            _buildInteractiveSave(),
          ],
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
            const Text("DAILY LOG", style: TextStyle(letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              "${widget.date.day} ${_getMonth(widget.date.month)}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2D1B4D)),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildFlowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Confirm Intensity", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2D1B4D))),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _flowNode(FlowLevel.none, "None"),
              _flowNode(FlowLevel.spotting, "Spotting"),
              _flowNode(FlowLevel.light, "Light"),
              _flowNode(FlowLevel.medium, "Medium"),
              _flowNode(FlowLevel.heavy, "Heavy"),
              _flowNode(FlowLevel.extreme, "Extreme"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _flowNode(FlowLevel level, String label) {
    final isSelected = _selectedFlow == level;
    return GestureDetector(
      onTap: () => setState(() => _selectedFlow = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D1B4D) : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[200]!),
        ),
        child: Column(
          children: [
             LiquidCubeVisualization(
               flowLevel: level, 
               size: 40,
               dayType: DayType.period,
             ),
             const SizedBox(height: 12),
             Text(
               label,
               style: TextStyle(
                 fontSize: 11,
                 fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                 color: isSelected ? Colors.white : Colors.grey,
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildPainSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Pain Level", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2D1B4D))),
            Text("${_painLevel}/10", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE63946))),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF2D1B4D),
            inactiveTrackColor: Colors.grey[100],
            thumbColor: const Color(0xFF2D1B4D),
            overlayColor: const Color(0xFF2D1B4D).withOpacity(0.1),
            trackHeight: 6,
          ),
          child: Slider(
            value: _painLevel.toDouble(),
            min: 0, max: 10, divisions: 10,
            onChanged: (v) => setState(() => _painLevel = v.toInt()),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveSave() {
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
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF2D1B4D),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2D1B4D).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        alignment: Alignment.center,
        child: const Text("Save Entry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }

  String _getMonth(int m) {
    const mths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return mths[m - 1];
  }
}
