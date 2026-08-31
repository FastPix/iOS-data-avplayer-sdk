import SwiftUI
import AVKit
import FastpixVideoDataAVPlayer

/// Owns the `AVPlayer` and the FastPix tracking object for one playback session.
///
/// The player and the SDK must live here — in an `ObservableObject` held by
/// `@StateObject` — not in the `View` struct, which SwiftUI recreates on every
/// render. `attach` wires the SDK to the same `AVPlayer` the `VideoPlayer` shows;
/// `teardown` stops tracking when the screen goes away.
@MainActor
final class PlayerModel: ObservableObject {
    let player: AVPlayer
    private let fpDataSDK = initAvPlayerTracking()
    private var started = false

    init(url: URL) {
        player = AVPlayer(url: url)
    }

    func attach(video: SampleVideo) {
        guard !started, isTracking else { player.play(); return }
        started = true

        // All metadata fields must live under the "data" key.
        let customMetadata: [String: Any] = ["data": [
            "workspace_id": workspaceKey,
            "video_title": video.title,
            "video_id": video.id,
            "viewer_id": "user-12345",
            "video_content_type": "movie",
            "video_stream_type": "on-demand",
            "player_name": "AVPlayerSwiftUIExample"
        ]]

        // SwiftUI's VideoPlayer has no AVPlayerLayer, so pass the player directly.
        fpDataSDK.trackAvPlayer(player: player, playerLayer: nil, customMetadata: customMetadata)
        player.play()
    }

    func teardown() {
        player.pause()
        // Stops the SDK's periodic time observer and internal timer.
        fpDataSDK.resetInitialization()
    }
}

/// Plays a stream in a SwiftUI `VideoPlayer` with the FastPix SDK attached.
struct PlayerView: View {
    let video: SampleVideo
    @StateObject private var model: PlayerModel

    init(video: SampleVideo) {
        self.video = video
        _model = StateObject(wrappedValue: PlayerModel(url: video.url))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VideoPlayer(player: model.player)
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.18), radius: 12, y: 6)

                statusPill
                metadataCard
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(video.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { model.attach(video: video) }
        .onDisappear { model.teardown() }
    }

    private var statusPill: some View {
        let color: Color = isTracking ? .green : .orange
        return HStack(spacing: 10) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(isTracking ? "FastPix tracking active" : "Add your Workspace Key to start tracking")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16).frame(height: 40)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var metadataCard: some View {
        let rows: [(String, String)] = [
            ("workspace_id", workspaceKey),
            ("video_id", video.id),
            ("video_title", video.title),
            ("video_content_type", "movie"),
            ("video_stream_type", "on-demand"),
            ("viewer_id", "user-12345"),
            ("player_name", "AVPlayerSwiftUIExample")
        ]
        return VStack(alignment: .leading, spacing: 12) {
            Text("TRACKED METADATA")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    HStack {
                        Text(row.0)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 12)
                        Text(row.1)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.vertical, 11)
                    if index < rows.count - 1 { Divider() }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
