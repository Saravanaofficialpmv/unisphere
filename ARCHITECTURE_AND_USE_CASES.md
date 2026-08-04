# UNISPHERE SRM — System Architecture & Application Use Cases

## 1. Overall System Architecture

**UNISPHERE SRM** is built as a cross-platform Flutter application targeted for Web, Desktop, and Mobile. It follows a clean modular architecture separating presentation, state management, router navigation, domain models, and service abstractions.

```
                  ┌──────────────────────────────────────────────────┐
                  │                 Presentation Layer               │
                  │   Admin / Staff / Student / Parent Dashboards    │
                  └─────────────────────────┬────────────────────────┘
                                            │
                                            ▼
                  ┌──────────────────────────────────────────────────┐
                  │               State & Router Layer               │
                  │         Riverpod + GoRouter Redirection         │
                  └─────────────────────────┬────────────────────────┘
                                            │
                                            ▼
                  ┌──────────────────────────────────────────────────┐
                  │               Service Abstraction                │
                  │     AuthService      │    SupabaseService        │
                  └─────────────┬────────────────────┬───────────────┘
                                │                    │
                        ┌───────┴──────┐      ┌──────┴───────┐
                        ▼              ▼      ▼              ▼
                    Production       Demo  Production      Demo
                    Supabase Auth   Mock   Supabase DB    Mock DB
```

### Key Architectural Layers

1. **Entry & Root Initialization** ([main.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/main.dart))
   - Initializes `Supabase` client credentials asynchronously.
   - Wraps the application in a `ProviderScope` to enable Riverpod dependency injection.
   - Provides a fallback `SupabaseErrorScreen` with interactive **"Launch Demo Mode"** capability.

2. **Navigation & Routing** ([app_router.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/navigation/app_router.dart))
   - Powered by `GoRouter` coupled with Riverpod's `StreamProvider<UserModel?>` (`authStateProvider`).
   - Implements dynamic **Role-Based Access Route Guards**: Unauthenticated users are redirected to `/onboarding` or `/login`. Authenticated users are automatically routed to their role-specific dashboard (`/admin`, `/staff`, `/student`, `/parent`).

3. **Data Access & Backend Service Layer** ([auth_service.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/services/auth_service.dart), [supabase_service.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/services/supabase_service.dart))
   - Implements an **Abstract Interface Pattern** (`AuthService` and `SupabaseService`) allowing seamless switching between production cloud databases and localized mock engines (`MockSupabaseService`).
   - Real-time reactivity powered by Supabase PostgreSQL Streams (`.stream(primaryKey: ['id'])`).

4. **Domain Data Models** ([models/](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/models))
   - Strongly typed domain objects with serialization methods:
     - [UserModel](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/models/user_model.dart): User identity and role definitions (`admin`, `staff`, `student`, `parent`).
     - [AnnouncementModel](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/models/announcement_model.dart): Global and department-level news.
     - [AssignmentModel](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/models/assignment_model.dart) & [SubmissionModel](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/models/submission_model.dart): Homework tasks and student responses.
     - [AttendanceModel](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/models/attendance_model.dart): Daily presence records.
     - [MarkModel](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/models/mark_model.dart): Exam, test, and grading metrics.

5. **Responsive UI & Navigation Shell** ([main_sidebar.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/widgets/common/main_sidebar.dart), [admin_shell.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/admin/admin_shell.dart))
   - Adapts dynamically between desktop wide layouts (collapsible left-hand sidebar) and mobile views (drawer navigation).

---

## 2. Detailed Application Use Cases

The application supports four primary role-based user personas, each tailored with dedicated workflows and modules.

### Use Case 1: Executive Administrator Portal (`UserRole.admin`)
- **Primary Dashboard Overview** ([admin_dashboard.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/admin/admin_dashboard.dart)):
  - **Key System Metrics**: View real-time institutional counts (Total Students, Staff Members, Departments) with growth indicators.
  - **Analytics Graphs**: Visual trend analysis of student enrollment over time and system pulse monitoring.
  - **Quick Action Triggers**: Instant modal shortcuts to register users, post institutional notices, assign tasks, and create new classes.
- **User Management Module** ([user_management.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/admin/modules/user_management.dart)):
  - **User Lifecycle Control**: Create, update, deactivate, or delete profiles across all roles.
  - **Filtering & Search**: Multi-criteria search by name, email, department, role, or active status.
- **Attendance Management Module** ([attendance_management.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/admin/modules/attendance_management.dart)):
  - View campus-wide attendance stats, track department-wise averages, and approve/reject leave requests.
- **Department Management Module** ([department_management.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/admin/modules/department_management.dart)):
  - Organize academic divisions, assign Department Heads (HODs), track budget allocation, and monitor student counts.
- **Announcement Management Module** ([announcement_management.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/admin/modules/announcement_management.dart)):
  - Broadcast campus updates targeted to specific user roles or departments.
- **Report & Role Management Modules** ([report_management.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/admin/modules/report_management.dart), [role_management.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/admin/modules/role_management.dart)):
  - Generate enterprise analytics reports (PDF/Excel exports) and configure Role-Based Access Control (RBAC) permission matrices.

---

### Use Case 2: Faculty & Administrative Staff (`UserRole.staff`)
- **Staff Administrative Hub** ([staff_dashboard.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/staff/staff_dashboard.dart)):
  - **Task & Assignment Delegation**: Create coursework assignments targeting specific classes (`CS-A`, `CS-B`) with due dates and score weights.
  - **Submission Review**: Grade and review digital coursework submissions handed in by students.
  - **Bulk Marks Upload**: Input and publish internal assessments, mid-term scores, and final grades into student academic records.
  - **Attendance Register**: Electronic attendance marking for class sessions.
  - **Faculty Library Access**: Search digital resource catalogs and manage borrowed literature.

---

### Use Case 3: Student Portal (`UserRole.student`)
- **Learner Hub** ([student_dashboard.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/student/student_dashboard.dart)):
  - **Personal Schedule**: Real-time view of daily class timetables (time slots, subject names, room/lab numbers).
  - **Attendance Tracker**: Radial visual indicator displaying personal overall presence percentage (e.g. 85%).
  - **Assignments & Tasks**: Track active assignments, pending deadlines, and upload solutions.
  - **Gradebook**: Review individual subject marks, GPA progression, and test scores.
  - **Campus Notices**: Live stream of college-wide announcements and library status.

---

### Use Case 4: Parent / Guardian Portal (`UserRole.parent`)
- **Guardian Dashboard** ([parent_dashboard.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/parent/parent_dashboard.dart)):
  - **Child Overview**: Monitor ward profile, current semester progress, overall attendance, CGPA, class rank, and total credits earned.
  - **Academic Progress Breakdown**: View scores obtained in unit tests, lab sessions, and term exams.
  - **Institutional Alerts**: Stay informed about parent-teacher conferences, upcoming sports meets, and official communications.
  - **Child Services**: Track tuition fee payment status and monitor school transport bus routes.

---

### Use Case 5: Common Authentication & Onboarding
- **Auth Screen** ([auth_screen.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/auth/auth_screen.dart)):
  - Email/Password sign-in with quick **Demo Account Credentials** (`admin@unisphere.edu`, `staff@unisphere.edu`, etc.).
  - Account registration request workflow ([request_submitted_screen.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/auth/request_submitted_screen.dart)).
  - Onboarding carousel for new users ([onboarding_screen.dart](file:///Users/saravana/flutter/clg_application_final%28unisphere%29/lib/screens/onboarding/onboarding_screen.dart)).
