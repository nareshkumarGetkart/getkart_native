//
//  PinterestMasonryFeed.swift
//  GetKart
//
//  Created by gurmukh on 13/08/26.
//

import SwiftUI


enum FeedSegment: Identifiable {
    case banner(ItemModel)
    case staggeredChunk([ItemModel]) // always non-banner items only

    var id: String {
        switch self {
        case .banner(let item):
            return "banner-\(item.id ?? 0)"
        case .staggeredChunk(let items):
            // stable id from first+last item in chunk
            return "chunk-\(items.first?.id ?? 0)-\(items.last?.id ?? 0)"
        }
    }
}





//MARK: PinterestMasonryFeed

struct PinterestMasonryFeed<ItemContent: View>: View {

    let items: [ItemModel]
    var spacing: CGFloat = 8

    let itemView: (ItemModel) -> ItemContent
    let onLastItemAppear: () -> Void
    let onOpenURL: (URL) -> Void
    let pushToView:(ItemModel)->Void

    @State private var lastTriggeredItemId: Int?

    private let paginationThreshold = 8
    private let chunkSize = 10

  /*
    // MARK: - Segment

    private enum Segment: Identifiable {
        case chunk([ItemModel])
        case banner(ItemModel)

        var id: String {
            switch self {
            case .chunk(let items):
                return "chunk-\(items.first?.id ?? 0)-\(items.last?.id ?? 0)"

            case .banner(let item):
                return "banner-\(item.id ?? 0)"
            }
        }
    }

    // MARK: - Build Segments

    private var segments: [Segment] {

        var result: [Segment] = []
        var buffer: [ItemModel] = []

        func flush() {
            guard !buffer.isEmpty else { return }

            var index = 0

            while index < buffer.count {

                let end = min(index + chunkSize, buffer.count)

                result.append(
                    .chunk(Array(buffer[index..<end]))
                )

                index += chunkSize
            }

            buffer.removeAll()
        }

        for item in items {

            if item.boardType == 4 || item.boardType == 5 {

                flush()

                result.append(.banner(item))

            } else {

                buffer.append(item)
            }
        }

        flush()

        return result
    }
*/
    
    // MARK: - Segment

    private enum Segment: Identifiable {
        case chunk(id: String, items: [ItemModel], isBeforeBanner: Bool)
        case banner(ItemModel)

        var id: String {
            switch self {
            case .chunk(let id, _, _): return id
            case .banner(let item): return "banner-\(item.id ?? 0)"
            }
        }
    }

    // MARK: - Build Segments

    private var segments: [Segment] {

        var result: [Segment] = []
        var buffer: [ItemModel] = []

        func flush(isBeforeBanner: Bool) {
            guard !buffer.isEmpty else { return }

            var index = 0
            while index < buffer.count {
                let end = min(index + chunkSize, buffer.count)
                let chunkSlice = Array(buffer[index..<end])
                let stableId = "chunk-\(chunkSlice.first?.id ?? 0)"
                let isLastPieceOfThisFlush = end == buffer.count
                result.append(
                    .chunk(
                        id: stableId,
                        items: chunkSlice,
                        // only the final slice right up against the banner needs uncapped equalization
                        isBeforeBanner: isBeforeBanner && isLastPieceOfThisFlush
                    )
                )
                index += chunkSize
            }
            buffer.removeAll()
        }

        for item in items {
            if item.boardType == 4 || item.boardType == 5 {
                flush(isBeforeBanner: true)
                result.append(.banner(item))
            } else {
                buffer.append(item)
            }
        }

        flush(isBeforeBanner: false)   // trailing chunk, no banner follows (yet)

        return result
    }
    
    // MARK: - Body

    var body: some View {

        LazyVStack(spacing: spacing) {
            let currentSegments = segments

            ForEach(segments) { segment in

                switch segment {

                case .banner(let item):

                    bannerView(item: item)
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            checkPagination(item)
                        }
                    
/*
                case .chunk(_, let chunkItems, let isBeforeBanner):
                    TwoColumnMasonryLayout(
                        items: chunkItems,
                        spacing: spacing,
                        shouldEqualizeBottom: segment.id != currentSegments.last?.id || isBeforeBanner,
                        equalizationCap: isBeforeBanner ? .greatestFiniteMagnitude : maxEqualizationHeight
                    ) {
                        ForEach(chunkItems, id: \.id) { item in
                            itemView(item)
                                .onAppear { checkPagination(item) }
                        }
                    }*/
                    
                case .chunk(_, let chunkItems, let isBeforeBanner):

                    // Guard against tiny/lopsided before-banner chunks (e.g. banner lands
                    // right after 1-2 items) — don't try to force-fill those, since an
                    // enormous single-card stretch looks worse than a small natural gap.
                    let isSafeToFullyEqualize = isBeforeBanner && chunkItems.count >= 4

                    TwoColumnMasonryLayout(
                        items: chunkItems,
                        spacing: spacing,
                        shouldEqualizeBottom: segment.id != currentSegments.last?.id || isBeforeBanner,
                        // generous but still bounded — closes normal-sized gaps fully,
                        // without risking a runaway stretch on a near-empty chunk
                        equalizationCap: isSafeToFullyEqualize ? 220 : maxEqualizationHeight
                    ) {
                        ForEach(chunkItems, id: \.id) { item in
                            itemView(item)
                                .onAppear { checkPagination(item) }
                        }
                    }
                }
            }

            // Backup pagination trigger
            Color.clear
                .frame(height: 1)
                .id("bottom-\(items.count)")
                .onAppear {

                    guard items.count >= paginationThreshold else {
                        return
                    }

                    onLastItemAppear()
                }
        }
        .onChange(of: items.count) { _ in
            lastTriggeredItemId = nil
        }
    }

    // MARK: - Pagination

    private func checkPagination(_ item: ItemModel) {

        guard let itemId = item.id else {
            return
        }

        guard let currentIndex = items.firstIndex(where: {
            $0.id == itemId
        }) else {
            return
        }

        let triggerIndex = max(
            items.count - paginationThreshold,
            0
        )

        guard currentIndex >= triggerIndex else {
            return
        }

        guard lastTriggeredItemId != itemId else {
            return
        }

        lastTriggeredItemId = itemId

        DispatchQueue.main.async {
            onLastItemAppear()
        }
    }

    // MARK: - Banner

    @ViewBuilder
    private func bannerView(item: ItemModel) -> some View {

        if item.boardType == 5 {

            BoardVideoBannerCard(product: item) { url in
                
                if  (item.banner?.redirectionType ?? "") == "wallet"{
                    pushToView(item)
                }else{
                    onOpenURL(url)

                }
            }

        } else {

            BoardBannerCard(product: item) { url in
                
                if (item.banner?.redirectionType ?? "") == "wallet"{
                    pushToView(item)
                }else{
                    onOpenURL(url)
                }
            }
        }
    }
}
/*
//MARK: - TwoColumnMasonryLayout
struct TwoColumnMasonryLayout: Layout {

    let items: [ItemModel]
    var spacing: CGFloat = 8
    var shouldEqualizeBottom: Bool = true

    private static let screenWidth = UIScreen.main.bounds.width

    struct CacheData {
        var frames: [CGRect] = []
        var size: CGSize = .zero
    }

    func makeCache(subviews: Subviews) -> CacheData {
        CacheData()
    }
/*
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {

        let totalWidth = proposal.width ?? Self.screenWidth
        let columnWidth = (totalWidth - spacing) / 2

        var frames = Array(
            repeating: CGRect.zero,
            count: subviews.count
        )

        var columnHeights: [CGFloat] = [0, 0]
        var lastInColumn: [Int?] = [nil, nil]

        for index in subviews.indices {

            let column = columnHeights[0] <= columnHeights[1] ? 0 : 1

            let size = subviews[index].sizeThatFits(
                ProposedViewSize(
                    width: columnWidth,
                    height: nil
                )
            )

            let x = column == 0
                ? 0
                : columnWidth + spacing

            let y = columnHeights[column]

            frames[index] = CGRect(
                x: x,
                y: y,
                width: columnWidth,
                height: size.height
            )

            columnHeights[column] += size.height + spacing
            lastInColumn[column] = index
        }

        let leftHeight = max(
            columnHeights[0] - spacing,
            0
        )

        let rightHeight = max(
            columnHeights[1] - spacing,
            0
        )

        let maxHeight = max(
            leftHeight,
            rightHeight
        )

       
        if shouldEqualizeBottom {

            let leftIndex = lastInColumn[0]
            let rightIndex = lastInColumn[1]

            let leftIsVideo: Bool = {
                guard let idx = leftIndex,
                      idx < items.count else {
                    return false
                }

                return items[idx].boardType == 2
            }()

            let rightIsVideo: Bool = {
                guard let idx = rightIndex,
                      idx < items.count else {
                    return false
                }

                return items[idx].boardType == 2
            }()

            if leftHeight < rightHeight {

                let diff = rightHeight - leftHeight

                if leftIsVideo {

                    // Keep video fixed.
                    // Don't stretch anything.
                }
                else if let idx = leftIndex {

                    frames[idx].size.height += diff
                }

            } else if rightHeight < leftHeight {

                let diff = leftHeight - rightHeight

                if rightIsVideo {

                    // Keep video fixed.
                    // Don't stretch anything.
                }
                else if let idx = rightIndex {

                    frames[idx].size.height += diff
                }
            }
        }

        cache.frames = frames
        cache.size = CGSize(
            width: totalWidth,
            height: maxHeight
        )

        return cache.size
    }
*/
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {

        let totalWidth = proposal.width ?? Self.screenWidth
        let columnWidth = (totalWidth - spacing) / 2

        var frames = Array(repeating: CGRect.zero, count: subviews.count)
        var columnHeights: [CGFloat] = [0, 0]
        var lastInColumn: [Int?] = [nil, nil]

        for index in subviews.indices {
            
            // ✅ Strict alternation: 0,1,0,1...
            let column = index % 2

            let size = subviews[index].sizeThatFits(
                ProposedViewSize(width: columnWidth, height: nil)
            )

            let x = column == 0 ? 0 : columnWidth + spacing
            let y = columnHeights[column]

            frames[index] = CGRect(x: x, y: y, width: columnWidth, height: size.height)

            columnHeights[column] += size.height + spacing
            lastInColumn[column] = index
        }

        let leftHeight  = max(columnHeights[0] - spacing, 0)
        let rightHeight = max(columnHeights[1] - spacing, 0)
        let maxHeight   = max(leftHeight, rightHeight)

        // ✅ Equalize bottom - but now it's always a small diff since columns are balanced
     /*   if shouldEqualizeBottom {
//            let leftIsVideo: Bool = {
//                return false
//                guard let idx = lastInColumn[0], idx < items.count else { return false }
//                return items[idx].boardType == 2
//            }()
//
//            let rightIsVideo: Bool = {
//                return false
//
//                guard let idx = lastInColumn[1], idx < items.count else { return false }
//                return items[idx].boardType == 2
//            }()

            if leftHeight < rightHeight {
                let diff = rightHeight - leftHeight
                if let idx = lastInColumn[0] {
                   // frames[idx].size.height += diff
                    
                    // Don't stretch beyond maxCardHeight
                           let currentH = frames[idx].size.height
                           frames[idx].size.height = min(currentH + diff, maxCardHeight)
                }
            } else if rightHeight < leftHeight {
                let diff = leftHeight - rightHeight
                if  let idx = lastInColumn[1] {
                   // frames[idx].size.height += diff
                    
                    // Don't stretch beyond maxCardHeight
                           let currentH = frames[idx].size.height
                           frames[idx].size.height = min(currentH + diff, maxCardHeight)
                }
            }
        }

        cache.frames = frames
        cache.size = CGSize(width: totalWidth, height: maxHeight)
        return cache.size
        
        */
        
        if shouldEqualizeBottom {

            if leftHeight < rightHeight {

                let diff = rightHeight - leftHeight

                if let idx = lastInColumn[0] {

                    let currentHeight = frames[idx].size.height

                    // Never stretch too much
                    let allowedGrowth = min(diff, maxEqualizationHeight)

                    // Never exceed max card height
                    let newHeight = min(
                        currentHeight + allowedGrowth,
                        580 //maxCardHeight
                    )

                    let actualGrowth = newHeight - currentHeight

                    frames[idx].size.height = newHeight

                    // IMPORTANT
                    columnHeights[0] += actualGrowth
                }

            } else if rightHeight < leftHeight {

                let diff = leftHeight - rightHeight

                if let idx = lastInColumn[1] {

                    let currentHeight = frames[idx].size.height

                    let allowedGrowth = min(
                        diff,
                        maxEqualizationHeight
                    )

                    let newHeight = min(
                        currentHeight + allowedGrowth,
                        570 //maxCardHeight
                    )

                    let actualGrowth = newHeight - currentHeight

                    frames[idx].size.height = newHeight

                    // IMPORTANT
                    columnHeights[1] += actualGrowth
                }
            }
        }
        cache.frames = frames
        cache.size = CGSize(width: totalWidth, height: maxHeight)
        return cache.size
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) {

        for index in subviews.indices {

            let frame = cache.frames[index]

            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + frame.minX,
                    y: bounds.minY + frame.minY
                ),
                proposal: ProposedViewSize(
                    width: frame.width,
                    height: frame.height
                )
            )
        }
    }
}
*/

struct TwoColumnMasonryLayout: Layout {

    let items: [ItemModel]
    var spacing: CGFloat = 8
    var shouldEqualizeBottom: Bool = true   // pass false while this chunk can still grow

    private static let screenWidth = UIScreen.main.bounds.width
    var equalizationCap: CGFloat = maxEqualizationHeight   // ← new, defaults to existing constant

    struct CacheData {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        // ✅ Once a chunk is equalized, its frames are locked forever —
        // no future call can shrink or re-stretch anything in it.
        var isFrozen: Bool = false
    }

    func makeCache(subviews: Subviews) -> CacheData {
        CacheData()
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {

        if cache.isFrozen {
            return cache.size
        }

        let totalWidth = proposal.width ?? Self.screenWidth
        let columnWidth = (totalWidth - spacing) / 2

        var frames = Array(repeating: CGRect.zero, count: subviews.count)
        var columnHeights: [CGFloat] = [0, 0]
        var lastInColumn: [Int?] = [nil, nil]

        // ✅ track ALL indices per column, in order, so we can walk backward
        // to find a stretch-safe item instead of always using the very last one
        var columnIndices: [[Int]] = [[], []]

        for index in subviews.indices {

            let column = index % 2

            let size = subviews[index].sizeThatFits(
                ProposedViewSize(width: columnWidth, height: nil)
            )

            let x = column == 0 ? 0 : columnWidth + spacing
            let y = columnHeights[column]

            frames[index] = CGRect(x: x, y: y, width: columnWidth, height: size.height)

            columnHeights[column] += size.height + spacing
            lastInColumn[column] = index
            columnIndices[column].append(index)
        }

        let leftHeight  = max(columnHeights[0] - spacing, 0)
        let rightHeight = max(columnHeights[1] - spacing, 0)
        var maxHeight   = max(leftHeight, rightHeight)

        // ✅ only cards with flexible/fillable image content should absorb stretch —
        // banner/ad/promo cards have fixed internal layout and would just show
        // blank space below their content instead of visually growing
        func canAbsorbStretch(_ index: Int) -> Bool {
            guard index < items.count else { return false }
            let type = items[index].boardType ?? 0
            // adjust this set to match whichever boardTypes render as
            // BoardBannerCard / BoardVideoBannerCard / PromotionalAdsCardStaggeredNew
            return type != 1 && type != 4 && type != 5
        }

        func stretchTarget(in column: Int) -> Int? {
            // walk backward from the last item in this column until we find
            // one that's safe to stretch
            for idx in columnIndices[column].reversed() {
                if canAbsorbStretch(idx) { return idx }
            }
            return nil
        }

        if shouldEqualizeBottom {

            if leftHeight < rightHeight {

                let diff = rightHeight - leftHeight

                if let idx = stretchTarget(in: 0) {

                    let currentHeight = frames[idx].size.height
                    let allowedGrowth = min(diff, equalizationCap)
                    let newHeight = min(currentHeight + allowedGrowth, 580)
                    let actualGrowth = newHeight - currentHeight

                    frames[idx].size.height = newHeight
                    columnHeights[0] += actualGrowth
                }

            } else if rightHeight < leftHeight {

                let diff = leftHeight - rightHeight

                if let idx = stretchTarget(in: 1) {

                    let currentHeight = frames[idx].size.height
                    let allowedGrowth = min(diff, equalizationCap)
                    let newHeight = min(currentHeight + allowedGrowth, 570)
                    let actualGrowth = newHeight - currentHeight

                    frames[idx].size.height = newHeight
                    columnHeights[1] += actualGrowth
                }
            }

            maxHeight = max(
                max(columnHeights[0] - spacing, 0),
                max(columnHeights[1] - spacing, 0)
            )

            cache.isFrozen = true
        }

        cache.frames = frames
        cache.size = CGSize(width: totalWidth, height: maxHeight)
        return cache.size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) {
        for index in subviews.indices {
            let frame = cache.frames[index]
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(width: frame.width, height: frame.height)
            )
        }
    }
}

//#Preview {
//    PinterestMasonryFeed()
//}


