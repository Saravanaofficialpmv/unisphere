import 'package:flutter/material.dart';
import 'package:unisphere/models/nptel_certificate_model.dart';

class NptelWorkflowCard extends StatelessWidget {
  final NptelCertificateModel? certificate;
  final VoidCallback? onUploadTap;
  final VoidCallback? onReuploadTap;

  const NptelWorkflowCard({
    super.key,
    this.certificate,
    this.onUploadTap,
    this.onReuploadTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = certificate?.status ?? 'None';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title & badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  ContainerHeaderIcon(icon: Icons.account_balance_rounded),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NPTEL Verification Flow',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Official Credit Verification Lifecycle',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (certificate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: certificate!.statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: certificate!.statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        certificate!.statusIcon,
                        color: certificate!.statusColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        certificate!.status,
                        style: TextStyle(
                          color: certificate!.statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Flow Diagram Steps
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              if (isCompact) {
                return _buildVerticalFlow(context, status);
              } else {
                return _buildHorizontalFlow(context, status);
              }
            },
          ),

          if (certificate != null && status == 'Rejected') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7F1D1D).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFF87171), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rejection Reason:',
                          style: TextStyle(
                            color: Color(0xFFF87171),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          certificate!.rejectionReason ?? 'Certificate rejected by faculty.',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (onReuploadTap != null)
                    ElevatedButton.icon(
                      onPressed: onReuploadTap,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Re-upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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

  Widget _buildHorizontalFlow(BuildContext context, String status) {
    final step1Active = true;
    final step2Active = status != 'None';
    final step3Active = status == 'Pending Verification' || status == 'Verified' || status == 'Rejected';
    final step4Active = status == 'Verified' || status == 'Rejected';
    final isVerified = status == 'Verified';
    final isRejected = status == 'Rejected';

    return Row(
      children: [
        Expanded(child: _buildFlowNode('Student', Icons.person_rounded, step1Active, isDone: step2Active)),
        _buildFlowArrow(step2Active),
        Expanded(child: _buildFlowNode('Upload Cert', Icons.upload_file_rounded, step2Active, isDone: step3Active)),
        _buildFlowArrow(step3Active),
        Expanded(child: _buildFlowNode('Pending Verif.', Icons.hourglass_top_rounded, step3Active, isDone: step4Active)),
        _buildFlowArrow(step4Active),
        Expanded(child: _buildFlowNode('Faculty/HOD Review', Icons.rate_review_rounded, step4Active, isDone: isVerified || isRejected)),
        _buildFlowArrow(isVerified || isRejected),
        Expanded(
          child: isRejected
              ? _buildFlowNode('Rejected\n(Re-upload)', Icons.cancel_rounded, true, isError: true)
              : _buildFlowNode('Verified\n(Dashboard)', Icons.verified_user_rounded, isVerified, isSuccess: isVerified),
        ),
      ],
    );
  }

  Widget _buildVerticalFlow(BuildContext context, String status) {
    final step2Active = status != 'None';
    final step3Active = status == 'Pending Verification' || status == 'Verified' || status == 'Rejected';
    final step4Active = status == 'Verified' || status == 'Rejected';
    final isVerified = status == 'Verified';
    final isRejected = status == 'Rejected';

    return Column(
      children: [
        _buildVerticalRow('Student', 'Upload Certificate', Icons.person_rounded, Icons.upload_file_rounded, true, step2Active),
        const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 20),
        _buildVerticalRow('Pending Verification', 'Faculty / HOD Review', Icons.hourglass_top_rounded, Icons.rate_review_rounded, step3Active, step4Active),
        const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 20),
        Row(
          children: [
            Expanded(
              child: _buildFlowNode(
                'Verified\n(Dashboard)',
                Icons.verified_rounded,
                isVerified,
                isSuccess: isVerified,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFlowNode(
                'Rejected\n(Re-upload)',
                Icons.cancel_rounded,
                isRejected,
                isError: isRejected,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalRow(String title1, String title2, IconData icon1, IconData icon2, bool active1, bool active2) {
    return Row(
      children: [
        Expanded(child: _buildFlowNode(title1, icon1, active1)),
        const Icon(Icons.keyboard_arrow_right_rounded, color: Color(0xFF64748B), size: 18),
        Expanded(child: _buildFlowNode(title2, icon2, active2)),
      ],
    );
  }

  Widget _buildFlowNode(
    String label,
    IconData icon,
    bool isActive, {
    bool isDone = false,
    bool isSuccess = false,
    bool isError = false,
  }) {
    Color bg = const Color(0xFF334155).withValues(alpha: 0.5);
    Color border = const Color(0xFF475569);
    Color fg = const Color(0xFF94A3B8);

    if (isSuccess) {
      bg = const Color(0xFF065F46).withValues(alpha: 0.6);
      border = const Color(0xFF10B981);
      fg = const Color(0xFF34D399);
    } else if (isError) {
      bg = const Color(0xFF7F1D1D).withValues(alpha: 0.6);
      border = const Color(0xFFEF4444);
      fg = const Color(0xFFF87171);
    } else if (isDone || isActive) {
      bg = const Color(0xFF2563EB).withValues(alpha: 0.3);
      border = const Color(0xFF3B82F6);
      fg = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowArrow(bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(
        Icons.chevron_right_rounded,
        color: active ? const Color(0xFF3B82F6) : const Color(0xFF475569),
        size: 18,
      ),
    );
  }
}

class ContainerHeaderIcon extends StatelessWidget {
  final IconData icon;
  const ContainerHeaderIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: const Color(0xFF60A5FA), size: 20),
    );
  }
}
