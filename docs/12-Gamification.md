# Gamification & Engagement Mechanics: AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Target Environment:** Flutter Client, Supabase PostgreSQL Triggers  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the experience points (XP) rewards, level progression models, daily streak validation logic, competitive league brackets, unlockable achievements, and UI micro-interactions for **AI Language Coach**. 

These systems are designed to improve user retention, encourage consistent daily study habits, and provide visual indicators of language proficiency.

---

## 2. Experience Points (XP) Allocation Matrix

XP measures effort and consistency. Points are awarded upon completing the following actions:

```
+---------------------------+---------------+-----------------------------------+-------------------------------------------+
| USER ACTION               | BASE XP       | MULTIPLIERS / BONUSES             | DESCRIPTION & SYSTEM ROLE                 |
+---------------------------+---------------+-----------------------------------+-------------------------------------------+
| Lesson Completed          | 50 XP         | +10 XP (Perfect Score)            | Standard lesson completion                |
+---------------------------+---------------+-----------------------------------+-------------------------------------------+
| SRS Vocabulary Quiz       | 20 XP         | None                              | Reviewing flashcard decks                 |
+---------------------------+---------------+-----------------------------------+-------------------------------------------+
| Conversational Chat       | 15 XP         | +5 XP (No grammar errors)         | Per chat message (capped at 150 XP/day)   |
+---------------------------+---------------+-----------------------------------+-------------------------------------------+
| LiveKit Voice Call        | 10 XP/min     | None                              | Spoken practice (capped at 100 XP/day)    |
+---------------------------+---------------+-----------------------------------+-------------------------------------------+
| Timed Mock Exam           | 200 XP        | None                              | Completed IELTS/PTE mock diagnostic test  |
+---------------------------+---------------+-----------------------------------+-------------------------------------------+
| Daily Target Met          | 100 XP        | +50 XP (7-Day Streak active)      | Completed target study minutes            |
+---------------------------+---------------+-----------------------------------+-------------------------------------------+
```

---

## 3. Level Progression Curve
Level requirements scale progressively using a quadratic growth formula:

$$\text{Required XP for Level } N = 100 \times N^2$$

### Level Threshold Examples:
*   **Level 1 to 2:** 100 XP
*   **Level 2 to 3:** 400 XP
*   **Level 3 to 4:** 900 XP
*   **Level 4 to 5:** 1,600 XP
*   **Level 10 to 11:** 10,000 XP

Upon reaching a new level, the client displays a **Level Up Card** modal overlay with celebratory confetti and haptic feedback.

---

## 4. Daily Streaks & Streak Freezes
Consistent practice is key to language learning. The streak engine tracks consecutive active days:
*   **Streak Increment:** Triggered when the user earns their first XP of the day.
*   **Streak Freeze:** If a user misses a day, a streak freeze is automatically consumed to protect their streak.
    *   *Free Plan:* Maximum **1** streak freeze slot. Can be purchased for **500 XP**.
    *   *Premium Plan:* Maximum **3** streak freeze slots. Can be purchased for **300 XP** or through in-app purchases.
*   **Database Trigger:** A daily cron job checks active user sessions at midnight (user's local timezone). If no activity is recorded and no streak freezes are available, the streak count is reset to **0**.

---

## 5. Weekly Leagues & Competitive Leaderboards
Users are placed in competitive leaderboards of **30 users** at similar levels. The league reset occurs every **Sunday at 23:59:59 UTC**.

```
  [1. Bronze] ---> [2. Silver] ---> [3. Gold] ---> [4. Platinum] ---> [5. Diamond]
```

### League Progression Rules:
*   **Promotion Zone:** The top 10 users in a leaderboard are promoted to the next league tier.
*   **Safe Zone:** Users ranked 11th to 25th remain in their current league tier.
*   **Demotion Zone:** The bottom 5 users are demoted to the previous league tier (except in the Bronze league).
*   **Diamond League:** The highest tier. The top 3 users in a Diamond leaderboard receive premium profile badges.

---

## 6. Achievements & Badges Catalog

Achievements reward specific milestones:

```
+-------------------+---------------------------------------+-------------------+---------------------------------------+
| BADGE ID          | TITLE & LOGO DETAILS                  | XP REWARD         | UNLOCK CONDITION                      |
+-------------------+---------------------------------------+-------------------+---------------------------------------+
| Rookie Speaker    | Rookie Speaker (Bronze Mic)           | 100 XP            | Complete 1st LiveKit voice session    |
+-------------------+---------------------------------------+-------------------+---------------------------------------+
| Grammar Master    | Grammatic Master (Gold Quill)         | 250 XP            | Complete 50 grammar correction checks |
+-------------------+---------------------------------------+-------------------+---------------------------------------+
| Polyglot          | Polyglot (Globe Icon)                 | 500 XP            | Study 2 target languages              |
+-------------------+---------------------------------------+-------------------+---------------------------------------+
| Vocab Guru        | Vocab Guru (Book Icon)                | 300 XP            | Master 100 vocabulary cards in SRS    |
+-------------------+---------------------------------------+-------------------+---------------------------------------+
| Timed Warrior     | Timed Warrior (Clock Icon)            | 400 XP            | Submit 5 mock timed examinations      |
+-------------------+---------------------------------------+-------------------+---------------------------------------+
| Persistence       | Persistence (Flame Icon)              | 1,000 XP          | Maintain a 30-day study streak        |
+-------------------+---------------------------------------+-------------------+---------------------------------------+
```

---

## 7. Gamification UI Widgets & Components
*   **Streak Indicator:** Animated flame icon on the dashboard displaying the active streak count. The flame glows when the daily study goal is met.
*   **XP Progress Bar:** A linear progress bar at the top of the dashboard showing progress toward the next level.
*   **League Rank Tile:** Displays the user's current league division (e.g., "Gold League") and their ranking in the active leaderboard.

---

## 8. Gamification Checklist

Verify gamified features against this checklist before production release:
*   [ ] Does the XP database trigger award points correctly across all activities?
*   [ ] Do level thresholds scale according to the quadratic progression formula?
*   [ ] Does the midnight database trigger consume streak freezes correctly?
*   [ ] Do streak counters reset to 0 if a day is missed without freezes?
*   [ ] Are weekly leaderboards reset and promotions processed every Sunday?
*   [ ] Do unlocked badges add the correct XP awards to profiles?
*   [ ] Are confetti and haptic feedbacks triggered upon level-ups and exam submissions?
