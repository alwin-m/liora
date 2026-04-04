import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DayLogSheet — iPhone-style bottom sheet for logging a single period day
//  User logs:  flow percentage (slider)  +  pain level (pills)
// ─────────────────────────────────────────────────────────────────────────────

class DayLogSheet extends StatefulWidget {
  final int dayNumber;
  final int totalDays;
  final DateTime date;
  final int initialFlow;   // 0–100
  final int initialPain;   // 0–3
  final void Function(int flowPercent, int painLevel) onSave;

  const DayLogSheet({
    super.key,
    required this.dayNumber,
    required this.totalDays,
    required this.date,
    this.initialFlow = 50,
    this.initialPain = 0,
    required this.onSave,
  });

  @override
  State<DayLogSheet> createState() => _DayLogSheetState();
}

class _DayLogSheetState extends State<DayLogSheet> {
  late double _flow;  // 0.0–100.0
  late int _pain;     // 0–3

  @override
  void initState() {
    super.initState();
    _flow = widget.initialFlow.toDouble();
    _pain = widget.initialPain;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String get _flowEmoji {
    if (_flow < 15) return '🩹';
    if (_flow < 35) return '💧';
    if (_flow < 60) return '🩸';
    if (_flow < 80) return '🩸💧';
    return '🩸🩸';
  }

  String get _flowLabel {
    if (_flow < 15) return 'Spotting';
    if (_flow < 35) return 'Light';
    if (_flow < 60) return 'Medium';
    if (_flow < 80) return 'Heavy';
    return 'Very Heavy';
  }

  Color get _flowColor {
    if (_flow < 35) return const Color(0xFFFFB3C6);
    if (_flow < 60) return const Color(0xFFE67598);
    return const Color(0xFFC1446F);
  }

  String _formatDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}';
  }

  static const _painLabels = ['😌 None', '😐 Mild', '😣 Moderate', '😖 Severe'];
  static const _painColors = [
    Color(0xFFDFF6DD),
    Color(0xFFFFF3CD),
    Color(0xFFFFE3EC),
    Color(0xFFFFCDD2),
  ];
  static const _painText = [
    Color(0xFF4CAF50),
    Color(0xFFF59E0B),
    Color(0xFFE67598),
    Color(0xFFE53935),
  ];

  @override
  Widget build(BuildContext context) {
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
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // ── Title row ──
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE67598),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: const Color(0xFFE67598).withValues(alpha: 0.3), blurRadius: 10)],
              ),
              child: Text(
                'LOG  ·  DAY ${widget.dayNumber}',
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            Text(
              _formatDate(widget.date),
              style: const TextStyle(fontSize: 13, color: Color(0xFFB56180)),
            ),
          ]),
          const SizedBox(height: 24),

          // ── Flow section ──
          Row(children: [
            Text(_flowEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    _flowLabel,
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: _flowColor,
                    ),
                  ),
                  Text(
                    '${_flow.round()}%',
                    style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800,
                      color: _flowColor,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _flowColor,
                    inactiveTrackColor: const Color(0xFFFFD6E4),
                    thumbColor: _flowColor,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _flow,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _flow = v);
                    },
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0%', style: TextStyle(fontSize: 10, color: Color(0xFFB56180))),
                    Text('Flow amount', style: TextStyle(fontSize: 10, color: Color(0xFFB56180))),
                    Text('100%', style: TextStyle(fontSize: 10, color: Color(0xFFB56180))),
                  ],
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 24),

          // ── Pain section ──
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pain level',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFB56180)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(4, (i) {
              final selected = _pain == i;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _pain = i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? _painColors[i] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? _painText[i] : Colors.grey.shade200,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        _painLabels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? _painText[i] : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),

          // ── Save button ──
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
                widget.onSave(_flow.round(), _pain);
              },
              child: const Text('Save Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
