import AVKit
import MediaPlayer
import AVFoundation
import Combine
import Network
import WebKit
import CoreFoundation
import Foundation
import FastpixiOSVideoDataCore

public class initAvPlayerTracking: NSObject {
    
    public var fpCoreMetrix = FastpixMetrix()
    public var initiatedAvPlayer: AVPlayer?
    public var avPlayerLayer: AVPlayerLayer?
    public var avPlayerController: AVPlayerViewController?
    public var avPlayerItem: AVPlayerItem?
    public var playerToken: String? = ""
    public var customMetadata: [String: Any] = [:]
    public var periodicTimeObserver: Any?
    public var playerTimer: Timer?
    public var lastPlayheadTimeMs: Float = 0.0
    public var lastPlayheadTimeUpdated: CFAbsoluteTime = 0.0
    public var lastAdvertisedBitrate: Int = 0
    public var videoTransitionState: String = ""
    public var lastTimeUpdate = 0.0
    public var isVideoSeeking: Bool = false
    public var isPlayStarted: Bool = false
    public var isEnded: Bool = false
    public var lastTransferEventCount: Int = 0
    public var lastTransferDuration: Int = 0
    public var lastTransferredBytes: Int = 0
    
    public func trackAvPlayer(player: AVPlayer, playerLayer: AVPlayerLayer?, customMetadata: [String: Any]) {
        initializeAvPlayerTracking(player: player, playerLayer: playerLayer, customMetadata: customMetadata)
    }
    
    public func trackAvPlayerLayer(playerLayer: AVPlayerLayer, customMetadata: [String: Any]) {
        if let player = playerLayer.player {
            initializeAvPlayerTracking(player: player, playerLayer: playerLayer, customMetadata: customMetadata)
            avPlayerItem = playerLayer.player?.currentItem
        } else {
            print("Error: AVPlayerLayer does not have an associated AVPlayer instance.")
        }
    }
    
    public func trackAvPlayerController(playerController: AVPlayerViewController, customMetadata: [String: Any]) {
        if let player = playerController.player {
            initializeAvPlayerTracking(player: player, playerLayer: nil, customMetadata: customMetadata)
        } else {
            print("Error: AVPlayerViewController does not have an associated AVPlayer instance.")
        }
    }
    
    public func initializeAvPlayerTracking(player: AVPlayer, playerLayer: AVPlayerLayer?, customMetadata: [String: Any]) {
        if let _ = initiatedAvPlayer {
            initiatedAvPlayer = nil
            avPlayerLayer = nil
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: nil)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)
            fpCoreMetrix.dispatch(key: playerToken ?? "", event: "destroy", metadata: [:])
            resetInitialization()
        }
        
        if playerToken == "" {
            playerToken = UUID().uuidString.lowercased() as String
        }
        
        self.initiatedAvPlayer = player
        self.avPlayerLayer = playerLayer
        self.customMetadata = customMetadata
        lastTimeUpdate = CFAbsoluteTimeGetCurrent() - 0.1
        configureAvPlayerTracking()
        dispatchEvent(event: "playerReady", metadata: [:])
        videoTransitionState = "playerready"
        periodicTimeObserver = initiatedAvPlayer?.addPeriodicTimeObserver(
            forInterval: getTimeObserverInternal(),
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            if self.isTryingToPlay() {
                self.videoTransitionState = "buffering"
            } else if self.isBuffering() {
                self.emitPlaying()
            } else {
                self.dispatchTimeUpdateEvent()
            }
            self.seekTracker()
            self.updateLastPlayheadTime()
        }
        
        playerTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.dispatchTimeUpdateEvent()
        }
        
        player.addObserver(self, forKeyPath: "rate", options: [.initial, .new], context: nil)
        player.currentItem?.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.initial, .new], context: nil)
        player.addObserver(self, forKeyPath: "currentTime", options: [.initial, .new], context: nil)
        player.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.initial, .new], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerItemNewErrorLogEntry(_:)), name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAccessLogEntry(_:)), name: .AVPlayerItemNewAccessLogEntry, object: player.currentItem)
    }
    
    @objc public func playerDidFinishPlaying(_: Notification) {
        if initiatedAvPlayer?.currentItem != nil && !isEnded {
            isEnded = true
            isPlayStarted = false
            dispatchEvent(event: "ended", metadata: [:])
            videoTransitionState = "ended"
        }
    }
    
    @objc public func handlePlayerItemNewErrorLogEntry(_ notification: Notification) {
        let videoURL: String = (initiatedAvPlayer?.currentItem?.asset as? AVURLAsset)?.url.absoluteString ?? ""
        let url = URL(string: videoURL)
        let host = url?.host
        
        guard let playerItem = notification.object as? AVPlayerItem else { return }
        guard let errorLogEvent = playerItem.errorLog()?.events.last else { return }
        
        if (playerItem.errorLog()?.events.count ?? 0 > 0) && !isEnded {
            dispatchEvent(event: "requestFailed", metadata: [
                "request_error": errorLogEvent.errorDomain,
                "request_error_code": String(errorLogEvent.errorStatusCode),
                "request_error_text": errorLogEvent.errorComment ?? "",
                "request_hostname": host as Any,
                "request_url": videoURL
            ])
        }
    }
    
    @objc private func handleAccessLogEntry(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem,
              let _ = playerItem.accessLog(),
              let _ = playerItem.accessLog()?.events.last else { return }
        
        if let accessLog = playerItem.accessLog() {
            self.calculateBandwidthMetricFromAccessLog(accessLog)
            self.handleRenditionChangeInAccessLog(accessLog)
        }
    }
    
    public func calculateBandwidthMetricFromAccessLog(_ log: AVPlayerItemAccessLog) {
        guard log.events.count > 0, let lastEvent = log.events.last else { return }
        
        if lastTransferEventCount != log.events.count {
            lastTransferDuration = 0
            lastTransferredBytes = 0
            lastTransferEventCount = log.events.count
        }
        
        let requestCompletedTime = Date().timeIntervalSince1970
        var requestCompleteAttr: [String: Any] = [:]
        requestCompleteAttr["request_type"] = "media"
        
        let requestStartSecs = requestCompletedTime - (lastEvent.transferDuration - Double(lastTransferDuration))
        requestCompleteAttr["request_start"] = NSNumber(value: Int(requestStartSecs * 1000))
        requestCompleteAttr["request_response_end"] = NSNumber(value: Int(requestCompletedTime * 1000))
        requestCompleteAttr["request_bytes_loaded"] = NSNumber(value: Int(lastEvent.numberOfBytesTransferred) - Int(lastTransferredBytes))
        
        if requestCompleteAttr["request_bytes_loaded"] as? Int ?? 0 > 0 {
            dispatchEvent(event: "requestCompleted", metadata: requestCompleteAttr)
        }
        lastTransferredBytes = Int(lastEvent.numberOfBytesTransferred)
        lastTransferDuration = Int(lastEvent.transferDuration)
    }
    
    func doubleValuesAreEqual(_ x: Float, _ n: Float) -> Bool {
        return abs(x - n) < Float.ulpOfOne
    }
    
    func handleRenditionChangeInAccessLog(_ log: AVPlayerItemAccessLog) {
        guard let lastEvent = log.events.last else { return }
        
        let advertisedBitrate = lastEvent.indicatedBitrate
        let bitrateHasChanged = !doubleValuesAreEqual(Float(lastAdvertisedBitrate), Float(advertisedBitrate))
        
        if !bitrateHasChanged { return }
        
        if lastAdvertisedBitrate == 0 || !isPlayStarted {
            lastAdvertisedBitrate = Int(advertisedBitrate)
            return
        }
        
        guard lastEvent.playbackStartDate != nil else { return }
        dispatchEvent(event: "variantChanged", metadata: ["video_source_bitrate": abs(Int(advertisedBitrate))])
    }
    
    public func isPausedWhileAirPlaying() -> Bool {
#if os(visionOS)
        return false
#else
        return initiatedAvPlayer?.isExternalPlaybackActive == true && initiatedAvPlayer?.timeControlStatus == .paused
#endif
    }
    
    public func checkPlayerIsError() -> Bool {
        guard initiatedAvPlayer != nil, initiatedAvPlayer?.currentItem != nil, avPlayerLayer != nil else {
            return false
        }
        return initiatedAvPlayer?.error != nil || initiatedAvPlayer?.currentItem?.error != nil
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "status":
            if checkPlayerIsError() {
                emitError()
            }
            
        case "rate":
            if initiatedAvPlayer?.rate == 0.0 && isPlayingOrTryingToPlay() && !isEnded {
                emitPause()
            } else if initiatedAvPlayer?.rate != 0.0 && !isPlayingOrTryingToPlay() && !isEnded {
                emitPlay()
            }
            
        case "timeControlStatus":
            if isVideoSeeking && videoTransitionState == "playing" {
                emitPlaying()
            }
            
        case "playbackBufferEmpty":
            // FIX: Merged nested if + removed useless parentheses
            if initiatedAvPlayer?.currentItem?.isPlaybackBufferEmpty == true
                && initiatedAvPlayer?.timeControlStatus != .playing
                && isPausedWhileAirPlaying()
                && !isEnded {
                emitPlay()
                emitPlaying()
            }
            
        default:
            break
        }
    }
    
    public func isPlaying() -> Bool {
        return videoTransitionState == "playing"
    }
    
    public func isBuffering() -> Bool {
        return videoTransitionState == "buffering"
    }
    
    public func isTryingToPlay() -> Bool {
        return videoTransitionState == "play"
    }
    
    public func isPaused() -> Bool {
        return videoTransitionState == "paused"
    }
    
    public func isPlayingOrTryingToPlay() -> Bool {
        return isPlaying() || isTryingToPlay()
    }
    
    public func emitError() {
        guard initiatedAvPlayer != nil, initiatedAvPlayer?.currentItem != nil else { return }
        
        var errorMetadata: [String: Any] = [:]
        
        if let playerError = initiatedAvPlayer?.error as NSError? {
            let errorCode = playerError.code
            if errorCode != 0 && errorCode != NSNotFound {
                errorMetadata["player_error_code"] = "\(errorCode)"
            }
            if !playerError.localizedDescription.isEmpty {
                errorMetadata["player_error_message"] = "\(playerError.localizedDescription)"
            }
        } else if let playerItemError = initiatedAvPlayer?.currentItem?.error as NSError? {
            let errorCode = playerItemError.code
            if errorCode != 0 && errorCode != NSNotFound {
                errorMetadata["player_error_code"] = "\(errorCode)"
            }
            if !playerItemError.localizedDescription.isEmpty {
                errorMetadata["player_error_message"] = "\(playerItemError.localizedDescription)"
            }
        }
        
        if errorMetadata["player_error_code"] != nil {
            dispatchEvent(event: "error", metadata: errorMetadata)
            videoTransitionState = "error"
        }
    }
    
    public func emitPlay() {
        guard initiatedAvPlayer != nil else { return }
        if !isPlayStarted {
            isPlayStarted = true
            updateLastPlayheadTime()
        }
        dispatchEvent(event: "play", metadata: [:])
        videoTransitionState = "play"
        seekTracker()
        updateLastPlayheadTime()
    }
    
    public func emitPlaying() {
        guard initiatedAvPlayer != nil else { return }
        if isVideoSeeking {
            isVideoSeeking = false
            dispatchEvent(event: "seeked", metadata: [:])
        }
        dispatchEvent(event: "playing", metadata: [:])
        videoTransitionState = "playing"
    }
    
    public func emitPause() {
        guard initiatedAvPlayer != nil else { return }
        dispatchEvent(event: "pause", metadata: [:])
        videoTransitionState = "paused"
        seekTracker()
    }
    
    public func getTimeObserverInternal() -> CMTime {
        return CMTimeMakeWithSeconds(0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    }
    
    public func seekTracker() {
        guard isPlayStarted else { return }
        let playheadTimeElapsed = (getCurrentPlayheadTimeMs() - lastPlayheadTimeMs) / 1000
        let wallTimeElapsed = CFAbsoluteTimeGetCurrent() - lastPlayheadTimeUpdated
        let drift = playheadTimeElapsed - Float(wallTimeElapsed)
    
        if abs(playheadTimeElapsed) > 0.5 && abs(drift) > 0.2 {
            if isPlayStarted || videoTransitionState == "paused" {
                isVideoSeeking = true
                dispatchEvent(event: "seeking", metadata: [:])
            }
        } else if (videoTransitionState == "buffering" || videoTransitionState == "playing") && isVideoSeeking {
            isVideoSeeking = false
            dispatchEvent(event: "seeked", metadata: [:])
        }
    }
    
    public func updateLastPlayheadTime() {
        lastPlayheadTimeMs = getCurrentPlayheadTimeMs()
        lastPlayheadTimeUpdated = CFAbsoluteTimeGetCurrent()
    }
    
    public func getCurrentPlayheadTimeMs() -> Float {
        guard let currentTime = initiatedAvPlayer?.currentTime() else { return 0 }
        return Float(CMTimeGetSeconds(currentTime) * 1000)
    }
    
    public func fetchAvPlayerCurrentTime() -> Int {
        guard initiatedAvPlayer != nil else { return 0 }
        let currentTime = (initiatedAvPlayer?.currentItem?.currentTime().seconds ?? 0) * 1000
        return Int(currentTime)
    }
    
    public func getUniqueTimeStamp() -> Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
    
    public func dispatchTimeUpdateEvent() {
        guard initiatedAvPlayer != nil, isPlaying() else { return }
        
        let currentTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        if currentTime - lastTimeUpdate < 0.1 { return }
        
        lastTimeUpdate = currentTime
        dispatchEvent(event: "timeupdate", metadata: ["viewer_timestamp": getUniqueTimeStamp()])
    }
    
    public func getVideoSourceDimensions() -> CGSize {
        guard let playerItem = initiatedAvPlayer?.currentItem else { return .zero }
        for track in playerItem.tracks {
            if let assetTrack = track.assetTrack {
                let formatDescriptions = assetTrack.formatDescriptions as! [CMFormatDescription]
                for desc in formatDescriptions {
                    if CMFormatDescriptionGetMediaType(desc) == kCMMediaType_Video {
                        let dimensions = CMVideoFormatDescriptionGetDimensions(desc)
                        return CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
                    }
                }
            }
        }
        return .zero
    }
    
    public func fetchAvPlayerVideoState() -> [String: Any] {
        let videoSize = getVideoSourceDimensions()
        let videoURL: String? = (initiatedAvPlayer?.currentItem?.asset as? AVURLAsset)?.url.absoluteString
        let duration: Double? = initiatedAvPlayer?.currentItem?.asset.duration.seconds
        
        var videoState: [String: Any] = [
            "video_source_width": Int(videoSize.width),
            "video_source_height": Int(videoSize.height),
            "player_width": Int(avPlayerLayer?.bounds.width ?? 0),
            "player_height": Int(avPlayerLayer?.bounds.height ?? 0),
            "player_is_paused": initiatedAvPlayer?.timeControlStatus == .paused,
            "video_source_duration": (duration ?? 0) * 1000
        ]
        
        if let url = videoURL {
            videoState["video_source_url"] = url
        }
        
        if lastAdvertisedBitrate > 0 {
            videoState["video_source_bitrate"] = lastAdvertisedBitrate
        }
        
        return videoState
    }
    
    public func dispatchEvent(event: String, metadata: [String: Any] = [:]) {
        if playerToken != "" || playerToken != nil {
            fpCoreMetrix.dispatch(key: playerToken ?? "", event: event, metadata: metadata)
        }
    }
    
    public func configureAvPlayerTracking() {
        var updatedMetadata = customMetadata
        updatedMetadata["player_software_name"] = "iOS Av Player"
        updatedMetadata["player_software_version"] = "1.0.0"
        fpCoreMetrix.configure(key: playerToken ?? "", passableMetadata: updatedMetadata, fetchPlayheadTime: fetchAvPlayerCurrentTime, fetchVideoState: fetchAvPlayerVideoState)
    }
    
    public func destroPlayer() {
        guard initiatedAvPlayer == nil else { return }
        dispatchEvent(event: "destroy", metadata: [:])
    }
    
    public func videoChange(customMetadata: [String: Any]) {
        dispatchEvent(event: "videoChange", metadata: customMetadata)
    }
    
    public func resetInitialization() {
        playerTimer?.invalidate()
        playerTimer = nil
        
        if initiatedAvPlayer != nil, let observer = periodicTimeObserver {
            initiatedAvPlayer?.removeTimeObserver(observer)
            periodicTimeObserver = nil
        }
        
        playerToken = ""
        lastAdvertisedBitrate = 0
        customMetadata = [:]
        lastPlayheadTimeMs = 0.0
        lastPlayheadTimeUpdated = 0.0
        videoTransitionState = ""
        lastTimeUpdate = 0.0
        isVideoSeeking = false
        isPlayStarted = false
        isEnded = false
        lastTransferEventCount = 0
        lastTransferDuration = 0
        lastTransferredBytes = 0
    }
}
