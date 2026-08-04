# UNISPHERE SRM — Staff Panel Detailed Specification & Feature Matrix

## 1. Executive Overview

The **Staff & Faculty Panel** in UNISPHERE SRM serves as the core operational workspace for professors, assistant professors, lab instructors, and administrative department staff. It streamlines day-to-day academic workflows—from marking attendance and evaluating student coursework to publishing examination grades and managing faculty leave.

---

## 2. Core Functional Modules & Feature Breakdown

### Module 1: Home Dashboard & Quick Actions Hub
* **Daily Schedule Widget**: Timeline view of today's assigned lectures, lab sessions, room numbers, and subject codes (`e.g., CS301 - Data Structures, Room 204 @ 10:00 AM`).
* **Metric Counter Cards**:
  * Total Assigned Classes & Students.
  * Pending Coursework Submissions requiring grading.
  * Low Attendance Alerts (< 75%) among enrolled students.
* **Quick Action Shortcuts**: Single-click modal triggers to create announcements, assign tasks, log attendance, or upload marks.
* **Recent Activity Feed**: Real-time log of recent student submissions, administrative alerts, and department notices.

---

### Module 2: Attendance Register (`Take Attendance`)
* **Interactive Class Selector**: Select Department, Degree/Batch (`e.g., B.Tech CSE 2024-28`), Section (`CS-A`), and Subject.
* **Date & Period Selection**: Choose specific date and class hour (Period 1 to Period 8).
* **Attendance Grid / List View**:
  * Student Name, Roll Number, Photo, and Current Attendance Percentage.
  * Status toggles: **Present (P)**, **Absent (A)**, **Late (L)**, **On-Duty (OD)**.
  * **"Mark All Present"** bulk toggle button.
* **Absence Reason Logging**: Optional notes field for logging medical certificates or official college activity approvals.
* **Real-time Backend Sync**: Instantly updates student & parent dashboard attendance progress metrics.

---

### Module 3: Assignment Creation & Delegation (`Give Assignment`)
* **Assignment Form**:
  * Title, Detailed Instructions (Rich text / Markdown support).
  * Subject & Class Section Target Selection (`CS-A`, `CS-B`, or All Sections).
  * Due Date, Time Deadline, and Maximum Score/Weightage.
  * Attachment Support (Upload PDFs, reference docs, sample code).
* **Drafts & Scheduled Publishing**: Save assignment drafts or schedule post publishing for a future date.
* **Push Notifications**: Automatically alert enrolled students via in-app notification when an assignment is published.

---

### Module 4: Submission Review & Grading (`Review Submissions`)
* **Submissions Summary Matrix**:
  * Total Assigned vs. Submitted vs. Graded counters.
  * Filtering options: *Submitted, Overdue, Graded, Pending Review*.
* **Evaluation Workspace**:
  * Side-by-side view of student file upload (PDF previewer / document link).
  * Submission details: Student Name, Roll Number, Submission Timestamp (flagged if late).
  * Numerical Score Input Field & Feedback Comment Box.
* **Bulk Export**: Download student submissions as a compressed ZIP file or export grade sheet to Excel/CSV.

---

### Module 5: Marks & Internal Assessment Upload (`Upload Marks`)
* **Exam / Assessment Selector**: Choose Exam Type (Unit Test 1, Mid-Term 1, Final Lab, Semester Exam), Subject, and Batch.
* **Dynamic Grading Grid**:
  * Auto-calculated Totals, Percentages, and Grade point conversions (A+, A, B, C, F).
  * Validation rules preventing scores greater than maximum allocated marks.
  * Lock & Publish feature to finalize grades and release to Student/Parent portals.
* **Bulk Import/Export**: Download pre-filled template sheet, edit offline in Excel, and re-upload.

---

### Module 6: Faculty Library & Resource Sharing (`Library Access`)
* **Resource Catalog Search**: Query books, journals, whitepapers, and digital repositories available in the campus library.
* **Book Issue Status**: View checked-out literature, due dates, and renewal requests.
* **Course Material Repository**: Upload lecture notes, PPT slides, syllabus copies, and lab manuals accessible to enrolled students.

---

### Module 7: Faculty Advisor & Mentorship Hub
* **Mentee Roster**: List of 20–30 assigned students under faculty advisement.
* **360° Student Academic Snapshot**: Combined view of mentee attendance percentage, GPA trend, arrears count, and disciplinary record.
* **Parent-Teacher Meeting Notes**: Log notes from discussions with parents/guardians for official record keeping.

---

### Module 8: Faculty Leave & Substitution Management
* **Leave Application Workflow**:
  * Apply for Casual Leave (CL), On Duty (OD), or Sick Leave.
  * Select replacement faculty member for scheduled lectures.
* **Approval Status Tracker**: View pending, approved, or rejected leave applications submitted to the HOD/Principal.

---

## 3. Data Models & Database Schema Integration

The Staff Panel interacts with the following core Supabase tables and Dart models:

```
                          ┌───────────────────────────┐
                          │    UserModel (staff)      │
                          └─────────────┬─────────────┘
                                        │
        ┌───────────────────┬───────────┴───────────┬───────────────────┐
        ▼                   ▼                       ▼                   ▼
┌───────────────┐   ┌───────────────┐       ┌───────────────┐   ┌───────────────┐
│ AttendanceModel │ │AssignmentModel│       │   MarkModel   │   │SubmissionModel│
└───────────────┘   └───────┬───────┘       └───────────────┘   └───────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │SubmissionModel│
                    └───────────────┘
```

### Table Mapping:
1. **`users`**: `id`, `name`, `email`, `role = 'staff'`, `department`, `designation`, `phone`, `created_at`.
2. **`attendance`**: `id`, `student_id`, `subject_code`, `date`, `period`, `status ('present'|'absent'|'late'|'od')`, `marked_by_staff_id`.
3. **`assignments`**: `id`, `staff_id`, `subject`, `class_section`, `title`, `description`, `due_date`, `max_marks`, `attachment_url`.
4. **`submissions`**: `id`, `assignment_id`, `student_id`, `submitted_at`, `file_url`, `score`, `feedback_comments`, `status ('graded'|'pending')`.
5. **`marks`**: `id`, `student_id`, `subject`, `exam_type`, `marks_obtained`, `max_marks`, `grade`, `uploaded_by_staff_id`.

---

## 4. UI Architecture & Navigation Structure

```
StaffDashboard (Scaffold Shell)
├── MainSidebar (Collapsible Navigation / Mobile Drawer)
│   ├── Home Dashboard
│   ├── Give Assignment
│   ├── Review Submissions (Badge: Pending Count)
│   ├── Upload Marks
│   ├── Take Attendance
│   ├── Library Access
│   └── Staff Profile
└── Active Screen View (Dynamic Indexed Stack)
    ├── StaffHomeScreen (Header, Action Grid, Activity Feed)
    ├── AssignmentCreateScreen
    ├── SubmissionReviewScreen
    ├── MarksUploadScreen
    ├── AttendanceRegisterScreen
    └── ResourceLibraryScreen
```

---

## 5. Security & Access Control (RBAC)

* **Scope Enforcement**: Staff members can only view/edit records, attendance, and marks for subjects and department classes explicitly assigned to them.
* **Grade Lock Policies**: Published exam marks cannot be modified after HOD approval without an administrative override request.
* **Audit Trail**: Every attendance update and grade upload logs the `staff_id` and timestamp for compliance auditing.
