import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unisphere/models/nptel_certificate_model.dart';
import 'package:unisphere/widgets/nptel/nptel_upload_modal.dart';

class NptelInformationCard extends StatelessWidget {
  final NptelCertificateModel? certificate;
  final VoidCallback? onUploadTap;
  final VoidCallback? onBack;
  final bool isDialog;

  const NptelInformationCard({
    super.key,
    this.certificate,
    this.onUploadTap,
    this.onBack,
    this.isDialog = false,
  });

  static Future<void> showModal(
    BuildContext context, {
    NptelCertificateModel? certificate,
    VoidCallback? onUploadTap,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 520,
          child: NptelInformationCard(
            certificate: certificate,
            onUploadTap: onUploadTap,
            isDialog: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cert = certificate;
    final courseName = cert?.courseName ?? 'Programming in Java';
    final courseCode = cert?.courseCode ?? 'NPTEL24CS01';
    final instructor = 'Prof. XYZ';
    final duration = '12 Weeks';

    final enrollmentStatus = 'Enrolled';
    final enrollmentDate = '12 Jan 2025';
    final courseStatus = 'Completed';

    final score = cert?.score ?? '82%';
    final grade = cert?.grade ?? 'Elite';
    final resultStatus = 'Passed';

    final certAvailable = 'Yes';
    final certId = cert?.certificateId ?? 'NPTEL-CS20268812';
    final verificationStatus = cert?.status ?? 'Pending Verification';

    final creditsEarned = '4';
    final academicYear = cert?.academicYear ?? '2026–27';
    final semester = cert?.semester ?? '5th Semester';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle Pill
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎓', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'NPTEL Certification Details',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'View your course and certification information',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (isDialog) {
                      Navigator.of(context).pop();
                    } else if (onBack != null) {
                      onBack!();
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Scrollable Cards List
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Column(
                children: [
                  // 1. Course Information (2-Column Grid)
                  _buildCard(
                    title: 'Course Information',
                    icon: Icons.menu_book_rounded,
                    iconBg: const Color(0xFF3B82F6),
                    titleColor: const Color(0xFF2563EB),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGridItem(
                                icon: Icons.book_outlined,
                                label: 'Course Name',
                                value: courseName,
                              ),
                              const SizedBox(height: 12),
                              _buildGridItem(
                                icon: Icons.badge_outlined,
                                label: 'Course Code',
                                value: courseCode,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: const Color(0xFFF1F5F9),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGridItem(
                                icon: Icons.person_outline_rounded,
                                label: 'Instructor',
                                value: instructor,
                              ),
                              const SizedBox(height: 12),
                              _buildGridItem(
                                icon: Icons.access_time_rounded,
                                label: 'Duration',
                                value: duration,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Enrollment Status (3-Column Row)
                  _buildCard(
                    title: 'Enrollment Status',
                    icon: Icons.person_search_rounded,
                    iconBg: const Color(0xFF10B981),
                    titleColor: const Color(0xFF059669),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Enrollment Status',
                            customWidget: Text(
                              enrollmentStatus,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Enrollment Date',
                            customWidget: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF64748B)),
                                  const SizedBox(width: 3),
                                  Text(
                                    enrollmentDate,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Course Status',
                            customWidget: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF059669)),
                                  const SizedBox(width: 3),
                                  Text(
                                    courseStatus,
                                    style: const TextStyle(
                                      color: Color(0xFF059669),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Result (3-Column Row)
                  _buildCard(
                    title: 'Result',
                    icon: Icons.bar_chart_rounded,
                    iconBg: const Color(0xFFF59E0B),
                    titleColor: const Color(0xFFD97706),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Score',
                            value: score,
                            valueColor: const Color(0xFFEA580C),
                            isLarge: true,
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Grade',
                            value: grade,
                            valueColor: const Color(0xFFD97706),
                            isLarge: true,
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Result Status',
                            customWidget: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.shield_rounded, size: 13, color: Color(0xFF166534)),
                                    const SizedBox(width: 3),
                                    Text(
                                      resultStatus,
                                      style: const TextStyle(
                                        color: Color(0xFF166534),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Certification Status (3-Column Row)
                  _buildCard(
                    title: 'Certification Status',
                    icon: Icons.shield_rounded,
                    iconBg: const Color(0xFF8B5CF6),
                    titleColor: const Color(0xFF7C3AED),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Certificate Available',
                            customWidget: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      certAvailable,
                                      style: const TextStyle(
                                        color: Color(0xFF166534),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF166534)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Certificate ID',
                            customWidget: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: certId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Certificate ID copied to clipboard'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      certId,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF64748B)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Verification Status',
                            customWidget: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: verificationStatus == 'Verified'
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      verificationStatus,
                                      style: TextStyle(
                                        color: verificationStatus == 'Verified'
                                            ? const Color(0xFF166534)
                                            : const Color(0xFF7E22CE),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(
                                      verificationStatus == 'Verified'
                                          ? Icons.check_circle_rounded
                                          : Icons.access_time_rounded,
                                      size: 12,
                                      color: verificationStatus == 'Verified'
                                          ? const Color(0xFF166534)
                                          : const Color(0xFF7E22CE),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Credits (3-Column Row)
                  _buildCard(
                    title: 'Credits',
                    icon: Icons.military_tech_rounded,
                    iconBg: const Color(0xFFEC4899),
                    titleColor: const Color(0xFFDB2777),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Credits Earned',
                            value: creditsEarned,
                            isLarge: true,
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Academic Year',
                            value: academicYear,
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Semester',
                            value: semester,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (isDialog) Navigator.of(context).pop();
                        if (onUploadTap != null) {
                          onUploadTap!();
                        } else {
                          NptelUploadModal.show(context);
                        }
                      },
                      icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                      label: const Text('Upload Certificate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color titleColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumnStat({
    required String label,
    String? value,
    Widget? customWidget,
    Color? valueColor,
    bool isLarge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10.5,
          ),
        ),
        const SizedBox(height: 4),
        if (customWidget != null)
          customWidget
        else
          Text(
            value ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF0F172A),
              fontSize: isLarge ? 14 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: const Color(0xFFE2E8F0),
    );
  }
}
