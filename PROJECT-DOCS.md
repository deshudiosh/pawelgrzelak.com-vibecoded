# Portfolio Website - Project Docs

## Overview

Static portfolio site for a 3D artist. The site is video-first, runs on GitHub Pages, and is built with plain HTML, CSS, and JavaScript.

## Project Rules

- Keep the stack pure HTML, CSS, and JS.
- Do not introduce frameworks.
- Keep the current visual style.
- Prefer CSS animations over JS when possible.
- Treat performance as a primary requirement.

## Core Decisions

### Video Strategy

- Landing media uses separate assets for desktop and mobile.
- Desktop uses landscape video.
- Mobile uses portrait video.
- The switch happens at the `768px` breakpoint.
- MP4 is the primary format.
- WebM is the fallback format.
- Videos should autoplay silently and loop.
- Poster images should always be provided.

### Performance

- Keep video files aggressively optimized before shipping.
- Remove audio from background videos.
- Use `faststart` on MP4 files.
- Optimize poster images before deployment.
- Avoid loading unnecessary media early.
- Any enhancement should be measured against page-weight impact.

### Visual Direction

- Full-screen landing section with immersive video.
- Light beige content area with subtle texture.
- Darker landing area for contrast.
- Blurred, semi-transparent navigation once the user scrolls past the landing threshold.
- Clean, minimal typography and restrained motion.

## Current Behavior

- The landing section fills the viewport.
- Desktop and mobile videos are swapped responsively.
- The main navigation becomes visible after the user scrolls past roughly half of the landing section.
- The layout is single-column and media-led.

## File Structure

```text
pawelgrzelak.com-vibecoded/
|- index.html
|- project-template.html
|- style.css
|- script.js
|- convert-videos.bat
|- optimize-images.bat
|- optimize-images.ps1
|- generate_noise.py
`- assets/
```

## Asset Conventions

- Landing and project videos should follow a clear desktop/mobile naming pattern.
- Desktop assets should include:
  - `*-desktop-1080p.mp4`
  - `*-desktop-720p.webm`
  - `*-desktop-poster.jpg`
- Mobile assets should include:
  - `*-mobile-720p.mp4`
  - `*-mobile-480p.webm`
  - `*-mobile-poster.jpg`

## Workflow

### Videos

1. Convert source videos with `convert-videos.bat`.
2. Confirm the correct desktop or mobile orientation output.
3. Verify file sizes are reasonable before committing.
4. Generate or keep poster images for every video.

### Images

1. Optimize poster images before deployment.
2. Review image quality after compression.

### Site Updates

1. Update asset paths in `index.html` or project pages.
2. Test desktop and mobile breakpoints.
3. Verify autoplay, looping, poster fallback, and scroll-triggered nav behavior.

## Deployment

- The site is intended for GitHub Pages.
- Deploy from the main branch root unless the repo setup changes.
- Before pushing, verify that large media files are intentional and optimized.

## Quality Checklist

- Videos load correctly on desktop and mobile breakpoints.
- Poster images appear before media loads.
- Navigation transition still works after layout edits.
- No change introduces a framework or unnecessary dependency.
- Motion remains subtle and in line with the current style.
- Performance is not noticeably worse after the change.

## Known Priorities

- Improve perceived loading without changing the visual language.
- Favor progressive enhancement for advanced effects.
- Focus first on media loading strategy, not novelty features.

## Notes

- Keep secrets and API keys out of repository documentation.
- If implementation details drift, the source of truth is the actual codebase, not this file.

*Last updated: 2026-03-07*
