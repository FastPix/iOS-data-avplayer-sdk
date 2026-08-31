# FastPix Video Data AVPlayer — SwiftUI Example

A SwiftUI `VideoPlayer` with the FastPix Video Data AVPlayer SDK attached.

## Run

```bash
open AVPlayerSwiftUIExample.xcodeproj
```

Pick a Simulator (or your device), press **▶ Run**, tap a sample stream, then
open [dashboard.fastpix.com](https://dashboard.fastpix.com) → your workspace to
watch views appear. The project references the SDK as a local Swift package at
`../..`, so it builds against this checkout — no network fetch.

## Files

| File | Role |
|------|------|
| `PlayerView.swift` | Owns the `AVPlayer` + tracking object in an `ObservableObject` (`@StateObject`); attaches with `trackAvPlayer(player:playerLayer:nil)` in `.onAppear` and tears down in `.onDisappear`. |
| `HomeView.swift` | Landing list of sample streams; also holds `workspaceKey`. |
| `App.swift` | App entry point. |

> The player and tracking object live in an `ObservableObject`, **not** the View
> struct — SwiftUI recreates View structs on every render, which would churn the
> player. `VideoPlayer` has no `AVPlayerLayer`, so the SDK gets the `AVPlayer`
> directly (`playerLayer: nil`).

## Set your own workspace + stream

Edit `HomeView.swift`:

```swift
/// Replace with the Workspace Key from your FastPix dashboard (Workspaces).
let workspaceKey = "1029207880411545601"
```

Replace `workspaceKey` (dashboard.fastpix.com → **Workspaces**), and edit the
`samples` list to play your own HLS URLs. Without a valid key the app still plays
video but shows an orange "Add your Workspace Key" badge and sends no analytics.
