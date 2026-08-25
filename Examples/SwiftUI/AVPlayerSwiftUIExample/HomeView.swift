import SwiftUI

/// A sample HLS stream shown on the home screen.
struct SampleVideo: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let duration: String
    let url: URL
}

enum Theme {
    static let accent = Color(red: 0.235, green: 0.353, blue: 0.937)
    static let accentDark = Color(red: 0.145, green: 0.204, blue: 0.639)
}

/// Replace with the Workspace Key from your FastPix dashboard (Workspaces).
let workspaceKey = "1029207880411545601"
var isTracking: Bool { workspaceKey != "YOUR_WORKSPACE_KEY" && !workspaceKey.isEmpty }

private let samples: [SampleVideo] = [
    SampleVideo(
        id: "sample-video-001",
        title: "Big Buck Bunny",
        subtitle: "Blender Foundation · HLS",
        duration: "9:56",
        url: URL(string: "https://stream.fastpix.io/16ac212a-0f4f-49c5-9fd7-a42d9ff61541.m3u8")!
    ),
    SampleVideo(
        id: "sample-video-002",
        title: "Apple Basic Stream",
        subtitle: "Multi-variant · HLS",
        duration: "10:34",
        url: URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!
    )
]

/// Landing screen listing sample streams. Selecting one opens `PlayerView`,
/// where the FastPix Video Data AVPlayer SDK is attached.
struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerCard
                Text("SAMPLE STREAMS")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                ForEach(samples) { video in
                    NavigationLink(value: video) {
                        VideoCard(video: video)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("FastPix Demo")
        .navigationDestination(for: SampleVideo.self) { PlayerView(video: $0) }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "waveform.badge.magnifyingglass")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 10)
            Text("Video Data · AVPlayer")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
            Text("Pick a stream to play. The FastPix SDK is attached to AVPlayer and streams real-time playback analytics to your dashboard.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [Theme.accent, Theme.accentDark],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

private struct VideoCard: View {
    let video: SampleVideo

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                LinearGradient(colors: [Theme.accent, Theme.accentDark],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "play.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
            }
            .frame(width: 108, height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(video.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(video.duration)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(Theme.accent.opacity(0.12), in: Capsule())
                    .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
