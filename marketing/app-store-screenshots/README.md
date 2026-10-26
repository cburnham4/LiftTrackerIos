# Lift Tracker — App Store screenshot generator

Same workflow as Sunrise & Sunset / Truth Finder: Next.js frames + `html-to-image` / Puppeteer export.

## Run locally

```bash
cd marketing/app-store-screenshots
npm install
npm run dev
```

Open http://localhost:3000 — export individual slides or all PNGs.

### Generate on disk

```bash
npm run generate:screenshots
```

Writes 1320×2868 frames + 5244×2950 universal creative into `exported-store-screenshots/`.

## Capture source screenshots

UITest: `Lift TrackerUITests/testCaptureAppStoreScreens` → `/tmp/asc-captures/lifttracker/`.

Copy RGB PNGs into `public/screenshots/` as `home.png`, `routines.png`, `add-set.png`, `past-lifts.png`, `graph.png`, `download.png`.

## Brand

- Blue `#125688` (`LiftTrackerTheme.brandBlue`)
