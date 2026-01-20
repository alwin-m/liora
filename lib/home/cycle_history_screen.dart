import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CycleHistoryScreen extends StatefulWidget {
  const CycleHistoryScreen({super.key});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<CycleRecord> cycleHistory = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCycleHistory();
  }

  /// Load cycle history from Firestore
  Future<void> _loadCycleHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Fetch from Firestore (if cycle logs exist)
      final historySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cycleHistory')
          .orderBy('startDate', descending: true)
          .limit(12)
          .get();

      if (!mounted) return;

      final records = <CycleRecord>[];
      for (var doc in historySnapshot.docs) {
        final data = doc.data();
        records.add(CycleRecord(
          id: doc.id,
          startDate: (data['startDate'] as Timestamp).toDate(),
          endDate: data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
          cycleLength: data['cycleLength'] ?? 28,
          periodDuration: data['periodDuration'] ?? 5,
          notes: data['notes'],
        ));
      }

      setState(() {
        cycleHistory = records;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading cycle history: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load cycle history';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cycle History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFE67598)),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: const Color(0xFFE74C3C),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6F6152),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => isLoading = true);
                          _loadCycleHistory();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE67598),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : cycleHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 48,
                            color: const Color(0xFFE8E0D5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No cycle history yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6F6152),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Start logging your cycles to see them here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6F6152),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: cycleHistory.length,
                      itemBuilder: (context, index) {
                        final record = cycleHistory[index];
                        return _CycleHistoryCard(record: record);
                      },
                    ),
    );
  }
}

/// Cycle history record model
class CycleRecord {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;
  final int periodDuration;
  final String? notes;

  CycleRecord({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.cycleLength,
    required this.periodDuration,
    this.notes,
  });
}

/// Cycle history card widget
class _CycleHistoryCard extends StatelessWidget {
  final CycleRecord record;

  const _CycleHistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d, yyyy');
    final startDateText = dateFormatter.format(record.startDate);
    final endDateText = record.endDate != null
        ? dateFormatter.format(record.endDate!)
        : 'Ongoing';

    final daysDuration = record.endDate != null
        ? record.endDate!.difference(record.startDate).inDays + 1
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E0D5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Period Started',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F6152),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      startDateText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.circle,
                size: 12,
                color: Color(0xFFF4C7D8),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Period Ended',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F6152),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      endDateText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (daysDuration != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F6152),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$daysDuration days',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: const Color(0xFFE8E0D5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoBadge(
                label: 'Cycle Length',
                value: '${record.cycleLength} days',
              ),
              _InfoBadge(
                label: 'Period Duration',
                value: '${record.periodDuration} days',
              ),
            ],
          ),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFCF8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8E0D5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6F6152),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.notes!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6F6152),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Info badge widget
class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBadge({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6F6152),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
