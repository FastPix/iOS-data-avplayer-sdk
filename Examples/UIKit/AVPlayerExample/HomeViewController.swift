import UIKit

/// A sample stream shown on the home screen.
struct SampleVideo {
    let id: String
    let title: String
    let subtitle: String
    let duration: String
    let url: URL
}

/// Shared brand styling for the demo app.
enum Theme {
    static let accent = UIColor(red: 0.235, green: 0.353, blue: 0.937, alpha: 1)
    static let accentDark = UIColor(red: 0.145, green: 0.204, blue: 0.639, alpha: 1)
}

/// A view whose background is a horizontal-to-vertical gradient between two colors.
final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    init(colors: [UIColor]) {
        super.init(frame: .zero)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// Landing screen that lists a few sample streams. Selecting one opens the
/// player screen, where the FastPix Video Data AVPlayer SDK is attached.
final class HomeViewController: UIViewController {

    private let samples: [SampleVideo] = [
        SampleVideo(
            id: "sample-video-001",
            title: "Big Buck Bunny",
            subtitle: "On-demand · HLS",
            duration: "9:56",
            url: URL(string: "https://stream.fastpix.com/f7a1becb-b08a-4d5b-8b09-9f679194705c.m3u8")!
        ),
        SampleVideo(
            id: "sample-video-002",
            title: "Spider-Man Noir",
            subtitle: "On-demand · HLS",
            duration: "10:34",
            url: URL(string: "https://stream.fastpix.com/7c8d5087-edf7-462f-a1b3-e2fbd30747fa.m3u8")!
        )
    ]

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = .systemGroupedBackground
        table.rowHeight = 104
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        table.register(VideoCardCell.self, forCellReuseIdentifier: VideoCardCell.reuseID)
        table.tableHeaderView = makeHeaderView()
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "FastPix Demo"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Size the table header to fit its content once the width is known.
        guard let header = tableView.tableHeaderView else { return }
        let targetSize = CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let height = header.systemLayoutSizeFitting(targetSize).height
        if header.frame.height != height {
            header.frame.size.height = height
            tableView.tableHeaderView = header
        }
    }

    private func makeHeaderView() -> UIView {
        let card = GradientView(colors: [Theme.accent, Theme.accentDark])
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 20
        card.layer.cornerCurve = .continuous
        card.clipsToBounds = true

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        iconContainer.layer.cornerRadius = 12

        let icon = UIImageView(image: UIImage(systemName: "waveform.badge.magnifyingglass"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        iconContainer.addSubview(icon)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Video Data · AVPlayer"
        title.font = .systemFont(ofSize: 22, weight: .bold)
        title.textColor = .white

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.numberOfLines = 0
        subtitle.text = "Pick a stream to play. The FastPix SDK is attached to AVPlayer and streams real-time playback analytics to your dashboard."
        subtitle.font = .preferredFont(forTextStyle: .subheadline)
        subtitle.textColor = UIColor.white.withAlphaComponent(0.9)

        card.addSubview(iconContainer)
        card.addSubview(title)
        card.addSubview(subtitle)

        NSLayoutConstraint.activate([
            iconContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            iconContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),

            title.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            subtitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            subtitle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            subtitle.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])

        let sectionLabel = UILabel()
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.text = "SAMPLE STREAMS"
        sectionLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        sectionLabel.textColor = .secondaryLabel

        let wrapper = UIView()
        wrapper.addSubview(card)
        wrapper.addSubview(sectionLabel)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -16),

            sectionLabel.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 24),
            sectionLabel.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            sectionLabel.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -4)
        ])
        wrapper.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 240)
        return wrapper
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        samples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoCardCell.reuseID, for: indexPath) as! VideoCardCell
        cell.configure(with: samples[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let playerVC = PlayerViewController(video: samples[indexPath.row])
        navigationController?.pushViewController(playerVC, animated: true)
    }
}

/// Card-style cell with a gradient artwork thumbnail, title, subtitle and a duration pill.
final class VideoCardCell: UITableViewCell {
    static let reuseID = "VideoCardCell"

    private let card = UIView()
    private let artwork = GradientView(colors: [Theme.accent, Theme.accentDark])
    private let playIcon = UIImageView(image: UIImage(systemName: "play.fill"))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let durationPill = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setUp()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setUp() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.addSubview(card)

        artwork.translatesAutoresizingMaskIntoConstraints = false
        artwork.layer.cornerRadius = 12
        artwork.layer.cornerCurve = .continuous
        artwork.clipsToBounds = true
        card.addSubview(artwork)

        playIcon.translatesAutoresizingMaskIntoConstraints = false
        playIcon.tintColor = .white
        playIcon.contentMode = .scaleAspectFit
        artwork.addSubview(playIcon)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        subtitleLabel.textColor = .secondaryLabel

        durationPill.translatesAutoresizingMaskIntoConstraints = false
        durationPill.font = .systemFont(ofSize: 12, weight: .semibold)
        durationPill.textColor = Theme.accent
        durationPill.backgroundColor = Theme.accent.withAlphaComponent(0.12)
        durationPill.textAlignment = .center
        durationPill.layer.cornerRadius = 9
        durationPill.clipsToBounds = true

        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(durationPill)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            artwork.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            artwork.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            artwork.widthAnchor.constraint(equalToConstant: 108),
            artwork.heightAnchor.constraint(equalToConstant: 68),

            playIcon.centerXAnchor.constraint(equalTo: artwork.centerXAnchor),
            playIcon.centerYAnchor.constraint(equalTo: artwork.centerYAnchor),
            playIcon.widthAnchor.constraint(equalToConstant: 22),
            playIcon.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.topAnchor.constraint(equalTo: artwork.topAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: artwork.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            durationPill.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            durationPill.bottomAnchor.constraint(equalTo: artwork.bottomAnchor, constant: -2),
            durationPill.heightAnchor.constraint(equalToConstant: 18),
            durationPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    func configure(with video: SampleVideo) {
        titleLabel.text = video.title
        subtitleLabel.text = video.subtitle
        durationPill.text = "  \(video.duration)  "
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.card.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}
