# Changelog

All notable changes to this project will be documented in this file.

## [1.0.7]
- Updated iOS Data Core SDK.
- Code standardization updates applied across the SDK to align with best practices and strengthen overall stability.

## [1.0.6]
- Updated iOS Data Core SDK by updating the SDK’s default metrics collection domain to improve endpoint reliability and alignment with current infrastructure.

## [1.0.5]
- Added support for tvOS, enabling all existing features including engagement tracking, playback quality monitoring, error reporting, and custom metadata on Apple TV.
- Updated iOS Video Data Core.

## [1.0.4]
- Added `requset_hostname` and `request_url` parameters in the requestFailed event. 

## [1.0.3]
- Updated iOS Video Data Core.

## [1.0.2]
- Updated iOS Video Data Core.

## [1.0.1]
- Updated iOS Video Data Core.

## [1.0.0]

### Added
- **Integration with AVPlayer**: 
  - Enabled video performance tracking using FastPix Data SDK, supporting user engagement metrics, playback quality monitoring, and real-time streaming diagnostics.
  - Provides robust error management and reporting capabilities for video performance tracking.
  - Includes support for custom metadata, enabling users to pass optional fields such as `video_id`, `video_title`, `video_duration`, and more.
  - Introduced event tracking for `videoChange` to handle metadata updates during playback transitions.
