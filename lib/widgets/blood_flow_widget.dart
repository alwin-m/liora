import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  BloodFlowWidget
//  Shows animated liquid-fill vials for each day of the menstrual period.
//  • isCurrentPeriod = true  → containers represent TODAY's active cycle days
//  • isCurrentPeriod = false → containers represent the UPCOMING period days
//    (covers normal, fertile, and ovulation days – no special styling added
//     for fertile/ovulation per design spec; just show upcoming forecast)
// ─────────────────────────────────────────────────────────────────────────────

class BloodFlowWidget extends StatefulWidget {
  final int periodLength;
  final int flowIntensity;       // 0=light 1=medium 2=heavy
  final DateTime periodStartDate; // current period start OR next period start
  final int todayPeriodDay;       // 0 if not in period; 1..N if in period
  final bool isCurrentPeriod;

  const BloodFlowWidget({
    super.key,
    required this.periodLength,
    required this.flowIntensity,
    required this.periodStartDate,
    required this.todayPeriodDay,
    required this.isCurrentPeriod,
  });

  @override
  State<BloodFlowWidget> createState() => _BloodFlowWidgetState();
}

class _BloodFlowWidgetState extends State<BloodFlowWidget>
    with TickerProviderStateMixin {

  late final AnimationController _fillController;
  late final AnimationController _waveController;
  late final List<Animation<double>> _fillAnimations;

  // Biologically-accurate flow curves (fraction of container filled)
  static const Map<int, List<double>> _flowProfiles = {
    0: [0.30, 0.45, 0.30, 0.20, 0.12], // light
    1: [0.45, 0.70, 0.60, 0.40, 0.22], // medium
    2: [0.65, 0.90, 0.80, 0.55, 0.30], // heavy
  };

  List<double> get _dayFractions {
    final profile = _flowProfiles[widget.flowIntensity] ?? _flowProfiles[1]!;
    return List.generate(
      widget.periodLength,
      (i) => i < profile.length ? profile[i] : profile.last * 0.5,
    );
  }

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fillController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.periodLength * 300),
    )..forward();

    final fractions = _dayFractions;
    _fillAnimations = List.generate(fractions.length, (i) {
      final s = (i * 0.18).clamp(0.0, 0.9);
      final e = (s + 0.25).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: fractions[i]).animate(
        CurvedAnimation(
          parent: _fillController,
          curve: Interval(s, e, curve: Curves.easeOutCubic),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fillController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // ─── Tap → iPhone-style bottom sheet ───────────────────────────────────────
  void _onDayTap(BuildContext ctx, int dayIndex) {
    HapticFeedback.lightImpact();
    final fractions = _dayFractions;
    final dayNumber = dayIndex + 1;
    final isToday =
        widget.isCurrentPeriod && widget.todayPeriodDay == dayNumber;
    final dayDate = widget.periodStartDate.add(Duration(days: dayIndex));

    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (_) => _FlowDetailSheet(
        dayNumber: dayNumber,
        totalDays: widget.periodLength,
        fraction: fractions[dayIndex],
        flowIntensity: widget.flowIntensity,
        isToday: isToday,
        isCurrentPeriod: widget.isCurrentPeriod,
        dayDate: dayDate,
        waveController: _waveController,
      ),
    );
  }

  // ─── Status pill row ────────────────────────────────────────────────────────
  Widget _statusRow() {
    if (widget.isCurrentPeriod) {
      return Row(children: [
        _pill(
          label: 'PERIOD · DAY ${widget.todayPeriodDay}',
          bgColor: const Color(0xFFE67598),
          textColor: Colors.white,
          dotColor: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          'of ${widget.periodLength} days',
          style: const TextStyle(fontSize: 12, color: Color(0xFFB56180)),
        ),
      ]);
    }

    final today = DateTime.now();
    final daysUntil = widget.periodStartDate
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;

    return Row(children: [
      _pill(
        label: 'NORMAL DAY',
        bgColor: const Color(0xFFDFF6DD),
        textColor: const Color(0xFF4CAF50),
        dotColor: const Color(0xFF4CAF50),
      ),
      const SizedBox(width: 8),
      Text(
        daysUntil > 0
            ? 'Next period in $daysUntil days'
            : 'Period starting soon',
        style: const TextStyle(fontSize: 12, color: Color(0xFFB56180)),
      ),
    ]);
  }

  Widget _pill({
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color dotColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.8,
          ),
        ),
      ]),
    );
  }

  // ─── Intensity badge ────────────────────────────────────────────────────────
  Widget _intensityBadge() {
    const labels = ['Light', 'Medium', 'Heavy'];
    const colors = [Color(0xffffc1d8), Color(0xffE67598), Color(0xffC1446F)];
    final idx = widget.flowIntensity.clamp(0, 2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors[idx].withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colors[idx], width: 1),
      ),
      child: Text(
        labels[idx],
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors[idx],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: const Color(0xFFFFE3EC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(children: [
            const Icon(Icons.water_drop_rounded,
                color: Color(0xFFE67598), size: 20),
            const SizedBox(width: 8),
            const Text(
              'DAILY FLOW FORECAST',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Color(0xFFE67598),
              ),
            ),
            const Spacer(),
            _intensityBadge(),
          ]),
          const SizedBox(height: 12),

          // ── Status row ──
          _statusRow(),
          const SizedBox(height: 6),

          // ── Upcoming label (non-period days) ──
          if (!widget.isCurrentPeriod)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'Expected flow for next cycle',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFFB56180).withValues(alpha: 0.75),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // ── Vial containers ──
          AnimatedBuilder(
            animation: Listenable.merge([_fillController, _waveController]),
            builder: (ctx, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_fillAnimations.length, (i) {
                  final isToday =
                      widget.isCurrentPeriod && widget.todayPeriodDay == i + 1;
                  return GestureDetector(
                    onTap: () => _onDayTap(ctx, i),
                    child: _DayVial(
                      label: 'Day ${i + 1}',
                      fillFraction: _fillAnimations[i].value,
                      wavePhase: _waveController.value,
                      phaseOffset: i * 0.18,
                      isToday: isToday,
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 12),

          // ── Legend ──
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.touch_app_rounded,
                size: 13, color: const Color(0xFFB56180).withValues(alpha: 0.7)),
            const SizedBox(width: 5),
            Text(
              'Tap a day to see expected flow details',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFFB56180).withValues(alpha: 0.8),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _DayVial – single tappable liquid container
// ─────────────────────────────────────────────────────────────────────────────
class _DayVial extends StatelessWidget {
  final String label;
  final double fillFraction;
  final double wavePhase;
  final double phaseOffset;
  final bool isToday;

  const _DayVial({
    required this.label,
    required this.fillFraction,
    required this.wavePhase,
    required this.phaseOffset,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    const double h = 80.0;
    const double w = 36.0;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Today badge (always rendered, invisible when not today → keeps alignment)
      Opacity(
        opacity: isToday ? 1.0 : 0.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE67598),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE67598).withValues(alpha: 0.35),
                blurRadius: 6,
              )
            ],
          ),
          child: const Text(
            'TODAY',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),

      // Vial
      SizedBox(
        width: w,
        height: h,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CustomPaint(
            painter: _LiquidPainter(
              fillFraction: fillFraction,
              wavePhase: wavePhase + phaseOffset,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isToday
                      ? const Color(0xFFE67598)
                      : const Color(0xFFE67598).withValues(alpha: 0.45),
                  width: isToday ? 2.0 : 1.5,
                ),
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE67598).withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),

      const SizedBox(height: 6),

      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
          color: isToday
              ? const Color(0xFFE67598)
              : const Color(0xFFB56180),
        ),
      ),

      AnimatedOpacity(
        opacity: fillFraction > 0.02 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Text(
          '${(fillFraction * 100).round()}%',
          style: TextStyle(
            fontSize: 9,
            color: isToday
                ? const Color(0xFFE67598)
                : const Color(0xFFE67598).withValues(alpha: 0.7),
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _LiquidPainter – sinusoidal wave fill
// ─────────────────────────────────────────────────────────────────────────────
class _LiquidPainter extends CustomPainter {
  final double fillFraction;
  final double wavePhase;

  const _LiquidPainter({required this.fillFraction, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    if (fillFraction <= 0) return;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE57373).withValues(alpha: 0.75),
          const Color(0xFFE67598).withValues(alpha: 0.90),
          const Color(0xFFC1446F),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final waveH = size.height * 0.045;
    final baseY = size.height * (1.0 - fillFraction);
    final path = Path()..moveTo(0, baseY);

    for (double x = 0; x <= size.width; x++) {
      path.lineTo(
        x,
        baseY + sin((x / size.width) * 2 * pi + wavePhase * 2 * pi) * waveH,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Shimmer highlight
    final shimmer = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final sp = Path()
      ..moveTo(size.width * 0.1, baseY - 2)
      ..quadraticBezierTo(size.width * 0.35, baseY - 6, size.width * 0.55, baseY - 2)
      ..lineTo(size.width * 0.55, baseY + 3)
      ..quadraticBezierTo(size.width * 0.35, baseY + 7, size.width * 0.1, baseY + 3)
      ..close();
    canvas.drawPath(sp, shimmer);
  }

  @override
  bool shouldRepaint(_LiquidPainter old) =>
      old.fillFraction != fillFraction || old.wavePhase != wavePhase;
}

// ─────────────────────────────────────────────────────────────────────────────
//  _FlowDetailSheet – iPhone-style compact bottom popup
// ─────────────────────────────────────────────────────────────────────────────
class _FlowDetailSheet extends StatefulWidget {
  final int dayNumber;
  final int totalDays;
  final double fraction;
  final int flowIntensity;
  final bool isToday;
  final bool isCurrentPeriod;
  final DateTime dayDate;
  final AnimationController waveController;

  const _FlowDetailSheet({
    required this.dayNumber,
    required this.totalDays,
    required this.fraction,
    required this.flowIntensity,
    required this.isToday,
    required this.isCurrentPeriod,
    required this.dayDate,
    required this.waveController,
  });

  @override
  State<_FlowDetailSheet> createState() => _FlowDetailSheetState();
}

class _FlowDetailSheetState extends State<_FlowDetailSheet>
    with SingleTickerProviderStateMixin {

  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _progressAnim = Tween<double>(begin: 0, end: widget.fraction).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic),
    );
    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  String get _flowLabel {
    final p = (widget.fraction * 100).round();
    if (p >= 80) return 'Very Heavy';
    if (p >= 60) return 'Heavy';
    if (p >= 40) return 'Medium';
    if (p >= 20) return 'Light';
    return 'Spotting';
  }

  String _insight(int day) {
    switch (day) {
      case 1:
        return 'Flow typically builds on day 1. Rest, stay warm, and drink plenty of water. 🌸';
      case 2:
        return 'Flow usually peaks on day 2. Iron-rich foods like spinach and lentils help replenish. 💧';
      case 3:
        return 'Peak flow continues. Be gentle with yourself — light stretching can ease cramps. 🌷';
      case 4:
        return 'Flow begins to taper. Energy levels may start returning. ✨';
      default:
        return 'Flow is winding down. You\'re almost through this cycle! 🌿';
    }
  }

  String _formatDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.fraction * 100).round();

    return Container(
      // ── iPhone-style rounded sheet ──
      decoration: const BoxDecoration(
        color: Color(0xFFFDF6F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          )
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Drag handle pill ──
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // ── Day badge + counter ──
          Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: widget.isToday
                    ? const Color(0xFFE67598)
                    : const Color(0xFFFFE3EC),
                borderRadius: BorderRadius.circular(22),
                boxShadow: widget.isToday
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE67598).withValues(alpha: 0.3),
                          blurRadius: 12,
                        )
                      ]
                    : null,
              ),
              child: Text(
                widget.isToday
                    ? 'TODAY  ·  DAY ${widget.dayNumber}'
                    : 'UPCOMING  ·  DAY ${widget.dayNumber}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: widget.isToday
                      ? Colors.white
                      : const Color(0xFFE67598),
                ),
              ),
            ),
            const Spacer(),
            Text(
              'of ${widget.totalDays} days',
              style: const TextStyle(fontSize: 13, color: Color(0xFFB56180)),
            ),
          ]),

          const SizedBox(height: 5),

          // ── Sub-label ──
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.isToday
                  ? 'Period in progress'
                  : 'Expected ${_formatDate(widget.dayDate)}',
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFFB56180)),
            ),
          ),

          const SizedBox(height: 22),

          // ── Flow visual row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mini animated vial
              AnimatedBuilder(
                animation: widget.waveController,
                builder: (_, __) => SizedBox(
                  width: 52,
                  height: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (_, __) => CustomPaint(
                        painter: _LiquidPainter(
                          fillFraction: _progressAnim.value,
                          wavePhase: widget.waveController.value,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE67598)
                                  .withValues(alpha: 0.55),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Percentage + label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (_, __) => Text(
                        '${(_progressAnim.value * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE67598),
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _flowLabel,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC1446F),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Expected flow volume',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFFB56180)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Animated progress bar ──
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progressAnim.value,
                    backgroundColor: const Color(0xFFFFD6E4),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFE67598)),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Low',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFFB56180))),
                    Text('$pct% of peak',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB56180),
                            fontWeight: FontWeight.w600)),
                    const Text('Peak',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFFB56180))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Insight card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💧', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _insight(widget.dayNumber),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8B4062),
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
