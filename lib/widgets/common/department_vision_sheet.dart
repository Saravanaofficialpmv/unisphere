import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';

/// Interactive modal sheet displaying the HOD-published Department Vision, Mission, PEOs, POs, and PSOs for AI & DS.
void showDepartmentVisionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const DepartmentVisionSheet(),
  );
}

class DepartmentVisionSheet extends StatefulWidget {
  const DepartmentVisionSheet({super.key});

  @override
  State<DepartmentVisionSheet> createState() => _DepartmentVisionSheetState();
}

class _DepartmentVisionSheetState extends State<DepartmentVisionSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Department Charter & Outcomes',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Artificial Intelligence & Data Science (AI & DS)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // HOD Approval Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Official Document • Published by Dr. R. Sundaram (HOD - AI & DS)',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Tab Bar Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Vision & Mission'),
                Tab(text: 'PEOs (3)'),
                Tab(text: 'POs (12)'),
                Tab(text: 'PSOs (3)'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tab Contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVisionAndMissionTab(),
                _buildPeoTab(),
                _buildPoTab(),
                _buildPsoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. Vision & Mission Tab ──────────────────────
  Widget _buildVisionAndMissionTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        // Vision Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility_rounded, color: Color(0xFF38BDF8), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Vision of the Department',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'To emerge as a premier centre of excellence in Artificial Intelligence and Data Science by creating globally competent professionals, advancing impactful research, fostering innovation and entrepreneurship, and developing ethical, intelligent technologies for a sustainable and inclusive society.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFFE2E8F0), height: 1.55),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Mission Header
        const Row(
          children: [
            Icon(Icons.flag_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Mission of the Department',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Mission Items
        _buildMissionCard(
          number: '1',
          title: 'World-Class Pedagogy & Curriculum',
          description:
              'Provide world-class education through innovative pedagogy, outcome-based learning, and industry-aligned curricula in Artificial Intelligence and Data Science.',
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 10),
        _buildMissionCard(
          number: '2',
          title: 'Interdisciplinary Research & AI Solutions',
          description:
              'Promote interdisciplinary research, innovation, and lifelong learning to address global challenges through intelligent and data-driven solutions.',
          color: const Color(0xFF059669),
        ),
        const SizedBox(height: 10),
        _buildMissionCard(
          number: '3',
          title: 'Industry Collaboration & Employability',
          description:
              'Collaborate with industries, research institutions, and professional bodies to enhance experiential learning, technology development, and employability.',
          color: const Color(0xFFD97706),
        ),
        const SizedBox(height: 10),
        _buildMissionCard(
          number: '4',
          title: 'Ethical Leadership & Entrepreneurship',
          description:
              'Cultivate ethical leadership, entrepreneurial mindset, social responsibility, and professional excellence for sustainable technological advancement.',
          color: const Color(0xFF7C3AED),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildMissionCard({
    required String number,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'M$number',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. PEO Tab (Programme Educational Objectives) ──────────────────────
  Widget _buildPeoTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const Text(
          'Programme Educational Objectives (PEOs)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Target educational goals expected of AI & DS graduates within 3 to 5 years after graduation:',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        _buildPeoCard(
          peoId: 'PEO 1',
          title: 'Professional Excellence & Innovation',
          description:
              'Graduates will excel as competent professionals by applying Artificial Intelligence, Data Science, and computational intelligence to develop innovative solutions for complex engineering, industrial, and societal problems.',
          accentColor: const Color(0xFF2563EB),
          icon: Icons.psychology_rounded,
        ),
        const SizedBox(height: 12),
        _buildPeoCard(
          peoId: 'PEO 2',
          title: 'Lifelong Learning & Research Innovation',
          description:
              'Graduates will engage in lifelong learning, research, higher education, and technological innovation by adopting emerging AI technologies and contributing to knowledge creation and sustainable development.',
          accentColor: const Color(0xFF059669),
          icon: Icons.auto_graph_rounded,
        ),
        const SizedBox(height: 12),
        _buildPeoCard(
          peoId: 'PEO 3',
          title: 'Ethical Leadership & Global Impact',
          description:
              'Graduates will exhibit ethical values, leadership, entrepreneurial mindset, and effective communication while contributing to multidisciplinary teams and creating technology solutions with global impact.',
          accentColor: const Color(0xFF7C3AED),
          icon: Icons.public_rounded,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildPeoCard({
    required String peoId,
    required String title,
    required String description,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  peoId,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
              Icon(icon, color: accentColor, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── 3. PO Tab (Program Outcomes 1 - 12) ──────────────────────
  Widget _buildPoTab() {
    final List<Map<String, String>> poList = [
      {
        'id': 'PO 1',
        'title': 'Engineering Knowledge',
        'desc':
            'Apply the knowledge of mathematics, science, engineering fundamentals, and an engineering specialization to the solution of complex engineering problems.'
      },
      {
        'id': 'PO 2',
        'title': 'Problem Analysis',
        'desc':
            'Identify, formulate, review research literature, and analyze complex engineering problems reaching substantiated conclusions using first principles of mathematics, natural sciences, and engineering sciences.'
      },
      {
        'id': 'PO 3',
        'title': 'Design / Development of Solutions',
        'desc':
            'Design solutions for complex engineering problems and design system components or processes that meet the specified needs with appropriate consideration for the public health and safety, and the cultural, societal, and environmental considerations.'
      },
      {
        'id': 'PO 4',
        'title': 'Conduct Investigations of Complex Problems',
        'desc':
            'Use research-based knowledge and research methods including design of experiments, analysis and interpretation of data, and synthesis of the information to provide valid conclusions.'
      },
      {
        'id': 'PO 5',
        'title': 'Modern Tool Usage',
        'desc':
            'Create, select, and apply appropriate techniques, resources, and modern engineering and IT tools including prediction and modeling to complex engineering activities with an understanding of the limitations.'
      },
      {
        'id': 'PO 6',
        'title': 'The Engineer and Society',
        'desc':
            'Apply reasoning informed by the contextual knowledge to assess societal, health, safety, legal and cultural issues and the consequent responsibilities relevant to the professional engineering practice.'
      },
      {
        'id': 'PO 7',
        'title': 'Environment and Sustainability',
        'desc':
            'Understand the impact of the professional engineering solutions in societal and environmental contexts, and demonstrate the knowledge of, and need for sustainable development.'
      },
      {
        'id': 'PO 8',
        'title': 'Ethics',
        'desc':
            'Apply ethical principles and commit to professional ethics and responsibilities and norms of the engineering practice.'
      },
      {
        'id': 'PO 9',
        'title': 'Individual and Team Work',
        'desc':
            'Function effectively as an individual, and as a member or leader in diverse teams, and in multidisciplinary settings.'
      },
      {
        'id': 'PO 10',
        'title': 'Communication',
        'desc':
            'Communicate effectively on complex engineering activities with the engineering community and with society at large, such as, being able to comprehend and write effective reports and design documentation, make effective presentations, and give and receive clear instructions.'
      },
      {
        'id': 'PO 11',
        'title': 'Project Management and Finance',
        'desc':
            'Demonstrate knowledge and understanding of the engineering and management principles and apply these to one’s own work, as a member and leader in a team, to manage projects and in multidisciplinary environments.'
      },
      {
        'id': 'PO 12',
        'title': 'Life-Long Learning',
        'desc':
            'Recognize the need for, and have the preparation and ability to engage in independent and life-long learning in the broadest context of technological change.'
      },
    ];

    final filteredList = _searchQuery.isEmpty
        ? poList
        : poList
            .where((item) =>
                item['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item['desc']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item['id']!.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search PO 1-12 (e.g., ethics, tool, design)...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // List of POs
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final po = filteredList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          po['id']!,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              po['title']!,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              po['desc']!,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 4. PSO Tab (Program Specific Outcomes 1 - 3) ──────────────────────
  Widget _buildPsoTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const Text(
          'Program Specific Outcomes (PSOs)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Specific skills & competencies tailored for Artificial Intelligence and Data Science graduates:',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        _buildPsoCard(
          psoId: 'PSO 1',
          title: 'Intelligent AI & Deep Learning Systems',
          description:
              'Design, implement, and optimize intelligent systems using Artificial Intelligence, Machine Learning, Deep Learning, Natural Language Processing, and Computer Vision techniques to solve domain-specific challenges.',
          gradient: const [Color(0xFF2563EB), Color(0xFF3B82F6)],
          icon: Icons.memory_rounded,
        ),
        const SizedBox(height: 12),
        _buildPsoCard(
          psoId: 'PSO 2',
          title: 'Data Engineering & Predictive Intelligence',
          description:
              'Apply advanced data engineering, analytics, visualization, and predictive modeling techniques using state-of-the-art industrial tools and AI frameworks to transform data into actionable intelligence for strategic decision-making.',
          gradient: const [Color(0xFF059669), Color(0xFF10B981)],
          icon: Icons.analytics_rounded,
        ),
        const SizedBox(height: 12),
        _buildPsoCard(
          psoId: 'PSO 3',
          title: 'Ethical MLOps & Scalable AI Architecture',
          description:
              'Engineer scalable, reliable, secure, and ethical AI-enabled solutions by integrating cloud computing, edge intelligence, Generative AI, IoT, and MLOps while effectively managing multidisciplinary projects and adhering to professional and societal responsibilities.',
          gradient: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
          icon: Icons.hub_rounded,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildPsoCard({
    required String psoId,
    required String title,
    required String description,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gradient.first.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  psoId,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
              Icon(icon, color: gradient.first, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.5),
          ),
        ],
      ),
    );
  }
}
