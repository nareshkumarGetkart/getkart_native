//
//  BoardVideoCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/05/26.
//




import UIKit
import AVFoundation


final class BoardVideoCell: UICollectionViewCell {

    private let videoView = VideoPlayerUIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.clipsToBounds = true
        videoView.layer.cornerRadius = 18

        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        videoView.cleanup()
    }

    func configure(item: ItemModel) {

        guard let link = item.videoLink,
              let url = URL(string: link) else { return }

        videoView.configure(url: url)
    }

    func play() {
        videoView.play()
    }

    func pause() {
        videoView.pause()
    }
}


final class VideoPlayerUIView: UIView {

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    func configure(url: URL) {

        if player == nil {
            player = AVPlayer()
            playerLayer = self.layer as? AVPlayerLayer
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.player = player
        }

        let item = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: item)
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func cleanup() {
        pause()
        player?.replaceCurrentItem(with: nil)
        playerLayer?.player = nil
        player = nil
    }
}
