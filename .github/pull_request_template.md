# FastPix Video Data AVPlayer SDK - Documentation PR

## Documentation Changes

### What Changed
- [ ] New documentation added
- [ ] Existing documentation updated
- [ ] Documentation errors fixed
- [ ] Code examples updated
- [ ] Links and references updated

### Files Modified
- [ ] README.md
- [ ] docs/ files
- [ ] USAGE.md
- [ ] CONTRIBUTING.md
- [ ] Other: _______________

### Summary
**Brief description of changes:**

Updated documentation to reflect FastPix Video Data AVPlayer SDK integration, including setup, installation via Swift Package Manager, initialization, configuration, metadata handling, AVPlayer tracking, AVPlayerLayer tracking, AVPlayerViewController tracking, video stream changes, and tvOS support. Added detailed Swift code examples for tracking video analytics with custom metadata.

### Code Examples
```swift
import FastpixVideoDataAVPlayer

// Initialize the SDK for tracking AVPlayer analytics
let fpDataSDK = initAvPlayerTracking()

let customMetadata = [
  "data": [
        workspace_id: "WORKSPACE_KEY", // Replace with your actual workspace key
        video_title: "Test Content",   // Title of the video being played
        video_id: "f01a98s76t90p88i67x", // Unique identifier for the video
        viewer_id: "user12345",        // Unique viewer identifier
        video_content_type: "series",  // Content type (e.g., series, movie)
        video_stream_type: "on-demand",// Stream type (live/on-demand)
        custom_1: "",                  // Custom metadata field 1
        custom_2: ""                   // Custom metadata field 2
  ]
]

// Track AVPlayer
fpDataSDK.trackAvPlayer(
    player: player,   // AVPlayer instance
    customMetadata: customMetadata
)

// Track AVPlayerLayer
fpDataSDK.trackAvPlayerLayer(
    playerLayer: playerLayer, // AVPlayerLayer instance
    customMetadata: customMetadata
)

// Track AVPlayerViewController
fpDataSDK.trackAvPlayerController(
    playerController: playerController, // AVPlayerViewController instance
    customMetadata: customMetadata
)

// Dispatch events manually
fpDataSDK.dispatchEvent(event: "videoChange", metadata: [
    video_id: "123def",
    video_title: "Daalcheeni",
    video_series: "Comedy Capsule"
])
```

### Testing
- [ ] All code examples tested on iOS
- [ ] Links verified
- [ ] Grammar checked
- [ ] Formatting consistent

### Review Checklist
- [ ] Content is accurate
- [ ] Code examples work as expected
- [ ] Links are working
- [ ] Grammar is correct
- [ ] Formatting is consistent

---

**Ready for review!**
