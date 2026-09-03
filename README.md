# FastPix Video Data for AVPlayer - iOS and tvOS video analytics and QoE monitoring SDK (Swift)

[![Latest release](https://img.shields.io/github/v/release/FastPix/iOS-data-avplayer-sdk?sort=semver)](https://github.com/FastPix/iOS-data-avplayer-sdk/releases)
[![Platform: iOS](https://img.shields.io/badge/platform-iOS%2013%2B%20%7C%20tvOS-000000?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-F05138?logo=swift&logoColor=white)](https://swift.org)
[![SPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen?logo=swift)](https://swift.org/package-manager/)
[![license](https://img.shields.io/github/license/FastPix/iOS-data-avplayer-sdk)](https://github.com/FastPix/iOS-data-avplayer-sdk/blob/main/LICENSE)

The FastPix Video Data SDK for AVPlayer adds real-time video analytics and Quality of Experience (QoE) monitoring to any `AVPlayer`, `AVPlayerLayer`, or `AVPlayerViewController` in your iOS or tvOS app. It automatically collects viewer engagement, playback quality (bitrate, buffering, startup time, render quality), and playback errors, and surfaces them on the [FastPix dashboard](https://dashboard.fastpix.com) for monitoring and analysis.

**Works with:** iOS 13+ · tvOS · Swift 5.9 · Swift Package Manager · AVPlayer / AVPlayerLayer / AVPlayerViewController

📖 **Monitor AVPlayer docs:** https://fastpix.com/docs/ios-and-cross-platform-players/monitor-avplayer &nbsp;·&nbsp; 🚀 **Dashboard:** https://dashboard.fastpix.com

<br />

## What you can track

- **Viewer engagement** - understand how users interact with your videos.
- **Playback quality** - real-time bitrate, buffering, startup performance, render quality, and playback-failure metrics.
- **Error management** - detailed error reports to diagnose playback failures quickly.
- **Custom metadata** - attach your own fields (`custom_1` to `custom_10`, plus named attributes like `video_title` and `video_id`) to every view.
- **Centralized dashboard** - visualize and compare metrics on the FastPix dashboard.
- **iOS and tvOS** - the same tracking works on Apple TV apps using AVPlayer.

<br />

## Start here

If you are adding this SDK for the first time, follow these steps in order:

1. [Get your Workspace Key](#1-get-your-workspace-key)
2. [Install the SDK with Swift Package Manager](#2-install-the-sdk-with-swift-package-manager)
3. [Import the SDK](#3-import-the-sdk)
4. [Initialize and attach the SDK to your player](#4-initialize-and-attach-the-sdk-to-your-player)
5. [Pass custom metadata](#5-pass-custom-metadata)
6. [Handle video changes in the same player](#6-handle-video-changes-in-the-same-player)
7. [Verify it works](#7-verify-it-works)

<br />

## Before you begin

Make sure you have the following ready:

| Requirement | Details |
|---|---|
| **Xcode** | With an app project targeting **iOS 13.0 or later**. |
| **A FastPix account** | Free to create at the [FastPix Dashboard](https://dashboard.fastpix.com). |
| **A Workspace Key** | Your client-side monitoring key. Get it in [step 1](#1-get-your-workspace-key). |
| **An AVPlayer to monitor** | An existing `AVPlayer`, `AVPlayerLayer`, or `AVPlayerViewController` in your app. |

<br />

## 1. Get your Workspace Key

You initialize the SDK with your Workspace Key (learn more about [Workspaces](https://fastpix.com/docs/getting-started/set-up-a-workspace)):

1. Log in to the [FastPix Dashboard](https://dashboard.fastpix.com) and open the **Workspaces** section.
2. Copy the **Workspace Key** for client-side monitoring. You pass this key as `workspace_id` in the metadata (shown below).

<br />

## 2. Install the SDK with Swift Package Manager

This SDK is distributed via Swift Package Manager.

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL:

   ```
   https://github.com/FastPix/iOS-data-avplayer-sdk.git
   ```

3. Choose the latest stable version and click **Add Package**.
4. Select the target where you want to use the SDK and click **Add Package**.

Xcode resolves the package and its dependency (`FastpixiOSVideoDataCore`) automatically. To confirm resolution from the command line, run this in your project directory:

```bash
xcodebuild -resolvePackageDependencies
```

The output lists the resolved packages, including `FastpixVideoDataAVPlayer` and `FastpixiOSVideoDataCore`.

<br />

## 3. Import the SDK

```swift
import FastpixVideoDataAVPlayer
```

<br />

## 4. Initialize and attach the SDK to your player

Create an instance of `initAvPlayerTracking`, build your metadata (all fields go under a `"data"` key), and attach it to your player. Hold a strong reference to the SDK instance so tracking lives for the whole playback session.

```swift
import FastpixVideoDataAVPlayer

let fpDataSDK = initAvPlayerTracking()

let customMetadata: [String: Any] = [
  "data": [
        "workspace_id": "WORKSPACE_KEY", // Unique key to identify your workspace (replace with your actual workspace key)
        "video_title": "Test Content", // Title of the video being played (replace with the actual title of your video)
        "video_id": "f01a98s76t90p88i67x", // A unique identifier for the video (replace with your actual video ID for tracking purposes)
  ]
]

// Track AVPlayer Layer
fpDataSDK.trackAvPlayerLayer(
    playerLayer: playerLayer,   // The AVPlayerLayer instance managing the playback
    customMetadata: customMetadata
)

// Track AVPlayer
fpDataSDK.trackAvPlayer(
    player: player,   // The AVPlayer instance managing the playback
    playerLayer: playerLayer,   // The AVPlayerLayer for the player, or nil if you don't have one
    customMetadata: customMetadata
)

// Track AVPlayer Controller
fpDataSDK.trackAvPlayerController(
    playerController: playerController,   // The AVPlayerViewController instance managing the playback
    customMetadata: customMetadata
)
```

> Use whichever `track…` method matches how you present video: `trackAvPlayerLayer` for a raw `AVPlayerLayer`, `trackAvPlayer` for an `AVPlayer`, or `trackAvPlayerController` for an `AVPlayerViewController`. You do not need to call all three.

<br />

## 5. Pass custom metadata

See the [user-passable metadata](https://fastpix.com/docs/working-with-video-data/pass-custom-metadata-to-metrics) documentation for every field FastPix supports. Named attributes such as `video_title` and `video_id` are passed directly, and you can use `custom_1` to `custom_10` for your own business logic. All fields go under the `"data"` key:

```swift
let customMetadata: [String: Any] = [
    "data": [
        "workspace_id": "WORKSPACE_KEY", // Unique key to identify your workspace (replace with your actual workspace key)
        "video_title": "Test Content", // Title of the video being played (replace with the actual title of your video)
        "video_id": "f01a98s76t90p88i67x", // A unique identifier for the video (replace with your actual video ID for tracking purposes)
        "viewer_id": "user12345", // A unique identifier for the viewer (e.g., user ID, session ID, or any other unique value)
        "video_content_type": "series", // Type of content being played (e.g., series, movie, etc.)
        "video_stream_type": "on-demand", // Type of streaming (e.g., live, on-demand)

        // Custom fields for additional business logic
        "custom_1": "", // Use this field to pass any additional data needed for your specific business logic
        "custom_2": "", // Use this field to pass any additional data needed for your specific business logic

        // Add any additional metadata
    ]
]
```

> **Tip:** Keep metadata consistent across video loads so comparisons are easy in your analytics dashboard.

<br />

## 6. Handle video changes in the same player

When your app plays multiple videos back-to-back in the same player (playlists, a video series, or "up next"), notify the SDK when a new video starts so it begins a fresh view. The `dispatchEvent` metadata is a flat dictionary (no `"data"` wrapper):

```swift
import FastpixVideoDataAVPlayer

let fpDataSDK = initAvPlayerTracking()

fpDataSDK.trackAvPlayerLayer(
    playerLayer: playerView.renderingView.playerLayer,
    customMetadata: customMetadata
)

fpDataSDK.dispatchEvent(event: "videoChange", metadata: [
    "video_id": "123def", // Unique identifier for the new video
    "video_title": "Daalcheeni", // Title of the new video
    "video_series": "Comedy Capsule", // Series name if applicable

    // ... and other metadata
])
```

<br />

## 7. Verify it works

1. Build and run your app, then play a video through the `AVPlayer` you attached the SDK to.
2. Log in to the [FastPix Dashboard](https://dashboard.fastpix.com) and open the **Video Data** section.
3. Within a few minutes of playback, your view appears with its metrics (startup time, bitrate, buffering) and any custom metadata you passed, such as `video_title` and `video_id`.

If no data appears, confirm that `workspace_id` is set to your real Workspace Key, that you kept a strong reference to the `initAvPlayerTracking()` instance for the whole playback session, and that the device has network access.

<br />

## tvOS support

The SDK also works on tvOS, so you can collect the same playback analytics from your Apple TV apps using AVPlayer: viewer engagement, playback quality, errors, and custom events, just as on iOS. If you run into any issues on tvOS, reach out to FastPix support.

<br />

## Which FastPix repo do I need?

This SDK **collects analytics** from AVPlayer. For playback, uploads, and other platforms:

| I want to... | Repo |
|---|---|
| Play FastPix video in an iOS app | [iOS-player](https://github.com/FastPix/iOS-player) |
| Use the shared iOS data core this SDK builds on | [iOS-core-data-sdk](https://github.com/FastPix/iOS-core-data-sdk) |
| Collect playback analytics on Roku | [Roku-data-core-SDK](https://github.com/FastPix/Roku-data-core-SDK) |
| Play FastPix video on the web | [web-player-component](https://github.com/FastPix/web-player-component) |
| Add resumable uploads to an iOS app | [iOS-Uploads](https://github.com/FastPix/iOS-Uploads) |

Browse everything in the [FastPix organization](https://github.com/orgs/FastPix/repositories).

<br />

## FAQ

**What does this SDK do?**
It collects real-time video analytics and QoE metrics (engagement, bitrate, buffering, startup time, errors) from AVPlayer and reports them to the FastPix dashboard. See [What you can track](#what-you-can-track).

**Which package URL do I add in Xcode?**
`https://github.com/FastPix/iOS-data-avplayer-sdk.git`. See [Install the SDK](#2-install-the-sdk-with-swift-package-manager).

**What is the module name to import?**
`import FastpixVideoDataAVPlayer` (note the lowercase "p" in "Fastpix").

**Where do I get my Workspace Key?**
From the Workspaces section of the [FastPix Dashboard](https://dashboard.fastpix.com). See [Get your Workspace Key](#1-get-your-workspace-key).

**Why must metadata keys be quoted, and what is the `"data"` wrapper?**
`customMetadata` is a `[String: Any]` dictionary, so keys are string literals like `"workspace_id"`. For the `track…` methods, all fields are nested under a top-level `"data"` key; for `dispatchEvent`, the metadata is a flat dictionary. This matches the SDK's own [example app](https://github.com/FastPix/iOS-data-avplayer-sdk/tree/main/example).

**Which platforms and versions are supported?**
iOS 13.0+ and tvOS, Swift 5.9. See [Before you begin](#before-you-begin).

**Does it support tvOS?**
Yes - see [tvOS support](#tvos-support).

<br />

## Documentation

- **Monitor AVPlayer (iOS and tvOS)**: [fastpix.com/docs/ios-and-cross-platform-players/monitor-avplayer](https://fastpix.com/docs/ios-and-cross-platform-players/monitor-avplayer)
- **Pass custom metadata to metrics**: [fastpix.com/docs/working-with-video-data/pass-custom-metadata-to-metrics](https://fastpix.com/docs/working-with-video-data/pass-custom-metadata-to-metrics)
- **Set up a workspace**: [fastpix.com/docs/getting-started/set-up-a-workspace](https://fastpix.com/docs/getting-started/set-up-a-workspace)
- **Runnable example app**: [example/](https://github.com/FastPix/iOS-data-avplayer-sdk/tree/main/example)

<br />

## License

This SDK is released under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
