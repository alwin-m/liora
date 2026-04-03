import 'package:flutter/material.dart';
import '../models/cycle_record.dart';
import '../models/smart_prediction_model.dart';
import 'liquid_cube_visualization.dart';
import '../core/cycle_algorithm.dart';

class CycleHistorySheet extends StatelessWidget {
  final List<CycleRecord> history;

  const CycleHistorySheet({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          const Text(
            "Cycle History",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D1B4D)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: history.isEmpty 
              ? _buildEmptyState() 
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) => _buildHistoryItem(history[index]),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 12),
          const Text("No cycles recorded yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(CycleRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          const LiquidCubeVisualization(flowLevel: FlowLevel.medium, size: 50, dayType: DayType.period),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${record.startDate.day}/${record.startDate.month}/${record.startDate.year}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Cycle Length: ${record.cycleLength} days",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                record.deviation >= 0 ? "+${record.deviation}" : "${record.deviation}",
                style: TextStyle(
                  fontWeight: FontWeight.w900, 
                  color: record.deviation.abs() <= 1 ? Colors.green : Colors.orange,
                  fontSize: 18,
                ),
              ),
              const Text("days", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}