import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/hackathon_model.dart';
import 'package:unisphere/services/hackathon_service.dart';
import 'package:unisphere/repositories/hackathon_repository.dart';
import 'package:unisphere/controllers/hackathon_state.dart';

final hackathonServiceProvider = Provider<HackathonService>((ref) {
  return ApiHackathonService();
});

final hackathonRepositoryProvider = Provider<HackathonRepository>((ref) {
  return HackathonRepository();
});

final hackathonControllerProvider = StateNotifierProvider<HackathonController, HackathonState>((ref) {
  final repository = ref.watch(hackathonRepositoryProvider);
  return HackathonController(repository);
});

class HackathonController extends StateNotifier<HackathonState> {
  final HackathonRepository _repository;
  static const int _pageSize = 5;

  HackathonController(this._repository) : super(const HackathonState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(status: HackathonStatus.loading, errorMessage: null);

    try {
      final featuredFuture = _repository.fetchFeaturedHackathon();
      final hackathonsFuture = _repository.fetchHackathons(
        page: 1,
        limit: _pageSize,
        category: state.selectedCategory == 'All' ? null : state.selectedCategory,
      );

      final results = await Future.wait([featuredFuture, hackathonsFuture]);

      final featured = results[0] as HackathonModel?;
      final list = results[1] as List<HackathonModel>;

      if (list.isEmpty && featured == null) {
        state = state.copyWith(
          status: HackathonStatus.empty,
          hackathons: [],
          featuredHackathon: null,
          clearFeatured: true,
          page: 1,
          hasMore: false,
        );
      } else {
        state = state.copyWith(
          status: HackathonStatus.success,
          hackathons: list,
          featuredHackathon: featured,
          page: 1,
          hasMore: list.length >= _pageSize,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: HackathonStatus.error,
        errorMessage: 'Unable to load hackathons: ${e.toString()}',
      );
    }
  }

  Future<void> refresh() async {
    await loadInitialData();
  }

  Future<void> filterByCategory(String category) async {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category, page: 1);
    await loadInitialData();
  }

  Future<void> loadNextPage() async {
    if (!state.hasMore || state.isLoadingMore || state.status != HackathonStatus.success) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final newItems = await _repository.fetchHackathons(
        page: nextPage,
        limit: _pageSize,
        category: state.selectedCategory == 'All' ? null : state.selectedCategory,
      );

      if (newItems.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
      } else {
        state = state.copyWith(
          hackathons: [...state.hackathons, ...newItems],
          page: nextPage,
          isLoadingMore: false,
          hasMore: newItems.length >= _pageSize,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<Map<String, dynamic>> registerTeam(String hackathonId, Map<String, dynamic> data) async {
    try {
      final result = await _repository.registerTeam(hackathonId, data);
      // Refresh local state to update userRegistrationStatus
      await loadInitialData();
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
