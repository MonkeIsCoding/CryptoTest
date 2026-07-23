# CryptoTest

A native iOS app for tracking cryptocurrency prices, maintaining a personal watchlist, and setting price alerts with local notifications.

## API

[CoinGecko API](https://www.coingecko.com/en/api) (free tier, no authentication required):
- `GET /coins/markets` — live market data for the coin list (price, market cap, rank, 24h change).
- `GET /coins/{id}/market_chart` - historical price series for the detail screen's chart.

## Tech stack

| | |
|---|---|
| Language | Swift 6.0|
| UI | SwiftUI |
| Local persistence | SwiftData |
| Charts | Swift Charts |
| Backend | Firebase (Auth + Firestore), via Swift Package Manager (`firebase-ios-sdk` ≥ 12.16.0) |
| Tests | Swift Testing (not XCTest) |
| Min. deployment target | iOS 26.4 |

## Architecture

Every external dependency (network, persistence, auth, notifications) sits behind a protocol, with a Firebase/SwiftData implementation and a `Mock*` implementation for previews and tests, wired together via constructor injection at the composition root (`CryptoTestApp.swift`).

**Coin data flow:** CoinGecko is only ever called to *fetch* fresh market data — it's never read from directly by the UI. A refresh updates CoinGecko's response into a single shared `coins` collection in Firestore (so any user's refresh keeps prices current for everyone), and the app reads *that* collection into SwiftData for offline display. **CoinGecko → Firestore → SwiftData**. (Firestore as remote source of truth, mirrored into SwiftData for offline reads)

**Watchlist and alerts:** Firestore is the per-user source of truth, and every successful fetch/add/remove/delete mirrors into SwiftData so those screens keep working offline.

**The sync/fallback logic:** (try remote, fall back to SwiftData cache on failure, mirror successful fetches back to SwiftData) lives directly inside the `@Observable` managers (`CoinManager`, `WatchlistManager`, `AlertManager`) Managers are consequently the ViewModel layer *and* the orchestration layer — specifically used for the conveniece of the environment.

**Typed errors throughout:** `APIError` (`.invalidResponse`, `.rateLimited`, `.server(statusCode:)`, `.decoding`) covers the network layer; every `throws`  propagates a real, typed error rather than a generic one, and managers catch it, fall back to cached data where appropriate, and re-throw so the UI can distinguish "offline, showing cached data" from "something else went wrong."

## Features

- **Auth** — email/password sign up, log in, log out, and account deletion (which cleans up that user's Firestore watchlist/alert documents *and* their local SwiftData mirror).
- **Home** — semi-live coin prices, search, sort (rank / name / 24h change), pull-to-refresh, works offline from the last synced cache.
- **Coin detail** — price history chart (Swift Charts) with its own independent loading/error/retry state, watchlist toggle, price alert creation.
- **Watchlist** — persisted list of favorited coins, offline-capable.
- **Alerts** — create/delete price alerts, local notification fires when a target price is crossed, checked on every price refresh *and* immediately at creation (so an alert whose condition is already met doesn't wait for the next refresh to notify).
- **Settings** — light/dark/system appearance, notification toggle (local), log out, delete account.
- Loading / empty / error states throughout, with a visible retry action distinct from the offline indicator.
- **Accessibility:** VoiceOver-friendly labels throughout the app.

## Running the project

1. Xcode 26+ (Swift 6 toolchain, iOS 26.4 SDK).
2. Clone the repo.
3. **Firebase config**: `GoogleService-Info.plist` is intentionally excluded from the repo (`.gitignore`) since it contains project-specific keys. **It will be sent over classroom with the remaining documentation for the porject.**
4. Open `CryptoTest.xcodeproj` and let Swift Package Manager resolve the Firebase SDK dependency.
5. Build & run on a simulator or device.

## Testing

Run via `Product ▸ Test` (⌘U) or the `CryptoTestTests` scheme. The suite (Swift Testing) covers:
- The SwiftData persistence layer (insert/update/delete-stale sync logic, sort order, offline-fallback correctness) against an in-memory `ModelContainer`.
- The networking layer (`APIClient`, `CoinGeckoService`) against a stubbed `URLSession` — no live network calls.
- All three managers (`CoinManager`, `WatchlistManager`, `AlertManager`): fetch success/failure fallback, caching, the alert-trigger-at-creation behavior, and the account-deletion cleanup path.

No test hits the real network or a real Firestore project — everything is exercised through the `Mock*`/stub implementations behind each protocol.
