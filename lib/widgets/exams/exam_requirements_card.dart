import 'package:flutter/material.dart';
import 'package:unisphere/models/exam_model.dart';

class ExamRequirementsCard extends StatelessWidget {
  final List<ExamRequirementItem> requirements;

  const ExamRequirementsCard({
    super.key,
    required this.requirements,
  });

  @override
  Widget build(BuildContext context) {
    if (requirements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'No special equipment rules specified for this examination.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.rule_folder_rounded, color: Color(0xFF0284C7), size: 20),
              SizedBox(width: 8),
              Text(
                'Exam Requirements & Rules',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          ...requirements.map((item) => _buildRequirementRow(item)),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(ExamRequirementItem item) {
    String symbol = '⚠';
    String statusLabel = 'Required';
    Color symbolBg = const Color(0xFFFEF3C7);
    Color symbolColor = const Color(0xFFD97706);

    if (item.status == ExamRequirementStatus.allowed) {
      symbol = '✓';
      statusLabel = 'Allowed';
      symbolBg = const Color(0xFFDCFCE7);
      symbolColor = const Color(0xFF16A34A);
    } else if (item.status == ExamRequirementStatus.notAllowed) {
      symbol = '✕';
      statusLabel = 'Not Allowed';
      symbolBg = const Color(0xFFFEE2E2);
      symbolColor = const Color(0xFFDC2626);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Symbol Tag Box
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: symbolBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  color: symbolColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Requirement Label & Note
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (item.note != null && item.note!.isNotEmpty)
                  Text(
                    item.note!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ),

          // Status Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: symbolBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: symbolColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
