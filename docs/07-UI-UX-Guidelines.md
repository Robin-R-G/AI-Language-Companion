# UI/UX Design Guidelines: AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Design Standard:** Material 3 Compliance  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the visual language, interactive layouts, typography parameters, color palettes, micro-interactions, and accessibility standards for the **AI Language Coach** mobile client. 

These specifications ensure visual consistency across developers and designers, resulting in a cohesive experience on both Android and iOS devices.

---

## 2. Design Philosophy
Learning a new language is mentally taxing and can induce performance anxiety, particularly during speaking drills. The visual environment of AI Language Coach must counteract this by creating a calm, encouraging, and distraction-free interface.

### Design Principles:
*   **Clean:** Keep screens uncluttered. Prioritize whitespace to give structural breathing room.
*   **Calm:** Use soft background tones and rounded cards to reduce stress.
*   **Intelligent:** Ensure information is highly organized, displaying details only when needed.
*   **Minimal:** Restrict actions on a single screen to one primary call-to-action (CTA) to reduce cognitive load.
*   **Motivational:** Visually celebrate micro-successes (like streak increases or lesson completions) using animations.

---

## 3. Core Design Principles

1.  **Simplicity First:** Avoid visual clutter. Hide complex configuration options behind menus, leaving core actions clean and visible.
2.  **Visible Progression:** Integrate progress indicators (daily streak dials, XP points, progress bars) across all major screens to reinforce consistency.
3.  **Humanized AI Persona:** Establish tutor personas with friendly illustrations and supportive language, avoiding mechanical error indicators.
4.  **Effortless Path to Practice:** Ensure users can launch their daily speaking practice in less than two taps from the home screen.

---

## 4. Main Navigation Structure

The app shell uses a persistent bottom navigation bar coupled with a floating action button (FAB) for voice call shortcuts.

### Bottom Navigation Tabs:
*   🏠 **Home Hub:** Today's tasks, daily mission lists, and quick-start guides.
*   💬 **Practice:** Access to the lesson catalog, reading inputs, and writing evaluations.
*   📊 **Progress:** Weekly charts, grammar error logs, and predicted exam scores.
*   🏆 **Achievements:** League ranks, badges catalog, and shareable certificates.
*   👤 **Profile:** Personal settings, native language parameters, and subscriptions.

### Floating Action Button (FAB):
*   🎤 **Primary Action:** "Start Speaking" voice call trigger.
*   **Design:** Located bottom-center or bottom-right, using an elevated circles shape with the primary accent color.

---

## 5. Home Screen Layout

The home screen acts as the user's daily control hub, structured vertically:

```
+--------------------------------------------------------+
|  [Greeting & Streak Card]                              |
|  "Hi, Rahul! 🔥 5-Day Streak"                          |
+--------------------------------------------------------+
|  [Today's Target Progress Indicator]                   |
|  [=== 15m Practiced / 20m Goal ===]                    |
+--------------------------------------------------------+
|  [Today's Mission Card]                                |
|  "Mock IELTS Speaking Topic: Travel"                   |
|  [Start Daily Lesson Button - Primary CTA]             |
+--------------------------------------------------------+
|  [Quick Actions Grid]                                  |
|  [ Vocabulary SRS ]  [ Grammar Log ]  [ Mock Exam ]    |
+--------------------------------------------------------+
|  [Daily Motivational Quote Card]                       |
|  "Your language skills are opening new doors!"         |
+--------------------------------------------------------+
```

---

## 6. Onboarding Flow

Onboarding is structured as a sequential progress wizard. Each screen displays a top linear progress indicator showing active completion status:

```
  1. Welcome Screen (Value proposition, branding illustration)
                       |
                       v
  2. Native Language (L1 selection dropdown - Malayalam spotlighted)
                       |
                       v
  3. Learning Language (L2 target selection cards)
                       |
                       v
  4. Proficiency Level (Beginner, Intermediate, Advanced CEFR options)
                       |
                       v
  5. Goal Type (Exam prep target selection: e.g., IELTS, OET, General)
                       |
                       v
  6. Study Commitment (Select daily allocation: 10, 20, 40, or 60 minutes)
                       |
                       v
  7. Tutor Persona Selection (Select AI coach character archetype)
                       |
                       v
  8. AI Diagnostic Call (Optional 3-minute voice test setup) ---> HOME
```

---

## 7. AI Chat Interface

*   **Conversation Logs:** Messages appear as alternating bubbles. User inputs align to the right (Slate background), and AI responses align to the left (White/Light surface background).
*   **Grammar Corrections:** Grammatical errors are highlighted inline with a dotted underline. Tapping the word overlays a slide-up sheet displaying the correction details.
*   **Interactive Input Bar:** Enforces a clean bottom alignment containing:
    *   *Left:* Keyboard toggle.
    *   *Center:* Text input field.
    *   *Right:* Mic icon (held to record or tapped to open voice call session).
    *   *Translation Switch:* A toggle overlay allowing users to instantly view their native Malayalam translation card.

---

## 8. Voice Call Interface

The Voice Call Screen is designed to be clean and distraction-free, minimizing visual noise so the user can focus on speaking:

```
+--------------------------------------------------------+
|  [Back to Chat Close Button]             [Voice speed] |
+--------------------------------------------------------+
|                                                        |
|                     [Tutor Avatar]                     |
|                                                        |
|                [Real-time Audio Wave]                  |
|                 (Active input curves)                  |
|                                                        |
+--------------------------------------------------------+
|  [Real-time Subtitle / Transcript Card Overlay]         |
|  "AI: Tell me about your hometown, Rahul..."           |
+--------------------------------------------------------+
|  [Call Actions Panel]                                  |
|  [Mute Button]      [End Call (Red)]      [Speaker Toggle] |
+--------------------------------------------------------+
```

### Visual Audio Wave Components:
*   *AI Speaking:* Smooth, wave lines in primary blue (#2563EB) dynamically adjusting to the voice frequency.
*   *User Speaking:* Active green (#22C55E) wave lines showing audio inputs.
*   *Silent State:* Faded flat lines showing the connection is listening.

---

## 9. Dashboard Analytics

*   **KPI Cards:** Display study times, grammar correction counts, and active vocabulary cards in a grid layout.
*   **Exam Score Predictor:** A prominent circular dial chart at the top showing estimated exam scores (e.g., IELTS Band 7.0).
*   **Trend Graphs:** Line charts plotting scores across weeks, with tooltips displaying study metrics upon tapping data nodes.

---

## 10. Lesson Screen Layout
*   **Header Module:** Displays difficulty badges (e.g., CEFR B2), estimated time, and a progress bar.
*   **Exercise Cards:** Clean, white cards containing questions, clear choice buttons, and translation triggers.
*   **Reward Grids:** Upon completion, display congratulatory messages alongside XP point animations.

---

## 11. Vocabulary SRS Cards
*   **SRS Card Interface:** Card widgets use a clean 16px corner radius.
*   **Front Side:** Target word, phonetic script, and an audio play button.
*   **Back Side:** Meaning, Malayalam translation, and example sentences.
*   **Action Keys:** Clean rating buttons (e.g., "Hard", "Good", "Easy") positioned at the bottom of the card to update review intervals.

---

## 12. Grammar Screen Layout
*   **Syllabus Cards:** Highlight the active grammatical rule (e.g., Subject-Verb Agreement) followed by comparative Malayalam logic panels.
*   **Malayalam Scaffold Guides:** Highlight comparative rule structures:
    *   *English:* **Subject + Verb + Object**
    *   *Malayalam:* **Subject + Object + Verb**
*   **Mistakes log:** Highlight past errors in a collapsible checklist.

---

## 13. Mock Exam Interface
*   **Lockdown Theme:** Visual frame changes to slate grey.
*   **Timer Display:** A countdown clock is displayed in the upper-right corner. It flashes in red when less than 2 minutes remain.
*   **Exam Controls:** The pause button is disabled during exams to ensure realistic testing conditions.
*   **Submit Action:** Enforce double-confirmation dialog screens before final submission.

---

## 14. Achievement Dashboard
*   **Badges Matrix:** Clean grid of earned (colorized) and locked (greyed-out) badges.
*   **League Standings:** Vertical leaderboard displaying user ranks, profile avatars, and weekly XP numbers.

---

## 15. User Profile Screen
*   **Avatar Section:** Large circular profile image with active streak and subscription badges.
*   **Option Lists:** Vertical list tiles for settings (App config, Languages, Subscriptions, GDPR Privacy data wipe, Log out).

---

## 16. Color System

The interface uses a curated, accessible color palette built for Material 3.

```
+-----------------------------------+-----------------------------------+---------------------------+
| DESIGN SYSTEM TOKEN               | HEX VALUE CODE                    | USAGE ROLE                |
+-----------------------------------+-----------------------------------+---------------------------+
| Primary Color                     | #2563EB                           | Core branding, primary    |
|                                   |                                   | CTAs, active indicators   |
+-----------------------------------+-----------------------------------+---------------------------+
| Secondary Color                   | #7C3AED                           | Focus paths, highlights   |
+-----------------------------------+-----------------------------------+---------------------------+
| Accent Color                      | #22C55E                           | Success state, streaks    |
+-----------------------------------+-----------------------------------+---------------------------+
| Warning Color                     | #F59E0B                           | Milestones, notifications |
+-----------------------------------+-----------------------------------+---------------------------+
| Error Color                       | #EF4444                           | Corrections, warnings     |
+-----------------------------------+-----------------------------------+---------------------------+
| Background Light                  | #F8FAFC                           | Standard app background   |
+-----------------------------------+-----------------------------------+---------------------------+
| Background Dark (AMOLED)          | #0F172A                           | Dark theme background     |
+-----------------------------------+-----------------------------------+---------------------------+
| Surface Color                     | #FFFFFF                           | Cards, dialogues, menus   |
+-----------------------------------+-----------------------------------+---------------------------+
| Text Primary                      | #111827                           | Primary title body copy   |
+-----------------------------------+-----------------------------------+---------------------------+
| Text Secondary                    | #6B7280                           | Secondary captions, dates |
+-----------------------------------+-----------------------------------+---------------------------+
```

### Contrast Compliance:
Light and dark text must maintain a minimum contrast ratio of **4.5:1** against backgrounds, conforming to WCAG 2.1 AA accessibility standards.

---

## 17. Typography Specification

The typography system uses the **Inter** font family (with **SF Pro** as a fallback for iOS).

```
+------------------+------------------+------------------+------------------+-----------------------+
| STYLE NAME       | FONT SIZE (px)   | WEIGHT PROFILE   | LINE HEIGHT (px) | CONTEXT ROLE          |
+------------------+------------------+------------------+------------------+-----------------------+
| Display          | 32               | Bold (700)       | 40               | Splash headers, streak|
+------------------+------------------+------------------+------------------+-----------------------+
| Heading 1        | 24               | Bold (700)       | 32               | Screen page headers   |
+------------------+------------------+------------------+------------------+-----------------------+
| Title            | 20               | Semi-Bold (600)  | 28               | Cards, dialog titles  |
+------------------+------------------+------------------+------------------+-----------------------+
| Subtitle         | 16               | Medium (500)     | 24               | Section summaries     |
+------------------+------------------+------------------+------------------+-----------------------+
| Body Copy        | 14               | Regular (400)    | 20               | General reads, logs   |
+------------------+------------------+------------------+------------------+-----------------------+
| Caption          | 12               | Light (300)      | 16               | Dynamic dates, stamps |
+------------------+------------------+------------------+------------------+-----------------------+
| Button Text      | 14               | Semi-Bold (600)  | 20               | Buttons labels        |
+------------------+------------------+------------------+------------------+-----------------------+
```

---

## 18. Iconography
*   **Icon Family:** *Material Symbols Rounded*.
*   **Sizing:**
    *   Standard UI elements: **24dp**.
    *   Small listings: **18dp**.
    *   Primary action icons: **32dp**.

---

## 19. Button Configurations
*   **Primary Button:** Filled color background (#2563EB), white text, 8px corner radius. Used for main actions (e.g., "Start Lesson").
*   **Secondary Button:** Outlined border (1.5px, #2563EB), transparent surface, colored text. Used for alternative options (e.g., "Review Mistakes").
*   **Tertiary Button:** Plain text link, no border/background. Used for low-priority actions (e.g., "Skip Onboarding").
*   **Disabled State:** Solid grey background (#E2E8F0), dark grey text (#94A3B8), pointer inputs disabled.

---

## 20. Card Configurations
*   **Corner Radius:** **16px** (smooth, rounded aesthetics).
*   **Shadow Details:** Low elevation shadow (`blurRadius: 8, color: rgba(0,0,0,0.05)`) to maintain a clean flat-design look.
*   **Padding:** Default layout padding is **16px** on small screens and **20px** on tablets.

---

## 21. Animation Guidelines
*   **Transition Speeds:** Standard transitions must execute within **150ms to 300ms** to ensure the interface feels responsive.
*   **Transition Patterns:**
    *   *Page transitions:* Slide left/right or soft fade.
    *   *Card expansions:* Smooth scaling from the center point.
    *   *Lottie assets:* Use selectively to prevent performance bottlenecks.

---

## 22. Micro-Interactions
*   **Success Triggers:** Streak completions, mock exam submits, and badge unlocks must trigger card confetti animations.
*   **Haptic Patterns:** Emit brief haptic vibrations when keys are tapped, or answers are validated.

---

## 23. Empty States

Empty screens must never display blank pages. They must include:
1.  An illustration or icon explaining why the screen is empty.
2.  A clear message (e.g., *"No conversations yet."*).
3.  A single primary CTA button routing the user to resolve the state (e.g., `[Start Practice]`).

---

## 24. Loading States
Never show frozen or unrendered screens.
*   **Shimmer Elements:** Lists, dashboards, and profile fields must use animated grey skeleton containers (shimmers) while queries run.
*   **Progress Indicators:** Asynchronous operations (like audio rendering or payment checks) must overlay circular progress indicator animations.

---

## 25. Error States
*   **Error Layouts:** Displays error icons, brief descriptions of the issue, and primary retry buttons.
*   *Example:* *"We couldn't load your lesson. Please verify your connection."* `[Retry]`.

---

## 26. Accessibility Requirements
*   **Touch Targets:** Interactive targets (buttons, inputs, sliders) must maintain minimum dimensions of **48 x 48dp** to accommodate users with varying motor control.
*   **Screen Reader Semantics:** Every image and interactive icon must include descriptive label semantics.
*   **Contrast Levels:** Colored components must maintain WCAG AA contrast standards.

---

## 27. Responsive Layout Rules
*   **Adaptive Layout Grids:** Standard screen margins must scale dynamically:
    *   *Phones:* **16dp**.
    *   *Tablets/Foldables:* **32dp** (using split-screen layout configurations).

---

## 28. Dark Theme Standards
*   **AMOLED Friendly:** Dark mode must use a dark background (#0F172A) instead of plain black to save battery life on OLED screens while maintaining readability.
*   **Automation:** App configurations must adapt automatically to match active system preferences.

---

## 29. AI Persona Style
AI responses must be supportive and clear. Corrective reviews must avoid red, warning-style callouts, using instead soft informational cards to protect user motivation and confidence.

---

## 30. Gamification UX
*   **Daily Goals Display:** Dials indicating the daily target minutes completed.
*   **Streak counters:** Flame icons that animate when the day's study tasks are finalized.

---

## 31. Notification Banners
Reminders must be personal and actionable, routing users directly to active lesson pathways upon tapping.

---

## 32. Premium Experience
Premium actions must display refined gold elements (#F59E0B) and custom badges to distinguish Pro accounts.

---

## 33. Spacing Scale

The spacing scale enforces consistency across layouts:
*   **4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48dp** (enforcing 4dp and 8dp layouts grids).

---

## 34. UX Performance Metrics
*   Target a lesson completion rate of **>80%**.
*   Maintain a cold boot app launch time of **under 3 seconds**.

---

## 35. Design System Checklist

Validate visual assets against this checklist before merging:
*   [ ] Does the contrast ratio of all text meet WCAG AA standards?
*   [ ] Do all interactive elements have touch targets of at least 48 x 48dp?
*   [ ] Do empty screen states feature an illustration and a clear call-to-action (CTA)?
*   [ ] Do lists and dashboards display shimmer loading states?
*   [ ] Has dark mode been checked on active OLED devices?
*   [ ] Are layout paddings consistent across varying screen aspect ratios?
