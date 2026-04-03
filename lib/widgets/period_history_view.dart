/// PERIOD HISTORY VIEW
///
/// Displays historical period cycles with blood flow visualization
/// Shows predictions vs actuals and learning progress

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/period_editor_model.dart';
import '../services/period_editor_provider.dart';
import '../services/ml_learning_service.dart';
import '../widgets/blood_flow_visualization.dart';

class PeriodHistoryView extends StatefulWidget {
  final MLLearningService mlService;

  const PeriodHistoryView({Key? key, required this.mlService})
    : super(key: key);

  @override
  State<PeriodHistoryView> createState() => _PeriodHistoryViewState();
}

class _PeriodHistoryViewState extends State<PeriodHistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadingFuture = Future.delayed(Duration.zero);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Period History & Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Calendar View'),
            Tab(text: 'Cycles'),
            Tab(text: 'Learning'),
          ],
        ),
      ),
      body: Consumer<PeriodEditorProvider>(
        builder: (context, provider, _) {
          return FutureBuilder(
            future: _loadingFuture,
            builder: (context, snapshot) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildCalendarView(provider),
                  _buildCyclesView(provider),
                  _buildLearningView(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ======== TAB 1: CALENDAR VIEW ========

  Widget _buildCalendarView(PeriodEditorProvider provider) {
    final cycleHistory = provider.cycleHistory;

    if (cycleHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No cycle history yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Edit period dates to start tracking',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Latest cycle calendar
        if (cycleHistory.isNotEmpty)
          _buildLatestCycleCalendar(cycleHistory.last),
        const SizedBox(height: 24),
        // Statistics
        _buildCalendarStatistics(cycleHistory),
      ],
    );
  }

  Widget _buildLatestCycleCalendar(PeriodCycleEdit latestCycle) {
    final daysInMonth = DateTime(
      latestCycle.actualStartDate.year,
      latestCycle.actualStartDate.month + 1,
      0,
    ).day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latest Cycle',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        BloodFlowCalendarView(
          daysInMonth: daysInMonth,
          currentDay: DateTime.now().day,
          getIntensityForDay: (day) {
            final date = DateTime(
              latestCycle.actualStartDate.year,
              latestCycle.actualStartDate.month,
              day,
            );

            final edit = latestCycle.dailyEdits.firstWhere(
              (e) => e.date == date,
              orElse: () => DailyPeriodEdit(
                date: date,
                hadBleeding: false,
                flowIntensity: BloodFlowIntensity.none,
                painLevel: 0,
                wasPredicted: false,
                deviationDays: 0,
                editedAt: DateTime.now(),
              ),
            );

            return edit.hadBleeding
                ? edit.flowIntensity
                : BloodFlowIntensity.none;
          },
        ),
      ],
    );
  }

  Widget _buildCalendarStatistics(List<PeriodCycleEdit> cycleHistory) {
    final recentCycles = cycleHistory.length >= 3
        ? cycleHistory.sublist(cycleHistory.length - 3)
        : cycleHistory;

    final avgCycleLength =
        (recentCycles
                    .map(
                      (c) =>
                          c.actualEndDate.difference(c.actualStartDate).inDays,
                    )
                    .reduce((a, b) => a + b) /
                recentCycles.length)
            .toInt();

    final avgPeriodLength =
        (recentCycles
                    .map((c) => c.getActualPeriodLength())
                    .reduce((a, b) => a + b) /
                recentCycles.length)
            .toInt();

    final avgAccuracy =
        (recentCycles
                    .map((c) => c.calculateAccuracy())
                    .reduce((a, b) => a + b) /
                recentCycles.length)
            .toStringAsFixed(1);

    return CycleStatisticsWidget(
      bleedingDays: avgPeriodLength,
      averageIntensity: BloodFlowIntensity.medium,
      cycleLength: avgCycleLength,
      accuracyPercent: double.parse(avgAccuracy),
    );
  }

  // ======== TAB 2: CYCLES VIEW ========

  Widget _buildCyclesView(PeriodEditorProvider provider) {
    final cycleHistory = provider.cycleHistory;

    if (cycleHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No cycle data yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cycleHistory.length,
      reverse: true, // Show latest first
      itemBuilder: (context, index) {
        final cycle = cycleHistory[index];
        return _buildCycleCard(cycle);
      },
    );
  }

  Widget _buildCycleCard(PeriodCycleEdit cycle) {
    final accuracy = cycle.calculateAccuracy();
    final periodLength = cycle.getActualPeriodLength();
    final startDiff = cycle.actualStartDate
        .difference(cycle.predictedStartDate)
        .inDays;

    final accuracyColor = accuracy >= 80
        ? Colors.green
        : (accuracy >= 60 ? Colors.orange : Colors.red);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(cycle.actualStartDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${periodLength} days',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accuracyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${accuracy.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: accuracyColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),

            // Prediction comparison
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Predicted',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(cycle.predictedStartDate),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: startDiff < 0
                            ? Colors.blue.shade50
                            : (startDiff > 0
                                  ? Colors.orange.shade50
                                  : Colors.green.shade50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        startDiff == 0
                            ? 'On time'
                            : '$startDiff day${startDiff.abs() > 1 ? 's' : ''} ${startDiff < 0 ? 'early' : 'late'}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: startDiff < 0
                              ? Colors.blue
                              : (startDiff > 0 ? Colors.orange : Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Actual',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(cycle.actualStartDate),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Blood flow visualization
            _buildCycleBloodFlowRow(cycle),
            const SizedBox(height: 12),

            // Edits made
            if (cycle.dailyEdits.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '${cycle.dailyEdits.length} entries edited',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleBloodFlowRow(PeriodCycleEdit cycle) {
    final bleedingDays = cycle.dailyEdits.where((e) => e.hadBleeding).toList();

    if (bleedingDays.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'No bleeding data recorded',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bleedingDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final day = bleedingDays[index];
          return Tooltip(
            message:
                '${day.date.day}: ${day.flowIntensity.label()} (Pain: ${day.painLevel}/10)',
            child: BloodFlowCube(
              intensity: day.flowIntensity,
              day: day.date.day,
              size: 32,
            ),
          );
        },
      ),
    );
  }

  // ======== TAB 3: LEARNING VIEW ========

  Widget _buildLearningView() {
    final stats = widget.mlService.getLearningStatistics();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main progress card
        _buildProgressCard(stats),
        const SizedBox(height: 24),

        // Accuracy metrics
        _buildAccuracyMetrics(stats),
        const SizedBox(height: 24),

        // Learning statistics
        _buildLearningStatistics(stats),
      ],
    );
  }

  Widget _buildProgressCard(LearningStatistics stats) {
    final progress = stats.getProgressPercentage();
    final estimatedCycles = stats.getEstimatedCyclesToTarget();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prediction Learning Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 80 ? Colors.green : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Current vs Target
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(stats.currentAccuracy * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward, color: Colors.grey.shade400),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Target',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(stats.targetAccuracy * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estimate
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      estimatedCycles > 100
                          ? 'Keep logging your cycles to improve accuracy'
                          : 'Est. $estimatedCycles more cycles to reach ${(stats.targetAccuracy * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyMetrics(LearningStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accuracy Metrics',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricItem(
                  'Latest',
                  '${(stats.currentAccuracy * 100).toStringAsFixed(0)}%',
                ),
                _buildMetricItem(
                  'Trend',
                  '${stats.accuracyTrend > 0 ? '+' : ''}${stats.accuracyTrend.toStringAsFixed(1)}%',
                  color: stats.accuracyTrend > 0 ? Colors.green : Colors.orange,
                ),
                _buildMetricItem('Cycles', '${stats.totalCyclesLearned}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value, {
    Color color = Colors.redAccent,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLearningStatistics(LearningStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Statistics',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Updates', '${stats.totalUpdates}'),
            const SizedBox(height: 12),
            _buildStatRow(
              'Learning Rate',
              '${(stats.learningRate * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              'Data Points',
              '${stats.totalCyclesLearned * 5} (${stats.totalCyclesLearned} cycles)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ======== HELPERS ========

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
