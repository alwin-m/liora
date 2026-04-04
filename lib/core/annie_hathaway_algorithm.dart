import '../models/hathaway_cycle_log.dart';
import 'cycle_algorithm.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Annie Hathaway Algorithm
//  Named after the actor — an adaptive, self-learning, fully on-device
//  menstrual cycle prediction engine.
//
//  Design constraints:
//  • Pure Dart math — zero ML frameworks, zero internet required
//  • Optimised for 4–8 GB RAM phones
//  • Works offline from the first install
//  • Falls back gracefully to the static CycleAlgorithm until trained
//  • Minimum 2 confirmed cycles needed before learning kicks in
// ─────────────────────────────────────────────────────────────────────────────

class AnnieHathawayAlgorithm {
  // ── Constants ──────────────────────────────────────────────────────────────
  static const int _minCycles = 2;          // Min confirmed cycles to start learning
  static const int _minCycleLength = 18;    // Biological safety guard (days)
  static const int _maxCycleLength = 45;    // Biological safety guard (days)
  static const int _maxBiasCorrection = 5;  // Cap systematic deviation fix (days)

  /// Recency weights — most recent cycle gets 1.0, older cycles get less.
  static const List<double> _weights = [1.0, 0.65, 0.45, 0.28, 0.15];

  /// Static fallback flow profile (bell curve, medium intensity)
  static const List<double> _staticFlow = [
    0.35, 0.70, 0.60, 0.42, 0.25, 0.12, 0.05
  ];

  final List<HathawayCycleLog> _logs;
  final CycleAlgorithm _fallback;

  const AnnieHathawayAlgorithm({
    required List<HathawayCycleLog> logs,
    required CycleAlgorithm fallback,
  })  : _logs = logs,
        _fallback = fallback;

  // ── Training data ───────────────────────────────────────────────────────────

  /// Confirmed cycles sorted newest-first, with outliers filtered.
  List<HathawayCycleLog> get _trained => _logs
      .where((c) =>
          c.hasActualStart &&
          c.actualCycleLength != null &&
          c.actualCycleLength! >= _minCycleLength &&
          c.actualCycleLength! <= _maxCycleLength)
      .toList()
    ..sort((a, b) => b.actualStart!.compareTo(a.actualStart!));

  /// Whether Annie has enough real data to override static predictions.
  bool get isTrained => _trained.length >= _minCycles;

  /// How many clean cycles Annie has learned from.
  int get trainingCycleCount => _trained.length;

  // ── Cycle length ────────────────────────────────────────────────────────────

  /// Recency-weighted average cycle length from confirmed data.
  int get predictedCycleLength {
    final cycles = _trained;
    if (cycles.isEmpty) return _fallback.adjustedCycleLength;
    double wSum = 0, lenSum = 0;
    for (int i = 0; i < cycles.length; i++) {
      final w = i < _weights.length ? _weights[i] : _weights.last;
      lenSum += cycles[i].actualCycleLength! * w;
      wSum += w;
    }
    return (lenSum / wSum).round().clamp(_minCycleLength, _maxCycleLength);
  }

  // ── Bias correction ─────────────────────────────────────────────────────────

  /// Systematic start-date bias from last 3 cycles.
  /// Positive → user tends to start LATER than predicted.
  /// Negative → user tends to start EARLIER.
  int get _biasCorrection {
    final cycles = _trained;
    if (cycles.length < _minCycles) return 0;
    final recent = cycles.take(3).toList();
    final avgDev = recent.fold<int>(0, (s, c) => s + c.deviation) /
        recent.length;
    return avgDev.round().clamp(-_maxBiasCorrection, _maxBiasCorrection);
  }

  // ── Period length ───────────────────────────────────────────────────────────

  int get predictedPeriodLength {
    final withLen = _trained.where((c) => c.actualPeriodLength != null).toList();
    if (withLen.isEmpty) return _fallback.adjustedPeriodLength;
    double wSum = 0, lenSum = 0;
    for (int i = 0; i < withLen.length; i++) {
      final w = i < _weights.length ? _weights[i] : _weights.last;
      lenSum += withLen[i].actualPeriodLength! * w;
      wSum += w;
    }
    return (lenSum / wSum).round().clamp(2, 10);
  }

  // ── Next period date ────────────────────────────────────────────────────────

  /// Today-aware next period prediction.
  DateTime getNextPeriodDate() {
    if (!isTrained) return _fallback.getNextPeriodDate();

    final latest = _trained.first.actualStart!;
    final today = _normalize(DateTime.now());
    final latestNorm = _normalize(latest);

    final cycleLen = predictedCycleLength;
    final bias = _biasCorrection;

    final daysSince = today.difference(latestNorm).inDays;
    int ahead = daysSince ~/ cycleLen + 1;
    DateTime next =
        latestNorm.add(Duration(days: ahead * cycleLen + bias));

    while (next.isBefore(today)) {
      ahead++;
      next = latestNorm.add(Duration(days: ahead * cycleLen + bias));
    }
    return next;
  }

  /// Direct prediction: given a confirmed start, predict the next one.
  DateTime predictNextFrom(DateTime confirmedStart) {
    if (!isTrained) return _fallback.getNextPeriodDate();
    return _normalize(confirmedStart)
        .add(Duration(days: predictedCycleLength + _biasCorrection));
  }

  // ── Daily flow profile ──────────────────────────────────────────────────────

  /// Returns the expected flow fraction (0.0–1.0) for each day of the next
  /// period, learned from the user's own logged flow percentages.
  List<double> predictDailyFlowProfile(int periodLength) {
    final withLogs = _trained.where((c) => c.hasDayLogs).toList();

    if (withLogs.isEmpty) {
      // Fall back to static bell-curve profile
      return List.generate(
        periodLength,
        (i) => i < _staticFlow.length ? _staticFlow[i] : _staticFlow.last * 0.5,
      );
    }

    // Recency-weighted per-day averages
    final Map<int, double> sumMap = {};
    final Map<int, double> wMap = {};

    for (int ci = 0; ci < withLogs.length; ci++) {
      final w = ci < _weights.length ? _weights[ci] : _weights.last;
      for (final dl in withLogs[ci].dayLogs) {
        sumMap[dl.dayNumber] = (sumMap[dl.dayNumber] ?? 0) + (dl.flowPercent / 100.0) * w;
        wMap[dl.dayNumber] = (wMap[dl.dayNumber] ?? 0) + w;
      }
    }

    return List.generate(periodLength, (i) {
      final dn = i + 1;
      if (sumMap.containsKey(dn)) {
        return (sumMap[dn]! / wMap[dn]!).clamp(0.0, 1.0);
      }
      return i < _staticFlow.length ? _staticFlow[i] : 0.05;
    });
  }

  // ── Status labels ───────────────────────────────────────────────────────────

  /// Human-readable status for UI badges.
  String get statusLabel {
    if (!isTrained) return 'Learning…';
    if (trainingCycleCount < 4) return 'Personalising';
    return 'Personalised';
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
}
