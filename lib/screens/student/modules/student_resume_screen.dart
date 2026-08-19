import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/resume_service.dart';
import 'package:unisphere/widgets/resume/resume_completeness_card.dart';
import 'package:unisphere/widgets/resume/resume_document_view.dart';
import 'package:unisphere/widgets/student/student_profile_edit_request_modal.dart';

class StudentResumeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final Function(int tabIndex)? onNavigateToTab;

  const StudentResumeScreen({
    super.key,
    this.onBack,
    this.onNavigateToTab,
  });

  @override
  ConsumerState<StudentResumeScreen> createState() => _StudentResumeScreenState();
}

class _StudentResumeScreenState extends ConsumerState<StudentResumeScreen> {

  void _handleCompletenessAction(String actionRoute) {
    if (actionRoute == 'projects') {
      if (widget.onNavigateToTab != null) {
        widget.onNavigateToTab!(16); // Feature Hub
      } else {
        _showEditProfileModal();
      }
    } else if (actionRoute == 'certifications') {
      if (widget.onNavigateToTab != null) {
        widget.onNavigateToTab!(11); // Certifications screen
      }
    } else if (actionRoute == 'hackathons') {
      if (widget.onNavigateToTab != null) {
        widget.onNavigateToTab!(10); // Hackathons screen
      }
    } else {
      _showEditProfileModal();
    }
  }

  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StudentProfileEditRequestModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(currentUserProvider);
    final user = authState.value ?? ref.watch(authServiceProvider).currentUser;
    final resumeAsync = ref.watch(currentStudentResumeStreamProvider);
    final fallbackResume = ref.read(resumeServiceProvider).generateSyncFallbackResume(user: user);
    final activeResume = resumeAsync.value ?? fallbackResume;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
                onPressed: widget.onBack,
              )
            : null,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description_rounded, size: 18, color: Color(0xFF2563EB)),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Professional Resume',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Auto-generated from verified records',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sync_rounded, size: 11, color: Color(0xFF059669)),
                SizedBox(width: 3),
                Text(
                  'Live Sync',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 22),
            tooltip: 'Request Profile Edit',
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: _showEditProfileModal,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569), size: 20),
            tooltip: 'Refresh Resume Data',
            padding: const EdgeInsets.only(left: 4, right: 8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {
              ref.invalidate(currentStudentResumeStreamProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Synchronizing latest student records...'),
                  backgroundColor: Color(0xFF2563EB),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Completeness Card at top
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: ResumeCompletenessCard(
                completeness: activeResume.completeness,
                onActionTap: _handleCompletenessAction,
              ),
            ),

            // A4 Document Preview
            ResumeDocumentView(
              resume: activeResume,
              onEditRequest: _showEditProfileModal,
              showControls: true,
              shrinkWrap: true,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
