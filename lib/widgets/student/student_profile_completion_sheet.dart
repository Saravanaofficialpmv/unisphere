import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/student_profile_model.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/firebase_firestore_service.dart';

class StudentProfileCompletionSheet extends ConsumerStatefulWidget {
  const StudentProfileCompletionSheet({super.key});

  @override
  ConsumerState<StudentProfileCompletionSheet> createState() =>
      _StudentProfileCompletionSheetState();
}

class _StudentProfileCompletionSheetState
    extends ConsumerState<StudentProfileCompletionSheet> {
  int _currentStep = 1;
  bool _isSavingDraft = false;
  bool _isSubmitting = false;

  // Validation Error State Flags
  bool _dobError = false;
  bool _genderError = false;
  bool _bloodGroupError = false;
  bool _religionError = false;
  bool _communityError = false;
  bool _primaryMobileError = false;
  bool _fatherNameError = false;
  bool _motherNameError = false;

  // ── Step 1: Personal ──
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _deptController = TextEditingController();
  final _emailController = TextEditingController();
  String? _dob;
  String? _gender;
  String? _bloodGroup;
  final String _nationality = 'Indian';
  String? _religion;
  String? _community;
  final _casteController = TextEditingController();
  String? _motherTongue;
  bool _isFirstGraduate = false;
  bool _isDifferentlyAbled = false;
  final _disabilityController = TextEditingController();
  String? _studentPhotoUrl;

  // ── Step 2: Contact & Address ──
  final _primaryMobileController = TextEditingController();
  final _alternateMobileController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  String? _emergencyRelation;
  final _emergencyPhoneController = TextEditingController();

  // Permanent Address
  final _permLine1Controller = TextEditingController();
  final _permLine2Controller = TextEditingController();
  final _permAreaController = TextEditingController();
  final _permCityController = TextEditingController();
  final _permDistrictController = TextEditingController();
  final _permStateController = TextEditingController(text: 'Tamil Nadu');
  final _permPincodeController = TextEditingController();

  // Current Address
  bool _sameAsPermanent = true;
  final _currLine1Controller = TextEditingController();
  final _currLine2Controller = TextEditingController();
  final _currAreaController = TextEditingController();
  final _currCityController = TextEditingController();
  final _currDistrictController = TextEditingController();
  final _currStateController = TextEditingController(text: 'Tamil Nadu');
  final _currPincodeController = TextEditingController();

  // ── Step 3: Parents & Guardian ──
  // Father
  String? _fatherPhotoUrl;
  final _fatherNameController = TextEditingController();
  final _fatherPhoneController = TextEditingController();
  final _fatherEmailController = TextEditingController(); // OPTIONAL
  String? _fatherQual;
  final _fatherOccupationController = TextEditingController();
  String? _fatherIncome;

  // Mother
  String? _motherPhotoUrl;
  final _motherNameController = TextEditingController();
  final _motherPhoneController = TextEditingController();
  final _motherEmailController = TextEditingController(); // OPTIONAL
  String? _motherQual;
  final _motherOccupationController = TextEditingController();
  String? _motherIncome;

  // Guardian (Optional)
  bool _hasGuardian = false;
  String? _guardianPhotoUrl;
  final _guardianNameController = TextEditingController();
  String? _guardianRelation;
  final _guardianPhoneController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _guardianQualController = TextEditingController();
  final _guardianOccupationController = TextEditingController();
  final _guardianAddressController = TextEditingController();

  // ── Step 4: Previous Education ──
  // 10th
  final _tenthSchoolController = TextEditingController();
  String? _tenthBoard;
  String? _tenthMedium;
  final _tenthRegNoController = TextEditingController();
  final _tenthYearController = TextEditingController();
  final _tenthTotalController = TextEditingController(text: '500');
  final _tenthObtainedController = TextEditingController();
  double _tenthPercentage = 0.0;

  // 12th / Diploma
  final _twelfthSchoolController = TextEditingController();
  String? _twelfthBoard;
  String? _twelfthMedium;
  final _twelfthRegNoController = TextEditingController();
  final _twelfthYearController = TextEditingController();
  final _twelfthTotalController = TextEditingController(text: '600');
  final _twelfthObtainedController = TextEditingController();
  double _twelfthPercentage = 0.0;

  // ── Step 5: Living & Accommodation ──
  LivingType? _selectedLivingType;
  final _hostelNameController = TextEditingController();
  final _hostelBlockController = TextEditingController();
  final _hostelRoomController = TextEditingController();
  final _hostelBedController = TextEditingController();
  final _hostelAdmissionController = TextEditingController();
  final _accOwnerNameController = TextEditingController();
  final _accOwnerPhoneController = TextEditingController();
  final _accAddressController = TextEditingController();
  final _accRentController = TextEditingController();

  bool get _isDayScholar => _selectedLivingType != LivingType.collegeHostel;

  // ── Step 6: Day Scholar Transport (STRICTLY ONLY: BUS, BIKE, WALK) ──
  PrimaryTransportMode? _transportMode;
  String? _busType;
  final _boardingPointController = TextEditingController();
  final _busStopController = TextEditingController();
  final _pickupTimeController = TextEditingController();
  String? _vehicleType;
  final _vehicleRegNoController = TextEditingController();
  final String _driverType = 'Student';
  bool _parkingPermission = true;
  final bool _licenceAvailable = true;
  final _distanceController = TextEditingController(text: '12 km');
  final _travelTimeController = TextEditingController(text: '30 mins');
  final _arrivalTimeController = TextEditingController(text: '08:25 AM');
  final _departureTimeController = TextEditingController(text: '05:00 PM');

  // ── Step 7: Documents ──
  final List<StudentDocument> _uploadedDocuments = [
    StudentDocument(id: 'doc_photo', name: 'Student Passport Photo', isRequired: true, fileUrl: '', fileName: ''),
    StudentDocument(id: 'doc_10th', name: '10th Standard Marksheet', isRequired: true, fileUrl: '', fileName: ''),
    StudentDocument(id: 'doc_12th', name: '12th / Diploma Marksheet', isRequired: true, fileUrl: '', fileName: ''),
    StudentDocument(id: 'doc_tc', name: 'Transfer Certificate (TC)', isRequired: true, fileUrl: '', fileName: ''),
    StudentDocument(id: 'doc_community', name: 'Community Certificate', isRequired: false, fileUrl: '', fileName: ''),
  ];

  // ── Step 8: Confirmation ──
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _loadInitialUserData();
  }

  void _loadInitialUserData() async {
    final user = ref.read(currentUserProvider).value ?? ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final meta = user.metadata ?? {};
    _nameController.text = meta['fullName'] ?? user.name;
    _regNoController.text = meta['registerNumber'] ?? '';
    _deptController.text = meta['department'] ?? 'Computer Science';
    _emailController.text = user.email;
    _studentPhotoUrl = user.profileImageUrl ?? meta['photoUrl'];

    // Load draft if available
    final draft = await ref.read(firebaseFirestoreServiceProvider).getStudentProfileDraft(user.uid);
    if (draft != null && mounted) {
      setState(() {
        if (draft['dob'] != null) _dob = draft['dob'];
        if (draft['primaryMobile'] != null) _primaryMobileController.text = draft['primaryMobile'];
        if (draft['permLine1'] != null) _permLine1Controller.text = draft['permLine1'];
        if (draft['permCity'] != null) _permCityController.text = draft['permCity'];
        if (draft['permState'] != null) _permStateController.text = draft['permState'];
        if (draft['permPincode'] != null) _permPincodeController.text = draft['permPincode'];
        if (draft['currLine1'] != null) _currLine1Controller.text = draft['currLine1'];
        if (draft['currCity'] != null) _currCityController.text = draft['currCity'];
        if (draft['currState'] != null) _currStateController.text = draft['currState'];
        if (draft['currPincode'] != null) _currPincodeController.text = draft['currPincode'];
        if (draft['fatherName'] != null) _fatherNameController.text = draft['fatherName'];
        if (draft['fatherPhone'] != null) _fatherPhoneController.text = draft['fatherPhone'];
        if (draft['motherName'] != null) _motherNameController.text = draft['motherName'];
        if (draft['motherPhone'] != null) _motherPhoneController.text = draft['motherPhone'];
        if (draft['tenthObtained'] != null) _tenthObtainedController.text = draft['tenthObtained'];
        if (draft['twelfthObtained'] != null) _twelfthObtainedController.text = draft['twelfthObtained'];
        _calculateEducationPercentages();
      });
    }
  }

  void _calculateEducationPercentages() {
    final tTotal = double.tryParse(_tenthTotalController.text) ?? 500;
    final tObtained = double.tryParse(_tenthObtainedController.text) ?? 0;
    if (tTotal > 0) _tenthPercentage = (tObtained / tTotal) * 100;

    final twTotal = double.tryParse(_twelfthTotalController.text) ?? 600;
    final twObtained = double.tryParse(_twelfthObtainedController.text) ?? 0;
    if (twTotal > 0) _twelfthPercentage = (twObtained / twTotal) * 100;
  }

  Future<void> _saveDraft() async {
    final user = ref.read(currentUserProvider).value ?? ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isSavingDraft = true);
    await ref.read(firebaseFirestoreServiceProvider).saveStudentProfileDraft(user.uid, {
      'dob': _dob,
      'primaryMobile': _primaryMobileController.text,
      'permLine1': _permLine1Controller.text,
      'permCity': _permCityController.text,
      'permState': _permStateController.text,
      'permPincode': _permPincodeController.text,
      'currLine1': _currLine1Controller.text,
      'currCity': _currCityController.text,
      'currState': _currStateController.text,
      'currPincode': _currPincodeController.text,
      'fatherName': _fatherNameController.text,
      'fatherPhone': _fatherPhoneController.text,
      'motherName': _motherNameController.text,
      'motherPhone': _motherPhoneController.text,
      'tenthObtained': _tenthObtainedController.text,
      'twelfthObtained': _twelfthObtainedController.text,
      'livingType': _selectedLivingType?.name ?? '',
      'transportMode': _transportMode?.name ?? '',
    });
    if (mounted) {
      setState(() => _isSavingDraft = false);
    }
  }

  int get _totalSteps => _isDayScholar ? 8 : 7;
  int get _displayStepNumber => (_currentStep == 6 && !_isDayScholar) ? 6 : _currentStep;

  void _fillMockData() {
    setState(() {
      // Step 1: Personal
      _dob = '15/05/2005';
      _gender = 'Male';
      _bloodGroup = 'O+';
      _religion = 'Hindu';
      _community = 'BC';
      _casteController.text = 'Kongu Vellalar';
      _motherTongue = 'Tamil';
      _isFirstGraduate = true;
      _isDifferentlyAbled = false;
      _dobError = false;
      _genderError = false;
      _bloodGroupError = false;
      _religionError = false;
      _communityError = false;

      // Step 2: Contact & Address
      _primaryMobileController.text = '+91 98765 43210';
      _alternateMobileController.text = '+91 98765 00000';
      _personalEmailController.text = 'student.test@gmail.com';
      _emergencyNameController.text = 'Senthil Kumar M';
      _emergencyRelation = 'Father';
      _emergencyPhoneController.text = '+91 99944 12345';
      _permLine1Controller.text = '123, Anna Nagar 2nd Street';
      _permCityController.text = 'Karur';
      _permPincodeController.text = '639002';
      _primaryMobileError = false;

      // Step 3: Parents & Guardian
      _fatherNameController.text = 'Senthil Kumar M';
      _fatherPhoneController.text = '+91 98765 11111';
      _fatherEmailController.text = 'senthilkumar@gmail.com';
      _fatherQual = 'Bachelor Degree';
      _fatherOccupationController.text = 'Business';
      _fatherIncome = '₹3,00,000 - ₹5,00,000';
      _motherNameController.text = 'Lakshmi S';
      _motherPhoneController.text = '+91 98765 22222';
      _motherQual = 'School';
      _motherOccupationController.text = 'Homemaker';
      _motherIncome = '₹1,00,000 - ₹3,00,000';
      _fatherNameError = false;
      _motherNameError = false;

      // Step 4: Previous Education
      _tenthSchoolController.text = 'Government Higher Sec School';
      _tenthBoard = 'State Board';
      _tenthMedium = 'English';
      _tenthRegNoController.text = '10TH98765';
      _tenthYearController.text = '2021';
      _tenthTotalController.text = '500';
      _tenthObtainedController.text = '465';
      _twelfthSchoolController.text = 'VSB Higher Sec School';
      _twelfthBoard = 'State Board';
      _twelfthMedium = 'English';
      _twelfthRegNoController.text = '12TH12345';
      _twelfthYearController.text = '2023';
      _twelfthTotalController.text = '600';
      _twelfthObtainedController.text = '552';
      _calculateEducationPercentages();

      // Step 5 & 6: Living & Transport
      _selectedLivingType = LivingType.homeFamily;
      _transportMode = PrimaryTransportMode.BUS;
      _busType = 'College Bus';
      _boardingPointController.text = 'Gandhigramam';
      _busStopController.text = 'College Main Gate';
      _pickupTimeController.text = '07:45 AM';
      _distanceController.text = '14 km';
      _travelTimeController.text = '35 mins';

      // Step 8: Confirmation
      _isConfirmed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ Mock data auto-filled for testing!'),
        backgroundColor: Color(0xFF2563EB),
        duration: Duration(seconds: 1),
      ),
    );
  }

  int get _progressPercentage {
    final stepProgress = (_currentStep / _totalSteps * 100).round();
    return stepProgress.clamp(10, 100);
  }

  void _nextStep() {
    if (_currentStep == 1) {
      final dobErr = _dob == null || _dob!.isEmpty;
      final genderErr = _gender == null;
      final bgErr = _bloodGroup == null;
      final relErr = _religion == null;
      final commErr = _community == null;

      if (dobErr || genderErr || bgErr || relErr || commErr) {
        setState(() {
          _dobError = dobErr;
          _genderError = genderErr;
          _bloodGroupError = bgErr;
          _religionError = relErr;
          _communityError = commErr;
        });
        return;
      }
    }
    if (_currentStep == 2 && _primaryMobileController.text.trim().isEmpty) {
      setState(() => _primaryMobileError = true);
      return;
    }
    if (_currentStep == 3) {
      final fEmpty = _fatherNameController.text.trim().isEmpty;
      final mEmpty = _motherNameController.text.trim().isEmpty;
      if (fEmpty || mEmpty) {
        setState(() {
          _fatherNameError = fEmpty;
          _motherNameError = mEmpty;
        });
        return;
      }
    }

    _saveDraft();

    setState(() {
      if (_currentStep == 5 && !_isDayScholar) {
        _currentStep = 7; // Skip Step 6 Day Scholar Transport for College Hostel students!
      } else if (_currentStep < 8) {
        _currentStep++;
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep == 7 && !_isDayScholar) {
        _currentStep = 5; // Return back to Step 5 for Hostel students
      } else if (_currentStep > 1) {
        _currentStep--;
      }
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _submitFinalProfile() async {
    if (!_isConfirmed) {
      _showError('Please confirm that the information provided is accurate.');
      return;
    }

    final user = ref.read(currentUserProvider).value ?? ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    _calculateEducationPercentages();

    final profile = FullStudentProfileModel(
      studentUid: user.uid,
      completionStatus: 'submitted',
      completionPercentage: 100,
      personal: StudentPersonalDetails(
        fullName: _nameController.text.trim(),
        registerNumber: _regNoController.text.trim(),
        department: _deptController.text.trim(),
        collegeEmail: _emailController.text.trim(),
        profilePhotoUrl: _studentPhotoUrl,
        dateOfBirth: _dob,
        gender: _gender ?? 'Male',
        bloodGroup: _bloodGroup ?? 'O+',
        nationality: _nationality,
        religion: _religion ?? 'Hindu',
        community: _community ?? 'BC',
        caste: _casteController.text.trim(),
        motherTongue: _motherTongue ?? 'Tamil',
        isFirstGraduate: _isFirstGraduate,
        isDifferentlyAbled: _isDifferentlyAbled,
        disabilityDetails: _disabilityController.text.trim(),
      ),
      contact: StudentContactDetails(
        primaryMobile: _primaryMobileController.text.trim(),
        alternateMobile: _alternateMobileController.text.trim(),
        personalEmail: _personalEmailController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim(),
        emergencyContactRelationship: _emergencyRelation ?? 'Father',
        emergencyContactNumber: _emergencyPhoneController.text.trim(),
        permanentAddress: StudentAddress(
          addressLine1: _permLine1Controller.text.trim(),
          addressLine2: _permLine2Controller.text.trim(),
          area: _permAreaController.text.trim(),
          city: _permCityController.text.trim(),
          district: _permDistrictController.text.trim(),
          state: _permStateController.text.trim(),
          pincode: _permPincodeController.text.trim(),
        ),
        sameAsPermanent: _sameAsPermanent,
        currentAddress: _sameAsPermanent
            ? StudentAddress(
                addressLine1: _permLine1Controller.text.trim(),
                addressLine2: _permLine2Controller.text.trim(),
                area: _permAreaController.text.trim(),
                city: _permCityController.text.trim(),
                district: _permDistrictController.text.trim(),
                state: _permStateController.text.trim(),
                pincode: _permPincodeController.text.trim(),
              )
            : StudentAddress(
                addressLine1: _currLine1Controller.text.trim(),
                addressLine2: _currLine2Controller.text.trim(),
                area: _currAreaController.text.trim(),
                city: _currCityController.text.trim(),
                district: _currDistrictController.text.trim(),
                state: _currStateController.text.trim(),
                pincode: _currPincodeController.text.trim(),
              ),
      ),
      parents: StudentParentDetails(
        father: ParentRecord(
          photoUrl: _fatherPhotoUrl,
          name: _fatherNameController.text.trim(),
          mobileNumber: _fatherPhoneController.text.trim(),
          email: _fatherEmailController.text.trim().isNotEmpty ? _fatherEmailController.text.trim() : null,
          qualification: _fatherQual ?? 'Bachelor Degree',
          occupation: _fatherOccupationController.text.trim(),
          annualIncome: _fatherIncome ?? '₹1,00,000 - ₹3,00,000',
        ),
        mother: ParentRecord(
          photoUrl: _motherPhotoUrl,
          name: _motherNameController.text.trim(),
          mobileNumber: _motherPhoneController.text.trim(),
          email: _motherEmailController.text.trim().isNotEmpty ? _motherEmailController.text.trim() : null,
          qualification: _motherQual ?? 'School',
          occupation: _motherOccupationController.text.trim(),
          annualIncome: _motherIncome ?? '₹1,00,000 - ₹3,00,000',
        ),
        guardian: _hasGuardian
            ? GuardianRecord(
                photoUrl: _guardianPhotoUrl,
                name: _guardianNameController.text.trim(),
                relationship: _guardianRelation ?? 'Guardian',
                mobileNumber: _guardianPhoneController.text.trim(),
                email: _guardianEmailController.text.trim().isNotEmpty ? _guardianEmailController.text.trim() : null,
                qualification: _guardianQualController.text.trim(),
                occupation: _guardianOccupationController.text.trim(),
                address: _guardianAddressController.text.trim(),
              )
            : null,
      ),
      education: StudentPreviousEducation(
        tenth: EducationRecord(
          institutionName: _tenthSchoolController.text.trim(),
          boardOrUniversity: _tenthBoard ?? 'State Board',
          medium: _tenthMedium ?? 'English',
          registerNumber: _tenthRegNoController.text.trim(),
          passingYear: _tenthYearController.text.trim(),
          totalMarks: double.tryParse(_tenthTotalController.text) ?? 500,
          marksObtained: double.tryParse(_tenthObtainedController.text) ?? 0,
          percentage: _tenthPercentage,
        ),
        twelfthOrDiploma: EducationRecord(
          institutionName: _twelfthSchoolController.text.trim(),
          boardOrUniversity: _twelfthBoard ?? 'State Board',
          medium: _twelfthMedium ?? 'English',
          registerNumber: _twelfthRegNoController.text.trim(),
          passingYear: _twelfthYearController.text.trim(),
          totalMarks: double.tryParse(_twelfthTotalController.text) ?? 600,
          marksObtained: double.tryParse(_twelfthObtainedController.text) ?? 0,
          percentage: _twelfthPercentage,
        ),
      ),
      living: StudentLivingDetails(
        livingType: _selectedLivingType ?? LivingType.homeFamily,
        details: _selectedLivingType == LivingType.collegeHostel
            ? {
                'hostelName': _hostelNameController.text.trim(),
                'block': _hostelBlockController.text.trim(),
                'roomNo': _hostelRoomController.text.trim(),
                'bedNo': _hostelBedController.text.trim(),
                'admissionDate': _hostelAdmissionController.text.trim(),
              }
            : {
                'ownerName': _accOwnerNameController.text.trim(),
                'ownerPhone': _accOwnerPhoneController.text.trim(),
                'address': _accAddressController.text.trim(),
                'rent': _accRentController.text.trim(),
              },
      ),
      transport: _isDayScholar
          ? StudentTransportDetails(
              mode: _transportMode ?? PrimaryTransportMode.BUS,
              modeDetails: _transportMode == PrimaryTransportMode.BUS
                  ? {
                      'busType': _busType,
                      'boardingPoint': _boardingPointController.text.trim(),
                      'busStop': _busStopController.text.trim(),
                      'pickupTime': _pickupTimeController.text.trim(),
                    }
                  : _transportMode == PrimaryTransportMode.BIKE
                      ? {
                          'vehicleType': _vehicleType,
                          'vehicleRegNo': _vehicleRegNoController.text.trim(),
                          'driverType': _driverType,
                          'parkingPermission': _parkingPermission,
                          'licenceAvailable': _licenceAvailable,
                        }
                      : {},
              oneWayDistanceKm: _distanceController.text.trim(),
              oneWayTravelTimeMinutes: _travelTimeController.text.trim(),
              usualArrivalTime: _arrivalTimeController.text.trim(),
              usualDepartureTime: _departureTimeController.text.trim(),
            )
          : null,
      documents: _uploadedDocuments,
    );

    final profileMap = profile.toMap();
    profileMap['verificationStatus'] = 'pending_hod';
    profileMap['completionPercentage'] = _progressPercentage;

    await ref.read(firebaseFirestoreServiceProvider).submitFullStudentProfile(profileMap);

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Profile Submitted Successfully!',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your 360° student profile has been submitted. Some information and documents will be verified by your Class Advisor.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Go to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedStepBar() {
    final stepTitles = [
      'Personal Details',
      'Contact Details',
      'Parent Details',
      'Education',
      'Living Details',
      if (_isDayScholar) 'Transport Mode',
      'Documents',
      'Review & Submit',
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stepTitles.length,
        itemBuilder: (context, idx) {
          final stepNum = idx + 1;
          final isCurrent = stepNum == _displayStepNumber;
          final isPassed = stepNum < _displayStepNumber;

          return GestureDetector(
            onTap: () {
              if (isPassed) {
                setState(() => _currentStep = stepNum);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    stepTitles[idx],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                      color: isCurrent
                          ? const Color(0xFF2563EB)
                          : (isPassed ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3.5,
                    width: 75,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF2563EB)
                          : (isPassed ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.94),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Top Header Drag Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: _currentStep > 1 ? _previousStep : () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Complete Student Profile',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: _isSavingDraft ? null : _saveDraft,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.save_as_rounded, size: 16, color: Color(0xFF2563EB)),
                          label: Text(_isSavingDraft ? 'Saving...' : 'Save Draft', style: const TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildSegmentedStepBar(),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Step Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStepBody(),
            ),
          ),

          // Fixed Bottom Control Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      if (_currentStep > 1) {
                        _previousStep();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Back', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _currentStep == 8
                          ? (_isSubmitting ? null : _submitFinalProfile)
                          : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _currentStep == 8 ? 'Submit' : 'Next',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepBody() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Personal();
      case 2:
        return _buildStep2ContactAddress();
      case 3:
        return _buildStep3ParentsGuardian();
      case 4:
        return _buildStep4Education();
      case 5:
        return _buildStep5Living();
      case 6:
        return _isDayScholar ? _buildStep6Transport() : _buildStep7Documents();
      case 7:
        return _isDayScholar ? _buildStep7Documents() : _buildStep8Review();
      case 8:
        return _buildStep8Review();
      default:
        return _buildStep1Personal();
    }
  }

  // ── STEP 1: PERSONAL ──
  Widget _buildStep1Personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 1: Personal Details', 'Verified details are locked. Enter your personal credentials.'),
        const SizedBox(height: 16),
        _buildReadOnlyField('Student Name', _nameController.text, Icons.verified_user_rounded),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildReadOnlyField('Register Number', _regNoController.text, Icons.badge_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildReadOnlyField('Department', _deptController.text, Icons.school_rounded)),
          ],
        ),
        const SizedBox(height: 12),
        _buildReadOnlyField('College Email', _emailController.text, Icons.email_rounded),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),

        // Date of Birth DatePicker
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Date of Birth *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
            if (_dobError)
              const Text(
                '⚠️ Required field',
                style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2005, 5, 15),
              firstDate: DateTime(1990),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _dob = DateFormat('dd/MM/yyyy').format(picked);
                _dobError = false;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _dobError ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _dobError ? Colors.red : const Color(0xFFCBD5E1),
                width: _dobError ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dob ?? 'Select Date of Birth',
                  style: TextStyle(
                    color: _dobError
                        ? Colors.red
                        : (_dob == null ? Colors.grey : Colors.black87),
                    fontSize: 14,
                    fontWeight: _dobError ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Icon(
                  Icons.calendar_month_rounded,
                  color: _dobError ? Colors.red : const Color(0xFF2563EB),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_dobError)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 4),
            child: Text(
              'Please select your Date of Birth to proceed',
              style: TextStyle(color: Colors.red, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                'Gender',
                _gender,
                ['Male', 'Female', 'Other'],
                (val) => setState(() {
                  _gender = val;
                  _genderError = false;
                }),
                hasError: _genderError,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                'Blood Group',
                _bloodGroup,
                ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                (val) => setState(() {
                  _bloodGroup = val;
                  _bloodGroupError = false;
                }),
                hasError: _bloodGroupError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                'Religion',
                _religion,
                ['Hindu', 'Christian', 'Muslim', 'Sikh', 'Jain', 'Other'],
                (val) => setState(() {
                  _religion = val;
                  _religionError = false;
                }),
                hasError: _religionError,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                'Community',
                _community,
                ['OC', 'BC', 'MBC', 'SC', 'ST', 'DNC'],
                (val) => setState(() {
                  _community = val;
                  _communityError = false;
                }),
                hasError: _communityError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildTextField(_casteController, 'Caste', 'e.g. Kongu Vellalar'),
        const SizedBox(height: 14),

        SwitchListTile(
          title: const Text('First Graduate in Family?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          value: _isFirstGraduate,
          onChanged: (val) => setState(() => _isFirstGraduate = val),
          activeThumbColor: const Color(0xFF2563EB),
        ),
        SwitchListTile(
          title: const Text('Differently Abled?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          value: _isDifferentlyAbled,
          onChanged: (val) => setState(() => _isDifferentlyAbled = val),
          activeThumbColor: const Color(0xFF2563EB),
        ),
        if (_isDifferentlyAbled)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildTextField(_disabilityController, 'Disability Details', 'Specify disability percentage & type'),
          ),
      ],
    );
  }

  // ── STEP 2: CONTACT & ADDRESS ──
  Widget _buildStep2ContactAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 2: Contact & Address', 'Provide emergency contacts and current living address.'),
        const SizedBox(height: 16),
        _buildTextField(
          _primaryMobileController,
          'Primary Mobile Number *',
          '+91 98765 43210',
          icon: Icons.phone_rounded,
          hasError: _primaryMobileError,
          errorText: 'Please enter Primary Mobile Number',
          onChanged: (val) {
            if (val.trim().isNotEmpty && _primaryMobileError) {
              setState(() => _primaryMobileError = false);
            }
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(_alternateMobileController, 'Alternate Mobile Number (Optional)', '+91 98765 00000'),
        const SizedBox(height: 12),
        _buildTextField(_personalEmailController, 'Personal Email (Optional)', 'student@gmail.com'),
        const SizedBox(height: 16),

        const Text('Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTextField(_emergencyNameController, 'Contact Name', 'Father / Guardian Name')),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                'Relationship',
                _emergencyRelation,
                ['Father', 'Mother', 'Guardian', 'Uncle', 'Aunt', 'Brother', 'Sister', 'Other'],
                (val) => setState(() => _emergencyRelation = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(_emergencyPhoneController, 'Emergency Phone Number', '+91 99944 00000'),
        const SizedBox(height: 20),

        const Text('Permanent Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        _buildTextField(_permLine1Controller, 'Address Line 1', 'Door No, Street Name'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTextField(_permCityController, 'City / Town', 'Karur')),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_permPincodeController, 'Pincode', '639002')),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(_permStateController, 'State', 'Tamil Nadu'),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Current Address Same as Permanent?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Switch(
              value: _sameAsPermanent,
              onChanged: (val) => setState(() => _sameAsPermanent = val),
              activeThumbColor: const Color(0xFF2563EB),
            ),
          ],
        ),
        if (!_sameAsPermanent) ...[
          const SizedBox(height: 8),
          _buildTextField(_currLine1Controller, 'Current Address Line 1', 'Door No, Street Name'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_currCityController, 'City / Town', 'Karur')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_currPincodeController, 'Pincode', '639002')),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(_currStateController, 'State', 'Tamil Nadu'),
        ],
      ],
    );
  }

  // ── STEP 3: PARENTS & GUARDIAN ──
  Widget _buildStep3ParentsGuardian() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 3: Parent & Guardian Details', 'Father & Mother details are required. Parent emails are OPTIONAL.'),
        const SizedBox(height: 16),

        // Father Card
        _buildParentCard(
          title: 'Father Details',
          nameCtrl: _fatherNameController,
          phoneCtrl: _fatherPhoneController,
          emailCtrl: _fatherEmailController,
          occupationCtrl: _fatherOccupationController,
          qualValue: _fatherQual ?? 'Bachelor Degree',
          incomeValue: _fatherIncome ?? '₹1,00,000 - ₹3,00,000',
          nameError: _fatherNameError,
          onNameChanged: (val) {
            if (val.trim().isNotEmpty && _fatherNameError) {
              setState(() => _fatherNameError = false);
            }
          },
          onQualChanged: (v) => setState(() => _fatherQual = v!),
          onIncomeChanged: (v) => setState(() => _fatherIncome = v!),
        ),
        const SizedBox(height: 16),

        // Mother Card
        _buildParentCard(
          title: 'Mother Details',
          nameCtrl: _motherNameController,
          phoneCtrl: _motherPhoneController,
          emailCtrl: _motherEmailController,
          occupationCtrl: _motherOccupationController,
          qualValue: _motherQual ?? 'School',
          incomeValue: _motherIncome ?? '₹1,00,000 - ₹3,00,000',
          nameError: _motherNameError,
          onNameChanged: (val) {
            if (val.trim().isNotEmpty && _motherNameError) {
              setState(() => _motherNameError = false);
            }
          },
          onQualChanged: (v) => setState(() => _motherQual = v!),
          onIncomeChanged: (v) => setState(() => _motherIncome = v!),
        ),
        const SizedBox(height: 16),

        // Guardian Card (Optional)
        SwitchListTile(
          title: const Text('+ Add Guardian Details (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          value: _hasGuardian,
          onChanged: (val) => setState(() => _hasGuardian = val),
          activeThumbColor: const Color(0xFF2563EB),
        ),
        if (_hasGuardian) ...[
          const SizedBox(height: 8),
          _buildTextField(_guardianNameController, 'Guardian Name', 'Name'),
          const SizedBox(height: 8),
          _buildDropdown(
            'Relationship',
            _guardianRelation,
            ['Father', 'Mother', 'Guardian', 'Uncle', 'Aunt', 'Brother', 'Sister', 'Other'],
            (val) => setState(() => _guardianRelation = val),
          ),
          const SizedBox(height: 8),
          _buildTextField(_guardianPhoneController, 'Mobile Number', '+91 98765 00000'),
        ],
      ],
    );
  }

  Widget _buildParentCard({
    required String title,
    required TextEditingController nameCtrl,
    required TextEditingController phoneCtrl,
    required TextEditingController emailCtrl,
    required TextEditingController occupationCtrl,
    required String qualValue,
    required String incomeValue,
    bool nameError = false,
    ValueChanged<String>? onNameChanged,
    required ValueChanged<String?> onQualChanged,
    required ValueChanged<String?> onIncomeChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: nameError ? Colors.red : const Color(0xFFE2E8F0), width: nameError ? 1.5 : 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          _buildTextField(
            nameCtrl,
            'Full Name *',
            'Parent Name',
            hasError: nameError,
            errorText: 'Please enter parent name',
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 8),
          _buildTextField(phoneCtrl, 'Mobile Number *', '+91 98765 43210'),
          const SizedBox(height: 8),
          _buildTextField(emailCtrl, 'Email Address (OPTIONAL)', 'parent@gmail.com'),
          const SizedBox(height: 8),
          _buildTextField(occupationCtrl, 'Occupation', 'Business / Agriculture'),
        ],
      ),
    );
  }

  // ── STEP 4: PREVIOUS EDUCATION ──
  Widget _buildStep4Education() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 4: Previous Education', 'Enter your 10th and 12th/Diploma academic records.'),
        const SizedBox(height: 16),

        const Text('10th Standard Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildTextField(_tenthSchoolController, 'School Name', 'Government / Private School'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTextField(_tenthObtainedController, 'Marks Obtained', '450')),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_tenthTotalController, 'Total Marks', '500')),
          ],
        ),
        const SizedBox(height: 16),

        const Text('12th Standard / Diploma Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildTextField(_twelfthSchoolController, 'Higher Sec School / Polytechnic', 'School / College Name'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTextField(_twelfthObtainedController, 'Marks Obtained', '540')),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_twelfthTotalController, 'Total Marks', '600')),
          ],
        ),
      ],
    );
  }

  // ── STEP 5: LIVING & ACCOMMODATION ──
  Widget _buildStep5Living() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 5: Living & Accommodation', 'Where are you currently staying during college term?'),
        const SizedBox(height: 16),

        _buildLivingOptionCard(LivingType.collegeHostel, 'College Hostel', 'Official VSB Hostel Resident'),
        _buildLivingOptionCard(LivingType.homeFamily, 'Home with Family', 'Staying with parents / day scholar'),
        _buildLivingOptionCard(LivingType.pgHostel, 'PG / Private Hostel', 'Private hostel accommodation'),
        _buildLivingOptionCard(LivingType.rentedHouse, 'Rented House / Room', 'Rented house with friends'),

        const SizedBox(height: 16),
        if (_selectedLivingType == LivingType.collegeHostel) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_rounded, color: Color(0xFF2563EB), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hostel Resident Notice: Step 6 (Day Scholar Transport) will be automatically skipped.',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(_hostelNameController, 'Hostel Name', 'VSB Men\'s Hostel'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_hostelBlockController, 'Block', 'Block A')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_hostelRoomController, 'Room No', '304')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLivingOptionCard(LivingType type, String title, String subtitle) {
    final isSelected = _selectedLivingType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedLivingType = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF0F172A))),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 6: DAY SCHOLAR TRANSPORT (STRICTLY ONLY BUS, BIKE, WALK) ──
  Widget _buildStep6Transport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 6: Day Scholar Transport Mode', 'Select your primary mode of travel to college.'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildTransportChip(PrimaryTransportMode.BUS, 'Bus', Icons.directions_bus_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _buildTransportChip(PrimaryTransportMode.BIKE, 'Bike', Icons.two_wheeler_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _buildTransportChip(PrimaryTransportMode.WALK, 'Walk', Icons.directions_walk_rounded)),
          ],
        ),
        const SizedBox(height: 16),

        if (_transportMode == PrimaryTransportMode.BUS) ...[
          _buildDropdown('Bus Type', _busType, ['College Bus', 'Public Bus'], (val) => setState(() => _busType = val)),
          const SizedBox(height: 8),
          _buildTextField(_boardingPointController, 'Boarding Point', 'Gandhigramam'),
          const SizedBox(height: 8),
          _buildTextField(_pickupTimeController, 'Pickup Time', '07:45 AM'),
        ],

        if (_transportMode == PrimaryTransportMode.BIKE) ...[
          _buildDropdown('Vehicle Type', _vehicleType, ['Bike', 'Scooter'], (val) => setState(() => _vehicleType = val)),
          const SizedBox(height: 8),
          _buildTextField(_vehicleRegNoController, 'Vehicle Registration Number', 'TN 47 AB 1234'),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('College Parking Permission Required?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            value: _parkingPermission,
            onChanged: (v) => setState(() => _parkingPermission = v),
            activeThumbColor: const Color(0xFF2563EB),
          ),
        ],

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField(_distanceController, 'One-Way Distance', '12 km')),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_travelTimeController, 'Travel Time', '30 mins')),
          ],
        ),
      ],
    );
  }

  Widget _buildTransportChip(PrimaryTransportMode mode, String label, IconData icon) {
    final isSelected = _transportMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _transportMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : const Color(0xFF475569)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ── STEP 7: DOCUMENTS ──
  Widget _buildStep7Documents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 7: Documents', 'Upload certificate scans for college verification.'),
        const SizedBox(height: 16),

        ..._uploadedDocuments.map((doc) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded, color: Color(0xFF2563EB), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(doc.fileName.isNotEmpty ? doc.fileName : 'Status: Pending Upload', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Uploaded ${doc.name}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(70, 32),
                    ),
                    child: const Text('Upload', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ── STEP 8: REVIEW & SUBMIT ──
  Widget _buildStep8Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 8: Review & Submit', 'Confirm all profile summary details before final submission.'),
        const SizedBox(height: 16),

        _buildSummaryCard('Personal Details', [
          'Name: ${_nameController.text}',
          'DOB: ${_dob ?? 'Not selected'}',
          'Gender: ${_gender ?? 'Not selected'}',
          'Blood Group: ${_bloodGroup ?? 'Not selected'}',
        ]),
        const SizedBox(height: 12),
        _buildSummaryCard('Contact & Address', [
          'Mobile: ${_primaryMobileController.text}',
          'Permanent: ${_permLine1Controller.text}, ${_permCityController.text}, ${_permStateController.text} - ${_permPincodeController.text}',
        ]),
        const SizedBox(height: 12),
        _buildSummaryCard('Parents Details', [
          'Father: ${_fatherNameController.text} (${_fatherPhoneController.text})',
          'Mother: ${_motherNameController.text} (${_motherPhoneController.text})',
        ]),
        const SizedBox(height: 12),
        _buildSummaryCard('Living & Transport', [
          'Staying Type: ${_selectedLivingType?.name ?? 'Not selected'}',
          if (_isDayScholar) 'Transport Mode: ${_transportMode?.name ?? 'Not selected'}',
        ]),
        const SizedBox(height: 20),

        CheckboxListTile(
          value: _isConfirmed,
          onChanged: (v) => setState(() => _isConfirmed = v ?? false),
          title: const Text(
            'I confirm that all information provided is accurate and true to my knowledge.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
          ),
          activeColor: const Color(0xFF2563EB),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          ...items.map((it) => Text('• $it', style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _fillMockData,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF2563EB)),
                SizedBox(width: 4),
                Text('Fill Mock Data', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 18),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    String hint, {
    IconData? icon,
    bool hasError = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: hasError ? Colors.red : const Color(0xFF64748B),
            ),
          ),
        ),
        TextFormField(
          controller: ctrl,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, fontWeight: FontWeight.w400),
            prefixIcon: icon != null ? Icon(icon, color: hasError ? Colors.red : const Color(0xFF2563EB), size: 18) : null,
            filled: true,
            fillColor: hasError ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
            errorText: hasError ? (errorText ?? 'Required field') : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFFE2E8F0),
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFF2563EB),
                width: hasError ? 2.0 : 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    bool hasError = false,
  }) {
    final validValue = (value != null && items.contains(value)) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: hasError ? Colors.red : const Color(0xFF64748B),
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: validValue,
          isExpanded: true,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
          hint: Text(
            'Select $label',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasError ? Colors.red : const Color(0xFF94A3B8),
              fontSize: 13.5,
              fontWeight: hasError ? FontWeight.bold : FontWeight.w400,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: hasError ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFFE2E8F0),
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFF2563EB),
                width: hasError ? 2.0 : 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items
              .map((it) => DropdownMenuItem(
                    value: it,
                    child: Text(it, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
