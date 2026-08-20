# 🎓 Unisphere - Student Panel Feature Proposals & Roadmap

A comprehensive feature proposal document designed for the **Unisphere Student Panel**. This document details high-impact, modern features categorized by domain, complete with user stories, technical requirements, UI/UX entry points, and an implementation priority matrix.

---

## 📌 Table of Contents
1. [Executive Summary](#-executive-summary)
2. [Category 1: Academic & AI Intelligence](#-1-academic--ai-intelligence)
3. [Category 2: Placement, Careers & Professional Hub](#-2-placement-careers--professional-hub)
4. [Category 3: Daily Campus Operations & Paperless Workflows](#-3-daily-campus-operations--paperless-workflows)
5. [Category 4: Peer Community & Campus Engagement](#-4-peer-community--campus-engagement)
6. [Category 5: Smart Utilities & OS-Level Integrations](#-5-smart-utilities--os-level-integrations)
7. [Implementation Matrix & Roadmap](#-implementation-matrix--roadmap)

---

## 🌟 Executive Summary

Unisphere already delivers a rich student experience with:
- **Academics:** Interactive Timetable, Attendance Tracker, Gradebook, CGPA Planner, Exam Hall Tickets, and Syllabus Viewer.
- **Career & Skills:** Hackathon Management, Verified Certifications, LeetCode Sync, GitHub Dev Portfolio, and Professional Resume Generator.
- **Campus Life:** Announcements, Events, Digital ID Card, Photo Gallery, and Library Status.

This document proposes next-generation features that transform the Student Panel from a static information dashboard into an **active, AI-assisted campus operating system**.

---

## 🧠 1. Academic & AI Intelligence

### 1.1. Smart "Safe-to-Miss" Attendance Forecaster
* **Problem:** Students constantly calculate how many classes they can afford to miss for symposiums, illness, or hackathons without dropping below the required 75% or 85% threshold.
* **Proposed Solution:** 
  * Interactive slider simulating future missed hours or planned leaves.
  * Real-time projection: *"If you miss 3 hours of Data Structures next week, your attendance will be 76.2% (Safe: 1 hour buffer remaining)"*.
  * Automated alerts when a subject approaches the critical 75% boundary.
* **Target Screen:** [`lib/screens/student/modules/student_attendance_screen.dart`](file:///Users/saravana/Downloads/unisphere-main-v2/lib/screens/student/modules/student_attendance_screen.dart)

### 1.2. AI Syllabus Tutor & Flashcard Generator
* **Problem:** Students need quick revision notes before unit tests or semester exams.
* **Proposed Solution:**
  * One-tap AI summary generator integrated directly into the syllabus unit viewer.
  * Generates 5-minute revision flashcards, formula cheat sheets, and 10-question practice quizzes based on the uploaded syllabus documents.
* **Target Screen:** [`lib/screens/student/modules/syllabus_document_viewer_screen.dart`](file:///Users/saravana/Downloads/unisphere-main-v2/lib/screens/student/modules/syllabus_document_viewer_screen.dart)

### 1.3. Previous Years Question Papers (PYQ) & Solved Model Papers
* **Problem:** Students search across multiple unofficial drives and groups for past exam papers.
* **Proposed Solution:**
  * Department & semester-filtered archive of university and internal test question papers.
  * Tagged by subject, regulation, and year with downloadable PDFs and verified answer keys.
* **Target Screen:** New module accessible via `FeatureHubScreen` and `SubjectDetailsScreen`.

---

## 💼 2. Placement, Careers & Professional Hub

### 2.1. Placement Drive & Internship Portal
* **Problem:** Placement notices and eligibility criteria are scattered across notice boards and messaging groups.
* **Proposed Solution:**
  * Live listings of upcoming on-campus and off-campus recruitment drives.
  * Automated eligibility engine checking student CGPA, active arrears/backlogs, and department against company criteria.
  * 1-Click Application utilizing the existing Unisphere Resume profile.
  * Application status tracker: `Applied` $\rightarrow$ `Aptitude Shortlist` $\rightarrow$ `Technical Interview` $\rightarrow$ `HR Round` $\rightarrow$ `Offer Received`.
* **Target Screen:** New screen in sidebar under `CAREER & SKILLS`.

### 2.2. ATS Resume Score & Role Match Analyzer
* **Problem:** Students don't know how well their resume matches specific roles like *Flutter Developer*, *Data Scientist*, or *Cloud DevOps Engineer*.
* **Proposed Solution:**
  * Live AI score based on skills extracted from their LeetCode, GitHub, Certifications, and Project entries.
  * Actionable feedback: *"Add Docker and CI/CD to your resume to increase match for DevOps positions by +25%"*.
* **Target Screen:** [`lib/screens/student/modules/student_resume_screen.dart`](file:///Users/saravana/Downloads/unisphere-main-v2/lib/screens/student/modules/student_resume_screen.dart)

### 2.3. Hackathon & Project Teammate Matcher
* **Problem:** Students want to participate in hackathons but lack specific teammates (e.g., UI/UX designer or backend engineer).
* **Proposed Solution:**
  * Open team bulletin board linked to [hackathons_screen.dart](file:///Users/saravana/Downloads/unisphere-main-v2/lib/screens/features/hackathons_screen.dart).
  * Post a vacancy (e.g., *"Team CyberKnights looking for 1 Flutter frontend developer for Smart India Hackathon"*).
  * Students can browse vacancies and request to join with 1-click.
* **Target Screen:** [`lib/screens/features/hackathon_team_management_screen.dart`](file:///Users/saravana/Downloads/unisphere-main-v2/lib/screens/features/hackathon_team_management_screen.dart)

---

## 🏛️ 3. Daily Campus Operations & Paperless Workflows

### 3.1. Digital On-Duty (OD) & Leave Application Workflow
* **Problem:** Physical paper forms for On-Duty (OD) permissions for competitions, symposiums, or sports often get lost or take days to get signed by multiple faculty members.
* **Proposed Solution:**
  * Paperless multi-step approval workflow:
    1. Student submits request with proof (OD category, date, certificate/invitation PDF).
    2. Auto-notified to Class Advisor/Mentor for 1st approval.
    3. Auto-routed to Head of Department (HOD) for final approval.
    4. Upon approval, attendance automatically reconciles with the official attendance register.
* **Target Screen:** Available under `FeatureHubScreen` and `StudentAttendanceScreen`.

### 3.2. Live Campus Bus & Shuttle GPS Tracker
* **Problem:** Commuter students waste time waiting at stops without knowing if their college bus is delayed or has passed.
* **Proposed Solution:**
  * Live map view showing all college transport routes, real-time bus locations, estimated arrival times (ETA), and driver contact info.
  * Push alerts for route delays or breakdown updates.
* **Target Screen:** New screen in sidebar under `CAMPUS LIFE`.

### 3.3. Cafeteria / Canteen Pre-Ordering & Rush Meter
* **Problem:** 15-minute recess breaks are often lost waiting in cafeteria lines.
* **Proposed Solution:**
  * Daily live menu with pricing and dietary tags.
  * Pre-order token generation to pick up snacks/meals directly at the counter.
  * Real-time rush indicator: `Quiet`, `Moderate`, `Busy`.
* **Target Screen:** New tool in `FeatureHubScreen`.

### 3.4. Lab Equipment & Discussion Room Booking
* **Problem:** Conflict in reserving college resources like 3D printers, project labs, conference rooms, or sports courts.
* **Proposed Solution:**
  * Interactive calendar slot reservation with purpose declaration and faculty mentor approval.
* **Target Screen:** Accessible from `FeatureHubScreen`.

---

## 👥 4. Peer Community & Campus Engagement

### 4.1. Course Doubt Clearance & Notes Sharing Hub
* **Problem:** Doubts during late-night exam study often go unanswered.
* **Proposed Solution:**
  * Subject-wise forum where students post questions, code snippets, or handwritten notes.
  * Upvoting system for high-quality peer solutions.
  * Faculty / Peer Tutor badges for verified answers.
* **Target Screen:** Sub-tab under `SubjectDetailsScreen`.

### 4.2. Campus Marketplace & Lost & Found
* **Problem:** Seniors have used engineering textbooks, lab coats, drafters, and Arduino kits with no easy channel to hand them down to juniors.
* **Proposed Solution:**
  * **Student Marketplace:** Verified peer-to-peer buy/sell/borrow listings for academic supplies.
  * **Lost & Found:** Upload photo and description of lost/found items with room tag and claim verification.
* **Target Screen:** New screen under `CAMPUS LIFE`.

### 4.3. Confidential Grievance & Student Welfare Portal
* **Problem:** Students hesitate to report issues regarding infrastructure, harassment, or hostel facilities without privacy safeguards.
* **Proposed Solution:**
  * Anonymous complaint submission categorized by department, hostel, or administration.
  * Encrypted ticket tracker displaying progress (*Received $\rightarrow$ In Review $\rightarrow$ Resolved*).
* **Target Screen:** Accessible via `FeatureHubScreen` or Settings.

---

## 📱 5. Smart Utilities & OS-Level Integrations

### 5.1. Lock Screen & Home Screen Glanceable Widgets
* **Capabilities:**
  * **Next Class Widget:** Displays next period name, room number, and time countdown.
  * **Attendance Gauge Widget:** Real-time overall percentage badge.
  * **Quick Digital ID Pass:** Quick tile on Android / Dynamic Island widget on iOS for gate pass scanning.

### 5.2. Offline-First Caching
* **Capabilities:**
  * Cache timetable, downloaded syllabus documents, offline hall tickets, and QR digital ID so students never get blocked due to poor campus Wi-Fi or basement lab deadzones.

---

## 📊 Implementation Matrix & Roadmap

| Feature | Category | Effort / Complexity | Impact | Recommended Priority |
| :--- | :--- | :---: | :---: | :---: |
| **Smart Attendance "Safe-to-Miss" Calculator** | Academics | **Low** | ⭐⭐⭐⭐⭐ | **Phase 1 (Immediate)** |
| **Digital OD & Leave Workflow** | Operations | **Medium** | ⭐⭐⭐⭐⭐ | **Phase 1 (Immediate)** |
| **Placement Drive & Internship Tracker** | Career | **Medium-High** | ⭐⭐⭐⭐⭐ | **Phase 2 (Core)** |
| **Hackathon Teammate Matcher** | Career | **Medium** | ⭐⭐⭐⭐ | **Phase 2 (Core)** |
| **AI Syllabus Tutor & Flashcard Generator** | Academics & AI | **Medium** | ⭐⭐⭐⭐ | **Phase 2 (Core)** |
| **Course Doubt Forum & Notes Sharing** | Community | **Medium** | ⭐⭐⭐⭐ | **Phase 3 (Expansion)** |
| **Live Campus Bus GPS Tracker** | Utilities | **High** | ⭐⭐⭐⭐ | **Phase 3 (Expansion)** |
| **Campus Marketplace & Lost & Found** | Community | **Low-Medium** | ⭐⭐⭐ | **Phase 3 (Expansion)** |
| **Cafeteria Pre-Order System** | Utilities | **High** | ⭐⭐⭐ | **Phase 4 (Advanced)** |
| **OS Home Screen & Lock Screen Widgets** | Utilities | **Medium** | ⭐⭐⭐⭐ | **Phase 4 (Advanced)** |

---

*Document prepared for Unisphere Student Experience Architecture.*
