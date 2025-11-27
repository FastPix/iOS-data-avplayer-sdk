---
name: Documentation Issue
about: Report problems with the FastPix iOS Video Data AVPlayer SDK documentation
title: '[DOCS] '
labels: ['documentation', 'needs-triage']
assignees: ''
---

# Documentation Issue

Thank you for helping improve the FastPix iOS Video Data AVPlayer SDK documentation! Please provide the following details:

---

## Issue Type
- [ ] Missing documentation
- [ ] Incorrect or outdated information
- [ ] Unclear explanation
- [ ] Broken links
- [ ] Missing/incorrect code example
- [ ] Other: _______________

---

## Description
**Describe the documentation issue clearly:**

<!-- What is wrong or confusing in the current documentation? -->

---

## Current Documentation (Problematic Section)
**Paste the exact snippet or explain what the current documentation says:**

<!-- Include lines, screenshots, or text that contain the issue -->

---

## Expected Documentation (Correct Version)

Provide the corrected or expected content.  
Example:

```swift
// Correct usage example for FastPix Video Data AVPlayer SDK
import FastpixVideoDataAVPlayer

let fpDataSDK = initAvPlayerTracking()

let customMetadata = [
    "data": [
        "workspace_id": "WORKSPACE_KEY",     // Required workspace identifier
        "video_title": "Test Content",       // Title of the current video
        "video_id": "f01a98s76t90p88i67x"    // Unique video identifier
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

// Notify SDK when a new video starts playing
fpDataSDK.dispatchEvent(event: "videoChange", metadata: [
    "video_id": "123def",
    "video_title": "Daalcheeni",
    "video_series": "Comedy Capsule"
])
```

---

## Location of Issue
**Where is the issue located?**

- [ ] README.md
- [ ] docs/ directory
- [ ] USAGE.md
- [ ] API reference
- [ ] Code examples
- [ ] tvOS notes
- [ ] Other: _______________

**Specify file + section (required):**

<!-- e.g., README.md → "Basic Integration" section -->

---

## Impact
**How is this documentation issue affecting users?**

- [ ] Prevents integration / blocks onboarding
- [ ] Causes incorrect implementation
- [ ] Creates developer confusion
- [ ] Leads to support requests
- [ ] Other: _______________

---

## Proposed Fix
**Describe how the documentation should be updated:**

<!-- Provide corrections, updated code, or improved explanation -->

---

## Additional Context
Include any supporting details, logs, screenshots, discussions, or links.

---

## Related Issues
- GitHub Issues: _______________________
- User Feedback: _______________________

---

## How Did You Find the Issue?
- [ ] While integrating the SDK
- [ ] User-reported confusion
- [ ] Code did not work as documented
- [ ] Reviewing for accuracy
- [ ] Other: _______________

---

## Priority
Please assign a priority:

- [ ] Critical (Blocks SDK usage)
- [ ] High (Major confusion/inaccuracy)
- [ ] Medium (Clarification needed)
- [ ] Low (Minor improvement)

---

## Checklist
Before submitting, please confirm:

- [ ] I identified the specific documentation issue
- [ ] I included current and expected content
- [ ] I explained the impact
- [ ] I suggested a fix
- [ ] I checked if this was already reported
- [ ] I attached additional context if needed

---

**Thank you for helping improve the FastPix Video Data AVPlayer SDK documentation! 📘**
