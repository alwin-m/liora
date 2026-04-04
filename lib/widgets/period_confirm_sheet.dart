import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PeriodConfirmSheet — iPhone-style sheet for confirming or correcting
//  the predicted period start date.
//  This feeds the Annie Hathaway Algorithm's training loop.
// ─────────────────────────────────────────────────────────────────────────────

class PeriodConfirmSheet extends StatefulWidget {
  final DateTime predictedDate;
  final void Function(DateTime actualDate) onConfirm;
  final VoidCallback? onSkip;

  const PeriodConfirmSheet({
    super.key,
    required this.predictedDate,
    required this.onConfirm,
    this.onSkip,
  });

  @override
  State<PeriodConfirmSheet> createState() => _PeriodConfirmSheetState();
}

class _PeriodConfirmSheetState extends State<PeriodConfirmSheet> {
  DateTime _selectedDate = DateTime.now();
  bool _showDatePicker = false;

  String _formatDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const wd = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${wd[d.weekday - 1]}, ${m[d.month - 1]} ${d.day}';
  }

  int get _deviationDays {
    final norm1 = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final norm2 = DateTime(widget.predictedDate.year, widget.predictedDate.month, widget.predictedDate.day);
    return norm1.difference(norm2).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF6F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.fromLTRB(
          24, 14, 24, MediaQuery.of(context).viewInsets.bottom + 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          Container(
            width: 38, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 20),

          // ── Header icon ──
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3EC),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFFE67598).withValues(alpha: 0.25), blurRadius: 12)],
            ),
            child: const Icon(Icons.water_drop_rounded, color: Color(0xFFE67598), size: 28),
          ),
          const SizedBox(height: 16),

          // ── Title ──
          const Text(
            'Period Started?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF3B1A2A)),
          ),
          const SizedBox(height: 6),
          Text(
            'Predicted: ${_formatDate(widget.predictedDate)}',
            style: const TextStyle(fontSize: 13, color: Color(0xFFB56180)),
          ),
          const SizedBox(height: 24),

          // ── Yes — today button ──
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67598),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                widget.onConfirm(DateTime(today.year, today.month, today.day));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Yes, it started today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(
                    _formatDate(today),
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Different date option ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _showDatePicker
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE67598),
                  side: const BorderSide(color: Color(0xFFE67598), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => setState(() => _showDatePicker = true),
                child: const Text(
                  'It started on a different day',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            secondChild: Column(
              children: [
                // Date picker row (±7 days from today)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3EC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final d = DateTime(today.year, today.month, today.day - 6 + i);
                      final isSelected = _selectedDate.day == d.day &&
                          _selectedDate.month == d.month &&
                          _selectedDate.year == d.year;
                      const days = ['M','T','W','T','F','S','S'];
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedDate = d);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36, height: 52,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE67598) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                days[d.weekday - 1],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? Colors.white : const Color(0xFFB56180),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${d.day}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : const Color(0xFF3B1A2A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                // Deviation badge
                if (_deviationDays != 0)
                  Text(
                    '${_deviationDays > 0 ? '+' : ''}$_deviationDays days vs prediction',
                    style: TextStyle(
                      fontSize: 12,
                      color: _deviationDays.abs() <= 2
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE67598),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67598),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      widget.onConfirm(_selectedDate);
                    },
                    child: Text(
                      'Confirm ${_formatDate(_selectedDate)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Skip ──
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              widget.onSkip?.call();
            },
            child: const Text(
              'Not started yet — skip',
              style: TextStyle(fontSize: 13, color: Color(0xFFB56180), decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
