import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';

class RoleManagementModule extends StatefulWidget {
  const RoleManagementModule({super.key});

  @override
  State<RoleManagementModule> createState() => _RoleManagementModuleState();
}

class _RoleManagementModuleState extends State<RoleManagementModule> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildTopGovernanceStats(isDesktop),
        const SizedBox(height: 32),
        _buildAccessTableSection(isDesktop),
        const SizedBox(height: 32),
        _buildGovernanceFooter(isDesktop),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SECURITY & GOVERNANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: Text('Access Requests & Role Assignment', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, overflow: TextOverflow.ellipsis))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Row(children: [CircleAvatar(radius: 3, backgroundColor: Colors.blue), SizedBox(width: 8), Text('24 Pending Review', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold))])),
          ],
        ),
      ],
    );
  }

  Widget _buildTopGovernanceStats(bool isDesktop) {
    return Row(
      children: [
        Expanded(child: _governanceCard('Pending Requests', '24', '+5 since last hour', Icons.assignment_rounded, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _governanceCard('Recent Approvals', '142', '98% acceptance rate', Icons.how_to_reg_rounded, Colors.brown)),
        const SizedBox(width: 16),
        Expanded(child: _governanceCard('Active Roles', '12', 'Managed permissions', Icons.verified_user_rounded, Colors.blueGrey)),
      ],
    );
  }

  Widget _governanceCard(String title, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(sub, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessTableSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(value: false, onChanged: (v) {}, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  const Text('Select All Pending', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(width: 24),
                  const Text('0 items selected', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              Row(
                children: [
                   const Text('Assign Bulk Role', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                   const SizedBox(width: 16),
                   ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Bulk Approve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _tableHeader(),
          _requestEntry('Jordan Smith', 'UN-9042', 'js', 'jordan.s@university.edu', 'Oct 12, 2023', 'Staff'),
          _requestEntry('Sarah Chen', 'Access Granted', 'sc', 's.chen@student.uni.edu', 'Oct 12, 2023', 'Student', isApproved: true),
          _requestEntry('Marcus Thorne', 'UN-4412', 'mt', '+1 (555) 092-1134', 'Oct 11, 2023', 'Parent'),
          _requestEntry('Elena Rodriguez', 'UN-8821', 'er', 'elena.ro@uni-staff.com', 'Oct 11, 2023', 'Select Role'),
          const SizedBox(height: 24),
          _paginationBar(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('NAME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 3, child: Text('EMAIL/MOBILE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text('REQUEST DATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text('PROPOSED ROLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text('ACTION', textAlign: TextAlign.right, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _requestEntry(String name, String id, String initials, String contact, String date, String role, {bool isApproved = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Row(children: [CircleAvatar(radius: 18, backgroundColor: isApproved ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1), child: Text(initials.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isApproved ? Colors.green : Colors.blue))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)), Text(id, style: TextStyle(fontSize: 9, color: isApproved ? Colors.green : Colors.grey, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis))]))])),
          Expanded(flex: 3, child: Text(contact, style: const TextStyle(fontSize: 11, color: Colors.grey, overflow: TextOverflow.ellipsis))),
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), const Text('10:42 AM', style: TextStyle(fontSize: 8, color: Colors.grey))])),
          Expanded(flex: 2, child: isApproved ? Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: const Text('STUDENT', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)))) : Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(role, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)), const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey)]))),
          Expanded(flex: 2, child: isApproved ? const Align(alignment: Alignment.centerRight, child: Icon(Icons.more_vert, size: 18, color: Colors.grey)) : Row(mainAxisAlignment: MainAxisAlignment.end, children: [const Text('Reject', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(width: 16), ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D4ED8), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Approve Access', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))]))
        ],
      ),
    );
  }

  Widget _paginationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Showing 4 of 24 pending requests', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        Row(
          children: [
            const Icon(Icons.keyboard_arrow_left, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            _pageBtn('1', true),
            _pageBtn('2', false),
            _pageBtn('3', false),
            const SizedBox(width: 12),
            const Icon(Icons.keyboard_arrow_right, size: 20, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _pageBtn(String n, bool active) {
    return Container(width: 32, height: 32, margin: const EdgeInsets.symmetric(horizontal: 4), alignment: Alignment.center, decoration: BoxDecoration(color: active ? const Color(0xFF2563EB) : Colors.transparent, borderRadius: BorderRadius.circular(6)), child: Text(n, style: TextStyle(color: active ? Colors.white : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)));
  }

  Widget _buildGovernanceFooter(bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Role Quick Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _quickSettingCard('Admin Permissions', 'Full system access and user management.', Icons.vpn_key_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _quickSettingCard('Staff Access', 'Academic record and attendance controls.', Icons.assignment_ind_outlined)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.blue.withValues(alpha: 0.05))),
            child: Column(
              children: [
                CircleAvatar(radius: 24, backgroundColor: Colors.white, child: Icon(Icons.restore, color: Colors.blue.shade700, size: 28)),
                const SizedBox(height: 16),
                const Text('Audit Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('View the history of role modifications and access approvals for compliance.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5)),
                const SizedBox(height: 20),
                TextButton(onPressed: () {}, child: const Text('Open Log History', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickSettingCard(String title, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 22),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.4)),
        ],
      ),
    );
  }
}
