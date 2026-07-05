# AI Language Coach
# Design System

Version: 1.0
Status: Production
Last Updated: July 2026

---

# 1. Purpose

The Design System defines the visual language, interaction principles, accessibility standards, and reusable UI foundations for AI Language Coach.

Its goals are to:

- Maintain visual consistency
- Improve usability
- Accelerate development
- Ensure accessibility
- Support multiple platforms
- Create a premium learning experience

Every screen, component, and interaction must follow this document.

---

# 2. Design Principles

The UI should be:

- Clean
- Modern
- Educational
- Minimal
- Friendly
- Fast
- Accessible
- Consistent
- Professional

Avoid unnecessary visual clutter.

---

# 3. Design Philosophy

The interface should encourage learning by:

- Reducing cognitive load
- Highlighting important actions
- Providing clear feedback
- Maintaining consistent layouts
- Using meaningful animations
- Supporting focus and concentration

---

# 4. Platform Support

Design for:

- Android
- iOS
- Web
- Tablet
- Desktop
- Foldables

Use adaptive layouts rather than separate designs whenever possible.

---

# 5. Color System

Primary

- Primary
- Primary Container
- On Primary

Secondary

- Secondary
- Secondary Container
- On Secondary

Neutral

- Background
- Surface
- Surface Variant
- Outline

Feedback

- Success
- Warning
- Error
- Info

Maintain WCAG-compliant contrast ratios.

---

# 6. Typography

Use a modern sans-serif font.

Hierarchy:

Display

Headline

Title

Body

Label

Caption

Support dynamic font scaling for accessibility.

---

# 7. Spacing System

Base unit:

```
4dp
```

Common spacing:

```
4
8
12
16
20
24
32
40
48
64
```

Avoid arbitrary spacing values.

---

# 8. Grid System

Use:

- 8dp grid
- Responsive columns
- Safe areas
- Consistent gutters
- Adaptive margins

---

# 9. Border Radius

Small

```
8dp
```

Medium

```
12dp
```

Large

```
16dp
```

Extra Large

```
24dp
```

Use consistent corner styles throughout the application.

---

# 10. Elevation

Define standard elevation levels:

- Flat
- Low
- Medium
- High
- Modal

Use shadows sparingly.

---

# 11. Icons

Use one consistent icon family.

Requirements:

- Rounded style
- Consistent stroke width
- Scalable
- Accessible labels

Avoid mixing icon styles.

---

# 12. Buttons

Support:

- Primary
- Secondary
- Outlined
- Text
- Icon
- Floating
- Voice Action

Each button includes:

- Hover
- Focus
- Pressed
- Disabled
- Loading

---

# 13. Inputs

All inputs should include:

- Labels
- Placeholders
- Helper text
- Validation
- Error messages
- Success indicators
- Accessibility labels

---

# 14. Cards

Standard card styles:

Lesson

Vocabulary

Grammar

Exam

Analytics

Progress

AI Chat

Achievement

Subscription

Cards should share consistent spacing and elevation.

---

# 15. Navigation

Support:

Bottom Navigation

Navigation Rail

Sidebar

Top App Bar

Tabs

Breadcrumbs

Navigation should adapt to screen size.

---

# 16. Motion

Animation principles:

- Purposeful
- Fast
- Smooth
- Consistent

Preferred durations:

100ms

200ms

300ms

500ms

Avoid distracting animations.

---

# 17. Microinteractions

Include:

Button feedback

Swipe gestures

Progress updates

Voice indicators

Typing animations

Achievement celebrations

Loading transitions

---

# 18. Dark Mode

Support:

- Light Theme
- Dark Theme
- High Contrast Theme

All components must automatically adapt.

---

# 19. Accessibility

Support:

- Screen readers
- Keyboard navigation
- VoiceOver
- TalkBack
- Dynamic text
- Reduced motion
- High contrast
- Semantic labels
- Focus order

Meet WCAG 2.2 AA standards where practical.

---

# 20. Responsive Breakpoints

Suggested widths:

Mobile

0–599dp

Tablet

600–1023dp

Desktop

1024dp+

Large Desktop

1440dp+

Layouts should adapt fluidly between breakpoints.

---

# 21. Empty States

Every empty state should include:

- Friendly illustration or icon
- Clear explanation
- Recommended action
- Primary CTA

---

# 22. Error States

Every error state should provide:

- Human-readable message
- Retry action
- Support link (where appropriate)
- Logging behind the scenes

Avoid exposing technical errors to users.

---

# 23. Loading States

Use:

- Skeleton loaders
- Progress indicators
- Shimmer effects
- Streaming indicators

Avoid blank screens during loading.

---

# 24. Internationalization

Design must support:

- Right-to-left languages
- Variable text lengths
- Locale-specific formatting
- Unicode fonts

Avoid fixed-width text containers.

---

# 25. Quality Standards

Every screen should be:

- Pixel-consistent
- Responsive
- Accessible
- Theme-aware
- Performance-optimized
- Easy to maintain

---

# 26. Definition of Done

The Design System is complete when:

- Every UI element follows consistent visual rules.
- Components share spacing, typography, and color standards.
- Themes are fully supported.
- Accessibility is built into every screen.
- Responsive layouts work across all supported devices.
- The application presents a cohesive, premium user experience.
