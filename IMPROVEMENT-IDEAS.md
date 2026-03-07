# Improvement Ideas

*Updated: 2026-03-07*

## Purpose

This file is a short backlog of possible improvements for the portfolio. It should stay practical and aligned with the project rules:

- pure HTML, CSS, and JavaScript
- no frameworks
- preserve the current visual style
- prefer CSS animation where possible
- prioritize performance

## Current Priorities

### 1. Video Loading

- Lazy-load project videos when they approach the viewport.
- Preload only the most important landing media.
- Improve poster usage so loading feels faster before video playback starts.

Why it matters:
- This is the highest-value performance work on a video-heavy site.

### 2. Motion Polish

- Add staggered reveal timing to project items.
- Refine section transitions without making the site feel busy.
- Keep motion subtle and mostly CSS-driven.

Why it matters:
- Improves perceived quality without changing the visual language.

### 3. Navigation and Scroll Feedback

- Add a simple scroll progress indicator.
- Review scroll-triggered nav timing and smoothness.
- Consider a light parallax effect only if it does not hurt performance.

Why it matters:
- Small feedback improvements can make the site feel more deliberate.

### 4. Project Presentation

- Add project detail pages for stronger storytelling.
- Expand projects with more media, process shots, or short case-study text.
- Consider lightweight filtering only if the number of projects grows enough to justify it.

Why it matters:
- Better content structure is often more valuable than decorative interaction.

## Secondary Ideas

### View Transitions API

- Useful for page-to-page or card-to-detail transitions.
- Should be treated as progressive enhancement.
- Worth doing only after loading performance is in good shape.

### Smooth Motion Library

- A lightweight smooth-scroll library such as `Lenis` could make the site feel more polished.
- This should be evaluated carefully against bundle cost, scroll behavior, and mobile performance.
- Only worth adding if the benefit is clearly visible and the implementation stays simple.

### Cursor Effects

- Custom cursor or magnetic hover effects could add polish.
- These should stay subtle and should not interfere with usability.
- Lower priority than performance and content improvements.

### Animated Texture

- A very subtle animated grain layer could add depth.
- Only worth testing if it has negligible performance cost.

## Ideas to Treat Carefully

- Smooth-scroll libraries add weight and should not be a default choice.
- Swipe systems, pull-to-refresh, or app-like gestures are probably unnecessary for this site.
- Theme switching is not a priority unless there is a strong design reason for it.
- Infinite scroll or pagination should wait until content size actually requires it.

## Suggested Order

1. Lazy loading for project videos
2. Preload review for above-the-fold media
3. Staggered reveal polish
4. Scroll progress indicator
5. Project detail pages
6. View Transitions API

## Rule for New Ideas

Before adding a feature, check:

- Does it improve performance, clarity, or presentation?
- Does it fit the current visual style?
- Can it be done without a framework?
- Is it worth the extra page weight and maintenance?
