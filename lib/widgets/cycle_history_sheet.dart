import 'package:flutter/material.dart';
import '../core/cycle_session.dart';
import '../models/hathaway_cycle_log.dart';
import '../models/hathaway_day_log.dart';

class CycleHistorySheet extends StatelessWidget {
  const CycleHistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = CycleSession.annieLogs;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF6F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history_rounded, color: Color(0xFFE67598), size: 22),
              const SizedBox(width: 8),
              const Text(
                "Cycle History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFE67598), letterSpacing: 0.5),
              ),
              if (CycleSession.isAnnieTrained) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE67598).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE67598), width: 0.5),
                  ),
                  child: const Text('Trained', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFE67598))),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No cycle history logged yet", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _HistoryItem(log: log);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final HathawayCycleLog log;

  const _HistoryItem({required this.log});

  Color _getDeviationColor() {
    if (log.deviation.abs() <= 1) return const Color(0xFF4CAF50);
    if (log.deviation.abs() <= 3) return const Color(0xFFF59E0B);
    return const Color(0xFFE67598);
  }

  String _formatDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dev = log.deviation;
    final devText = dev == 0 ? "On Time" : "${dev.abs()}d ${dev > 0 ? 'late' : 'early'}";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(log.actualStart ?? log.predictedStart),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF3B1A2A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDeviationColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  devText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _getDeviationColor()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Flow cubes
          if (log.hasDayLogs) ...[
            const Text("FLOW PROFILE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            Row(
              children: log.dayLogs.map((day) => _FlowCube(day: day)).toList(),
            ),
          ] else
            const Text("No flow data logged", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),

          const SizedBox(height: 12),
          Row(
            children: [
              _infoTile(Icons.loop_rounded, "${log.actualCycleLength ?? '--'}d Cycle"),
              const SizedBox(width: 15),
              _infoTile(Icons.calendar_view_day_rounded, "${log.actualPeriodLength ?? '--'}d Period"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFB56180)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFFB56180), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _FlowCube extends StatelessWidget {
  final HathawayDayLog day;

  const _FlowCube({required this.day});

  @override
  Widget build(BuildContext context) {
    final opacity = (day.flowPercent / 100.0).clamp(0.1, 1.0);
    return Tooltip(
      message: "Day ${day.dayNumber}: ${day.flowPercent}% Flow",
      child: Container(
        width: 18,
        height: 18,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE67598).withOpacity(opacity),
          borderRadius: BorderRadius.circular(4),
          border: day.painLevel > 1 
              ? Border.all(color: const Color(0xFFC1446F), width: 1.5) 
              : null,
        ),
        child: day.painLevel > 1 
            ? const Center(child: Icon(Icons.flash_on, size: 10, color: Colors.white))
            : null,
      ),
    );
  }
}