import 'package:flutter/material.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

import 'package:intl/intl.dart';

class FeeItem {
  final String category;
  final String description;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isDiscount;

  FeeItem({
    required this.category,
    required this.description,
    required this.amount,
    required this.icon,
    required this.color,
    this.isDiscount = false,
  });
}

class FeeTransaction {
  final String txnId;
  final String title;
  final double amount;
  final String date;
  final String paymentMode;
  final String status;

  FeeTransaction({
    required this.txnId,
    required this.title,
    required this.amount,
    required this.date,
    required this.paymentMode,
    required this.status,
  });
}

class FeesScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const FeesScreen({
    super.key,
    this.onBack,
  });

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  // Fee state
  final double _totalAnnualFee = 125000;
  final double _scholarshipDiscount = 15000;
  double _paidAmount = 85000;

  double get _netAnnualFee => _totalAnnualFee - _scholarshipDiscount;
  double get _pendingBalance => (_netAnnualFee - _paidAmount).clamp(0, double.infinity);

  late List<FeeItem> _feeBreakdown;
  late List<FeeTransaction> _transactions;

  @override
  void initState() {
    super.initState();
    _feeBreakdown = [
      FeeItem(
        category: 'Tuition Fee',
        description: 'Core academic lectures, faculty guidance & continuous evaluation',
        amount: 65000,
        icon: Icons.school_rounded,
        color: const Color(0xFF2563EB),
      ),
      FeeItem(
        category: 'Development & Campus Infra',
        description: 'Smart classrooms, high-speed Wi-Fi, campus amenities & security',
        amount: 15000,
        icon: Icons.business_rounded,
        color: const Color(0xFF0284C7),
      ),
      FeeItem(
        category: 'Special Lab & Cloud Computing',
        description: 'Advanced AI/ML Lab, AWS/GCP cloud credits & hardware kits',
        amount: 12000,
        icon: Icons.memory_rounded,
        color: const Color(0xFF7C3AED),
      ),
      FeeItem(
        category: 'Examination & Controller Fee',
        description: 'Mid-term and end-sem exam valuation, hall tickets & grade sheets',
        amount: 8000,
        icon: Icons.assignment_turned_in_rounded,
        color: const Color(0xFF059669),
      ),
      FeeItem(
        category: 'Library & Digital IEEE Resources',
        description: 'Access to physical library, IEEE Xplore digital journals & e-books',
        amount: 5000,
        icon: Icons.local_library_rounded,
        color: const Color(0xFFD97706),
      ),
      FeeItem(
        category: 'Sports & Campus Life Activity',
        description: 'Sports complex access, annual tech fest & student club activities',
        amount: 5000,
        icon: Icons.sports_basketball_rounded,
        color: const Color(0xFFEA580C),
      ),
      FeeItem(
        category: 'Merit Scholarship Concession',
        description: 'Institutional Merit Scholarship (CGPA >= 8.50 Reward Discount)',
        amount: 15000,
        icon: Icons.card_giftcard_rounded,
        color: const Color(0xFF10B981),
        isDiscount: true,
      ),
    ];

    _transactions = [
      FeeTransaction(
        txnId: 'TXN-88492019',
        title: 'Semester 5 Initial Tuition Installment',
        amount: 62500,
        date: '15 Jun 2025',
        paymentMode: 'Google Pay (UPI)',
        status: 'SUCCESS',
      ),
      FeeTransaction(
        txnId: 'TXN-77382104',
        title: 'Semester 6 Partial Fee Payment',
        amount: 22500,
        date: '10 Jan 2026',
        paymentMode: 'HDFC Net Banking',
        status: 'SUCCESS',
      ),
    ];
  }

  void _showPaymentModal() {
    if (_pendingBalance <= 0) {
      return;
    }

    String selectedPaymentMode = 'UPI / Google Pay';
    final payAmountCtrl = TextEditingController(text: _pendingBalance.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentPayAmount = double.tryParse(payAmountCtrl.text) ?? _pendingBalance;

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pay Due Balance',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Instant digital receipt generation',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount Input
                  TextField(
                    controller: payAmountCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setModalState(() {}),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    decoration: InputDecoration(
                      labelText: 'Payment Amount (₹)',
                      prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFF2563EB)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      helperText: 'Pending Balance: ${currencyFormat.format(_pendingBalance)}',
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Select Payment Gateway Mode',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 10),

                  ...['UPI / Google Pay / PhonePe', 'HDFC / SBI NetBanking', 'Credit / Debit Card'].map((mode) {
                    final isSelected = selectedPaymentMode == mode;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedPaymentMode = mode),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              mode,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (currentPayAmount <= 0) return;
                        final nowStr = DateFormat('dd MMM yyyy').format(DateTime.now());
                        final newTxnId = 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

                        setState(() {
                          _paidAmount += currentPayAmount;
                          _transactions.insert(
                            0,
                            FeeTransaction(
                              txnId: newTxnId,
                              title: 'Online Fee Payment',
                              amount: currentPayAmount,
                              date: nowStr,
                              paymentMode: selectedPaymentMode,
                              status: 'SUCCESS',
                            ),
                          );
                        });

                        Navigator.pop(context);
                        _showPaymentSuccessDialog(newTxnId, currentPayAmount);
                      },
                      icon: const Icon(Icons.lock_rounded, size: 18),
                      label: Text(
                        'Proceed & Pay ${currencyFormat.format(currentPayAmount)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentSuccessDialog(String txnId, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 48),
            ),
            const SizedBox(height: 12),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Successfully received ${currencyFormat.format(amount)}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Text('Transaction ID: $txnId', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  const Text('Official e-Receipt generated & attached.', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download Receipt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            UnisphereHeaderCard(
              title: 'Fee Structure & Payments',
              subtitle: 'Academic Year 2025 – 2026',
              onBack: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TOP SUMMARY CARD
                    _buildTopSummaryCard(),
                    const SizedBox(height: 24),

                    // 2. ITEMIZED FEE STRUCTURE BREAKDOWN
                    const Text(
                      'Itemized Fee Component Breakdown',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Detailed breakdown of all tuition, lab, exam, and infrastructure charges.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    _buildItemizedFeeBreakdownCard(),
                    const SizedBox(height: 24),

                    // 3. SEMESTER INSTALLMENT SCHEDULE
                    const Text(
                      'Semester Installment Schedule',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),
                    _buildSemesterInstallmentsCard(),
                    const SizedBox(height: 24),

                    // 4. PAYMENT HISTORY & RECEIPTS LOG
                    const Text(
                      'Payment History & Official Receipts',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentHistoryCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. TOP SUMMARY CARD ───────────────────────────────────────────────────

  Widget _buildTopSummaryCard() {
    final isFullyPaid = _pendingBalance <= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFullyPaid
              ? [const Color(0xFF047857), const Color(0xFF10B981)]
              : [const Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isFullyPaid ? const Color(0xFF10B981) : const Color(0xFF2563EB)).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NET ANNUAL DEGREE FEE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBFDBFE), letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isFullyPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isFullyPaid ? 'FULLY PAID' : 'PARTIALLY PAID',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isFullyPaid ? const Color(0xFF047857) : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            currencyFormat.format(_netAnnualFee),
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Paid Amount', style: TextStyle(fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Text(currencyFormat.format(_paidAmount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF60A5FA))),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: Colors.white24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pending Due', style: TextStyle(fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Text(
                      currencyFormat.format(_pendingBalance),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _pendingBalance > 0 ? const Color(0xFFFCA5A5) : const Color(0xFF6EE7B7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _showPaymentModal,
              icon: Icon(isFullyPaid ? Icons.check_circle_rounded : Icons.payment_rounded, size: 18),
              label: Text(
                isFullyPaid ? 'View Payment Receipts' : 'Pay Due Balance (${currencyFormat.format(_pendingBalance)})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFullyPaid ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                foregroundColor: isFullyPaid ? Colors.white : const Color(0xFF1E3A8A),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. ITEMIZED FEE COMPONENT BREAKDOWN ───────────────────────────────────

  Widget _buildItemizedFeeBreakdownCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _feeBreakdown.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final item = _feeBreakdown[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                              ),
                              if (item.isDiscount) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('REWARD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.isDiscount ? "- " : ""}${currencyFormat.format(item.amount)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: item.isDiscount ? const Color(0xFF059669) : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'NET TOTAL ANNUAL FEE',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
                Text(
                  currencyFormat.format(_netAnnualFee),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. SEMESTER INSTALLMENT SCHEDULE ──────────────────────────────────────

  Widget _buildSemesterInstallmentsCard() {
    final installments = [
      {
        'sem': 'Semester 5 Fee Installment',
        'due': 'Paid on 15 Jun 2025',
        'amount': 62500.0,
        'status': 'PAID',
        'color': const Color(0xFF059669),
      },
      {
        'sem': 'Semester 6 Fee Installment',
        'due': 'Due by 25 Aug 2026',
        'amount': 62500.0,
        'status': _pendingBalance <= 0 ? 'PAID' : 'PARTIAL DUE',
        'color': _pendingBalance <= 0 ? const Color(0xFF059669) : const Color(0xFFD97706),
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: installments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = installments[index];
        final color = (item['color'] as Color?) ?? const Color(0xFF2563EB);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.date_range_rounded, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['sem'] as String,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['due'] as String,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(item['amount']),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['status'] as String,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── 4. PAYMENT HISTORY & RECEIPTS LOG ─────────────────────────────────────

  Widget _buildPaymentHistoryCard() {
    if (_transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No payment transaction logs found.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final txn = _transactions[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          txn.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${txn.date} • via ${txn.paymentMode}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(txn.amount),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${txn.txnId}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 14, color: Color(0xFF2563EB)),
                    label: const Text(
                      'Download e-Receipt',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
