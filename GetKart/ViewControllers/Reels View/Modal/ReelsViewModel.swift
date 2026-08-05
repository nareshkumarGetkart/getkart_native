import Foundation
import SwiftUI

@MainActor
final class ReelsViewModel: ObservableObject {

    // MARK: Published

    @Published var reels: [ItemModel] = []
    @Published var currentIndex: Int = 0
    @Published var isLoading = false
    @Published var isLastPage = false
    @Published var hasLoadedOnce = false
    @Published var isRefreshing = false

    // MARK: Pagination

    private var currentPage = 0
    private var requestedPages: Set<Int> = []
    private let pageSize = 10

    // MARK: Initial Load

    func loadIfNeeded() {
        guard reels.isEmpty else { return }
        loadPage(1)
    }

    func loadOnce(){
        if reels.count <= 1{
            loadPage(1)
        }
    }
    // MARK: Refresh

    func refresh() async {

        currentPage = 0
        isLastPage = false
        requestedPages.removeAll()
        reels.removeAll()

        loadPage(1)
    }

    // MARK: Reel Changed

    func reelAppeared(at index: Int) {

        guard reels.indices.contains(index) else { return }

        currentIndex = index

        autoplayCurrent()
        preloadUpcomingVideos()

        if index >= reels.count - 3 {
            tryLoadNextPage()
        }
    }

    // MARK: Pagination

    func tryLoadNextPage() {

        let next = currentPage + 1

        guard !isLoading else { return }
        guard !isLastPage else { return }
        guard !requestedPages.contains(next) else { return }

        requestedPages.insert(next)

        loadPage(next)
    }

    // MARK: API

    private func loadPage(_ page: Int) {

        guard let obj = reels.first else{ return }
        
        isLoading = true

       
        let url = Constant.shared.get_promotional_videos + "?page=\(page)&exclude_id=\(obj.id ?? 0)&category_id=\(obj.categoryID ?? 0)"

        URLhandler.sharedinstance.makeCall(
            url: url,
            param: nil,
            methodType: .get
        ) { [weak self] response, error in

            guard let self else { return }

            DispatchQueue.main.async {

                self.isLoading = false
                self.hasLoadedOnce = true

                guard error == nil else { return }

                guard
                    let dict = response as? NSDictionary,
                    let data = dict["data"] as? NSDictionary,
                    let array = data["data"] as? [[String: Any]]
                else {
                    self.isLastPage = true
                    return
                }

                let newItems = array.compactMap {
                    try? JSONDecoder().decode(
                        ItemModel.self,
                        from: JSONSerialization.data(withJSONObject: $0)
                    )
                }

                let wasEmpty = self.reels.isEmpty

                self.reels.append(contentsOf: newItems)

                self.currentPage = data["current_page"] as? Int ?? page
                let last = data["last_page"] as? Int ?? page
                self.isLastPage = self.currentPage >= last

                // First load: nothing will trigger reelAppeared via onChange
                // (index starts at 0 with nothing to "change" from), so
                // kick off autoplay + preload manually here.
                if wasEmpty, !newItems.isEmpty {
                    self.reelAppeared(at: self.currentIndex)
                }
            }
        }
    }

    // MARK: Autoplay

//    private func autoplayCurrent() {
//
//        guard reels.indices.contains(currentIndex) else { return }
//
//        guard
//            let id = reels[currentIndex].id,
//            let video = reels[currentIndex].videoLink,
//            let url = URL(string: video)
//        else {
//            return
//        }
//
//        _ = ReelsVideoManager.shared.player(for: id, url: url)
//
//        ReelsVideoManager.shared.playOnly(id: id)
//    }
//    
    // MARK: Autoplay

    private func autoplayCurrent() {

        guard reels.indices.contains(currentIndex) else { return }

        guard
            let id = reels[currentIndex].id,
            let video = reels[currentIndex].videoLink,
            let url = URL(string: video)
        else {
            return
        }

        // Just ensure the player exists — DO NOT call playOnly here.
        // Actual play/pause is driven by ReelPageView.onChange(of: isCurrent)
        // to avoid two different code paths racing to control the same player.
        _ = ReelsVideoManager.shared.player(for: id, url: url)
    }

    // MARK: Prefetch

    private func preloadUpcomingVideos() {

        guard !reels.isEmpty else { return }

        let upcoming = reels
            .dropFirst(currentIndex + 1)
            .prefix(2)

        let urls = upcoming
            .compactMap { $0.videoLink }
            .compactMap(URL.init(string:))

        ReelsVideoPreloadManager.shared.preload(urls: urls)

        for item in upcoming {

            guard
                let id = item.id,
                let video = item.videoLink,
                let url = URL(string: video)
            else {
                continue
            }

            ReelsVideoManager.shared.warmup(id: id, url: url)
        }
    }

    // MARK: Like

    func updateLike(boardId: Int, isLiked: Bool) {

        guard let index = reels.firstIndex(where: { $0.id == boardId }) else { return }

        reels[index].isLiked = isLiked

        manageLikeApi(boardId: boardId)
    }

    private func manageLikeApi(boardId: Int) {

        let params: [String: Any] = ["board_id": boardId]

        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.manage_board_favourite,
            param: params,
            methodType: .post
        ) { [weak self] response, error in

            guard let self else { return }
            guard error == nil else { return }

            guard
                let dict = response as? NSDictionary,
                let data = dict["data"] as? NSDictionary
            else {
                return
            }

            let count = data["favourite_count"] as? Int ?? 0

            DispatchQueue.main.async {

                if let index = self.reels.firstIndex(where: { $0.id == boardId }) {
                    self.reels[index].totalLikes = count
                }
            }
        }
    }

    // MARK: Comment

    func updateComment(boardId: Int, count: Int, comment: CommentModel?) {

        guard let index = reels.firstIndex(where: { $0.id == boardId }) else { return }

        reels[index].commentsCount = count
        reels[index].lastComment = comment
    }

    // MARK: Cleanup

    func clear() {

        ReelsVideoManager.shared.reset()

        reels.removeAll()
        requestedPages.removeAll()
        currentPage = 0
        isLastPage = false
    }

    deinit {
        print("♻️ ReelsViewModel Deinit")
    }
    
    func outboundClickApi(boardId: Int) {
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.board_outbond_click,
            param: ["board_id": boardId],
            methodType: .post
        ) { _, _ in }
    }
}
