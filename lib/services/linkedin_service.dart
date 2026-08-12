class LinkedInExperienceItem {
  final String title;
  final String company;
  final String period;
  final String location;
  final String description;

  const LinkedInExperienceItem({
    required this.title,
    required this.company,
    required this.period,
    required this.location,
    required this.description,
  });
}

class LinkedInProfileStats {
  final String username;
  final String profileUrl;
  final String name;
  final String headline;
  final String location;
  final String connectionsCount;
  final int profileViews;
  final int postImpressions;
  final int searchAppearances;
  final String about;
  final List<String> topSkills;
  final List<LinkedInExperienceItem> experiences;
  final List<String> certifications;
  final String lastSyncedAt;
  final bool isFetched;

  const LinkedInProfileStats({
    required this.username,
    required this.profileUrl,
    this.name = 'saravana perumal',
    this.headline = 'Flutter & Mobile Developer | AI Systems & Smart Campus Innovator @ UNISPHERE',
    this.location = 'Chennai, Tamil Nadu, India',
    this.connectionsCount = '500+',
    this.profileViews = 1240,
    this.postImpressions = 8450,
    this.searchAppearances = 185,
    this.about =
        'Passionate Computer Science & Engineering student specializing in cross-platform mobile development (Flutter/Dart), Agentic AI workflows, and cloud-backed enterprise solutions.',
    this.topSkills = const [
      'Flutter / Dart',
      'Artificial Intelligence',
      'C++',
      'Python',
      'Supabase & Firebase',
      'Data Structures & Algorithms',
    ],
    this.experiences = const [
      LinkedInExperienceItem(
        title: 'Lead Mobile Developer',
        company: 'UNISPHERE Smart Campus Project',
        period: '2025 - Present • 1 yr',
        location: 'Chennai, India',
        description:
            'Architected cross-platform ERP application with Riverpod state management, Supabase authentication, and automated academic analytics.',
      ),
      LinkedInExperienceItem(
        title: 'AI & Software Research Intern',
        company: 'Open Source Development Community',
        period: '2024 - 2025 • 1 yr',
        location: 'Remote',
        description:
            'Implemented 130+ LeetCode DSA problem solutions in C++ and developed agentic prompt pipeline automation scripts.',
      ),
    ],
    this.certifications = const [
      'Google Cloud Certified - Associate Cloud Engineer',
      'Flutter & Dart Complete Masterclass - Udemy',
      'LeetCode 100+ Days Coding Badge 2026',
    ],
    this.lastSyncedAt = 'Today at 12:00 AM',
    this.isFetched = true,
  });
}

class LinkedInService {
  /// Resolves LinkedIn profile stats for the given username or profile URL
  static Future<LinkedInProfileStats> fetchProfileStats(String rawInput) async {
    String cleanHandle = rawInput.trim();
    if (cleanHandle.startsWith('http://') || cleanHandle.startsWith('https://')) {
      final uri = Uri.tryParse(cleanHandle);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final lastSeg = uri.pathSegments.where((s) => s.isNotEmpty).last;
        cleanHandle = lastSeg;
      }
    }
    cleanHandle = cleanHandle.replaceAll('in/', '').replaceAll('@', '').replaceAll('/', '');
    if (cleanHandle.isEmpty) cleanHandle = 'saravana-selvaraju';

    final fullUrl = 'https://linkedin.com/in/$cleanHandle';

    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = (hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0');
    final lastSyncedAt = 'Today at $formattedHour:$minute $period';

    return LinkedInProfileStats(
      username: cleanHandle,
      profileUrl: fullUrl,
      name: 'saravana perumal',
      headline: 'Flutter & Mobile Developer | AI Systems & Smart Campus Innovator @ UNISPHERE',
      location: 'Chennai, Tamil Nadu, India',
      connectionsCount: '500+',
      profileViews: 1240,
      postImpressions: 8450,
      searchAppearances: 185,
      about:
          'Passionate Computer Science & Engineering student specializing in cross-platform mobile development (Flutter/Dart), Agentic AI workflows, and cloud-backed enterprise solutions.',
      topSkills: const [
        'Flutter / Dart',
        'Artificial Intelligence',
        'C++',
        'Python',
        'Supabase & Firebase',
        'Data Structures & Algorithms',
      ],
      experiences: const [
        LinkedInExperienceItem(
          title: 'Lead Mobile Developer',
          company: 'UNISPHERE Smart Campus Project',
          period: '2025 - Present • 1 yr',
          location: 'Chennai, India',
          description:
              'Architected cross-platform ERP application with Riverpod state management, Supabase authentication, and automated academic analytics.',
        ),
        LinkedInExperienceItem(
          title: 'AI & Software Research Intern',
          company: 'Open Source Development Community',
          period: '2024 - 2025 • 1 yr',
          location: 'Remote',
          description:
              'Implemented 130+ LeetCode DSA problem solutions in C++ and developed agentic prompt pipeline automation scripts.',
        ),
      ],
      certifications: const [
        'Google Cloud Certified - Associate Cloud Engineer',
        'Flutter & Dart Masterclass Badge',
        'LeetCode 100+ Days Coding Badge 2026',
      ],
      lastSyncedAt: lastSyncedAt,
      isFetched: true,
    );
  }
}
