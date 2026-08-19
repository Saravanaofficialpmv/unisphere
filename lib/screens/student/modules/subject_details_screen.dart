import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/syllabus_model.dart';
import 'package:unisphere/screens/student/modules/syllabus_document_viewer_screen.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final SyllabusSubjectModel subject;

  const SubjectDetailsScreen({
    super.key,
    required this.subject,
  });

  Color get _typeColor {
    switch (subject.subjectType.toLowerCase()) {
      case 'practical':
      case 'lab':
        return const Color(0xFF0D9488);
      case 'elective':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color get _typeBgColor {
    switch (subject.subjectType.toLowerCase()) {
      case 'practical':
      case 'lab':
        return const Color(0xFFCCFBF1);
      case 'elective':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(subject.lastUpdated);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            UnisphereHeaderCard(
              title: '${subject.subjectCode} Details',
              subtitle: '${subject.year} · ${subject.semester}',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Primary Overview Card
                    _buildOverviewHeaderCard(),
                    const SizedBox(height: 20),

                    // Prominent View Syllabus Document Banner Button
                    _buildViewDocumentBannerButton(context),
                    const SizedBox(height: 24),

                    // Syllabus Document Metadata Box
                    _buildDocumentMetadataCard(context, formattedDate),
                    const SizedBox(height: 24),

                    // Course Description / Overview Section
                    if (subject.description.isNotEmpty) ...[
                      const Text(
                        'Course Description & Objectives',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          subject.description,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Units & Topics Breakdown Section
                    if (subject.units.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.list_alt_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Syllabus Units Breakdown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${subject.units.length} Units',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...subject.units.map((unit) => _buildUnitCard(unit)),
                      const SizedBox(height: 24),
                    ],

                    // Textbooks & References Section
                    if (subject.textbooks.isNotEmpty || subject.referenceBooks.isNotEmpty) ...[
                      const Text(
                        'Prescribed Textbooks & References',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBooksCard(),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  subject.subjectCode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _typeBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  subject.subjectType,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _typeColor,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      '${subject.credits} Credits',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subject.subjectName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.school_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subject.department,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewDocumentBannerButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 22),
        label: const Text(
          'View Syllabus Document',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SyllabusDocumentViewerScreen(subject: subject),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentMetadataCard(BuildContext context, String formattedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.documentFileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${subject.documentSize}  ·  Updated: $formattedDate',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SyllabusDocumentViewerScreen(subject: subject),
                ),
              );
            },
            child: const Text('Open →', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCard(SyllabusUnitModel unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              unit.unitNumber,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          title: Text(
            unit.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: unit.topics
                    .map((topic) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            topic,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subject.textbooks.isNotEmpty) ...[
            const Text(
              'TEXTBOOKS:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            ...subject.textbooks.map((tb) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Expanded(
                        child: Text(
                          tb,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (subject.referenceBooks.isNotEmpty) ...[
            if (subject.textbooks.isNotEmpty) const Divider(height: 24, color: Color(0xFFE2E8F0)),
            const Text(
              'REFERENCE BOOKS:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            ...subject.referenceBooks.map((rb) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Expanded(
                        child: Text(
                          rb,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
