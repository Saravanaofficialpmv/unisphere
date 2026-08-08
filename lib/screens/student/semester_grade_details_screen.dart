import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/providers/gradebook_provider.dart';

class SemesterGradeDetailsScreen extends ConsumerWidget {
  final int semesterIndex;

  const SemesterGradeDetailsScreen({
    super.key,
    required this.semesterIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradebookProvider);
    if (semesterIndex < 0 || semesterIndex >= state.semesters.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Semester Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Semester not found.'),
        ),
      );
    }

    final sem = state.semesters[semesterIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${sem.name} Details',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Academic grade breakdown & credit points',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Semester Overview Banner
              _buildSemesterBanner(sem),
              const SizedBox(height: 20),

              // Subject Grade Details Header
              const Text(
                'Subject-wise Grade Breakdown',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              // Grade Details Table / List Card
              _buildSubjectGradeTableCard(context, sem),
              const SizedBox(height: 20),

              // Bottom Summary Statistics Card
              _buildBottomSummaryCard(sem),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterBanner(SemesterModel sem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      sem.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (sem.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${sem.subjects.length} Subjects Registered • ${sem.eligibleCredits} Eligible Credits',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFBFDBFE)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF34D399)),
                    const SizedBox(width: 4),
                    Text(
                      '${sem.passedCount} Passed',
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                    if (sem.failedCount > 0) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.cancel_rounded, size: 14, color: Color(0xFFF87171)),
                      const SizedBox(width: 4),
                      Text(
                        '${sem.failedCount} RA',
                        style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                const Text(
                  'SGPA',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  sem.sgpa.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF60A5FA)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectGradeTableCard(BuildContext context, SemesterModel sem) {
    if (sem.subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'No subject grade records available for this semester.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table Header
          Container(
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Subject Code / Name',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'Creds',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
                SizedBox(
                  width: 55,
                  child: Text(
                    'Grade',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'Point',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Credit×GP',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sem.subjects.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final sub = sem.subjects[index];
              final gp = sub.gradePoint;

              Color gradeBgColor;
              Color gradeTextColor;

              if (sub.isExcluded) {
                gradeBgColor = const Color(0xFFFEF3C7);
                gradeTextColor = const Color(0xFFD97706);
              } else if (sub.grade == 'O' || sub.grade == 'A+') {
                gradeBgColor = const Color(0xFFD1FAE5);
                gradeTextColor = const Color(0xFF059669);
              } else if (sub.grade == 'A' || sub.grade == 'B+') {
                gradeBgColor = const Color(0xFFDBEAFE);
                gradeTextColor = const Color(0xFF2563EB);
              } else {
                gradeBgColor = const Color(0xFFEEF2FF);
                gradeTextColor = const Color(0xFF4F46E5);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Code + Name
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              sub.code,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            sub.name,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Credits
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${sub.credits}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                    ),
                    // Grade Badge
                    SizedBox(
                      width: 55,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: gradeBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sub.grade,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: gradeTextColor),
                          ),
                        ),
                      ),
                    ),
                    // Grade Point
                    SizedBox(
                      width: 50,
                      child: Text(
                        gp != null ? '${gp.toInt()}' : '-',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: sub.isExcluded ? Colors.orange.shade800 : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    // Credit x Grade Point
                    SizedBox(
                      width: 60,
                      child: Text(
                        gp != null ? '${sub.weightedPoints.toInt()}' : '0',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummaryCard(SemesterModel sem) {
    final totalCreds = sem.eligibleCredits;
    final totalPoints = sem.totalWeightedPoints;
    final sgpaVal = sem.sgpa;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Eligible Credits',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
              ),
              Text(
                '$totalCreds Credits',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Credit Points',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
              ),
              Text(
                totalPoints.toStringAsFixed(1),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFBFDBFE)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SEMESTER SGPA',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Formula: Σ(Credit × GP) / Σ(Credits)',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                  ),
                ],
              ),
              Text(
                sgpaVal.toStringAsFixed(2),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
