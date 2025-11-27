---
name: Bug Report  
about: Report an issue related to the FastPix iOS Video Data AVPlayer SDK  
title: '[BUG] '  
labels: bug  
assignees: ''  
---

## Bug Description  
A clear and concise description of the issue you encountered.

---

## Reproduction Steps

### 1. **SDK Setup**

Add the FastPix iOS Video Data AVPlayer SDK via Swift Package Manager:

```
https://github.com/fastpix/iOS-video-data-avplayer.git
```

Import the SDK:

```swift
import FastpixVideoDataAVPlayer
```

---

### 2. **Code To Reproduce**

Provide a reproducible example. Example:

```swift
import FastpixVideoDataAVPlayer
import AVFoundation
import AVKit

let fpDataSDK = initAvPlayerTracking()

let customMetadata = [
    "data": [
        "workspace_id": "WORKSPACE_KEY",
        "video_title": "Test Content",
        "video_id": "VIDEO_001"
    ]
]

// Track AVPlayer
fpDataSDK.trackAvPlayer(
    player: player,
    customMetadata: customMetadata
)

// Track AVPlayerLayer
fpDataSDK.trackAvPlayerLayer(
    playerLayer: playerLayer,
    customMetadata: customMetadata
)

// Track AVPlayerViewController
fpDataSDK.trackAvPlayerController(
    playerController: playerController,
    customMetadata: customMetadata
)

// Dispatch event on video change
fpDataSDK.dispatchEvent(event: "videoChange", metadata: [
    "video_id": "NEW_ID",
    "video_title": "New Video"
])

```

Replace this block with the exact code where the issue occurs.

---

## Expected Behavior
```
<!-- Describe the expected outcome -->
```

## Actual Behavior
```
<!-- Describe what actually happened -->
```

---

## Environment

- **SDK Version**: [e.g., 1.0.x]
- **iOS Version**: [e.g., 17.2]
- **Device / Simulator**: [iPhone 15 Pro, Apple TV, Xcode Simulator]
- **Xcode Version**: [e.g., 15.3]
- **Integration Method**: Swift Package Manager (SPM)
- **Player Type Used**: AVPlayer / AVPlayerLayer / AVPlayerViewController

---

## Code Sample
```swift
// Provide a minimal reproducible sample
```

---

## Logs / Errors / Stack Trace
```
Paste console logs, crash logs, or any error messages here.
```

---

## Additional Context
Add any extra details that may help us debug the issue.

## Screenshots / Screen Recording
Attach screenshots or a screen recording, if applicable.

---
