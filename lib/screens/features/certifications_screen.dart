import 'package:flutter/material.dart';
import 'package:clg_application/screens/features/feature_hub_screen.dart';

class CertificateModel {
  final String id;
  final String title;
  final String issuer;
  final String category;
  final String fileType; // PDF, PNG, JPG
  final String fileSize;
  final DateTime uploadDate;
  final DateTime? issueDate;
  final String credentialId;
  String status; // 'Approved', 'Pending', 'Rejected'
  final String? rejectionReason;
  final String certificateUrl;

  CertificateModel({
    required this.id,
    required this.title,
    required this.issuer,
    required this.category,
    required this.fileType,
    required this.fileSize,
    required this.uploadDate,
    this.issueDate,
    required this.credentialId,
    required this.status,
    this.rejectionReason,
    required this.certificateUrl,
  });
}

class CertificationsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const CertificationsScreen({super.key, this.onBack});

  @override
  State<CertificationsScreen> createState() => _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';
  final String _selectedCategoryFilter = 'All';

  final List<CertificateModel> _certificates = [
    CertificateModel(
      id: 'CERT-001',
      title: 'AWS Certified Solutions Architect – Associate',
      issuer: 'Amazon Web Services (AWS)',
      category: 'Cloud & DevOps',
      fileType: 'PDF',
      fileSize: '1.8 MB',
      uploadDate: DateTime.now().subtract(const Duration(days: 12)),
      issueDate: DateTime(2025, 11, 15),
      credentialId: 'AWS-ASA-9920148',
      status: 'Approved',
      certificateUrl: 'https://aws.amazon.com/verification',
    ),
    CertificateModel(
      id: 'CERT-002',
      title: 'Google Cloud Associate Cloud Engineer',
      issuer: 'Google Cloud Training',
      category: 'Cloud & DevOps',
      fileType: 'PNG',
      fileSize: '2.4 MB',
      uploadDate: DateTime.now().subtract(const Duration(days: 5)),
      issueDate: DateTime(2026, 01, 10),
      credentialId: 'GCP-ACE-778102',
      status: 'Approved',
      certificateUrl: 'https://google.accredible.com/verify',
    ),
    CertificateModel(
      id: 'CERT-003',
      title: 'Meta Front-End Developer Professional Certificate',
      issuer: 'Coursera & Meta',
      category: 'Technical',
      fileType: 'PDF',
      fileSize: '3.1 MB',
      uploadDate: DateTime.now().subtract(const Duration(days: 2)),
      issueDate: DateTime(2026, 02, 01),
      credentialId: 'META-FED-88419',
      status: 'Pending',
      certificateUrl: 'https://coursera.org/verify/meta-fed',
    ),
    CertificateModel(
      id: 'CERT-004',
      title: 'NPTEL Elite + Gold Certification in Data Structures',
      issuer: 'IIT Madras & NPTEL',
      category: 'Academic',
      fileType: 'PDF',
      fileSize: '1.2 MB',
      uploadDate: DateTime.now().subtract(const Duration(days: 20)),
      issueDate: DateTime(2025, 10, 30),
      credentialId: 'NPTEL-CS-2025-091',
      status: 'Approved',
      certificateUrl: 'https://nptel.ac.in/noc/E-certificate',
    ),
    CertificateModel(
      id: 'CERT-005',
      title: 'Certified Ethical Hacker (CEH v12)',
      issuer: 'EC-Council',
      category: 'Cybersecurity',
      fileType: 'JPG',
      fileSize: '4.0 MB',
      uploadDate: DateTime.now().subtract(const Duration(days: 1)),
      issueDate: DateTime(2026, 01, 20),
      credentialId: 'ECC-CEH-33910',
      status: 'Rejected',
      rejectionReason: 'Certificate image is blurry and issuer stamp is not clearly legible. Please re-upload a clear PDF scan.',
      certificateUrl: 'https://aspen.eccouncil.org/verify',
    ),
  ];

  List<CertificateModel> get _filteredCertificates {
    return _certificates.where((cert) {
      final matchesSearch = cert.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          cert.issuer.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          cert.credentialId.toLowerCase().contains(_searchController.text.toLowerCase());

      final matchesStatus = _selectedStatusFilter == 'All' || cert.status == _selectedStatusFilter;
      final matchesCategory = _selectedCategoryFilter == 'All' || cert.category == _selectedCategoryFilter;

      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addNewCertificate(CertificateModel cert) {
    setState(() {
      _certificates.insert(0, cert);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text('"${cert.title}" submitted successfully for verification!')),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateBackToFeatureHub(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const FeatureHubScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _certificates.length;
    final approvedCount = _certificates.where((c) => c.status == 'Approved').length;
    final pendingCount = _certificates.where((c) => c.status == 'Pending').length;
    final rejectedCount = _certificates.where((c) => c.status == 'Rejected').length;

    final scaffold = Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => _navigateBackToFeatureHub(context),
        ),
        title: const Text(
          'Certifications & Uploads',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: UnconstrainedBox(
              child: ElevatedButton.icon(
                onPressed: () => _showUploadCertificateDialog(context),
                icon: const Icon(Icons.upload_file_rounded, size: 16),
                label: const Text('Upload New', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analytics Overview Header
              _buildAnalyticsCards(totalCount, approvedCount, pendingCount, rejectedCount),
              const SizedBox(height: 20),

              // Search & Filter Controls
              _buildSearchAndFilterControls(),
              const SizedBox(height: 16),

              // Certificates List
              if (_filteredCertificates.isEmpty)
                _buildEmptyState()
              else
                Column(
                  children: _filteredCertificates.map((cert) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildCertificateCard(cert),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateBackToFeatureHub(context);
      },
      child: scaffold,
    );
  }

  // ── Analytics Overview Cards ────────────────────────────────────────────────
  Widget _buildAnalyticsCards(int total, int approved, int pending, int rejected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Color(0xFFA78BFA), size: 20),
              SizedBox(width: 8),
              Text(
                'Certification Portfolio',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatBadge('TOTAL', '$total', Colors.white, Colors.white10)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatBadge('APPROVED', '$approved', const Color(0xFF34D399), const Color(0xFF065F46).withValues(alpha: 0.4))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatBadge('PENDING', '$pending', const Color(0xFFFBBF24), const Color(0xFF78350F).withValues(alpha: 0.4))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatBadge('REJECTED', '$rejected', const Color(0xFFF87171), const Color(0xFF7F1D1D).withValues(alpha: 0.4))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String count, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.8), letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search & Filter Controls ────────────────────────────────────────────────
  Widget _buildSearchAndFilterControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search certificates, issuers, or credentials...',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => setState(() => _searchController.clear()),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Status Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: 8),
              _buildFilterChip('Approved'),
              const SizedBox(width: 8),
              _buildFilterChip('Pending'),
              const SizedBox(width: 8),
              _buildFilterChip('Rejected'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String status) {
    final isSelected = _selectedStatusFilter == status;
    Color chipColor;
    switch (status) {
      case 'Approved':
        chipColor = const Color(0xFF10B981);
        break;
      case 'Pending':
        chipColor = const Color(0xFFF59E0B);
        break;
      case 'Rejected':
        chipColor = const Color(0xFFEF4444);
        break;
      default:
        chipColor = const Color(0xFF7C3AED);
    }

    return ChoiceChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedStatusFilter = status);
      },
      selectedColor: chipColor,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF475569),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? chipColor : const Color(0xFFE2E8F0)),
      ),
      showCheckmark: false,
    );
  }

  // ── Certificate Card Item ─────────────────────────────────────────────────
  Widget _buildCertificateCard(CertificateModel cert) {
    Color statusBg;
    Color statusText;
    IconData statusIcon;

    switch (cert.status) {
      case 'Approved':
        statusBg = const Color(0xFFD1FAE5);
        statusText = const Color(0xFF065F46);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Pending':
        statusBg = const Color(0xFFFEF3C7);
        statusText = const Color(0xFF92400E);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'Rejected':
        statusBg = const Color(0xFFFEE2E2);
        statusText = const Color(0xFF991B1B);
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusBg = const Color(0xFFE2E8F0);
        statusText = const Color(0xFF475569);
        statusIcon = Icons.help_outline_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cert.fileType == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                        size: 13,
                        color: cert.fileType == 'PDF' ? const Color(0xFFEF4444) : const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${cert.fileType} • ${cert.fileSize}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusText),
                      const SizedBox(width: 4),
                      Text(
                        cert.status.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Certificate Details
            Text(
              cert.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.business_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cert.issuer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.key_rounded, size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'ID: ${cert.credentialId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_month_outlined, size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  'Uploaded ${cert.uploadDate.day}/${cert.uploadDate.month}/${cert.uploadDate.year}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),

            if (cert.status == 'Rejected' && cert.rejectionReason != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cert.rejectionReason!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPreviewModal(context, cert),
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text('Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: cert.status == 'Approved'
                        ? () => _downloadCertificate(context, cert)
                        : null,
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Download', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFF1F5F9),
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_off_rounded, size: 40, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Certificates Found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search query or status filter.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // ── Download Action ───────────────────────────────────────────────────────
  void _downloadCertificate(BuildContext context, CertificateModel cert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text('Downloading "${cert.title}.${cert.fileType.toLowerCase()}"...')),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Preview Modal ─────────────────────────────────────────────────────────
  void _showPreviewModal(BuildContext context, CertificateModel cert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Certificate Document Preview',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mock Certificate Canvas Preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCD34D), width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.workspace_premium_rounded, size: 56, color: Color(0xFFD97706)),
                        const SizedBox(height: 12),
                        const Text(
                          'CERTIFICATE OF COMPLETION',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, color: Color(0xFF78350F)),
                        ),
                        const SizedBox(height: 6),
                        const Text('PROUDLY PRESENTED TO', style: TextStyle(fontSize: 10, color: Color(0xFFB45309), letterSpacing: 1.5)),
                        const SizedBox(height: 10),
                        const Text(
                          'Alex Johnson',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontFamily: 'serif'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'For successfully fulfilling all requirements and demonstrating proficiency in',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cert.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(cert.issuer, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  const Text('ISSUING AUTHORITY', style: TextStyle(fontSize: 8, color: Colors.grey)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(cert.credentialId, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  const Text('CREDENTIAL VERIFICATION ID', style: TextStyle(fontSize: 8, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: cert.status == 'Approved'
                          ? () {
                              Navigator.pop(context);
                              _downloadCertificate(context, cert);
                            }
                          : null,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download Certificate File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Upload Certificate Modal Form ─────────────────────────────────────────
  void _showUploadCertificateDialog(BuildContext context) {
    final titleController = TextEditingController();
    final issuerController = TextEditingController();
    final credIdController = TextEditingController();
    String selectedCategory = 'Technical';
    String selectedFileType = 'PDF';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.upload_file_rounded, color: Color(0xFF7C3AED), size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Upload Certificate',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Form Fields
                      const Text('Certificate Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'e.g. AWS Certified Developer Associate',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text('Issuing Organization *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: issuerController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Amazon Web Services / Coursera',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: selectedCategory,
                                  isExpanded: true,
                                  items: ['Technical', 'Cloud & DevOps', 'Cybersecurity', 'Academic', 'Soft Skills']
                                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: (val) => setModalState(() => selectedCategory = val!),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('File Format', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: selectedFileType,
                                  isExpanded: true,
                                  items: ['PDF', 'PNG', 'JPG']
                                      .map((fmt) => DropdownMenuItem(value: fmt, child: Text(fmt, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: (val) => setModalState(() => selectedFileType = val!),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      const Text('Credential ID / Verification URL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: credIdController,
                        decoration: InputDecoration(
                          hintText: 'e.g. AWS-DEV-109284',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // File Attachment Zone Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.cloud_upload_rounded, size: 36, color: Color(0xFF7C3AED)),
                            SizedBox(height: 8),
                            Text('Tap to select file from device', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                            SizedBox(height: 2),
                            Text('Supports PDF, PNG, JPG (Max 10 MB)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.trim().isEmpty || issuerController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill in certificate name and issuer.')),
                              );
                              return;
                            }

                            final newCert = CertificateModel(
                              id: 'CERT-00${_certificates.length + 1}',
                              title: titleController.text.trim(),
                              issuer: issuerController.text.trim(),
                              category: selectedCategory,
                              fileType: selectedFileType,
                              fileSize: '2.1 MB',
                              uploadDate: DateTime.now(),
                              credentialId: credIdController.text.trim().isNotEmpty ? credIdController.text.trim() : 'VERIFIED-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                              status: 'Pending',
                              certificateUrl: 'https://unisphere.edu/verify',
                            );

                            Navigator.pop(context);
                            _addNewCertificate(newCert);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Submit for Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
