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

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cycle History')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        title: const Text(
          'Cycle History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFFDFCF8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cycleHistory')
            .orderBy('startDate', descending: true)
            .limit(24)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFFE67598)),
                  strokeWidth: 2.5,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Color(0xFFE74C3C),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load cycle history',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F6152),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67598),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: const Color(0xFFE8E0D5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No cycle history yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your logged cycles will appear here. Start tracking to build your history!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6F6152),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final startDate =
                  (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now();
              final endDate =
                  (data['endDate'] as Timestamp?)?.toDate();
              final cycleLength = data['cycleLength'] as int? ?? 28;
              final periodDuration = data['periodDuration'] as int? ?? 5;
              final notes = data['notes'] as String? ?? '';

              final duration = endDate != null
                  ? endDate.difference(startDate).inDays + 1
                  : periodDuration;

              return _CycleHistoryCard(
                startDate: startDate,
                endDate: endDate,
                duration: duration,
                cycleLength: cycleLength,
                notes: notes,
              );
            },
          );
        },
      ),
    );
  }
}

/// Single cycle history card
class _CycleHistoryCard extends StatelessWidget {
  final DateTime startDate;
  final DateTime? endDate;
  final int duration;
  final int cycleLength;
  final String notes;

  const _CycleHistoryCard({
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.cycleLength,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d');
    final monthYearFormatter = DateFormat('MMMM yyyy');

    final startMonthYear = monthYearFormatter.format(startDate);
    final startDay = dateFormatter.format(startDate);
    final endDay = endDate != null ? dateFormatter.format(endDate!) : null;

    // Check if same month
    final sameMonth = endDate != null &&
        startDate.year == endDate!.year &&
        startDate.month == endDate!.month;

    String dateRange;
    if (endDate != null) {
      if (sameMonth) {
        dateRange = '$startDay – $endDay';
      } else {
        dateRange = '$startDay – ${dateFormatter.format(endDate!)}';
      }
    } else {
      dateRange = startDay;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E0D5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Month/Year + Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startMonthYear,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F6152),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateRange,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4C7D8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$duration days',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE67598),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Cycle Length',
                    value: '$cycleLength days',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    label: 'Period Duration',
                    value: '$duration days',
                  ),
                ),
              ],
            ),

            // Notes (if any)
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6F6152),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notes,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small stat item widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6F6152),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE67598),
          ),
        ),
      ],
    );
  }
}

/// Old model for reference (now using snapshots directly)
class CycleRecord {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;
  final int periodDuration;
  final String notes;

  CycleRecord({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.cycleLength,
    required this.periodDuration,
    required this.notes,
  });
}
