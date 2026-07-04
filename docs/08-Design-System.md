# UI/UX Design System: AI Language Coach
**Version:** 1.0  
**Status:** Production  
**Design Standard:** Material 3 Adaptive UI Compliance  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the design tokens, visual elements, layout guides, custom components, and accessibility guidelines for **AI Language Coach**. 

It ensures visual consistency between Design (Figma) and Development (Flutter), resulting in a cohesive experience across Android and iOS platforms.

---

## 2. Design Principles
Every user interface layout must align with these core goals:
*   **Simplicity First:** Hide advanced configuration details behind menus, keeping main actions clean.
*   **Learning-Focused:** Maximize readable whitespace to prevent visual fatigue.
*   **Reduce Cognitive Load:** Restrict actions on a single screen to one primary call-to-action (CTA).
*   **Friendly & Motivating:** Use supportive illustrations, soft colors, and confetti transitions to celebrate progress.

---

## 3. Brand Identity
*   **Personality:** Intelligent, Friendly, Professional, Trustworthy, Motivating.
*   **Core Keywords:** Learn, Speak, Grow, Confidence, Progress.

---

## 4. Color Palette Tokens

We use a curated palette that meets WCAG AA contrast standards:

### 4.1 Light Mode System Tokens
```
+-------------------+-------------------+-----------------------------------------------------------+
| TOKEN NAME        | HEX COLOR CODE    | APPLICATION SCOPE / ROLE                                  |
+-------------------+-------------------+-----------------------------------------------------------+
| Primary 500       | #4F46E5           | Core branding color, primary CTA buttons, active states  |
+-------------------+-------------------+-----------------------------------------------------------+
| Primary 600       | #4338CA           | Hover states, focused boundaries                          |
+-------------------+-------------------+-----------------------------------------------------------+
| Primary 700       | #3730A3           | Pressed states, dark text elements                        |
+-------------------+-------------------+-----------------------------------------------------------+
| Secondary         | #06B6D4           | Accent features, secondary page indicators                |
+-------------------+-------------------+-----------------------------------------------------------+
| Success           | #22C55E           | Correct answers, completed tasks, streaks                 |
+-------------------+-------------------+-----------------------------------------------------------+
| Warning           | #F59E0B           | Timer clocks, warning flags                               |
+-------------------+-------------------+-----------------------------------------------------------+
| Error             | #EF4444           | Grammar mistakes, logout buttons, destructive actions     |
+-------------------+-------------------+-----------------------------------------------------------+
| Info              | #3B82F6           | Tips overlays, RAG explanations indicators                |
+-------------------+-------------------+-----------------------------------------------------------+
| Background        | #F8FAFC           | Main application background backdrop                      |
+-------------------+-------------------+-----------------------------------------------------------+
| Surface           | #FFFFFF           | Cards, dialog sheets, popups panels                       |
+-------------------+-------------------+-----------------------------------------------------------+
| Text Primary      | #0F172A           | Primary screen headings, standard black copy              |
+-------------------+-------------------+-----------------------------------------------------------+
| Text Secondary    | #64748B           | Captions, dates, secondary descriptions                   |
+-------------------+-------------------+-----------------------------------------------------------+
| Border            | #E2E8F0           | Thin divider lines, cards borders                         |
+-------------------+-------------------+-----------------------------------------------------------+
| Disabled          | #CBD5E1           | Inactive buttons backgrounds, greyed text                 |
+-------------------+-------------------+-----------------------------------------------------------+
```

---

## 5. Dark Mode Tokens

For dark mode, we use an AMOLED-friendly dark palette to save battery life while maintaining readability:
*   `Background`: **#0F172A** (Slate dark background)
*   `Surface`: **#1E293B** (Elevated cards surface)
*   `Card`: **#334155** (Deep slate cards)
*   `Primary`: **#6366F1** (Accessible indigo)
*   `Text`: **#F8FAFC** (Accessible light grey)
*   `Border`: **#475569** (Muted divider line)

---

## 6. Typography Grid

We use the **Inter** font family (with **Roboto** as a fallback for compatibility):

```
+------------------+------------------+------------------+------------------+-----------------------+
| HIERARCHY LEVEL  | SIZE VALUE (px)  | LINE HEIGHT (px) | LETTER SPACING   | FONT WEIGHT           |
+------------------+------------------+------------------+------------------+-----------------------+
| Display          | 48               | 56               | -1.0px           | Bold (700)            |
+------------------+------------------+------------------+------------------+-----------------------+
| H1 (Headers)     | 36               | 44               | -0.5px           | Bold (700)            |
+------------------+------------------+------------------+------------------+-----------------------+
| H2 (Subheaders)  | 30               | 38               | -0.2px           | Semi-Bold (600)       |
+------------------+------------------+------------------+------------------+-----------------------+
| H3 (Cards)       | 24               | 32               | 0.0px            | Semi-Bold (600)       |
+------------------+------------------+------------------+------------------+-----------------------+
| H4 (Tile Headers)| 20               | 28               | 0.0px            | Medium (500)          |
+------------------+------------------+------------------+------------------+-----------------------+
| Body Large       | 18               | 26               | 0.1px            | Regular (400)         |
+------------------+------------------+------------------+------------------+-----------------------+
| Body             | 16               | 24               | 0.1px            | Regular (400)         |
+------------------+------------------+------------------+------------------+-----------------------+
| Caption          | 14               | 20               | 0.2px            | Regular (400)         |
+------------------+------------------+------------------+------------------+-----------------------+
| Small            | 12               | 16               | 0.4px            | Light (300)           |
+------------------+------------------+------------------+------------------+-----------------------+
```

---

## 7. Spacing & Corner Radii

### 7.1 Spacing Scale
Layout spacing must align with a **4px/8px** grid:
*   **4 / 8 / 12 / 16 / 24 / 32 / 40 / 48 / 64 / 96px**

### 7.2 Border Radius Scale
*   `Small` (8px): Inner buttons, tags, checkbox borders.
*   `Medium` (12px): Dialog sheets, text input fields.
*   `Large` (16px): Lessons listings cards, vocabulary flashcards.
*   `XL` (24px): Bottom sheets sheets overlays.
*   `Round` (999px): Streaks flame circles, primary FABs, user profile avatars.

---

## 8. Elevation & Shadows
*   `Level 1 (Cards):` Subtle shadow (`blurRadius: 8, color: rgba(0,0,0,0.04)`) to separate cards from the background.
*   `Level 2 (Dialogs):` Medium shadow (`blurRadius: 16, color: rgba(0,0,0,0.08)`) to emphasize modal overlays.
*   `Level 3 (FABs):` Elevated shadow (`blurRadius: 16, spreadRadius: 2, color: rgba(79,70,229,0.2)`) to highlight main action buttons.

---

## 9. Flutter Design Tokens Code

```dart
// lib/core/constants/design_tokens.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color primary500 = Color(0xff4f46e5);
  static const Color primary600 = Color(0xff4338ca);
  static const Color primary700 = Color(0xff3730a3);
  static const Color secondary = Color(0xff06b6d4);
  static const Color success = Color(0xff22c55e);
  static const Color warning = Color(0xfff59e0b);
  static const Color error = Color(0xffef4444);
  static const Color info = Color(0xff3b82f6);
  static const Color background = Color(0xfff8fafc);
  static const Color surface = Color(0xffffffff);
  static const Color textPrimary = Color(0xff0f172a);
  static const Color textSecondary = Color(0xff64748b);
  static const Color border = Color(0xffe2e8f0);
}
```

---

## 10. Core Reusable Component Layouts

### 10.1 Button States
*   **Primary Button (Filled):** Height **48dp**, rounded corners (8px), Primary 500 background.
*   **Secondary Button (Outlined):** Height **48dp**, rounded corners (8px), transparent background with a 1.5px Primary 500 border.
*   **Tertiary Button (Text Link):** Plain text, no borders or background colors.
*   **Disabled State:** Grey background (#CBD5E1), muted text (#64748B), pointer inputs disabled.

### 10.2 Input Fields
*   **States:**
    *   *Default:* Light grey border (#E2E8F0) with secondary placeholder labels.
    *   *Focused:* 2px Primary 500 border (#4F46E5), label shifts upwards.
    *   *Error:* 2px Red border (#EF4444), error text displayed below the field.

### 10.3 Card Configurations
*   **Lesson Cards:** Horizontal layout containing a progress bar, difficulty badge, and title.
*   **Vocabulary SRS Cards:** Card widget with a 16px corner radius, display term, and translation trigger.

---

## 11. Screen Layout Components

### 11.1 Dashboard Widgets
*   **Streak Circle:** A circular dial showing target study minutes completed.
*   **Score Chart:** Line graph showing score trends across weeks.

### 11.2 AI Chat Screen
*   **User Message Bubble:** Right-aligned, dark slate blue background (#0F172A), white text.
*   **AI Message Bubble:** Left-aligned, white background (#FFFFFF / #1E293B), dark primary text.
*   **Grammar Feedback Card:** Appears as a slide-up sheet showing correction details.
*   **Translation Toggle:** Inline toggle switch to display Malayalam translations.

### 11.3 Voice Screen
*   **AI Avatar:** A central glowing circle that pulses to reflect speaking volume.
*   **Live Waveform:** Real-time audio waveform (blue curves for AI speaking, green curves for user speaking).
*   **End Call Action:** A red button (#EF4444) located bottom-center.

---

## 12. Micro-Interactions & Animations
*   **Confetti Triggers:** Celebrate lesson completions, mock exam submissions, and daily streak milestones with on-screen confetti.
*   **App Transition Pacing:** Standard screen slide/fade transitions must execute within **200ms to 350ms** to keep the interface feeling responsive.
*   **Haptic Mapping:** Trigger light haptics on button taps, and medium haptics on correct quiz answers.

---

## 13. Accessibility SLAs (WCAG 2.1 AA)
*   **Touch Targets:** Interactive components must maintain minimum dimensions of **48 x 48dp**.
*   **Screen Readers:** All images and icons must include descriptive label semantics.
*   **Contrast Levels:** Primary text and icons must maintain a minimum contrast ratio of **4.5:1** against backgrounds.

---

## 14. Responsive Layout Breakpoints
*   **Small Phones (0–399dp):** 4 columns grid, 16dp outer screen margins.
*   **Large Phones & Tablets (400–1023dp):** 8 columns grid, 32dp outer margins, split-screen layouts active.
*   **Foldables / Desktop (1024dp+):** 12 columns grid.

---

## 15. UI States (Empty, Loading, Error)
*   **Empty State:** Displays a simple illustration, a helpful message (e.g., *"No completed lessons yet"*), and a primary CTA button (e.g., `[Start Learning]`).
*   **Loading State:** Use shimmers (grey skeleton loaders) for list views to prevent blank screens during queries.
*   **Error State:** Displays an error icon, a friendly error message, and a retry button. Avoid technical jargon.

---

## 16. UI/UX Design System Checklist

Verify components against this checklist before production release:
*   [ ] Does the component support both Light and Dark themes?
*   [ ] Do interactive elements have touch targets of at least 48 x 48dp?
*   [ ] Are contrast ratios WCAG AA compliant (>4.5:1)?
*   [ ] Do lists and dashboards display shimmer loading states?
*   [ ] Do empty screen states feature an illustration and a clear call-to-action (CTA)?
*   [ ] Have layout paddings been tested for responsiveness across screen aspect ratios?
*   [ ] Does the UI match its corresponding Figma component tokens?
