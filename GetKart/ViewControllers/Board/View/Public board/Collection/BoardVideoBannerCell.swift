//
//  BoardVideoBannerCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/05/26.
//

import UIKit

final class BoardVideoBannerCell: UICollectionViewCell {

    private let videoView = VideoPlayerUIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.clipsToBounds = true
        videoView.layer.cornerRadius = 20

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

    func play() { videoView.play() }
    func pause() { videoView.pause() }
}




