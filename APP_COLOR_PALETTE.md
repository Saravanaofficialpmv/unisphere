# Unisphere Design System - Color Palette Documentation

Centralized reference for all colors, brand accents, status semantics, role portals, module colors, and gradients defined in [app_colors.dart](file:///Users/saravana/Downloads/unisphere-main-v2/lib/core/constants/app_colors.dart).

---

## 🎨 1. Brand & Primary Colors

| Color Name | Hex Code | Purpose & Usage |
| :--- | :--- | :--- |
| **Primary Brand** | `#2563EB` | Royal Indigo Blue — Primary brand header cards, primary action buttons, active tab indicators. |
| **Primary Light** | `#3B82F6` | Vibrant Electric Blue — Button hover states, primary gradient highlights. |
| **Primary Dark** | `#1D4ED8` | Deep Navy Indigo — Selected semester pills, active badge outlines. |
| **Primary Accent** | `#3F51B5` | Classic Indigo Accent — Subtitle icons, progress indicators. |
| **Primary Subtle** | `#EEF2FF` | Soft Indigo Blue Background Tint — Avatar containers, secondary button fills. |

---

## 👑 2. Role-Based Portal Accent Colors

| Role Portal | Hex Code | Theme Color |
| :--- | :--- | :--- |
| **Student Portal** | `#2563EB` | 🟦 Royal Blue |
| **Staff / Faculty Portal** | `#7C3AED` | 🟪 Royal Purple |
| **HOD Department Portal** | `#D97706` | 🟧 Deep Amber Gold |
| **Parent Portal** | `#059669` | 🟩 Emerald Teal |
| **Admin Control Portal** | `#DC2626` | 🟥 Crimson Red |

---

## 🟢 3. Status & Semantic Colors

| Status | Hex Code | Light Background Tint | Dark Text / Border |
| :--- | :--- | :--- | :--- |
| **Success / Passed** | `#10B981` | `#E8F5E9` (Emerald Tint) | `#2E7D32` (Forest Green) |
| **Warning / Safe Margin** | `#F59E0B` | `#FEF3C7` (Soft Amber) | `#EA580C` (Deep Orange) |
| **Error / Critical / Low** | `#EF4444` | `#FEE2E2` (Soft Red) | `#B91C1C` (Dark Crimson) |
| **Info / Notification** | `#3B82F6` | `#E0F2FE` (Soft Sky Blue) | `#0284C7` (Sky Blue) |

---

## 📚 4. Feature & Module Accents

| Feature Module | Hex Code | Visual Accent |
| :--- | :--- | :--- |
| **Timetable & Schedule** | `#5C6BC0` | 🟪 Indigo Blue |
| **Assignments & Submissions** | `#26A69A` | 🟩 Mint Teal |
| **Gradebook & Results** | `#EF5350` | 🟥 Coral Red |
| **Fees & Payments** | `#FFA726` | 🟧 Amber Gold |
| **Hackathons & Tech** | `#00ACC1` | 🟦 Cyan Blue |
| **Certifications & Badges** | `#10B981` | 🟩 Emerald Green |
| **Campus Events** | `#8E24AA` | 🟪 Deep Purple |

---

## 🌈 5. Search Bar & Special Gradients

| Gradient Component | Color Stops | Visual Effect |
| :--- | :--- | :--- |
| **Capsule Search Bar Border** | `#34D399` $\rightarrow$ `#F472B6` $\rightarrow$ `#3B82F6` | Mint Green $\rightarrow$ Soft Pink $\rightarrow$ Royal Blue Gradient |
| **Hero Banner Gradient** | `#1E3A8A` $\rightarrow$ `#2563EB` $\rightarrow$ `#3B82F6` | Deep Navy $\rightarrow$ Royal Blue Gradient |
| **Glassmorphism Overlay** | `#FFFFFF` (90% to 65% opacity) | Apple Frosted Glass Card Effect |

---

## 📄 Code Reference (`app_colors.dart`)

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand & Primary
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryAccent = Color(0xFF3F51B5);
  static const Color primarySubtle = Color(0xFFEEF2FF);

  // Background & Surface
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSubtle = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Status & Semantics
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Roles
  static const Color studentRole = Color(0xFF2563EB);
  static const Color staffRole = Color(0xFF7C3AED);
  static const Color hodRole = Color(0xFFD97706);
  static const Color parentRole = Color(0xFF059669);
  static const Color adminRole = Color(0xFFDC2626);
}
```
