import 'package:clg_application/models/hackathon_banner_model.dart';

enum HackathonBannerStatus { initial, loading, success, empty, error }

class HackathonBannerState {
  final HackathonBannerStatus status;
  final HackathonBannerModel? banner;
  final String? errorMessage;

  const HackathonBannerState({
    this.status = HackathonBannerStatus.initial,
    this.banner,
    this.errorMessage,
  });

  HackathonBannerState copyWith({
    HackathonBannerStatus? status,
    HackathonBannerModel? banner,
    bool clearBanner = false,
    String? errorMessage,
  }) {
    return HackathonBannerState(
      status: status ?? this.status,
      banner: clearBanner ? null : (banner ?? this.banner),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
