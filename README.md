# iAssets

iAssets is a personal “everything-as-an-asset” app that tracks your items’ lifecycle—cost-per-day, resale P&L, and net worth—with live FX conversion and iCloud sync.

## Requirements

- macOS with **Xcode 16+** (full Xcode, not only Command Line Tools)
- iOS 17.0+ (validated target: iPhone / iOS 26.x)
- Apple Developer team for device + CloudKit (optional for Simulator local mode)

## Open & Run

1. Open `iAssets.xcodeproj` in Xcode.
2. Select your **Team** under Signing & Capabilities.
3. Enable **iCloud → CloudKit** if not already applied from entitlements (`iCloud.app.iassets.ios`).
4. Run on a Simulator or your iPhone.

> This machine may not have Xcode installed. The project files are ready; build on a Mac with Xcode.

## What’s in MVP

| Area | Features |
| --- | --- |
| Dashboard | Net worth, FX status, status filters, category chart, trend snapshots |
| Cabinet | Grid/list showcase, search, filters, asset detail, retire / sell |
| Add | Photo, category, multi-currency purchase, target daily cost |
| Review | Sold P&L, daily-cost ranking, idle hints |
| Settings | Base currency, live FX refresh, iCloud toggle/status, JSON/CSV import & export |
| Onboarding | Intro → base currency → iCloud |

## Architecture

- SwiftUI + SwiftData
- CloudKit via `ModelConfiguration(cloudKitDatabase:)` when iCloud is enabled
- FX: [Frankfurter](https://www.frankfurter.app) on app open + manual refresh (cached offline)

## Bundle ID

`app.iassets.ios`

## Docs

See `产品文档.md` for the full product spec.
