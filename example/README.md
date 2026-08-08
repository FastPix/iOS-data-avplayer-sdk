# FastPix Video Data AVPlayer — Example App

A minimal iOS (UIKit) app showing how to integrate the
[FastPix Video Data AVPlayer SDK](https://github.com/FastPix/iOS-data-avplayer-sdk)
to collect playback analytics from an `AVPlayerViewController`.

## Requirements

- macOS with **Xcode 15 or later**
- **iOS 14.0+** simulator or device
- A **FastPix Workspace Key** — grab it from the
  [FastPix dashboard](https://dashboard.fastpix.com) under **Workspaces**
- (Device only) an Apple ID / signing team configured in Xcode

## How to run this app

### 1. Get the project

If you cloned the SDK repo, the example lives in the `example/` folder:

```bash
git clone https://github.com/FastPix/iOS-data-avplayer-sdk.git
cd iOS-data-avplayer-sdk/example
```

### 2. Open it in Xcode

```bash
open AVPlayerExample.xcodeproj
```

Or launch Xcode → **File → Open…** → select `AVPlayerExample.xcodeproj`.

### 3. Let Swift Package Manager resolve dependencies

On first open, Xcode automatically fetches the packages
(`FastpixVideoDataAVPlayer` and its `FastpixiOSVideoDataCore` dependency).
Wait until the progress spinner in the toolbar finishes. If it doesn't start,
choose **File → Packages → Resolve Package Versions**.

### 4. Add your Workspace Key

Open `AVPlayerExample/PlayerViewController.swift` and replace the placeholder:

```swift
// Replace with the Workspace Key from your FastPix dashboard.
private let workspaceKey = "YOUR_WORKSPACE_KEY"
```

Without a valid key the app still plays video, but the player screen shows an
orange **"Add your Workspace Key"** badge and no analytics are sent.
(Optionally edit the `samples` list in `HomeViewController.swift` to play your
own FastPix HLS URLs.)

### 5. Pick a destination and run

1. In the toolbar's scheme/destination selector, choose the **AVPlayerExample**
   scheme and a target:
   - **Simulator** — e.g. *iPhone 15 Pro* (no signing needed).
   - **Physical device** — select **Signing & Capabilities**, pick your **Team**
     so Xcode provisions the app, then plug in / select the device.
2. Press **⌘R** (or the ▶︎ Run button).
3. The app launches on the **Home** screen listing sample streams — tap one to
   open the player.

### 6. Verify tracking

- On the player screen you should see a green **"FastPix tracking active"**
  badge and the **Tracked metadata** card.
- Play, pause, and seek the video, then open your
  [FastPix dashboard](https://dashboard.fastpix.com) — the view and its metrics
  appear there (allow a short delay for data to arrive).

### Troubleshooting

- **"Failed to install" on a device** — clean with **Product → Clean Build
  Folder (⇧⌘K)** and run again. On the first install, trust the developer
  profile under **Settings → General → VPN & Device Management** on the device.
- **Package resolution errors** — **File → Packages → Reset Package Caches**,
  then resolve again.
- **No data on the dashboard** — confirm `workspaceKey` is set correctly and the
  device/simulator has network access.

## App structure

- `HomeViewController` — landing screen listing sample streams.
- `PlayerViewController` — plays the selected stream in an
  `AVPlayerViewController` and attaches the SDK. Shows a small status panel
  indicating whether tracking is active.

## How the integration works

```swift
import FastpixVideoDataAVPlayer

// Keep a strong reference for the whole playback session.
let fpDataSDK = initAvPlayerTracking()

// All metadata fields must live under the "data" key.
let customMetadata: [String: Any] = [
    "data": [
        "workspace_id": "YOUR_WORKSPACE_KEY",
        "video_title": "Test Content",
        "video_id": "sample-video-001",
        "viewer_id": "user-12345",
        "video_content_type": "movie",
        "video_stream_type": "on-demand"
    ]
]

// Attach to however you present video:
fpDataSDK.trackAvPlayerController(playerController: playerVC, customMetadata: customMetadata)
// or trackAvPlayer(player:customMetadata:)
// or trackAvPlayerLayer(playerLayer:customMetadata:)
```

When you swap in a new video in the same player (playlists / "up next"),
notify the SDK so it starts a new view:

```swift
fpDataSDK.dispatchEvent(event: "videoChange", metadata: [
    "video_id": "sample-video-002",
    "video_title": "Next Content"
])
```

See the
[official FastPix documentation](https://fastpix.com/docs/ios-and-cross-platform-players/monitor-avplayer)
for the full list of supported metadata and advanced usage.
