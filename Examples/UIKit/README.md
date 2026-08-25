# FastPix Video Data AVPlayer — UIKit Example

An `AVPlayerViewController` with the FastPix Video Data AVPlayer SDK attached.

## Run

```bash
open AVPlayerExample.xcodeproj
```

Pick a Simulator (or your device), press **▶ Run**, tap a sample stream, then
open [dashboard.fastpix.com](https://dashboard.fastpix.com) → your workspace to
watch views appear. The project references the SDK as a local Swift package at
`../..`, so it builds against this checkout — no network fetch.

## Files

| File | Role |
|------|------|
| `PlayerViewController.swift` | Creates the `AVPlayer`, embeds an `AVPlayerViewController`, and attaches the SDK with `trackAvPlayerController`. |
| `HomeViewController.swift` | Landing list of sample streams. |
| `AppDelegate.swift` / `SceneDelegate.swift` | App entry point (programmatic window, no storyboard). |

## Set your own workspace + stream

Edit `PlayerViewController.swift`:

```swift
// Replace with the Workspace Key from your FastPix dashboard.
private let workspaceKey = "1029207880411545601"
```

Replace `workspaceKey` (dashboard.fastpix.com → **Workspaces**), and edit the
`samples` list in `HomeViewController.swift` to play your own HLS URLs. Without a
valid key the app still plays video but shows an orange "Add your Workspace Key"
badge and sends no analytics.
