# FastPix Video Data AVPlayer — Example App

A minimal iOS (UIKit) app showing how to integrate the
[FastPix Video Data AVPlayer SDK](https://github.com/FastPix/iOS-data-avplayer-sdk)
to collect playback analytics from an `AVPlayerViewController`.

## Requirements

- Xcode 15 or later
- iOS 14.0+ deployment target

## Running the example

1. Open `AVPlayerExample.xcodeproj` in Xcode.
2. Xcode resolves the Swift Package dependencies automatically
   (`FastpixVideoDataAVPlayer` and its `FastpixiOSVideoDataCore` dependency).
   If it doesn't, choose **File → Packages → Resolve Package Versions**.
3. Open `AVPlayerExample/PlayerViewController.swift` and set `workspaceKey`
   to the Workspace Key from your
   [FastPix dashboard](https://dashboard.fastpix.com) (Workspaces section).
   Optionally edit the `samples` list in `HomeViewController.swift` to point
   at your own FastPix playback URLs.
4. Select a simulator or device and run.

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
