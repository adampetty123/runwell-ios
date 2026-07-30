# Runwell — native iOS app (SwiftUI)

Full native iOS rebuild of the Runwell dashboard (replaces the Expo/React-Native WebView shell).

## Status: Phase 1 foundation
- SwiftUI app scaffold (dark theme #131315, SF Pro Rounded, Face ID entitlement).
- API client against the live Runwell backend (`app.notforprofit.co`) — same endpoints the web dashboard uses.
- Screens: Login → Companies list → Agents list → per-agent Chat + Tasks.
- CI: GitHub Actions macOS runner builds the Xcode project and ships to TestFlight (`.github/workflows/ios.yml`).

## Build
Local compile requires macOS + Xcode. Project is generated from `project.yml` via [XcodeGen]:
```
brew install xcodegen && xcodegen generate && open Runwell.xcodeproj
```
CI does this automatically on push to `main`.

## Apple / TestFlight
Reuses the existing Runwell Apple account.
- Team: `Z3FSAXK2G4`
- Bundle id: `so.runwell.app` (already registered)
- App Store Connect API key: `6T4JPBSM8B` (Issuer `609b9a79-801f-4dfb-b96f-86f04f444004`)

Required GitHub repo secrets: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8_BASE64`.

## Roadmap
- Phase 2: flesh out chat (streaming/typing, reply-to), tasks (add/queue), settings.
- Phase 3: push notifications, Face ID unlock, native pull-to-refresh polish, full parity.
