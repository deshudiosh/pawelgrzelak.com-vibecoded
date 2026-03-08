# Double Landing Direction

## Summary

Adopt the double-landing structure.

The concept is strong because it matches the two identities you want to show:
- landing 1 presents authorship and point of view
- landing 2 proves professional range quickly
- the grid then becomes exploration, not first explanation

The key is to make the two sections do different jobs. If both behave like full-screen heroes with similar text weight, the site will feel slower and repetitive.

## Key Changes

- Replace the current first-screen subtitle with an authored thesis.
  Default direction: `PAWEŁ GRZELAK` + a sharper line such as `Inventing digital species`.
- Keep landing 1 as the most cinematic and singular moment.
  One dominant background piece, minimal copy, strong contrast, no extra clutter.
- Add landing 2 directly below as a professional reel section.
  Default format: one curated montage reel or stitched cuts, not a busy multi-panel composition.
- Keep landing 2 lighter on messaging.
  Use either no headline or a very restrained label like `Selected Professional Work`.
- Keep scroll behavior natural.
  No hard snap sections; use visual pacing and CSS-led transitions so mobile stays smooth.
- Keep the projects grid after landing 2.
  The grid becomes the deeper browse layer for all projects rather than the first proof of quality.
- Preserve the current dark-to-light page rhythm.
  Landing 1 stays dark and immersive; landing 2 should bridge into the lighter editorial `main` area instead of feeling like a separate microsite.

## Implementation Changes

- In `index.html`, split the current top flow into:
  1. primary manifesto hero
  2. professional reel section
  3. existing work grid section
- In `style.css`, introduce a distinct visual hierarchy between the two landings:
  landing 1 = full viewport, centered statement
  landing 2 = slightly more editorial, more compressed text treatment, clear transition into content
- In `script.js`, keep interactions lightweight:
  nav reveal should trigger after landing 1
  scroll indicator should only belong to landing 1
  any reel behavior should avoid heavy JS and rely on native video plus CSS reveal timing
- Performance defaults:
  preload only landing 1 media
  landing 2 reel should load after first paint / near viewport
  use posters aggressively
  avoid multiple autoplay videos at once unless testing proves it is safe

## Test Plan

- Desktop: landing 1 reads instantly, landing 2 feels like a distinct second beat, grid still appears early enough.
- Mobile: the second landing does not feel like a long blocker before projects.
- Performance: first hero remains the only guaranteed above-the-fold heavy media load.
- Motion: transitions between the two landings feel intentional without scroll-jank.
- Messaging: a first-time visitor can tell within a few seconds that you have both an authored experimental voice and professional production work.

## Assumptions

- Landing 1 should position you with an inventor/author thesis rather than a generic job title.
- Landing 2 should focus on professional/client work only.
- The later grid can remain broader and mixed unless you later decide to split it into categories.
- The current visual style stays intact: dark cinematic hero, restrained typography, CSS-first motion, no framework changes.
