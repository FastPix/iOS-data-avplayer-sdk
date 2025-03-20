**FastPix Video Data AVPlayer** enhances the integration steps with [AVPlayer](https://github.com/iOS-video-data-avplayer), enabling the collection of player analytics. It enables automatic tracking of video performance metrics, making the data readily available on the [FastPix dashboard](https://dashboard.fastpix.io) for monitoring and analysis. While the SDK is developed in Swift, the published spm package currently includes only the Swift output.

# Key Features:

- **Track Viewer Engagement:** Gain insights into how users interact with your videos.
- **Monitor Playback Quality:** Ensure video streaming by monitoring real-time metrics, including bitrate, buffering, startup performance, render quality, and playback failure errors.
- **Error Management:** Identify and resolve playback failures quickly with detailed error reports.
- **Customizable Tracking:** Flexible configuration to match your specific monitoring needs.
- **Centralized Dashboard:** Visualize and compare metrics on the [FastPix dashboard](https://dashboard.fastpix.io) to make data-driven decisions.

# Prerequisites:

## Getting started with FastPix:

To track and analyze video performance, initialize the SDK with your Workspace key (learn more about [Workspaces here](https://docs.fastpix.io/docs/workspaces)):

1. **[Access the FastPix Dashboard](https://dashboard.fastpix.io)**: Log in and navigate to the Workspaces section.
2. **Locate Your Workspace Key**: Copy the Workspace Key for client-side monitoring. Include this key in your Swift code on every page where you want to track video performance.

# Step 1: Installation and Setup:

To get started with this SDK, you can integrate it into your project using **Swift Package Manager (SPM)**. Follow these steps to add the package to your iOS project.

1. **Open your Xcode project** and navigate to:
   ```
   File → Add Packages…
   ```

2. **Enter the repository URL** for the FastPix SDK:
   ```
   https://github.com/fastpix/iOS-video-data-avplayer.git
   ```

3. **Choose the latest stable version** and click `Add Package`.

4. **Select the target** where you want to use the SDK and click `Add Package`.


# Step 2: Basic Integration

To integrate this SDK into your project, follow these steps:

## Import the SDK:

First, import the SDK into your Swift project:

```swift
import FastpixVideoDataAVPlayer
```

##  Initialize and Configure the SDK:

Create an instance of initAvPlayerTracking.

```swift
import FastpixVideoDataAVPlayer

let fpDataSDK = initAvPlayerTracking()

let customMetadata = [
  "data": [
        workspace_id: "WORKSPACE_KEY", // Unique key to identify your workspace (replace with your actual workspace key)
        video_title: "Test Content", // Title of the video being played (replace with the actual title of your video)
        video_id: "f01a98s76t90p88i67x", // A unique identifier for the video (replace with your actual video ID for tracking purposes)
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
    customMetadata: customMetadata
)

// Track AVPlayer Controller
fpDataSDK.trackAvPlayerController(
    playerController: playerController,   // The AVPlayerViewController instance managing the playback
    customMetadata: customMetadata
)
```

## Define player metadata

Check out the [user-passable metadata](https://docs.fastpix.io/docs/user-passable-metadata) documentation to see the metadata supported by FastPix. You can use custom metadata fields like `custom_1` to `custom_10` for your business logic, giving you the flexibility to pass any required values. Named attributes, such as `video_title` and `video_id`, can be passed directly as they are.

```swift
let customMetadata = [
    "data": [
        workspace_id: "WORKSPACE_KEY", // Unique key to identify your workspace (replace with your actual workspace key)
        video_title: "Test Content", // Title of the video being played (replace with the actual title of your video)
        video_id: "f01a98s76t90p88i67x", // A unique identifier for the video (replace with your actual video ID for tracking purposes)
        viewer_id: "user12345", // A unique identifier for the viewer (e.g., user ID, session ID, or any other unique value)
        video_content_type: "series", // Type of content being played (e.g., series, movie, etc.)
        video_stream_type: "on-demand", // Type of streaming (e.g., live, on-demand)

        // Custom fields for additional business logic
        custom_1: "", // Use this field to pass any additional data needed for your specific business logic
        custom_2: "", // Use this field to pass any additional data needed for your specific business logic

        // Add any additional metadata
    ]
]
```

### Note:

Keep metadata consistent across different video loads to make comparison easier in your analytics dashboard.

### Changing video streams in player

When your application plays multiple videos back-to-back in the same player, it’s essential to notify the FastPix SDK whenever a new video starts; possibly in scenarios like playlist content/ video series or any other video that user wants to play.

```swift
import FastpixVideoDataAVPlayer

let fpDataSDK = initAvPlayerTracking()

fpDataSDK.trackAvPlayerLayer(
    playerLayer: playerView.renderingView.playerLayer,
    customMetadata: customMetadata
)

fpDataSDK.dispatchEvent(event: "videoChange", metadata: [
    video_id: "123def", // Unique identifier for the new video
    video_title: "Daalcheeni", // Title of the new video
    video_series: "Comedy Capsule", // Series name if applicable

    // ... and other metadata
])
```

# Detailed Usage:

For more detailed steps and advanced usage, please refer to the official [FastPix Documentation](https://docs.fastpix.io/docs/av-player-ios).
