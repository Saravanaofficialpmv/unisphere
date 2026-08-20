class StaffCourse {
  final String code;
  final String name;
  final String yearSemester;
  final String section;
  final int studentCount;
  final String room;

  const StaffCourse({
    required this.code,
    required this.name,
    required this.yearSemester,
    required this.section,
    required this.studentCount,
    required this.room,
  });
}

class StaffLeaveRecord {
  final String id;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final int days;
  final String status; // Approved, Pending, Rejected
  final String reason;

  const StaffLeaveRecord({
    required this.id,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.status,
    required this.reason,
  });
}

class StaffDocument {
  final String id;
  final String title;
  final String fileType;
  final String fileSize;
  final String uploadDate;
  final String status;

  const StaffDocument({
    required this.id,
    required this.title,
    required this.fileType,
    required this.fileSize,
    required this.uploadDate,
    required this.status,
  });
}

class StaffDetailsModel {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String qualification;
  final String specialization;
  final String joiningDate;
  final String experience;
  final String employmentType;
  final String status;
  final String phone;
  final String email;
  final String dob;
  final String gender;
  final String address;
  final String photoUrl;
  final String bloodGroup;
  final String emergencyContact;
  final String staffCategory;
  final int coursesCount;
  final int studentsAssigned;
  final int classesThisWeek;
  final int attendancePercentage;
  final List<StaffCourse> courses;
  final List<StaffLeaveRecord> leaveHistory;
  final List<StaffDocument> documents;

  const StaffDetailsModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.qualification,
    required this.specialization,
    required this.joiningDate,
    required this.experience,
    required this.employmentType,
    required this.status,
    required this.phone,
    required this.email,
    required this.dob,
    required this.gender,
    required this.address,
    required this.photoUrl,
    this.bloodGroup = "O+ Positive",
    this.emergencyContact = "+91 98765 43211 (Spouse)",
    this.staffCategory = "Teaching Faculty",
    required this.coursesCount,
    required this.studentsAssigned,
    required this.classesThisWeek,
    required this.attendancePercentage,
    required this.courses,
    required this.leaveHistory,
    required this.documents,
  });

  StaffDetailsModel copyWith({
    String? id,
    String? name,
    String? designation,
    String? department,
    String? qualification,
    String? specialization,
    String? joiningDate,
    String? experience,
    String? employmentType,
    String? status,
    String? phone,
    String? email,
    String? dob,
    String? gender,
    String? address,
    String? photoUrl,
    String? bloodGroup,
    String? emergencyContact,
    String? staffCategory,
    int? coursesCount,
    int? studentsAssigned,
    int? classesThisWeek,
    int? attendancePercentage,
    List<StaffCourse>? courses,
    List<StaffLeaveRecord>? leaveHistory,
    List<StaffDocument>? documents,
  }) {
    return StaffDetailsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      joiningDate: joiningDate ?? this.joiningDate,
      experience: experience ?? this.experience,
      employmentType: employmentType ?? this.employmentType,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      staffCategory: staffCategory ?? this.staffCategory,
      coursesCount: coursesCount ?? this.coursesCount,
      studentsAssigned: studentsAssigned ?? this.studentsAssigned,
      classesThisWeek: classesThisWeek ?? this.classesThisWeek,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      courses: courses ?? this.courses,
      leaveHistory: leaveHistory ?? this.leaveHistory,
      documents: documents ?? this.documents,
    );
  }

  static StaffDetailsModel get defaultTharaniKumar => const StaffDetailsModel(
        id: "VSB10234",
        name: "Dr. K. Tharani Kumar",
        designation: "Assistant Professor",
        department: "Computer Science & Engineering",
        qualification: "Ph.D. (CSE)",
        specialization: "Artificial Intelligence & Data Analytics",
        joiningDate: "12 July 2020",
        experience: "4 Years 6 Months",
        employmentType: "Permanent",
        status: "Active",
        phone: "+91 98765 43210",
        email: "tharani.kumar@vsbec.edu.in",
        dob: "15 Mar 1994",
        gender: "Male",
        address: "Karur, Tamil Nadu",
        photoUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400",
        bloodGroup: "O+ Positive",
        emergencyContact: "+91 98765 43211 (Spouse)",
        staffCategory: "Teaching Faculty",
        coursesCount: 6,
        studentsAssigned: 120,
        classesThisWeek: 14,
        attendancePercentage: 96,
        courses: [
          StaffCourse(
            code: "CS8691",
            name: "Artificial Intelligence",
            yearSemester: "III Year / Sem 6",
            section: "Section A",
            studentCount: 60,
            room: "CSE Lab 1",
          ),
          StaffCourse(
            code: "CS8079",
            name: "Data Analytics",
            yearSemester: "IV Year / Sem 7",
            section: "Section B",
            studentCount: 60,
            room: "Hall 204",
          ),
          StaffCourse(
            code: "CS8791",
            name: "Machine Learning",
            yearSemester: "IV Year / Sem 7",
            section: "Section A",
            studentCount: 55,
            room: "AI Research Lab",
          ),
          StaffCourse(
            code: "GE8071",
            name: "Design Thinking",
            yearSemester: "III Year / Sem 5",
            section: "Section A",
            studentCount: 65,
            room: "CSE Lab 2",
          ),
          StaffCourse(
            code: "GE8151",
            name: "Python Programming",
            yearSemester: "I Year / Sem 2",
            section: "Section C",
            studentCount: 62,
            room: "Programming Lab 3",
          ),
          StaffCourse(
            code: "CS8591",
            name: "Web Technologies",
            yearSemester: "III Year / Sem 5",
            section: "Section B",
            studentCount: 58,
            room: "Web Lab 1",
          ),
        ],
        leaveHistory: [
          StaffLeaveRecord(
            id: "LV-2026-001",
            leaveType: "Casual Leave",
            fromDate: "12 May 2026",
            toDate: "13 May 2026",
            days: 2,
            status: "Approved",
            reason: "Family function in hometown",
          ),
          StaffLeaveRecord(
            id: "LV-2026-002",
            leaveType: "Medical Leave",
            fromDate: "04 Apr 2026",
            toDate: "05 Apr 2026",
            days: 2,
            status: "Approved",
            reason: "Viral fever and doctor consultation",
          ),
          StaffLeaveRecord(
            id: "LV-2026-003",
            leaveType: "On Duty (OD)",
            fromDate: "18 Feb 2026",
            toDate: "19 Feb 2026",
            days: 2,
            status: "Approved",
            reason: "Attending AI National Conference at NIT Trichy",
          ),
          StaffLeaveRecord(
            id: "LV-2026-004",
            leaveType: "Casual Leave",
            fromDate: "25 Jun 2026",
            toDate: "25 Jun 2026",
            days: 1,
            status: "Pending",
            reason: "Personal work at Karur RTO",
          ),
        ],
        documents: [
          StaffDocument(
            id: "DOC-01",
            title: "Resume / CV",
            fileType: "PDF",
            fileSize: "1.2 MB",
            uploadDate: "15 Jan 2026",
            status: "Verified",
          ),
          StaffDocument(
            id: "DOC-02",
            title: "Degree Certificate (Ph.D.)",
            fileType: "PDF",
            fileSize: "2.4 MB",
            uploadDate: "12 Jul 2020",
            status: "Verified",
          ),
          StaffDocument(
            id: "DOC-03",
            title: "Experience Certificate",
            fileType: "PDF",
            fileSize: "850 KB",
            uploadDate: "12 Jul 2020",
            status: "Verified",
          ),
          StaffDocument(
            id: "DOC-04",
            title: "ID Proof (Aadhaar & PAN)",
            fileType: "PDF",
            fileSize: "600 KB",
            uploadDate: "10 Jul 2020",
            status: "Verified",
          ),
          StaffDocument(
            id: "DOC-05",
            title: "Appointment Letter",
            fileType: "PDF",
            fileSize: "1.5 MB",
            uploadDate: "12 Jul 2020",
            status: "Verified",
          ),
        ],
      );
}
