# Figma Wireframes & Screen Specifications: AI Language Coach
**Version:** 1.0  
**Status:** Production  
**Target Environment:** Figma Design Canvas, Flutter Mobile Views  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the wireframe layouts, structural components, bottom navigation setups, user flows, and modal configurations for **AI Language Coach**. 

It provides designers and developers with a detailed visual blueprint for all 20+ application screens to align implementations and ensure consistent styling.

---

## 2. Navigation Architecture
The mobile application shell uses a persistent bottom navigation bar coupled with a floating action button (FAB) for voice call shortcuts:
*   🏠 **Home Hub:** Today's target targets, daily goals, and tasks list.
*   💬 **Practice:** Syllabuses, spelling lists, and writing logs.
*   📊 **Progress:** Weekly metrics trends, charts, and test score bands.
*   🏆 **Achievements:** Badges grids, streaks flame indicator, and leaderboards.
*   👤 **Profile:** Settings configurations and subscription gating cards.
*   🎤 **Primary Action (FAB):** Floating speaking icon to trigger a voice call session.

---

## 3. Core Screen Blueprints

### 3.1 Splash Screen
*   **Layout:** Centralized logo and brand typography.
*   **Components:**
    *   *Header:* None.
    *   *Body:* Center aligned logo, app title, version text.
    *   *Footer:* Circular progress indicator shimmer.

### 3.2 Welcome Screen
*   **Layout:** Hero illustration, value propositions, and onboarding action CTAs.
*   **Components:**
    *   *Body:* Illustration showing conversational speech bubbled graphics.
    *   *Footer:* Large `[Get Started]` primary button, and `[Login]` tertiary link.

### 3.3 Authentication (Login & Signup)
*   **Login View:**
    *   *Fields:* Email (AppTextField), Password (AppTextField with hide/reveal suffix icon).
    *   *Links:* `[Forgot Password?]` tertiary link.
    *   *Actions:* `[Login]` primary button, and OAuth sign-in buttons (Google, Apple).
*   **Signup View:**
    *   *Fields:* Name, Email, Password, Confirm Password text inputs.
    *   *Actions:* `[Create Account]` primary button.

### 3.4 Onboarding Wizard (5 Screens)
*   **Layout:** Top-aligned linear progress bar tracking steps progress.
*   *Screen 1 (Welcome Onboarding):* Brief introductory copy.
*   *Screen 2 (Native Language L1 selection):* Dropdown card highlighting Malayalam.
*   *Screen 3 (Target Language L2 selection):* Interactive check cards for English and German.
*   *Screen 4 (Target Goal):* Select exam modules (IELTS, PTE, Goethe, Conversational).
*   *Screen 5 (Daily Study Goal):* Select target duration slots (15m, 30m, 45m, 60m).

### 3.5 Placement Diagnostic Test
*   **Sections:** collapsable list for Grammar, Vocabulary, Listening, and Writing.
*   **Diagnostics Results Card:** Displays calculated CEFR levels (e.g., B1), lists of weak areas, and a `[Confirm Plan]` CTA.

---

## 4. Interactive Learning Screens

### 4.1 Dashboard Layout
*   *Header:* User profile avatar, current streak flame, and daily goals dial.
*   *Body:* `[Today's Recommended Lesson]` primary card CTA.
*   *Quick Actions Grid:* `[Vocabulary SRS]`, `[Grammar Log]`, `[Mock Exam]` tiles.
*   *Footer:* Collapsible list of unlocked badges.

### 4.2 AI Chat Screen
*   *App Bar:* Tutor avatar details, connection status dot, and Malayalam translation toggle.
*   *Body:* Alternating scrollable message bubbles:
    *   *User Bubbles:* Right-aligned, dark slate blue background.
    *   *AI Bubbles:* Left-aligned, white/light grey background.
*   *Dotted Highlight:* Grammatical errors are highlighted inline with a dotted underline. Tapping a flagged word overlays a slide-up grammar card sheet showing details.
*   *Footer Input Bar:* Keyboard toggle icon, text input box, and microphone button.

### 4.3 Live Voice Screen
*   *Body:* Glowing pulsing circular avatar, audio waveforms (blue lines for AI, green lines for user), timer overlay.
*   *Overlay:* Real-time subtitles text box.
*   *Footer Panel:* Mute mic toggle, end call red button, speaker toggle.

### 4.4 Lesson Screen
*   *Header:* Progress bar indicator.
*   *Body:* Lesson cards displaying quiz questions, and translation triggers.
*   *Footer:* `[Check Answer]` and `[Continue]` action buttons.

### 4.5 Vocabulary SRS Cards
*   *Front:* Target vocabulary word, phonetic transliteration, audio play icon.
*   *Back:* Meaning definition, Malayalam translation scaffolding guide, synonyms list.
*   *Action bar:* SRS interval ratings keys (`Hard`, `Good`, `Easy`).

### 4.6 Mock Exam Interface
*   *App Bar:* Countdown timer. Flashes in red when less than 2 minutes remain.
*   *Body:* Standard test sections, writing text editors, and word counter logs.
*   *Footer:* Double-confirmation `[Submit Exam]` dialog trigger.

---

## 5. UI States (Empty, Loading, Errors, Modals)

*   **Empty State:** Displays a simple illustration, a helpful message (e.g., *"No completed lessons yet"*), and a primary CTA button (e.g., `[Start Learning]`).
*   **Loading State:** Use shimmers (grey skeleton loaders) for list views to prevent blank screens during queries.
*   **Error State:** Displays an error icon, a friendly error message, and a retry button. Avoid technical jargon.
*   **Modal Dialogs:** Rounded overlay dialog boxes with double-confirmation CTAs (e.g., `[Exit Exam]`, `[Upgrade Plan]`).

---

## 6. Comprehensive User Flow Diagram (ASCII)

```text
  [Splash Screen]
         |
         v
  [Welcome Screen] ---> [Login / Signup]
                              |
                              v
                       [Onboarding Steps]
                              |
                              v
                     [Placement Diagnostic]
                              |
                              v
                      [Home Dashboard]
                              |
           +------------------+------------------+
           |                  |                  |
           v                  v                  v
     [Study Path]        [AI Chat]         [Voice Room]
           |                  |                  |
           v                  v                  v
     [Lesson Quiz]       [Grammar Card]    [Speech Evaluation]
           |                  |                  |
           +------------------+------------------+
                              |
                              v
                     [Progress / League]
```

---

## 7. Figma Project Canvas Setup
Manage your assets in these dedicated pages:
*   `01 Foundations:` Brand grids, Material 3 typography hierarchies, spacing scales.
*   `02 Components:` Buttons states, inputs fields, list cards templates.
*   `03 Authentication & Onboarding:` Screen layouts.
*   `04 Main Screens:` Dashboard widgets, AI chat bubbles, LiveKit waveform screens.
*   `05 Mock Exams & Diagnostic Results:` Writing editors, timer overlays.
*   `06 Prototypes:` Dynamic interactions, swipe actions, transition speeds.

---

## 8. Figma Wireframes Checklist

Verify wireframe designs against this checklist before code implementation:
*   [ ] Do all interactive elements have touch targets of at least 48 x 48dp?
*   [ ] Does the navigation structure support persistent bottom nav bars?
*   [ ] Do chat interfaces display User bubbles on the right and AI bubbles on the left?
*   [ ] Is the countdown exam timer configured to flash red?
*   [ ] Have empty and loading states been designed for all lists and dashboards?
*   [ ] Do modal dialogs enforce double-confirmation dialog screens?
*   [ ] Are figma canvas files organized according to foundations and component pages?
*   [ ] Has dark mode support been verified across OLED devices?
