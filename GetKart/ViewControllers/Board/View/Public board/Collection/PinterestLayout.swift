//
//  PinterestLayout.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/05/26.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemAt indexPath: IndexPath,
                        with width: CGFloat) -> CGFloat

    func collectionView(_ collectionView: UICollectionView,
                        isFullWidthItemAt indexPath: IndexPath) -> Bool
}

final class PinterestLayout: UICollectionViewLayout {

    weak var delegate: PinterestLayoutDelegate?

    var numberOfColumns: Int = 2
    var cellPadding: CGFloat = 6

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override func prepare() {

        guard let collectionView = collectionView else { return }
        cache.removeAll()
        contentHeight = 0

        let colWidth = (contentWidth - cellPadding) / CGFloat(numberOfColumns)

        var xOffset: [CGFloat] = []
        for col in 0..<numberOfColumns {
            xOffset.append(CGFloat(col) * (colWidth + cellPadding))
        }

        var yOffset = Array(repeating: CGFloat(0), count: numberOfColumns)

        var column = 0

        for itemIndex in 0..<collectionView.numberOfItems(inSection: 0) {

            let indexPath = IndexPath(item: itemIndex, section: 0)

            let isFullWidth = delegate?.collectionView(collectionView,
                                                       isFullWidthItemAt: indexPath) ?? false

            if isFullWidth {

                let width = contentWidth
                let height = delegate?.collectionView(collectionView,
                                                      heightForItemAt: indexPath,
                                                      with: width) ?? 200

                let y = yOffset.max() ?? 0

                let frame = CGRect(x: 0, y: y, width: width, height: height)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame

                cache.append(attributes)
                contentHeight = max(contentHeight, frame.maxY)

                // reset both columns after banner
                let newY = frame.maxY + cellPadding
                yOffset = Array(repeating: newY, count: numberOfColumns)

                column = 0

            } else {

                let width = colWidth
                let height = delegate?.collectionView(collectionView,
                                                      heightForItemAt: indexPath,
                                                      with: width) ?? 260

                let frame = CGRect(x: xOffset[column],
                                   y: yOffset[column],
                                   width: width,
                                   height: height)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame

                cache.append(attributes)
                contentHeight = max(contentHeight, frame.maxY)

                yOffset[column] += height + cellPadding

                if let minVal = yOffset.min(), let idx = yOffset.firstIndex(of: minVal) {
                    column = idx
                }
            }
        }
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]? {
        cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes? {
        cache.first(where: { $0.indexPath == indexPath })
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
}
