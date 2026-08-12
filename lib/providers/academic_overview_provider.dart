import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/services/leetcode_service.dart';
import 'package:unisphere/services/github_service.dart';
import 'package:unisphere/services/linkedin_service.dart';

class CustomUserLink {
  final String id;
  final String title;
  final String url;
  final String category;

  const CustomUserLink({
    required this.id,
    required this.title,
    required this.url,
    this.category = 'General',
  });
}

/// Data model representing the student's academic overview metrics.
class AcademicOverviewData {
  final double attendancePercentage;
  final double attendanceTrend;
  final String attendanceStatus;
  final double cgpa;
  final double cgpaTrend;
  final String cgpaLabel;
  final int odDays;
  final String odStatus;
  final int leetcodeSolved;
  final String leetcodeStatus;
  final String leetcodeUsername;
  final String githubUsername;
  final int githubRepos;
  final int githubStars;
  final int githubCommits;
  final String linkedinUrl;
  final String linkedinConnections;
  final String linkedinHeadline;
  final List<CustomUserLink> customLinks;

  const AcademicOverviewData({
    required this.attendancePercentage,
    required this.attendanceTrend,
    required this.attendanceStatus,
    required this.cgpa,
    required this.cgpaTrend,
    required this.cgpaLabel,
    this.odDays = 4,
    this.odStatus = 'Approved',
    this.leetcodeSolved = 130,
    this.leetcodeStatus = '130 Solved',
    this.leetcodeUsername = 'saravanapmv',
    this.githubUsername = 'Saravanaofficialpmv',
    this.githubRepos = 14,
    this.githubStars = 0,
    this.githubCommits = 87,
    this.linkedinUrl = 'https://www.linkedin.com/in/saravana-selvaraju/',
    this.linkedinConnections = '500+',
    this.linkedinHeadline = 'Flutter & Mobile Developer | AI Systems Innovator @ UNISPHERE',
    this.customLinks = const [
      CustomUserLink(
        id: 'cl_1',
        title: 'Codeforces Handle',
        url: 'https://codeforces.com/profile/saravanapmv',
        category: 'Coding',
      ),
      CustomUserLink(
        id: 'cl_2',
        title: 'Kaggle AI Ranks',
        url: 'https://kaggle.com/saravanaofficialpmv',
        category: 'AI',
      ),
    ],
  });
}

/// Notifier to manage state updates for the student's academic overview.
class AcademicOverviewNotifier extends StateNotifier<AcademicOverviewData> {
  AcademicOverviewNotifier()
      : super(
          const AcademicOverviewData(
            attendancePercentage: 85.0,
            attendanceTrend: 5.0,
            attendanceStatus: 'Good',
            cgpa: 8.72,
            cgpaTrend: 0.24,
            cgpaLabel: 'Current CGPA',
            odDays: 4,
            odStatus: 'Approved',
            leetcodeSolved: 130,
            leetcodeStatus: '130 Solved',
            leetcodeUsername: 'saravanapmv',
            githubUsername: 'Saravanaofficialpmv',
            githubRepos: 14,
            githubStars: 0,
            githubCommits: 87,
            linkedinUrl: 'https://www.linkedin.com/in/saravana-selvaraju/',
            linkedinConnections: '500+',
            linkedinHeadline: 'Flutter & Mobile Developer | AI Systems Innovator @ UNISPHERE',
          ),
        ) {
    fetchLeetCodeStats(state.leetcodeUsername);
    fetchGitHubStats(state.githubUsername);
    fetchLinkedInStats(state.linkedinUrl);
  }

  /// Automatically updates LeetCode solved count from public LeetCode API
  Future<void> fetchLeetCodeStats(String username) async {
    final stats = await LeetCodeService.fetchUserStats(username);
    state = AcademicOverviewData(
      attendancePercentage: state.attendancePercentage,
      attendanceTrend: state.attendanceTrend,
      attendanceStatus: state.attendanceStatus,
      cgpa: state.cgpa,
      cgpaTrend: state.cgpaTrend,
      cgpaLabel: state.cgpaLabel,
      odDays: state.odDays,
      odStatus: state.odStatus,
      leetcodeSolved: stats.totalSolved,
      leetcodeStatus: stats.status,
      leetcodeUsername: username,
      githubUsername: state.githubUsername,
      githubRepos: state.githubRepos,
      githubStars: state.githubStars,
      githubCommits: state.githubCommits,
      linkedinUrl: state.linkedinUrl,
      linkedinConnections: state.linkedinConnections,
      linkedinHeadline: state.linkedinHeadline,
      customLinks: state.customLinks,
    );
  }

  /// Automatically updates GitHub stats from GitHub REST API
  Future<void> fetchGitHubStats(String username) async {
    final stats = await GitHubService.fetchUserStats(username);
    state = AcademicOverviewData(
      attendancePercentage: state.attendancePercentage,
      attendanceTrend: state.attendanceTrend,
      attendanceStatus: state.attendanceStatus,
      cgpa: state.cgpa,
      cgpaTrend: state.cgpaTrend,
      cgpaLabel: state.cgpaLabel,
      odDays: state.odDays,
      odStatus: state.odStatus,
      leetcodeSolved: state.leetcodeSolved,
      leetcodeStatus: state.leetcodeStatus,
      leetcodeUsername: state.leetcodeUsername,
      githubUsername: username,
      githubRepos: stats.publicRepos,
      githubStars: stats.starsEarned,
      githubCommits: stats.commitsThisYear,
      linkedinUrl: state.linkedinUrl,
      linkedinConnections: state.linkedinConnections,
      linkedinHeadline: state.linkedinHeadline,
      customLinks: state.customLinks,
    );
  }

  /// Automatically updates LinkedIn professional profile stats
  Future<void> fetchLinkedInStats(String urlOrHandle) async {
    final stats = await LinkedInService.fetchProfileStats(urlOrHandle);
    state = AcademicOverviewData(
      attendancePercentage: state.attendancePercentage,
      attendanceTrend: state.attendanceTrend,
      attendanceStatus: state.attendanceStatus,
      cgpa: state.cgpa,
      cgpaTrend: state.cgpaTrend,
      cgpaLabel: state.cgpaLabel,
      odDays: state.odDays,
      odStatus: state.odStatus,
      leetcodeSolved: state.leetcodeSolved,
      leetcodeStatus: state.leetcodeStatus,
      leetcodeUsername: state.leetcodeUsername,
      githubUsername: state.githubUsername,
      githubRepos: state.githubRepos,
      githubStars: state.githubStars,
      githubCommits: state.githubCommits,
      linkedinUrl: stats.profileUrl,
      linkedinConnections: stats.connectionsCount,
      linkedinHeadline: stats.headline,
      customLinks: state.customLinks,
    );
  }

  void addCustomLink({required String title, required String url, String category = 'General'}) {
    final newLink = CustomUserLink(
      id: 'cl_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      url: url.trim(),
      category: category,
    );
    final updatedLinks = [...state.customLinks, newLink];
    state = AcademicOverviewData(
      attendancePercentage: state.attendancePercentage,
      attendanceTrend: state.attendanceTrend,
      attendanceStatus: state.attendanceStatus,
      cgpa: state.cgpa,
      cgpaTrend: state.cgpaTrend,
      cgpaLabel: state.cgpaLabel,
      odDays: state.odDays,
      odStatus: state.odStatus,
      leetcodeSolved: state.leetcodeSolved,
      leetcodeStatus: state.leetcodeStatus,
      leetcodeUsername: state.leetcodeUsername,
      githubUsername: state.githubUsername,
      githubRepos: state.githubRepos,
      githubStars: state.githubStars,
      githubCommits: state.githubCommits,
      linkedinUrl: state.linkedinUrl,
      linkedinConnections: state.linkedinConnections,
      linkedinHeadline: state.linkedinHeadline,
      customLinks: updatedLinks,
    );
  }

  void removeCustomLink(String linkId) {
    final updatedLinks = state.customLinks.where((l) => l.id != linkId).toList();
    state = AcademicOverviewData(
      attendancePercentage: state.attendancePercentage,
      attendanceTrend: state.attendanceTrend,
      attendanceStatus: state.attendanceStatus,
      cgpa: state.cgpa,
      cgpaTrend: state.cgpaTrend,
      cgpaLabel: state.cgpaLabel,
      odDays: state.odDays,
      odStatus: state.odStatus,
      leetcodeSolved: state.leetcodeSolved,
      leetcodeStatus: state.leetcodeStatus,
      leetcodeUsername: state.leetcodeUsername,
      githubUsername: state.githubUsername,
      githubRepos: state.githubRepos,
      githubStars: state.githubStars,
      githubCommits: state.githubCommits,
      linkedinUrl: state.linkedinUrl,
      linkedinConnections: state.linkedinConnections,
      linkedinHeadline: state.linkedinHeadline,
      customLinks: updatedLinks,
    );
  }

  void updateData({
    double? attendancePercentage,
    double? attendanceTrend,
    String? attendanceStatus,
    double? cgpa,
    double? cgpaTrend,
    String? cgpaLabel,
    int? odDays,
    String? odStatus,
    int? leetcodeSolved,
    String? leetcodeStatus,
    String? leetcodeUsername,
    String? githubUsername,
    int? githubRepos,
    int? githubStars,
    int? githubCommits,
    String? linkedinUrl,
    String? linkedinConnections,
    String? linkedinHeadline,
    List<CustomUserLink>? customLinks,
  }) {
    state = AcademicOverviewData(
      attendancePercentage: attendancePercentage ?? state.attendancePercentage,
      attendanceTrend: attendanceTrend ?? state.attendanceTrend,
      attendanceStatus: attendanceStatus ?? state.attendanceStatus,
      cgpa: cgpa ?? state.cgpa,
      cgpaTrend: cgpaTrend ?? state.cgpaTrend,
      cgpaLabel: cgpaLabel ?? state.cgpaLabel,
      odDays: odDays ?? state.odDays,
      odStatus: odStatus ?? state.odStatus,
      leetcodeSolved: leetcodeSolved ?? state.leetcodeSolved,
      leetcodeStatus: leetcodeStatus ?? state.leetcodeStatus,
      leetcodeUsername: leetcodeUsername ?? state.leetcodeUsername,
      githubUsername: githubUsername ?? state.githubUsername,
      githubRepos: githubRepos ?? state.githubRepos,
      githubStars: githubStars ?? state.githubStars,
      githubCommits: githubCommits ?? state.githubCommits,
      linkedinUrl: linkedinUrl ?? state.linkedinUrl,
      linkedinConnections: linkedinConnections ?? state.linkedinConnections,
      linkedinHeadline: linkedinHeadline ?? state.linkedinHeadline,
      customLinks: customLinks ?? state.customLinks,
    );
  }
}

/// Riverpod provider for student academic overview metrics.
final academicOverviewProvider =
    StateNotifierProvider<AcademicOverviewNotifier, AcademicOverviewData>(
  (ref) => AcademicOverviewNotifier(),
);
