import 'package:flutter/material.dart';
import '../core/cycle_session.dart';
import '../models/smart_prediction_model.dart';
import '../widgets/liquid_cube_visualization.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = CycleSession.dailyLogs;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Cycle History",
          style: TextStyle(
            color: Color(0xFF2D1B4D),
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
      ),
      body: logs.isEmpty 
        ? _buildEmptyState()
        : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[logs.length - 1 - index]; // Reverse chronological
            return _buildHistoryItem(log);
          },
        ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No logs recorded yet",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(DailyLogEntry log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          LiquidCubeVisualization(flowLevel: log.flowLevel, size: 60),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${log.date.day}/${log.date.month}/${log.date.year}",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                Text(
                  "Flow: ${log.flowLevel.name}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (log.deviation != DeviationType.none)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Deviation: ${log.deviation.name}",
                      style: TextStyle(color: Colors.orange[800], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              const Text("Pain", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(
                "${log.painLevel}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
