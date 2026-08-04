import 'package:flutter/material.dart';
import 'package:clg_application/core/constants/app_colors.dart';

class ReportManagementModule extends StatefulWidget {
  const ReportManagementModule({super.key});

  @override
  State<ReportManagementModule> createState() => _ReportManagementModuleState();
}

class _ReportManagementModuleState extends State<ReportManagementModule> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildTopPerformanceGrid(isDesktop),
        const SizedBox(height: 32),
        if (isDesktop) 
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildPerformanceBreakdown()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildSemesterTrends()),
            ],
          )
        else 
          Column(
            children: [
              _buildPerformanceBreakdown(),
              const SizedBox(height: 24),
              _buildSemesterTrends(),
            ],
          ),
        const SizedBox(height: 32),
        _buildAnalysisSummaries(isDesktop),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PERFORMANCE INTELLIGENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Departmental Performance', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Row(
              children: [
                _headerDropdown('AY 2023-24'),
                const SizedBox(width: 12),
                _headerDropdown('Semester 4'),
                const SizedBox(width: 12),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)), child: const Row(children: [Icon(Icons.tune, size: 16), SizedBox(width: 8), Text('More Filters', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))])),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerDropdown(String label) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)), child: Row(children: [Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)), const SizedBox(width: 8), const Icon(Icons.keyboard_arrow_down, size: 14)]));
  }

  Widget _buildTopPerformanceGrid(bool isDesktop) {
    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildGeneralStat('INSTITUTIONAL GPA', '3.84', '+0.12 from last sem', Icons.star_border_rounded)),
          const SizedBox(width: 12),
          Expanded(flex: 4, child: _buildTopDeptHero()),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: _buildAttendanceTrends()),
        ],
      ),
    );
  }

  Widget _buildGeneralStat(String label, String value, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 12, backgroundColor: Colors.blue.withValues(alpha: 0.1), child: Icon(icon, size: 14, color: Colors.blue)),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Row(children: [Icon(Icons.trending_up, size: 10, color: Colors.green), SizedBox(width: 4), Text('+0.12 from last sem', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _buildTopDeptHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Stack(
        children: [
          Positioned(right: -10, bottom: -10, child: Icon(Icons.school, size: 100, color: Colors.white.withValues(alpha: 0.1))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('TOP PERFORMING DEPT', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('Computer Science & AI', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _avatarStack(),
                  const SizedBox(width: 12),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: const Text('88% Distinction Rate', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarStack() {
    List<Widget> avatars = [0, 1, 2].map((i) => Align(
      widthFactor: 0.6,
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.white,
        child: CircleAvatar(radius: 10, backgroundColor: Colors.blue.shade200),
      ),
    )).toList();

    return Row(
      children: [
        ...avatars,
        const SizedBox(width: 12),
        const Text('+120', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAttendanceTrends() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('ATTENDANCE TRENDS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [20, 40, 60, 30, 80, 50, 40].map((h) => Container(width: 8, height: h.toDouble(), decoration: BoxDecoration(color: h == 80 ? Colors.blue : Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)))).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('92.4%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: const Text('Stable', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Performance Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 14), label: const Text('Export PDF', style: TextStyle(fontSize: 11))),
            ],
          ),
          const SizedBox(height: 16),
          _breakdownEntry('Computer Science', '42.5 / 50', '84.2 / 100', 'High', Colors.green),
          _breakdownEntry('Mechanical Eng.', '38.1 / 50', '76.5 / 100', 'On Track', Colors.blue),
          _breakdownEntry('Electrical Eng.', '39.8 / 50', '79.1 / 100', 'On Track', Colors.blue),
          _breakdownEntry('Biotechnology', '34.2 / 50', '68.4 / 100', 'Critical', Colors.red),
        ],
      ),
    );
  }

  Widget _breakdownEntry(String name, String internal, String external, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(internal, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey))),
          Expanded(flex: 2, child: Text(external, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey))),
          Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [CircleAvatar(radius: 3, backgroundColor: color), const SizedBox(width: 8), Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color))])),
        ],
      ),
    );
  }

  Widget _buildSemesterTrends() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Semester Trends', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Pass Percentage', style: TextStyle(fontSize: 10, color: Colors.grey)),
          const Text('96.8%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(height: 100, width: double.infinity, child: CustomPaint(painter: AreaChartPainter())),
          const SizedBox(height: 12),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('SEM 1', style: TextStyle(fontSize: 8, color: Colors.grey)), Text('SEM 4', style: TextStyle(fontSize: 8, color: Colors.grey))]),
        ],
      ),
    );
  }

  Widget _buildAnalysisSummaries(bool isDesktop) {
    return Row(
      children: [
        Expanded(child: _summaryBox('Strength Highlights', 'Subjects with > 90% Avg Internal Marks', Colors.green, _strengthItems)),
        const SizedBox(width: 24),
        Expanded(child: _summaryBox('Intervention Required', 'Subjects with < 65% Avg Internal Marks', Colors.red, _interventionItems)),
      ],
    );
  }

  static const List<Map<String, String>> _strengthItems = [
    {'dept': 'COMPUTER SCIENCE', 'subject': 'Data Structures & Algorithms', 'score': '48.2'},
    {'dept': 'ELECTRICAL ENG.', 'subject': 'Microprocessor Theory', 'score': '46.5'},
  ];

  static const List<Map<String, String>> _interventionItems = [
    {'dept': 'MECHANICAL ENG.', 'subject': 'Thermodynamics II', 'score': '28.4'},
    {'dept': 'BIOTECHNOLOGY', 'subject': 'Organic Chemistry', 'score': '31.2'},
  ];

  Widget _summaryBox(String title, String subtitle, Color color, List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(24), border: Border.all(color: color.withValues(alpha: 0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: color, child: const Icon(Icons.star_border, size: 14, color: Colors.white)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['dept']!, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)), Text(item['subject']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis))]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(item['score']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const Text('AVG MARK', style: TextStyle(fontSize: 7, color: Colors.grey, fontWeight: FontWeight.bold))]),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class AreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = Colors.blue..strokeWidth = 3..style = PaintingStyle.stroke;
    final paintArea = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue.withValues(alpha: 0.2), Colors.transparent]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.8);
    path.lineTo(size.width, size.height * 0.4);

    canvas.drawPath(path, paintLine);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paintArea);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
