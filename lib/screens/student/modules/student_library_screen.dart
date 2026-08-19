import 'package:flutter/material.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';


class StudentLibraryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const StudentLibraryScreen({
    super.key,
    this.onBack,
  });

  @override
  State<StudentLibraryScreen> createState() => _StudentLibraryScreenState();
}

class _StudentLibraryScreenState extends State<StudentLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _borrowedBooks = [
    {
      'id': 'bk_1',
      'title': 'Computer Networks: A Systems Approach',
      'author': 'Larry L. Peterson, Bruce S. Davie',
      'accessionNo': 'LIB-CS-88902',
      'issueDate': '25 Jul 2026',
      'dueDate': '15 Aug 2026',
      'daysLeft': 6,
      'isOverdue': false,
      'renewedCount': 0,
      'color': const Color(0xFF2563EB),
    },
    {
      'id': 'bk_2',
      'title': 'Database System Concepts (7th Ed.)',
      'author': 'Abraham Silberschatz, Henry F. Korth',
      'accessionNo': 'LIB-CS-77419',
      'issueDate': '20 Jul 2026',
      'dueDate': '10 Aug 2026',
      'daysLeft': 1,
      'isOverdue': false,
      'renewedCount': 1,
      'color': const Color(0xFFD97706),
    },
    {
      'id': 'bk_3',
      'title': 'Artificial Intelligence: A Modern Approach',
      'author': 'Stuart Russell, Peter Norvig',
      'accessionNo': 'LIB-CS-99104',
      'issueDate': '01 Aug 2026',
      'dueDate': '22 Aug 2026',
      'daysLeft': 13,
      'isOverdue': false,
      'renewedCount': 0,
      'color': const Color(0xFF059669),
    },
  ];

  final List<Map<String, dynamic>> _catalogBooks = [
    {
      'title': 'Operating System Concepts',
      'author': 'Silberschatz, Galvin, Gagne',
      'available': true,
      'copies': '12 available',
    },
    {
      'title': 'Introduction to Algorithms (CLRS)',
      'author': 'Thomas H. Cormen',
      'available': true,
      'copies': '8 available',
    },
    {
      'title': 'Clean Code: Handbook of Agile Craftsmanship',
      'author': 'Robert C. Martin',
      'available': false,
      'copies': 'Issued (Due 18 Aug)',
    },
  ];

  void _renewBook(Map<String, dynamic> book) {
    setState(() {
      book['renewedCount'] = (book['renewedCount'] as int) + 1;
      book['dueDate'] = '30 Aug 2026';
      book['daysLeft'] = 21;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (!mounted) return;
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.onBack == null && (ModalRoute.of(context)?.canPop ?? false),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;
        if (widget.onBack != null) {
          widget.onBack!();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
        child: Column(
          children: [
            UnisphereHeaderCard(
              title: 'Library Portal & Digital Resources',
              subtitle: 'Borrowed Books, Dues & E-Journals',
              onBack: () => _handleBack(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Overview Row
                    Row(
                      children: [
                        _buildStatCard('Active Loans', '${_borrowedBooks.length}', Icons.menu_book_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                        const SizedBox(width: 12),
                        _buildStatCard('Due Soon', '1', Icons.alarm_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
                        const SizedBox(width: 12),
                        _buildStatCard('Overdue Fine', '₹0', Icons.payments_rounded, const Color(0xFF059669), const Color(0xFFECFDF5)),
                      ],
                    ),
                    const SizedBox(height: 20),

            // Currently Borrowed Books Section
            const Text(
              'Currently Borrowed Books',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            ..._borrowedBooks.map((book) {
              final Color color = book['color'];
              final int daysLeft = book['daysLeft'];
              final bool isUrgent = daysLeft <= 2;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isUrgent ? const Color(0xFFFCD34D) : const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 56,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withValues(alpha: 0.2)),
                          ),
                          child: Icon(Icons.book_rounded, color: color, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                book['author'],
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Accession: ${book['accessionNo']}',
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Due Date: ${book['dueDate']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isUrgent ? const Color(0xFFD97706) : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Issued: ${book['issueDate']} (${book['renewedCount']} renewals)',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _renewBook(book),
                          icon: const Icon(Icons.autorenew_rounded, size: 14),
                          label: const Text('Renew Book'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUrgent ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Search Catalog Section
            const Text(
              'Digital Catalog Search',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search textbooks, e-journals, research papers...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            ..._catalogBooks.map((cBook) {
              final bool avail = cBook['available'];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(
                      avail ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                      color: avail ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cBook['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            '${cBook['author']} • ${cBook['copies']}',
                            style: TextStyle(fontSize: 11, color: avail ? const Color(0xFF64748B) : const Color(0xFFDC2626)),
                          ),
                        ],
                      ),
                    ),
                    if (avail)
                      TextButton(
                        onPressed: () {},
                        child: const Text('Reserve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ),
  ],
),
),
),
);
}

  Widget _buildStatCard(String label, String value, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ],
        ),
      ),
    );
  }
}
