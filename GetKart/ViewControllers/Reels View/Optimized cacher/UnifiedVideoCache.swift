//
//  UnifiedVideoCache.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 29/07/26.
//

import Foundation
import AVFoundation

// MARK: - Shared file location (same as your existing FileManager.cacheFileURL)

extension FileManager {

    func cacheFileURL(for url: URL) -> URL {
        let name = url.absoluteString.md5
        let dir = urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent(name)
    }

    func createFileIfNeeded(at url: URL) {
        if !fileExists(atPath: url.path) {
            createFile(atPath: url.path, contents: nil)
        }
    }
}

// MARK: - Unified cache manager

/// Single source of truth for video caching across the whole app.
/// Any screen — GSPlayer-based or Reels — calls into this instead of
/// maintaining its own download/cache logic.
final class UnifiedVideoCache: NSObject {

    static let shared = UnifiedVideoCache()

    let loaderQueue = DispatchQueue(label: "unified.video.cache.loader")

    private var tasks: [URL: UnifiedDownloadTask] = [:]
    private let tasksLock = NSLock()

    private override init() { super.init() }

    // MARK: Player item factory — use this from ANY screen

    /// Returns a ready-to-play AVPlayerItem for `url`, using disk cache
    /// if a complete download already exists (from any screen), otherwise
    /// streams from network while caching to disk for next time.
    func playerItem(for url: URL) -> AVPlayerItem {

        if let cached = UnifiedVideoCache.fullyCachedFile(for: url) {
            return AVPlayerItem(asset: Self.localAsset(fileURL: cached.fileURL, mimeType: cached.mimeType))
        }

        // Stream via resource loader so bytes get cached to disk as they play.
        let asset = AVURLAsset(url: url.unifiedCacheScheme())
        asset.resourceLoader.setDelegate(self, queue: loaderQueue)
        return AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["playable"])
    }

    /// Explicit background prefetch — for warming up upcoming items
    /// without attaching a player yet.
    func prefetch(url: URL) {

        if UnifiedVideoCache.isCached(url) { return }

        tasksLock.lock()
        let existing = tasks[url]
        tasksLock.unlock()

        guard existing == nil else { return }

        let task = UnifiedDownloadTask(url: url)

        tasksLock.lock()
        tasks[url] = task
        tasksLock.unlock()

        task.startBackgroundDownload { [weak self] in
            self?.tasksLock.lock()
            self?.tasks.removeValue(forKey: url)
            self?.tasksLock.unlock()
        }
    }

    static func isCached(_ url: URL) -> Bool {
        fullyCachedFile(for: url) != nil
    }

    // MARK: Meta

    private struct Meta: Codable {
        let expectedSize: Int64
        let mimeType: String?
    }

    private static func markerURL(for url: URL) -> URL {
        FileManager.default.cacheFileURL(for: url).appendingPathExtension("cachedone")
    }

     static func markComplete(for url: URL, expectedSize: Int64, mimeType: String?) {

        guard expectedSize > 100_000 else { return }

        let meta = Meta(expectedSize: expectedSize, mimeType: mimeType)
        guard let data = try? JSONEncoder().encode(meta) else { return }

        try? data.write(to: markerURL(for: url), options: .atomic)
    }

    fileprivate static func fullyCachedFile(for url: URL) -> (fileURL: URL, mimeType: String?)? {

        let fileURL = FileManager.default.cacheFileURL(for: url)
        let metaURL = markerURL(for: url)

        guard
            FileManager.default.fileExists(atPath: fileURL.path),
            let metaData = try? Data(contentsOf: metaURL),
            let meta = try? JSONDecoder().decode(Meta.self, from: metaData)
        else {
            return nil
        }

        guard
            let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
            let actualSize = attrs[.size] as? Int64,
            actualSize == meta.expectedSize,
            actualSize > 100_000
        else {
            return nil
        }

        return (fileURL, meta.mimeType)
    }

    private static func localAsset(fileURL: URL, mimeType: String?) -> AVURLAsset {
        let options: [String: Any] = ["AVURLAssetOutOfBandMIMETypeKey": mimeType ?? "video/mp4"]
        return AVURLAsset(url: fileURL, options: options)
    }
}

// MARK: - AVAssetResourceLoaderDelegate (for the "play while caching" path)

extension UnifiedVideoCache: AVAssetResourceLoaderDelegate {

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {

        guard let url = loadingRequest.request.url?.unifiedOriginalURL() else {
            return false
        }

        tasksLock.lock()
        let task = tasks[url] ?? UnifiedDownloadTask(url: url)
        tasks[url] = task
        tasksLock.unlock()

        task.addStreamingRequest(loadingRequest) { [weak self] in
            self?.tasksLock.lock()
            self?.tasks.removeValue(forKey: url)
            self?.tasksLock.unlock()
        }

        return true
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        didCancel loadingRequest: AVAssetResourceLoadingRequest
    ) {
        guard let url = loadingRequest.request.url?.unifiedOriginalURL() else { return }
        tasksLock.lock()
        tasks[url]?.cancel(request: loadingRequest)
        tasksLock.unlock()
    }
}

// MARK: - URL scheme helpers (route through the resource loader delegate)

private extension URL {

    func unifiedCacheScheme() -> URL {
        var comp = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        comp.scheme = "unifiedcache"
        return comp.url!
    }

    func unifiedOriginalURL() -> URL? {
        var comp = URLComponents(url: self, resolvingAgainstBaseURL: false)
        comp?.scheme = "https"
        return comp?.url
    }
}
