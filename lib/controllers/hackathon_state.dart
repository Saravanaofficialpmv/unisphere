import 'package:unisphere/models/hackathon_model.dart';

enum HackathonStatus { initial, loading, success, empty, error }

class HackathonState {
  final HackathonStatus status;
  final List<HackathonModel> hackathons;
  final HackathonModel? featuredHackathon;
  final String selectedCategory;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  const HackathonState({
    this.status = HackathonStatus.initial,
    this.hackathons = const [],
    this.featuredHackathon,
    this.selectedCategory = 'All',
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  HackathonState copyWith({
    HackathonStatus? status,
    List<HackathonModel>? hackathons,
    HackathonModel? featuredHackathon,
    bool clearFeatured = false,
    String? selectedCategory,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return HackathonState(
      status: status ?? this.status,
      hackathons: hackathons ?? this.hackathons,
      featuredHackathon: clearFeatured ? null : (featuredHackathon ?? this.featuredHackathon),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
