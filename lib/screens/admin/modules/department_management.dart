import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';

class DepartmentManagementModule extends StatefulWidget {
  const DepartmentManagementModule({super.key});

  @override
  State<DepartmentManagementModule> createState() => _DepartmentManagementModuleState();
}

class _DepartmentManagementModuleState extends State<DepartmentManagementModule> {
  final List<Map<String, dynamic>> _deptData = [
    {'name': 'Artificial Intelligence and Data Science', 'lead': 'Dr. K. Vance', 'students': '340', 'staff': '22', 'isActive': true},
    {'name': 'Bio-Technology', 'lead': 'Dr. R. Sharma', 'students': '210', 'staff': '15', 'isActive': true},
    {'name': 'Bio-Medical Engineering', 'lead': 'Dr. P. Nair', 'students': '180', 'staff': '14', 'isActive': true},
    {'name': 'Chemical Engineering', 'lead': 'Prof. A. Kumar', 'students': '220', 'staff': '16', 'isActive': true},
    {'name': 'Civil Engineering', 'lead': 'Dr. M. Patel', 'students': '290', 'staff': '19', 'isActive': true},
    {'name': 'Computer and Communication Engineering', 'lead': 'Dr. S. Sundaram', 'students': '310', 'staff': '20', 'isActive': true},
    {'name': 'Computer Science and Engineering', 'lead': 'Dr. Sarah Chen', 'students': '482', 'staff': '24', 'isActive': true},
    {'name': 'Computer Science and Business System', 'lead': 'Prof. D. Raj', 'students': '260', 'staff': '17', 'isActive': true},
    {'name': 'Artificial Intelligence and Machine Learning', 'lead': 'Dr. E. Miller', 'students': '380', 'staff': '25', 'isActive': true},
    {'name': 'Electrical and Electronics Engineering', 'lead': 'Dr. H. Gupta', 'students': '320', 'staff': '21', 'isActive': true},
    {'name': 'Electronics and Communication Engineering', 'lead': 'Dr. V. Rao', 'students': '450', 'staff': '28', 'isActive': true},
    {'name': 'Information Technology', 'lead': 'Prof. N. Swamy', 'students': '410', 'staff': '26', 'isActive': true},
    {'name': 'Mechanical Engineering', 'lead': 'Dr. J. Harrison', 'students': '390', 'staff': '23', 'isActive': true},
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Force stretch for hit-test stability
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        if (isWide) _buildWideLayout() else _buildMobileLayout(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCapacityUsageBanner(),
              const SizedBox(height: 24),
              _buildDirectorySection(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCreateClassPanel(),
              const SizedBox(height: 24),
              _buildSmartSchedulerBanner(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCapacityUsageBanner(),
        const SizedBox(height: 24),
        _buildDirectorySection(),
        const SizedBox(height: 24),
        _buildCreateClassPanel(),
        const SizedBox(height: 24),
        _buildSmartSchedulerBanner(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DIRECTORY > DEPARTMENTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1)),
            SizedBox(height: 8),
            Text('Departments', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {}, 
          icon: const Icon(Icons.add, size: 16), 
          label: const Text('Add Dept', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), 
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, 
            foregroundColor: Colors.blue.shade700, 
            elevation: 0, 
            padding: const EdgeInsets.symmetric(horizontal: 12), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.blue.shade700))
          )
        ),
      ],
    );
  }

  Widget _buildCapacityUsageBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GROWTH OUTLOOK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          const Text('Institutional Capacity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('82% Operating Load for Fall 2024.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            children: [
              _simpleStat('4,242', 'ENROLLED'),
              const SizedBox(width: 32),
              _simpleStat('270', 'FACULTY'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simpleStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDirectorySection() {
    return Column(
      children: _deptData.map((d) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _deptCard(
          d['name'] as String,
          d['lead'] as String,
          d['students'] as String,
          d['staff'] as String,
          d['isActive'] as bool,
        ),
      )).toList(),
    );
  }

  Widget _deptCard(String name, String lead, String students, String staff, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: isActive ? Colors.blue.shade700 : AppColors.background, borderRadius: BorderRadius.circular(10)),
                child: Icon(isActive ? Icons.business_rounded : Icons.account_balance_outlined, size: 18, color: isActive ? Colors.white : Colors.blueGrey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
                    Text('Lead: $lead', style: const TextStyle(fontSize: 11, color: Colors.grey, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              if (isActive) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: const Text('ACTIVE', style: TextStyle(color: Colors.blue, fontSize: 8, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stableMiniStat(students, 'STUDENTS'),
              const SizedBox(width: 8),
              _stableMiniStat(staff, 'STAFF'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stableMiniStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateClassPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_box_rounded, color: Colors.white, size: 20)),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MANAGEMENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                  Text('New Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _inputField('e.g. Advanced Data Structures B'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _dropdownField('Dr. Sarah Chen')),
              const SizedBox(width: 12),
              SizedBox(width: 80, child: _inputField('40')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('SUBJECT MAPPING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          _subjectMappingTile('Data Structures', 'Core • 4 Credits'),
          const SizedBox(height: 8),
          _subjectMappingTile('Logic Design', 'Lab • 2 Credits'),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Create Class Entity', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _inputField(String hint) {
    return Container(height: 48, width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)), child: TextField(decoration: InputDecoration(hintText: hint, border: InputBorder.none, hintStyle: const TextStyle(fontSize: 12, color: Colors.grey))));
  }

  Widget _dropdownField(String value) {
    return Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(value, style: const TextStyle(fontSize: 11, overflow: TextOverflow.ellipsis))), const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 16)]));
  }

  Widget _subjectMappingTile(String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
          Text(sub, style: const TextStyle(fontSize: 9, color: Colors.grey, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildSmartSchedulerBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue, size: 18),
              SizedBox(width: 12),
              Text('Smart Scheduler', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Optimal room mappings based on current class sizes.', style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.1), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Configure', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
