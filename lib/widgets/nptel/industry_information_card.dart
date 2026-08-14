import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unisphere/widgets/nptel/nptel_upload_modal.dart';

class IndustryInformationCard extends StatelessWidget {
  final String? title;
  final String? issuer;
  final String? credentialId;
  final String? credentialUrl;
  final VoidCallback? onUploadTap;
  final VoidCallback? onBack;
  final bool isDialog;

  const IndustryInformationCard({
    super.key,
    this.title,
    this.issuer,
    this.credentialId,
    this.credentialUrl,
    this.onUploadTap,
    this.onBack,
    this.isDialog = false,
  });

  static Future<void> showModal(
    BuildContext context, {
    String? title,
    String? issuer,
    String? credentialId,
    String? credentialUrl,
    VoidCallback? onUploadTap,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 820),
          child: IndustryInformationCard(
            title: title,
            issuer: issuer,
            credentialId: credentialId,
            credentialUrl: credentialUrl,
            onUploadTap: onUploadTap,
            isDialog: true,
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final certName = title ?? 'AWS Cloud Practitioner';
    final issuingOrg = issuer ?? 'Amazon Web Services';
    final certId = credentialId ?? 'AWS-CP-123456';
    final issueDate = '15 Feb 2025';

    final certStatus = 'Completed';
    final expiryDate = '15 Feb 2028';
    final verificationStatus = 'Verified';

    final credUrl = credentialUrl ?? 'https://aws.amazon.com/verification';
    final credType = 'Professional';
    final verifCode = 'ABCD-1234-EFGH';

    final skills = ['Cloud Concepts', 'Security & Compliance', 'Technology & Services'];
    final creditsEarned = '10';
    final creditType = 'AWS Training Credits';
    final academicYear = '2024–25';
    final description = 'Foundational understanding of AWS Cloud services and solutions.';

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
                    child: Text('🏢', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Industry Certification Details',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'View your industry credential and certification information',
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
                  // 1. Certification Information (2-Column Grid)
                  _buildCard(
                    title: 'Certification Information',
                    icon: Icons.account_balance_rounded,
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
                                icon: Icons.card_membership_rounded,
                                label: 'Certificate Name',
                                value: certName,
                              ),
                              const SizedBox(height: 12),
                              _buildGridItem(
                                icon: Icons.badge_outlined,
                                label: 'Certificate ID',
                                value: certId,
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
                                icon: Icons.domain_rounded,
                                label: 'Issuing Organization',
                                value: issuingOrg,
                              ),
                              const SizedBox(height: 12),
                              _buildGridItem(
                                icon: Icons.calendar_today_rounded,
                                label: 'Issue Date',
                                value: issueDate,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Status (3-Column Row)
                  _buildCard(
                    title: 'Status',
                    icon: Icons.task_alt_rounded,
                    iconBg: const Color(0xFF10B981),
                    titleColor: const Color(0xFF059669),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Certification Status',
                            customWidget: Text(
                              certStatus,
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
                            label: 'Expiry Date',
                            value: expiryDate,
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
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      verificationStatus,
                                      style: const TextStyle(
                                        color: Color(0xFF166534),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 12,
                                      color: Color(0xFF166534),
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

                  // 3. Credential Details (3-Column Row)
                  _buildCard(
                    title: 'Credential Details',
                    icon: Icons.bar_chart_rounded,
                    iconBg: const Color(0xFFF59E0B),
                    titleColor: const Color(0xFFD97706),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Credential URL',
                            customWidget: InkWell(
                              onTap: () => _launchUrl(credUrl),
                              child: Row(
                                children: const [
                                  Expanded(
                                    child: Text(
                                      'View Credential',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xFF2563EB),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFF2563EB)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Credential Type',
                            value: credType,
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Verification Code',
                            customWidget: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: verifCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Verification Code copied'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      verifCode,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Skills Covered
                  _buildCard(
                    title: 'Skills Covered',
                    icon: Icons.psychology_rounded,
                    iconBg: const Color(0xFF8B5CF6),
                    titleColor: const Color(0xFF7C3AED),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: skills.map((skill) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('• ', style: TextStyle(color: Color(0xFF7E22CE), fontWeight: FontWeight.bold)),
                            Text(
                              skill,
                              style: const TextStyle(
                                color: Color(0xFF6B21A8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Credits / Points (3-Column Row)
                  _buildCard(
                    title: 'Credits / Points',
                    icon: Icons.card_giftcard_rounded,
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
                            label: 'Credit Type',
                            value: creditType,
                          ),
                        ),
                        _buildVerticalDivider(),
                        Expanded(
                          child: _buildColumnStat(
                            label: 'Academic Year',
                            value: academicYear,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 6. Description
                  _buildCard(
                    title: 'Description',
                    icon: Icons.info_outline_rounded,
                    iconBg: const Color(0xFF0284C7),
                    titleColor: const Color(0xFF0369A1),
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12.5,
                        height: 1.3,
                      ),
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
