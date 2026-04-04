import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/vial_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DayLogSheet — iPhone-style bottom sheet for logging a single period day
//  Now upgraded with real-time liquid-fill vial animations.
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

class _DayLogSheetState extends State<DayLogSheet> with TickerProviderStateMixin {
  late double _flow;  // 0.0–100.0
  late int _pain;     // 0–3

  late final AnimationController _waveController;
  late final AnimationController _fillController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _flow = widget.initialFlow.toDouble();
    _pain = widget.initialPain;

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fillAnimation = Tween<double>(begin: _flow / 100, end: _flow / 100).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
    );
    
    _fillController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  void _updateFlow(double newValue) {
    HapticFeedback.selectionClick();
    setState(() {
      _flow = newValue;
    });
    
    // Animate the liquid level change
    _fillAnimation = Tween<double>(
      begin: _fillAnimation.value,
      end: newValue / 100,
    ).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
    );
    _fillController.forward(from: 0);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 25, offset: Offset(0, -6))],
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle ──
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // ── Header Row ──
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE67598),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: const Color(0xFFE67598).withValues(alpha: 0.35), blurRadius: 12)],
              ),
              child: Text(
                'LOG  ·  DAY ${widget.dayNumber}',
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900,
                  color: Colors.white, letterSpacing: 0.8,
                ),
              ),
            ),
            const Spacer(),
            Text(
              _formatDate(widget.date),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFB56180)),
            ),
          ]),
          const SizedBox(height: 32),

          // ── Interactive Flow Section ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LARGE INTERACTIVE VIAL
              SizedBox(
                width: 70,
                height: 120,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_fillAnimation, _waveController]),
                  builder: (context, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: VialPainter(
                        fillFraction: _fillAnimation.value,
                        wavePhase: _waveController.value,
                        color: _flowColor,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _flowColor.withValues(alpha: 0.5),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Flow Controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _flowLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800,
                        letterSpacing: 1.2, color: _flowColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_flow.round()}% FLOW',
                      style: TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w900,
                        color: _flowColor, height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _flowColor,
                        inactiveTrackColor: const Color(0xFFFFD6E4),
                        thumbColor: _flowColor,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
                        trackHeight: 10,
                        overlayColor: _flowColor.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: _flow,
                        min: 0,
                        max: 100,
                        divisions: 100, // Smoother slide
                        onChanged: _updateFlow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Pain Section ──
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'PAIN INTENSITY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFFB56180)),
            ),
          ),
          const SizedBox(height: 12),
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
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? _painColors[i] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? _painText[i] : Colors.grey.shade200,
                          width: selected ? 2.0 : 1.5,
                        ),
                        boxShadow: selected ? [
                          BoxShadow(color: _painText[i].withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
                        ] : null,
                      ),
                      child: Text(
                        _painLabels[i].split(' ').last, // Text only for compact fit
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          color: selected ? _painText[i] : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 36),

          // ── Save Button ──
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67598),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                shadowColor: const Color(0xFFE67598).withValues(alpha: 0.4),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                widget.onSave(_flow.round(), _pain);
              },
              child: const Text('SAVE CYCLE LOG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

