# Vendored ShipSwift sources

These files are copied from **[ShipSwift](https://github.com/signerlabs/ShipSwift)**
(`SWPackage/`), which is **not** a typical Swift package. Upstream’s README
Option 3 is to copy self-contained files from `SWAnimation/`, `SWChart/`,
`SWComponent/`, plus `SWUtil/` only if needed.

- License: MIT (see `LICENSE` in this folder)
- Copyright: SignerLabs
- Upstream commit: `f71ada2ea5187c316a3e67a37a6c8f5932ca13b2` (docs: add AGENTS.md)
- Types keep the `SW` prefix; view modifiers keep the `.sw` prefix

## Copied

| Path | Why |
| --- | --- |
| `SWPackage/SWAnimation/SWShimmer.swift` | Live shimmer sweep |
| `SWPackage/SWAnimation/SWTypewriterText.swift` | Live typewriter headline |
| `SWPackage/SWAnimation/SWGlowSweep.swift` | Gallery snapshot (static stand-in) |
| `SWPackage/SWChart/SWLineChart.swift` | Live line chart |
| `SWPackage/SWChart/SWDonutChart.swift` | Gallery donut |
| `SWPackage/SWChart/SWBarChart.swift` | Gallery bar |
| `SWPackage/SWChart/SWRingChart.swift` | Gallery rings |
| `SWPackage/SWComponent/Feedback/SWThinkingIndicator.swift` | Live thinking dots |
| `SWPackage/SWComponent/Display/SWStatusBadge.swift` | Gallery badges |
| `SWPackage/SWComponent/Display/SWKPICard.swift` | Gallery KPI cards |
| `SWPackage/SWComponent/Display/SWBulletPointText.swift` | Gallery bullets |
| `SWPackage/SWComponent/Display/SWGradientDivider.swift` | Gallery divider |

## Not copied (out of scope)

- Entire `SWModule/` tree (SWAuth/Amplify, SWCamera, SWPaywall/StoreKit, SWChat/ASR, SWTikTokTracking, SWSetting, SWSubjectLifting)
- `SWAnimation/SWMetal/` shader backgrounds (continuous Metal)
- `SWScrollingFAQ` (CADisplayLink on every row)
- `SWUtil/` (none of the copied files need it)

## Local patches

- `SWTypewriterText` typing delays use `Task` / `Task.sleep` instead of
  `DispatchQueue.main.asyncAfter` so the file type-checks under this repo’s
  Swift 6 app module. Public API and timing are unchanged.
- `SWRingChart.DataPoint` takes an optional `id` (default `UUID()`) so
  gallery fixtures can keep stable identities. Default call sites unchanged.
