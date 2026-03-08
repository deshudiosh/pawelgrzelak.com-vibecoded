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
|- README.md
|- AGENTS.md
|- docs/
|  |- PROJECT-DOCS.md
|  `- IMPROVEMENT-IDEAS.md
|- index.html
|- project-template.html
|- style.css
|- script.js
|- utility_scripts/
|  |- convert-videos.bat
|  |- optimize-images.bat
|  `- optimize-images.ps1
`- assets/
```

## Asset Conventions

- Landing and project videos should follow a clear desktop/mobile naming pattern.
- Treat landing video and project thumbnail video as separate asset types.
- For now, define thumbnail video rules only for the homepage.
- Recommended resolutions:

  | Asset                     | Desktop Max                    | Desktop Min                    | Mobile Max                     | Mobile Min                    |
  | ------------------------- | ------------------------------ | ------------------------------ | ------------------------------ | ----------------------------- |
  | Landing video             | `1920x1080` (`AV1.mp4`)        | `1280x720` (`VP9.webm`)        | `1080x1920` (`AV1.mp4`)        | `720x1280` (`VP9.webm`)       |
  | Project thumbnail video*  | `1440x810` (`AV1.mp4`)         | `960x540` (`VP9.webm`)         | `900x1600` (`AV1.mp4`)         | `540x960` (`VP9.webm`)        |

  \* Mobile values for project thumbnail video may change later. Mobile thumbnail margins are not defined yet.

- Each video type should have separate desktop and mobile exports.
- Every video should have a matching `.jpg` poster image.
- Future note: it may still be worth adding an extra `H.264 / MP4` fallback later if browser testing shows real gaps on older devices.
- File names should follow the current `assets` structure, for example: `projectname-desktop-1080p.mp4`, `projectname-mobile-480p.webm`, `projectname-mobile-poster.jpg`.

## Workflow

### Videos

1. Convert source videos with `utility_scripts/convert-videos.bat`.
2. Confirm the correct desktop or mobile orientation output.
3. Verify file sizes are reasonable before committing.
4. Generate or keep poster images for every video.

### Images

1. Optimize poster images before deployment with `utility_scripts/optimize-images.bat`.
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

*Last updated: 2026-03-08*
