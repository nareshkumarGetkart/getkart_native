import Foundation

/// Kicks off disk-caching for upcoming reels, ahead of the user scrolling to them.
/// Actual download/caching logic lives in ReelsVideoSource — this is just the
/// "which URLs to prefetch, how many at a time" policy layer.
final class ReelsVideoPreloadManager {

    static let shared = ReelsVideoPreloadManager()

    private init() {}

    /// Only preload a couple of videos ahead — matches ReelsVideoManager's warmup usage.
    func preload(urls: [URL]) {

        for url in urls.prefix(2) {
            ReelsVideoSource.prefetch(url: url)
        }
    }

    func preload(url: URL) {
        preload(urls: [url])
    }
}
