//
//  Untitled.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/05/26.
//


import UIKit

final class BoardFeedCollectionVC: UIViewController {

     var items: [ItemModel] = []
    private var heightCache: [Int: CGFloat] = [:]

    var onLoadNextPage: (() -> Void)?
    var onTapItem: ((ItemModel) -> Void)?
    var onOpenURL: ((URL) -> Void)?
    var onRefresh: (() -> Void)?
    
    private lazy var layout: PinterestLayout = {
        let l = PinterestLayout()
        l.delegate = self
        l.numberOfColumns = 2
        l.cellPadding = 6
        return l
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        cv.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 120, right: 5)

        cv.register(BoardItemCell.self, forCellWithReuseIdentifier: "BoardItemCell")
        cv.register(BoardVideoCell.self, forCellWithReuseIdentifier: "BoardVideoCell")
        cv.register(BoardBannerCell.self, forCellWithReuseIdentifier: "BoardBannerCell")
        cv.register(BoardVideoBannerCell.self, forCellWithReuseIdentifier: "BoardVideoBannerCell")

        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresh
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollToTop),
            name: NSNotification.Name("UICollectionScrollToTop"),
            object: nil
        )
    }

    @objc private func scrollToTop() {
        guard items.count > 0 else { return }
        collectionView.setContentOffset(.zero, animated: true)
    }
    @objc private func handleRefresh() {
        onRefresh?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func updateItems(_ newItems: [ItemModel]) {
        self.items = newItems
        self.collectionView.reloadData()
    }

    // MARK: - Height estimation
    private func estimatedHeight(for item: ItemModel, width: CGFloat) -> CGFloat {

        let id = item.id ?? 0
        if let cached = heightCache[id] {
            return cached
        }

        // Full width banner heights
        if item.boardType == 4 { return 220 }
        if item.boardType == 5 { return 240 }

        // Video promotional fixed height
        if item.boardType == 2 { return 330 }

        // Default card fallback
        return 260
    }

    private func cacheHeight(_ height: CGFloat, for item: ItemModel) {
        let id = item.id ?? 0
        heightCache[id] = height
    }

    // MARK: - Visible video autoplay
    private func handleVideoPlayback() {

        let visibleCells = collectionView.visibleCells

        for cell in visibleCells {

            if let videoCell = cell as? BoardVideoCell {
                let rect = collectionView.convert(videoCell.frame, to: view)
                let visiblePercent = visiblePercent(of: rect)

                if visiblePercent > 0.65 {
                    videoCell.play()
                } else {
                    videoCell.pause()
                }
            }

            if let bannerCell = cell as? BoardVideoBannerCell {
                let rect = collectionView.convert(bannerCell.frame, to: view)
                let visiblePercent = visiblePercent(of: rect)

                if visiblePercent > 0.65 {
                    bannerCell.play()
                } else {
                    bannerCell.pause()
                }
            }
        }
    }

    private func visiblePercent(of rect: CGRect) -> CGFloat {

        let screenH = view.bounds.height
        let visibleRect = rect.intersection(CGRect(x: 0, y: 0, width: rect.width, height: screenH))

        if rect.height <= 0 { return 0 }
        return visibleRect.height / rect.height
    }
}

extension BoardFeedCollectionVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let item = items[indexPath.item]

        if item.boardType == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardBannerCell",
                                                          for: indexPath) as! BoardBannerCell
            cell.configure(item: item)
            return cell
        }

        if item.boardType == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardVideoBannerCell",
                                                          for: indexPath) as! BoardVideoBannerCell
            cell.configure(item: item)
            return cell
        }

        if item.boardType == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardVideoCell",
                                                          for: indexPath) as! BoardVideoCell
            cell.configure(item: item)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardItemCell",
                                                      for: indexPath) as! BoardItemCell

        cell.configure(item: item) { [weak self] height in
            guard let self else { return }
            self.cacheHeight(height, for: item)
            self.collectionView.collectionViewLayout.invalidateLayout()
        }

        return cell
    }
}

extension BoardFeedCollectionVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let item = items[indexPath.item]

        if item.boardType == 4 || item.boardType == 5 {
            if let urlStr = item.outbondUrl,
               let url = URL(string: urlStr.getValidUrl()) {
                onOpenURL?(url)
            }
            return
        }

        onTapItem?(item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleVideoPlayback()

        let offsetY = scrollView.contentOffset.y
        let contentH = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentH - height - 900 {
            onLoadNextPage?()
        }
    }
}

extension BoardFeedCollectionVC: PinterestLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        isFullWidthItemAt indexPath: IndexPath) -> Bool {

        let item = items[indexPath.item]
        return item.boardType == 4 || item.boardType == 5
    }

    func collectionView(_ collectionView: UICollectionView,
                        heightForItemAt indexPath: IndexPath,
                        with width: CGFloat) -> CGFloat {

        let item = items[indexPath.item]
        return estimatedHeight(for: item, width: width)
    }
}
