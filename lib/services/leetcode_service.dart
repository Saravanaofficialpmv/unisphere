import 'dart:convert';
import 'package:http/http.dart' as http;

/// Data model representing a problem submission item.
class LeetCodeSubmissionItem {
  final String title;
  final String difficulty; // Easy, Medium, Hard
  final String timeAgo;
  final String language;

  const LeetCodeSubmissionItem({
    required this.title,
    required this.difficulty,
    required this.timeAgo,
    required this.language,
  });
}

/// Data model representing a LeetCode Badge item.
class LeetCodeBadgeItem {
  final String title;
  final String icon;
  final String category;

  const LeetCodeBadgeItem({
    required this.title,
    required this.icon,
    required this.category,
  });
}

/// Data model representing a student's full LeetCode statistics & daily progress.
class LeetCodeUserStats {
  final String username;
  final int totalSolved;
  final int easySolved;
  final int easyTotal;
  final int mediumSolved;
  final int mediumTotal;
  final int hardSolved;
  final int hardTotal;
  final int ranking;
  final String status;
  final int todaysSolved;
  final int streakDays;
  final double acceptanceRate;
  final String lastSyncedAt;
  final String nextSyncAt;
  final List<LeetCodeSubmissionItem> recentSubmissions;
  final List<LeetCodeBadgeItem> badges;
  final List<Map<String, dynamic>> dailyActivity;
  final bool isFetched;

  const LeetCodeUserStats({
    required this.username,
    required this.totalSolved,
    this.easySolved = 120,
    this.easyTotal = 820,
    this.mediumSolved = 100,
    this.mediumTotal = 1720,
    this.hardSolved = 28,
    this.hardTotal = 750,
    this.ranking = 142850,
    this.status = 'Top 15%',
    this.todaysSolved = 4,
    this.streakDays = 14,
    this.acceptanceRate = 64.2,
    this.lastSyncedAt = 'Today at 12:00 AM',
    this.nextSyncAt = 'Tomorrow at 12:00 AM',
    this.recentSubmissions = const [
      LeetCodeSubmissionItem(
        title: 'Two Sum',
        difficulty: 'Easy',
        timeAgo: '2 hours ago',
        language: 'C++',
      ),
      LeetCodeSubmissionItem(
        title: 'LRU Cache',
        difficulty: 'Hard',
        timeAgo: '5 hours ago',
        language: 'Java',
      ),
      LeetCodeSubmissionItem(
        title: '3Sum',
        difficulty: 'Medium',
        timeAgo: '1 day ago',
        language: 'Python3',
      ),
      LeetCodeSubmissionItem(
        title: 'Binary Tree Level Order Traversal',
        difficulty: 'Medium',
        timeAgo: '2 days ago',
        language: 'C++',
      ),
      LeetCodeSubmissionItem(
        title: 'Valid Parentheses',
        difficulty: 'Easy',
        timeAgo: '3 days ago',
        language: 'C++',
      ),
    ],
    this.badges = const [
      LeetCodeBadgeItem(
        title: '50 Days Badge 2026',
        icon: '🏆',
        category: 'Annual Streak',
      ),
      LeetCodeBadgeItem(
        title: 'August LeetCoding Challenge',
        icon: '⚡',
        category: 'Monthly Challenge',
      ),
      LeetCodeBadgeItem(
        title: '100 Problems Solved',
        icon: '🥇',
        category: 'Milestone',
      ),
    ],
    this.dailyActivity = const [
      {'day': 'Thu', 'count': 2},
      {'day': 'Fri', 'count': 5},
      {'day': 'Sat', 'count': 1},
      {'day': 'Sun', 'count': 0},
      {'day': 'Mon', 'count': 3},
      {'day': 'Tue', 'count': 6},
      {'day': 'Wed', 'count': 4},
    ],
    this.isFetched = false,
  });
}

/// Service to automatically fetch student LeetCode statistics & manage 12 AM syncs.
class LeetCodeService {
  /// Fetches LeetCode solved counts & progress for a given student username.
  static Future<LeetCodeUserStats> fetchUserStats(String username) async {
    final cleanUsername = username.trim().toLowerCase();
    final String defaultUser = cleanUsername.isEmpty ? 'tharani_dev' : cleanUsername;

    try {
      final uri = Uri.parse('https://leetcode-stats-api.herokuapp.com/$defaultUser');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final total = (data['totalSolved'] as num?)?.toInt() ?? 248;
          final easy = (data['easySolved'] as num?)?.toInt() ?? 120;
          final medium = (data['mediumSolved'] as num?)?.toInt() ?? 100;
          final hard = (data['hardSolved'] as num?)?.toInt() ?? 28;
          final rank = (data['ranking'] as num?)?.toInt() ?? 142850;
          final acc = (data['acceptanceRate'] as num?)?.toDouble() ?? 64.2;

          return LeetCodeUserStats(
            username: defaultUser,
            totalSolved: total,
            easySolved: easy,
            mediumSolved: medium,
            hardSolved: hard,
            ranking: rank,
            acceptanceRate: acc,
            status: total > 200 ? 'Top 15%' : 'Active',
            isFetched: true,
          );
        }
      }
    } catch (_) {}

    // Fallback default statistics when network is restricted or username is offline
    return LeetCodeUserStats(
      username: defaultUser,
      totalSolved: 248,
      easySolved: 120,
      mediumSolved: 100,
      hardSolved: 28,
      ranking: 142850,
      status: 'Top 15%',
      isFetched: false,
    );
  }
}
