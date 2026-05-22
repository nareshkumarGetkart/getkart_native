//
//  Untitled.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/05/26.
//

import UIKit
import Kingfisher

final class BoardBannerCell: UICollectionViewCell {

    private let imgView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 20

        contentView.addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
        imgView.kf.cancelDownloadTask()
    }

    func configure(item: ItemModel) {
        guard let urlStr = item.image,
              let url = URL(string: urlStr) else { return }
        imgView.kf.setImage(with: url)
    }
}
