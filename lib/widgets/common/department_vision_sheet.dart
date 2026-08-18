import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';

/// Interactive modal sheet displaying Department & Institute Vision, Mission, PEOs, POs, PSOs, and Outcome Mapping for AI & DS.
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
  int _selectedMainSection = 0; // 0: Institution, 1: Department
  late TabController _deptTabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _deptTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _deptTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
                        'Charter & Outcomes',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Academic Specification Portal',
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

          // 2-Section Primary Switcher (Institution vs Department)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMainSection = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedMainSection == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _selectedMainSection == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_rounded,
                              size: 18,
                              color: _selectedMainSection == 0 ? AppColors.primary : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Institution',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _selectedMainSection == 0 ? AppColors.primary : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMainSection = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedMainSection == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _selectedMainSection == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              size: 18,
                              color: _selectedMainSection == 1 ? AppColors.primary : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Department (AI & DS)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _selectedMainSection == 1 ? AppColors.primary : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Main View Content
          Expanded(
            child: _selectedMainSection == 0
                ? _buildInstitutionSection()
                : _buildDepartmentSection(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 1: INSTITUTION (Vision & Mission)
  // ==========================================
  Widget _buildInstitutionSection() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        // Institute Vision Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility_rounded, color: Color(0xFF2563EB), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'VISION OF THE INSTITUTE',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: 0.5),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'We endeavor to impart futuristic technical education of the highest quality to the student community and to inculcate discipline in them to face the world with self-confidence and thus we prepare them for life as responsible citizens to uphold human values and to be of service at large. We strive to bring up the Institution as an Institution of academic excellence of international standard.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.55),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Institute Mission Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, color: Color(0xFF059669), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'MISSION OF THE INSTITUTE',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: 0.5),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'We transform persons into personalities by the state-of-the-art infrastructure, time consciousness, quick response and the best academic practices through assessment and advice.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.55),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ==========================================
  // SECTION 2: DEPARTMENT (AI & DS Entire Charter)
  // ==========================================
  Widget _buildDepartmentSection() {
    return Column(
      children: [
        // Sub-Tab Navigation Bar for Department
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TabBar(
            controller: _deptTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            padding: const EdgeInsets.all(4),
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF64748B),
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            labelPadding: const EdgeInsets.symmetric(horizontal: 14),
            tabs: const [
              Tab(text: '🎯 Vision & Mission'),
              Tab(text: '🎓 PEOs (3)'),
              Tab(text: '📊 POs (11)'),
              Tab(text: '⚡ PSOs (3)'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Department Tab Contents
        Expanded(
          child: TabBarView(
            controller: _deptTabController,
            children: [
              _buildDeptVisionAndMissionTab(),
              _buildPeoTab(),
              _buildPoTab(),
              _buildPsoTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Department Vision & Mission ──────────────────────
  Widget _buildDeptVisionAndMissionTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        // Department Vision Card
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
                  Icon(Icons.auto_awesome_rounded, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 10),
                  Text(
                    'VISION OF THE DEPARTMENT',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'To emerge as a premier centre of excellence in Artificial Intelligence and Data Science by creating globally competent professionals, advancing impactful research, fostering innovation and entrepreneurship, and developing ethical, intelligent technologies for a sustainable and inclusive society.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFFE2E8F0), height: 1.55),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Department Mission Items (M1 - M4)
        _buildMissionCard(
          number: '1',
          description:
              'Provide world-class education through innovative pedagogy, outcome-based learning, and industry-aligned curricula in Artificial Intelligence and Data Science.',
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 8),
        _buildMissionCard(
          number: '2',
          description:
              'Promote interdisciplinary research, innovation, and lifelong learning to address global challenges through intelligent and data-driven solutions.',
          color: const Color(0xFF059669),
        ),
        const SizedBox(height: 8),
        _buildMissionCard(
          number: '3',
          description:
              'Collaborate with industries, research institutions, and professional bodies to enhance experiential learning, technology development, and employability.',
          color: const Color(0xFFD97706),
        ),
        const SizedBox(height: 8),
        _buildMissionCard(
          number: '4',
          description:
              'Cultivate ethical leadership, entrepreneurial mindset, social responsibility, and professional excellence for sustainable technological advancement.',
          color: const Color(0xFF7C3AED),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMissionCard({
    required String number,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'M$number',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                description,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PEO Tab (Programme Educational Objectives) ──────────────────────
  Widget _buildPeoTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _buildPeoCard(
          peoId: 'PEO 1',
          description:
              'Graduates will excel as competent professionals by applying Artificial Intelligence, Data Science, and computational intelligence to develop innovative solutions for complex engineering, industrial, and societal problems.',
          accentColor: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 10),
        _buildPeoCard(
          peoId: 'PEO 2',
          description:
              'Graduates will engage in lifelong learning, research, higher education, and technological innovation by adopting emerging AI technologies and contributing to knowledge creation and sustainable development.',
          accentColor: const Color(0xFF059669),
        ),
        const SizedBox(height: 10),
        _buildPeoCard(
          peoId: 'PEO 3',
          description:
              'Graduates will exhibit ethical values, leadership, entrepreneurial mindset, and effective communication while contributing to multidisciplinary teams and creating technology solutions with global impact.',
          accentColor: const Color(0xFF7C3AED),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPeoCard({
    required String peoId,
    required String description,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                description,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PO Tab (Program Outcomes 1 - 11) ──────────────────────
  Widget _buildPoTab() {
    final List<Map<String, String>> poList = [
      {
        'id': 'PO 1',
        'title': 'Engineering Knowledge',
        'desc':
            'Apply knowledge of mathematics, natural science, computing, engineering fundamentals and an engineering specialization as specified in WK1 to WK4 respectively to develop to the solution of complex engineering problems.'
      },
      {
        'id': 'PO 2',
        'title': 'Problem Analysis',
        'desc':
            'Identify, formulate, review research literature and analyze complex engineering problems reaching substantiated conclusions with consideration for sustainable development. (WK1 to WK4)'
      },
      {
        'id': 'PO 3',
        'title': 'Design/Development of Solutions',
        'desc':
            'Design creative solutions for complex engineering problems and design/develop systems/components/processes to meet identified needs with consideration for the public health and safety, whole-life cost, net zero carbon, culture, society and environment as required. (WK5)'
      },
      {
        'id': 'PO 4',
        'title': 'Conduct Investigations of Complex Problems',
        'desc':
            'Conduct investigations of complex engineering problems using research-based knowledge including design of experiments, modelling, analysis & interpretation of data to provide valid conclusions. (WK8).'
      },
      {
        'id': 'PO 5',
        'title': 'Engineering Tool Usage',
        'desc':
            'Create, select and apply appropriate techniques, resources and modern engineering & IT tools, including prediction and modelling recognizing their limitations to solve complex engineering problems. (WK2 and WK6).'
      },
      {
        'id': 'PO 6',
        'title': 'The Engineer and The World',
        'desc':
            'Analyze and evaluate societal and environmental aspects while solving complex engineering problems for its impact on sustainability with reference to economy, health, safety, legal framework, culture and environment. (WK1, WK5, and WK7).'
      },
      {
        'id': 'PO 7',
        'title': 'Ethics',
        'desc':
            'Apply ethical principles and commit to professional ethics, human values, diversity and inclusion; adhere to national & international laws. (WK9).'
      },
      {
        'id': 'PO 8',
        'title': 'Individual and Collaborative Team Work',
        'desc':
            'Function effectively as an individual, and as a member or leader in diverse/multi-disciplinary teams.'
      },
      {
        'id': 'PO 9',
        'title': 'Communication',
        'desc':
            'Communicate effectively and inclusively within the engineering community and society at large, such as being able to comprehend and write effective reports and design documentation, make effective presentations considering cultural, language, and learning differences.'
      },
      {
        'id': 'PO 10',
        'title': 'Project Management and Finance',
        'desc':
            'Apply knowledge and understanding of engineering management principles and economic decision-making and apply these to one’s own work, as a member and leader in a team, and to manage projects and in multidisciplinary environments.'
      },
      {
        'id': 'PO 11',
        'title': 'Life-Long Learning',
        'desc':
            'Recognize the need for, and have the preparation and ability for i) independent and life-long learning ii) adaptability to new and emerging technologies and iii) critical thinking in the broadest context of technological change. (WK8)'
      },
    ];

    final filteredList = _searchQuery.isEmpty
        ? poList
        : poList
            .where((item) =>
                item['desc']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item['id']!.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search PO 1-11...',
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final po = filteredList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              po['desc']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                                height: 1.45,
                              ),
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

  // ── PSO Tab (Program Specific Outcomes 1 - 3) ──────────────────────
  Widget _buildPsoTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _buildPsoCard(
          psoId: 'PSO 1',
          title: 'AI & Data Science',
          description:
              'Design, implement, and optimize intelligent systems using Artificial Intelligence, Machine Learning, Deep Learning, Natural Language Processing, and Computer Vision techniques to solve domain-specific challenges.',
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 10),
        _buildPsoCard(
          psoId: 'PSO 2',
          title: 'Data Analytics',
          description:
              'Apply advanced data engineering, analytics, visualization, and predictive modeling techniques using state-of-the-art industrial tools and AI frameworks to transform data into actionable intelligence for strategic decision-making.',
          color: const Color(0xFF059669),
        ),
        const SizedBox(height: 10),
        _buildPsoCard(
          psoId: 'PSO 3',
          title: 'Intelligent Systems',
          description:
              'Engineer scalable, reliable, secure, and ethical AI-enabled solutions by integrating cloud computing, edge intelligence, Generative AI, IoT, and MLOps while effectively managing multidisciplinary projects and adhering to professional and societal responsibilities.',
          color: const Color(0xFF7C3AED),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPsoCard({
    required String psoId,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              psoId,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
