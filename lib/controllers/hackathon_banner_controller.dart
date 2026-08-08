import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/services/hackathon_banner_service.dart';
import 'package:clg_application/controllers/hackathon_banner_state.dart';

final hackathonBannerServiceProvider = Provider<HackathonBannerService>((ref) {
  return ApiHackathonBannerService();
});

final hackathonBannerControllerProvider =
    StateNotifierProvider<HackathonBannerController, HackathonBannerState>((ref) {
  final service = ref.watch(hackathonBannerServiceProvider);
  return HackathonBannerController(service);
});

class HackathonBannerController extends StateNotifier<HackathonBannerState> {
  final HackathonBannerService _service;

  HackathonBannerController(this._service) : super(const HackathonBannerState()) {
    fetchBanner();
  }

  Future<void> fetchBanner() async {
    state = state.copyWith(status: HackathonBannerStatus.loading, errorMessage: null);

    try {
      final banner = await _service.getHackathonBanner();

      if (banner == null || !banner.isActive) {
        state = state.copyWith(
          status: HackathonBannerStatus.empty,
          clearBanner: true,
        );
      } else {
        state = state.copyWith(
          status: HackathonBannerStatus.success,
          banner: banner,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: HackathonBannerStatus.error,
        errorMessage: 'Unable to load hackathon banner: ${e.toString()}',
      );
    }
  }

  Future<void> refresh() async {
    await fetchBanner();
  }
}
