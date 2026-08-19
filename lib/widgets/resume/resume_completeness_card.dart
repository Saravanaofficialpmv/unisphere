import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:unisphere/models/student_resume_model.dart';

class ResumeCompletenessCard extends StatefulWidget {
  final ResumeCompleteness completeness;
  final Function(String actionRoute)? onActionTap;
  final bool isCompact;

  const ResumeCompletenessCard({
    super.key,
    required this.completeness,
    this.onActionTap,
    this.isCompact = false,
  });

  @override
  State<ResumeCompletenessCard> createState() => _ResumeCompletenessCardState();
}

class _ResumeCompletenessCardState extends State<ResumeCompletenessCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final comp = widget.completeness;
    final score = comp.scorePercentage;

    Color scoreColor;
    String scoreStatus;
    if (score >= 90) {
      scoreColor = const Color(0xFF10B981);
      scoreStatus = 'Recruiter Ready';
    } else if (score >= 70) {
      scoreColor = const Color(0xFF2563EB);
      scoreStatus = 'Strong Profile';
    } else if (score >= 50) {
      scoreColor = const Color(0xFFF59E0B);
      scoreStatus = 'Needs Enhancement';
    } else {
      scoreColor = const Color(0xFFEF4444);
      scoreStatus = 'Incomplete Information';
    }

    if (widget.isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 18,
              lineWidth: 3.5,
              percent: (score / 100).clamp(0.0, 1.0),
              center: Text(
                '$score%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
              progressColor: scoreColor,
              backgroundColor: const Color(0xFFF1F5F9),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Resume Completeness: $score%',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${comp.missingRecommended.length} recommended items remaining',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (comp.missingRecommended.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  scoreStatus,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircularPercentIndicator(
                  radius: 36,
                  lineWidth: 7.0,
                  animation: true,
                  percent: (score / 100).clamp(0.0, 1.0),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: scoreColor,
                        ),
                      ),
                      const Text(
                        'COMPLETE',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  progressColor: scoreColor,
                  backgroundColor: const Color(0xFFF1F5F9),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Resume Completeness',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: scoreColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 12,
                                  color: scoreColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  scoreStatus,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: scoreColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        score >= 85
                            ? 'Your resume incorporates real academic, project, and certification records and meets top industry recruiter standards.'
                            : 'Enhance your resume by completing missing recommended details like project links, LinkedIn profile, or verified certifications.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatPill(
                            'Required Info',
                            '${comp.requiredCompleted}/${comp.requiredTotal}',
                            comp.requiredCompleted == comp.requiredTotal
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _buildStatPill(
                            'Recommendations',
                            '${comp.recommendedCompleted}/${comp.recommendedTotal}',
                            const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Expansion Toggle Bar
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: _isExpanded
                    ? null
                    : const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    _isExpanded ? Icons.tune_rounded : Icons.checklist_rounded,
                    size: 16,
                    color: const Color(0xFF475569),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isExpanded
                        ? 'Hide Checklist & Recommendations'
                        : 'View Resume Optimization Checklist (${comp.checklist.where((c) => !c.isCompleted).length} Pending)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Detailed Expandable Checklist
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REQUIRED PROFILE INFORMATION',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...comp.requiredItems.map(
                    (item) => _buildChecklistItem(item),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'RECOMMENDED RESUME ENHANCEMENTS',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...comp.recommendedItems.map(
                    (item) => _buildChecklistItem(item),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(ResumeCompletenessItem item) {
    final isDone = item.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF8FAFC) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDone ? const Color(0xFFE2E8F0) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.pending_outlined,
            size: 18,
            color: isDone ? const Color(0xFF10B981) : const Color(0xFFD97706),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? const Color(0xFF334155)
                        : const Color(0xFF92400E),
                    decoration: isDone ? TextDecoration.none : null,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (!isDone && widget.onActionTap != null) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => widget.onActionTap!(item.actionRoute),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                item.actionLabel,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
