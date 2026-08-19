import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/syllabus_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SyllabusDocumentViewerScreen extends StatefulWidget {
  final SyllabusSubjectModel subject;

  const SyllabusDocumentViewerScreen({
    super.key,
    required this.subject,
  });

  @override
  State<SyllabusDocumentViewerScreen> createState() => _SyllabusDocumentViewerScreenState();
}

class _SyllabusDocumentViewerScreenState extends State<SyllabusDocumentViewerScreen> {
  int _currentPage = 1;
  final int _totalPages = 12;
  double _zoomScale = 1.0;
  bool _isDownloading = false;

  void _zoomIn() {
    setState(() {
      if (_zoomScale < 2.5) _zoomScale += 0.25;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_zoomScale > 0.75) _zoomScale -= 0.25;
    });
  }

  void _resetZoom() {
    setState(() {
      _zoomScale = 1.0;
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isDownloading = false);

    if (widget.subject.documentUrl.isNotEmpty) {
      final uri = Uri.parse(widget.subject.documentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${widget.subject.documentFileName}...'),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.subject.subjectCode} - Syllabus Document',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.subject.subjectName,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: _isDownloading ? null : _handleDownload,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Controls Bar (Page Indicator & Zoom)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  // Page Navigation Controls
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                    onPressed: _currentPage > 1 ? _prevPage : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Page $_currentPage of $_totalPages',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                    onPressed: _currentPage < _totalPages ? _nextPage : null,
                  ),

                  const Spacer(),

                  // Zoom Controls
                  IconButton(
                    icon: const Icon(Icons.zoom_out_rounded, color: Colors.white, size: 20),
                    onPressed: _zoomOut,
                  ),
                  Text(
                    '${(_zoomScale * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 20),
                    onPressed: _zoomIn,
                  ),
                  IconButton(
                    icon: const Icon(Icons.restart_alt_rounded, color: Color(0xFF94A3B8), size: 20),
                    onPressed: _resetZoom,
                  ),
                ],
              ),
            ),

            // PDF / Document Content Canvas
            Expanded(
              child: InteractiveViewer(
                scaleEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Transform.scale(
                      scale: _zoomScale,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 750),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Document Watermark Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.subject.department.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'ACADEMIC SYLLABUS DOCUMENT · ${widget.subject.academicYear}',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'OFFICIAL PUBLISHED',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32, thickness: 1.5, color: Color(0xFFE2E8F0)),

                            // Document Main Title Section
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    '${widget.subject.subjectCode}: ${widget.subject.subjectName}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${widget.subject.year} · ${widget.subject.semester} · ${widget.subject.credits} Credits (${widget.subject.subjectType})',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Page Content Simulation
                            _buildDocumentPageContent(_currentPage),

                            const SizedBox(height: 40),
                            const Divider(height: 24, color: Color(0xFFE2E8F0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Page $_currentPage of $_totalPages',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                                Text(
                                  'UniSphere Academic Portal · ${widget.subject.subjectCode}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPageContent(int page) {
    if (page == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. COURSE OBJECTIVES & OVERVIEW',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subject.description.isNotEmpty
                ? widget.subject.description
                : 'This course provides a comprehensive foundation in the core concepts, principles, algorithms, and practical applications of ${widget.subject.subjectName}.',
            style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 24),
          const Text(
            '2. DETAILED UNIT-WISE SYLLABUS BREAKDOWN',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          if (widget.subject.units.isNotEmpty)
            ...widget.subject.units.map((unit) => _buildUnitDocSection(unit))
          else
            const Text(
              'No unit topics listed.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SECTION $page: ADVANCED TOPICS & REFERENCE MATERIALS',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 12),
        const Text(
          'TEXTBOOKS & PRESCRIBED READINGS:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 8),
        ...widget.subject.textbooks.map((tb) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Expanded(
                    child: Text(
                      tb,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 20),
        const Text(
          'REFERENCE BOOKS & ONLINE RESOURCES:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 8),
        ...widget.subject.referenceBooks.map((rb) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Expanded(
                    child: Text(
                      rb,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildUnitDocSection(SyllabusUnitModel unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  unit.unitNumber,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  unit.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: unit.topics
                .map((topic) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        topic,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
