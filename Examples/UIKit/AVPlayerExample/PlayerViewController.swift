import UIKit
import AVKit
import AVFoundation
import FastpixVideoDataAVPlayer

/// Plays a stream through `AVPlayerViewController` and attaches the
/// FastPix Video Data AVPlayer SDK to collect playback analytics.
final class PlayerViewController: UIViewController {

    private let video: SampleVideo

    // Hold a strong reference so tracking lives for the whole playback session.
    private let fpDataSDK = initAvPlayerTracking()

    private var playerViewController: AVPlayerViewController?

    // Replace with the Workspace Key from your FastPix dashboard.
    private let workspaceKey = "1029207880411545601"

    private var isTracking: Bool { workspaceKey != "YOUR_WORKSPACE_KEY" && !workspaceKey.isEmpty }

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    init(video: SampleVideo) {
        self.video = video
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = video.title
        navigationItem.largeTitleDisplayMode = .never
        setUpLayout()
    }

    private func setUpLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        contentStack.addArrangedSubview(makePlayerCard())
        contentStack.addArrangedSubview(makeStatusPill())
        contentStack.addArrangedSubview(makeMetadataCard())
    }

    // MARK: - Player

    private func makePlayerCard() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .black
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.18
        container.layer.shadowRadius = 12
        container.layer.shadowOffset = CGSize(width: 0, height: 6)

        let player = AVPlayer(url: video.url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.view.backgroundColor = .black
        playerVC.view.layer.cornerRadius = 16
        playerVC.view.layer.cornerCurve = .continuous
        playerVC.view.clipsToBounds = true
        self.playerViewController = playerVC

        addChild(playerVC)
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(playerVC.view)
        NSLayoutConstraint.activate([
            playerVC.view.topAnchor.constraint(equalTo: container.topAnchor),
            playerVC.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            playerVC.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            playerVC.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            container.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 9.0 / 16.0)
        ])
        playerVC.didMove(toParent: self)

        // All metadata fields must live under the "data" key.
        let customMetadata: [String: Any] = ["data": trackedFields]

        fpDataSDK.trackAvPlayerController(
            playerController: playerVC,
            customMetadata: customMetadata
        )

        player.play()
        return container
    }

    // MARK: - Status pill

    private func makeStatusPill() -> UIView {
        let pill = UIView()
        pill.backgroundColor = (isTracking ? UIColor.systemGreen : UIColor.systemOrange).withAlphaComponent(0.12)
        pill.layer.cornerRadius = 14
        pill.layer.cornerCurve = .continuous
        pill.translatesAutoresizingMaskIntoConstraints = false

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = isTracking ? .systemGreen : .systemOrange
        dot.layer.cornerRadius = 4

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = isTracking ? .systemGreen : .systemOrange
        label.text = isTracking ? "FastPix tracking active" : "Add your Workspace Key to start tracking"

        pill.addSubview(dot)
        pill.addSubview(label)
        NSLayoutConstraint.activate([
            pill.heightAnchor.constraint(equalToConstant: 40),
            dot.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 16),
            dot.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(lessThanOrEqualTo: pill.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
        ])
        return pill
    }

    // MARK: - Metadata card

    /// The metadata being reported to FastPix (used both for tracking and display).
    private var trackedFields: [String: Any] {
        [
            "workspace_id": workspaceKey,
            "video_title": video.title,
            "video_id": video.id,
            "viewer_id": "user-12345",
            "video_content_type": "movie",
            "video_stream_type": "on-demand",
            "player_name": "AVPlayerExample"
        ]
    }

    private func makeMetadataCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16
        card.layer.cornerCurve = .continuous
        card.translatesAutoresizingMaskIntoConstraints = false

        let header = UILabel()
        header.text = "TRACKED METADATA"
        header.font = .systemFont(ofSize: 13, weight: .semibold)
        header.textColor = .secondaryLabel

        let rows = UIStackView()
        rows.axis = .vertical
        rows.spacing = 0

        let order = ["workspace_id", "video_id", "video_title", "video_content_type", "video_stream_type", "viewer_id", "player_name"]
        for (index, key) in order.enumerated() {
            let value = trackedFields[key].map { "\($0)" } ?? "—"
            rows.addArrangedSubview(makeMetadataRow(key: key, value: value, showSeparator: index < order.count - 1))
        }

        let stack = UIStackView(arrangedSubviews: [header, rows])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private func makeMetadataRow(key: String, value: String, showSeparator: Bool) -> UIView {
        let keyLabel = UILabel()
        keyLabel.text = key
        keyLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        keyLabel.textColor = .secondaryLabel
        keyLabel.setContentHuggingPriority(.required, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .firstBaseline

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        row.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 11),
            row.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -11),
            row.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor)
        ])

        if showSeparator {
            let separator = UIView()
            separator.backgroundColor = .separator
            separator.translatesAutoresizingMaskIntoConstraints = false
            wrapper.addSubview(separator)
            NSLayoutConstraint.activate([
                separator.heightAnchor.constraint(equalToConstant: 0.5),
                separator.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
                separator.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
                separator.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
            ])
        }
        return wrapper
    }

    /// Call when loading a new video into the same player (playlists / "up next")
    /// so the SDK starts a fresh view.
    func changeVideo(to next: SampleVideo) {
        fpDataSDK.dispatchEvent(event: "videoChange", metadata: [
            "video_id": next.id,
            "video_title": next.title
        ])
    }
}
