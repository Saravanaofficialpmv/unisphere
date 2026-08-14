import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/student_profile_model.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/firebase_firestore_service.dart';

class StudentProfileEditRequestModal extends ConsumerStatefulWidget {
  const StudentProfileEditRequestModal({super.key});

  @override
  ConsumerState<StudentProfileEditRequestModal> createState() =>
      _StudentProfileEditRequestModalState();
}

class _StudentProfileEditRequestModalState
    extends ConsumerState<StudentProfileEditRequestModal> {
  String _selectedCategory = 'Personal Details';
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  final List<EditRequestItem> _requestItems = [];

  final List<String> _categories = [
    'Personal Details',
    'Contact Information',
    'Permanent Address',
    'Parent & Guardian Details',
    'Previous Education',
    'Living & Accommodation',
    'Day Scholar Transport',
    'Documents',
  ];

  void _addItem(String label, String fieldName, String currentValue, String requestedValue) {
    if (requestedValue.trim().isEmpty) return;
    setState(() {
      _requestItems.add(EditRequestItem(
        category: _selectedCategory,
        fieldName: fieldName,
        label: label,
        currentValue: currentValue,
        requestedValue: requestedValue,
      ));
    });
  }

  void _showAddItemDialog() {
    final labelCtrl = TextEditingController();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Request Change for $_selectedCategory', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: InputDecoration(
                labelText: 'Field Name (Label)',
                hintText: 'e.g. Primary Mobile Number, DOB, Living Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: currentCtrl,
              decoration: InputDecoration(
                labelText: 'Current Value (Read-Only)',
                hintText: 'Existing value on record',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newCtrl,
              decoration: InputDecoration(
                labelText: 'Requested New Value',
                hintText: 'Enter proposed new value',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final label = labelCtrl.text.trim();
              final field = label.toLowerCase().replaceAll(' ', '_');
              final currentVal = currentCtrl.text.trim();
              final newVal = newCtrl.text.trim();

              if (label.isNotEmpty && newVal.isNotEmpty) {
                _addItem(label, field, currentVal, newVal);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Field Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEditRequest() async {
    if (_requestItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one requested field change.')),
      );
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for the edit request.')),
      );
      return;
    }

    final user = ref.read(currentUserProvider).value ?? ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    final meta = user.metadata ?? {};
    final request = ProfileEditRequest(
      requestId: 'req_${DateTime.now().millisecondsSinceEpoch}',
      studentUid: user.uid,
      studentName: user.name,
      registerNumber: meta['registerNumber']?.toString() ?? '922523243100',
      department: meta['department']?.toString() ?? 'Computer Science',
      batch: meta['batch']?.toString() ?? '2023 - 2027',
      academicYear: meta['year']?.toString() ?? '3rd Year',
      section: meta['section']?.toString() ?? 'CS-A',
      reason: _reasonController.text.trim(),
      items: _requestItems,
      createdAt: DateTime.now().toIso8601String(),
    );

    await ref.read(firebaseFirestoreServiceProvider).createProfileEditRequest(request.toMap());

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile edit request submitted to your Class Advisor for verification.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.90),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 24),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Request Profile Edit',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_rounded, color: Color(0xFF2563EB), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Submitted profile fields are locked. Requested changes will be automatically routed to your assigned Class Advisor for field-level approval.',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF1E40AF), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  const Text('Select Field Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Requested Field Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ElevatedButton.icon(
                        onPressed: _showAddItemDialog,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('+ Add Change', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_requestItems.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        'No field changes added yet. Click "+ Add Change" above.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                      ),
                    )
                  else
                    ..._requestItems.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text('Current: ${item.currentValue.isNotEmpty ? item.currentValue : "None"}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    Text('Requested: ${item.requestedValue}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                onPressed: () => setState(() => _requestItems.remove(item)),
                              ),
                            ],
                          ),
                        )),

                  const SizedBox(height: 16),
                  const Text('Reason for Request *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Explain why you are requesting these profile field modifications...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submit Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEditRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SUBMIT EDIT REQUEST TO ADVISOR ➔', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
