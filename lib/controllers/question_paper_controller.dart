import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/question_paper_model.dart';
import 'package:unisphere/services/question_paper_service.dart';

final questionPaperServiceProvider = Provider<QuestionPaperService>((ref) {
  return QuestionPaperService();
});

class QuestionPaperFilterState {
  final String department;
  final String semester;
  final String? subjectCode;
  final QuestionPaperType? paperType;
  final String regulation;
  final String examSession;
  final String searchQuery;
  final bool onlyWithAnswerKey;

  const QuestionPaperFilterState({
    this.department = 'All',
    this.semester = 'All',
    this.subjectCode,
    this.paperType,
    this.regulation = 'All',
    this.examSession = 'All',
    this.searchQuery = '',
    this.onlyWithAnswerKey = false,
  });

  QuestionPaperFilterState copyWith({
    String? department,
    String? semester,
    String? subjectCode,
    QuestionPaperType? paperType,
    bool clearPaperType = false,
    String? regulation,
    String? examSession,
    String? searchQuery,
    bool? onlyWithAnswerKey,
  }) {
    return QuestionPaperFilterState(
      department: department ?? this.department,
      semester: semester ?? this.semester,
      subjectCode: subjectCode ?? this.subjectCode,
      paperType: clearPaperType ? null : (paperType ?? this.paperType),
      regulation: regulation ?? this.regulation,
      examSession: examSession ?? this.examSession,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyWithAnswerKey: onlyWithAnswerKey ?? this.onlyWithAnswerKey,
    );
  }
}

class QuestionPaperState {
  final bool isLoading;
  final List<QuestionPaperModel> papers;
  final QuestionPaperFilterState filters;
  final String? error;

  const QuestionPaperState({
    this.isLoading = true,
    this.papers = const [],
    this.filters = const QuestionPaperFilterState(),
    this.error,
  });

  QuestionPaperState copyWith({
    bool? isLoading,
    List<QuestionPaperModel>? papers,
    QuestionPaperFilterState? filters,
    String? error,
  }) {
    return QuestionPaperState(
      isLoading: isLoading ?? this.isLoading,
      papers: papers ?? this.papers,
      filters: filters ?? this.filters,
      error: error,
    );
  }
}

class QuestionPaperController extends StateNotifier<QuestionPaperState> {
  final QuestionPaperService _service;

  QuestionPaperController(this._service) : super(const QuestionPaperState()) {
    loadPapers();
  }

  Future<void> loadPapers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final papers = await _service.getQuestionPapers(
        department: state.filters.department,
        semester: state.filters.semester,
        subjectCode: state.filters.subjectCode,
        paperType: state.filters.paperType,
        regulation: state.filters.regulation,
        examSession: state.filters.examSession,
        searchQuery: state.filters.searchQuery,
        onlyWithAnswerKey: state.filters.onlyWithAnswerKey,
      );
      state = state.copyWith(isLoading: false, papers: papers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateFilters(QuestionPaperFilterState newFilters) {
    state = state.copyWith(filters: newFilters);
    loadPapers();
  }

  void setPaperTypeFilter(QuestionPaperType? type) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        paperType: type,
        clearPaperType: type == null,
      ),
    );
    loadPapers();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      filters: state.filters.copyWith(searchQuery: query),
    );
    loadPapers();
  }

  void setSubjectFilter(String? subjectCode) {
    state = state.copyWith(
      filters: state.filters.copyWith(subjectCode: subjectCode),
    );
    loadPapers();
  }

  void setSemesterFilter(String semester) {
    state = state.copyWith(
      filters: state.filters.copyWith(semester: semester),
    );
    loadPapers();
  }

  void setDepartmentFilter(String department) {
    state = state.copyWith(
      filters: state.filters.copyWith(department: department),
    );
    loadPapers();
  }

  void setRegulationFilter(String regulation) {
    state = state.copyWith(
      filters: state.filters.copyWith(regulation: regulation),
    );
    loadPapers();
  }

  void toggleOnlyWithAnswerKey(bool val) {
    state = state.copyWith(
      filters: state.filters.copyWith(onlyWithAnswerKey: val),
    );
    loadPapers();
  }

  Future<bool> uploadPaper(QuestionPaperModel paper) async {
    try {
      await _service.uploadQuestionPaper(paper);
      await loadPapers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deletePaper(String id) async {
    try {
      await _service.deleteQuestionPaper(id);
      await loadPapers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> incrementDownload(String id) async {
    await _service.incrementDownloadCount(id);
    // Optimistically update
    state = state.copyWith(
      papers: state.papers.map((p) {
        if (p.id == id) {
          return p.copyWith(downloadCount: p.downloadCount + 1);
        }
        return p;
      }).toList(),
    );
  }
}

final questionPaperControllerProvider =
    StateNotifierProvider<QuestionPaperController, QuestionPaperState>((ref) {
  final service = ref.watch(questionPaperServiceProvider);
  return QuestionPaperController(service);
});

final staffUploadedPapersProvider =
    FutureProvider.family<List<QuestionPaperModel>, String>((ref, staffId) async {
  final service = ref.watch(questionPaperServiceProvider);
  // Re-read when controller updates
  ref.watch(questionPaperControllerProvider);
  return service.getStaffUploadedPapers(staffId);
});
