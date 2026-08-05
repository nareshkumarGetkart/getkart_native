import Foundation
import AVFoundation

private struct ReelsCacheMeta: Codable {
    let expectedSize: Int64
    let mimeType: String?
}

enum ReelsVideoSource {

//    static func playerItem(for url: URL) -> AVPlayerItem {
//
//        if let cached = validatedCachedLocalURL(for: url) {
//            return AVPlayerItem(asset: makeLocalAsset(fileURL: cached.fileURL, mimeType: cached.mimeType))
//        }
//
//        return AVPlayerItem(url: url)
//    }

    static func playerItem(for url: URL) -> AVPlayerItem {

        if let cached = validatedCachedLocalURL(for: url) {
            let playableURL = cachedFileURLWithExtension(originalFileURL: cached.fileURL, remoteURL: url)
            return AVPlayerItem(url: playableURL)
        }

        return AVPlayerItem(url: url)
    }
    
    private static func cachedFileURLWithExtension(originalFileURL: URL, remoteURL: URL) -> URL {

        // Derive extension from the remote URL's path (e.g. .mp4), fallback to mp4.
        let ext = remoteURL.pathExtension.isEmpty ? "mp4" : remoteURL.pathExtension

        let renamed = originalFileURL.deletingPathExtension().appendingPathExtension(ext)

        if !FileManager.default.fileExists(atPath: renamed.path) {
            try? FileManager.default.copyItem(at: originalFileURL, to: renamed)
        }

        return renamed
    }
    
    static func isCached(_ url: URL) -> Bool {
        validatedCachedLocalURL(for: url) != nil
    }

    /// Downloads the full video to disk in chunks via URLSession's
    /// built-in streaming, so large files don't sit fully in memory.
    static func prefetch(url: URL) {

        if isCached(url) { return }

        lock.lock()
        let alreadyRunning = activeDownloads.contains(url)
        if !alreadyRunning { activeDownloads.insert(url) }
        lock.unlock()

        guard !alreadyRunning else { return }

        let fileURL = FileManager.default.cacheFileURL(for: url)
        let metaURL = cacheMetaURL(for: url)
        let tmpURL = fileURL.appendingPathExtension("tmp-\(UUID().uuidString)")

        let task = URLSession.shared.downloadTask(with: url) { location, response, error in

            defer {
                lock.lock()
                activeDownloads.remove(url)
                lock.unlock()
            }

            guard let location, error == nil else { return }

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                return
            }

            do {
                try FileManager.default.moveItem(at: location, to: tmpURL)

                let attrs = try FileManager.default.attributesOfItem(atPath: tmpURL.path)
                let size = attrs[.size] as? Int64 ?? 0

                guard size > 100_000 else {
                    try? FileManager.default.removeItem(at: tmpURL)
                    return
                }

                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                try FileManager.default.moveItem(at: tmpURL, to: fileURL)

                let meta = ReelsCacheMeta(expectedSize: size, mimeType: response?.mimeType)
                if let data = try? JSONEncoder().encode(meta) {
                    try? data.write(to: metaURL, options: .atomic)
                }

            } catch {
                try? FileManager.default.removeItem(at: tmpURL)
            }
        }

        task.resume()
    }

    static func invalidateCache(for url: URL) {
        let fileURL = FileManager.default.cacheFileURL(for: url)
        let metaURL = cacheMetaURL(for: url)
        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.removeItem(at: metaURL)
    }

    static func clearAllCache() {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        guard let contents = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return }
        for file in contents { try? FileManager.default.removeItem(at: file) }
    }

    // MARK: - Private

    private static var activeDownloads: Set<URL> = []
    private static let lock = NSLock()

    private static func cacheMetaURL(for url: URL) -> URL {
        FileManager.default.cacheFileURL(for: url).appendingPathExtension("reelsmeta3")
    }

    /// The fix: tell AVURLAsset the MIME type explicitly, since the local
    /// cache file has no extension for AVFoundation to infer format from.
    private static func makeLocalAsset(fileURL: URL, mimeType: String?) -> AVURLAsset {

        let options: [String: Any] = [
            "AVURLAssetOutOfBandMIMETypeKey": mimeType ?? "video/mp4"
        ]

        return AVURLAsset(url: fileURL, options: options)
    }
    
    private static func validatedCachedLocalURL(for url: URL) -> (fileURL: URL, mimeType: String?)? {

        let fileURL = FileManager.default.cacheFileURL(for: url)
        let metaURL = cacheMetaURL(for: url)

        guard
            FileManager.default.fileExists(atPath: fileURL.path),
            let metaData = try? Data(contentsOf: metaURL),
            let meta = try? JSONDecoder().decode(ReelsCacheMeta.self, from: metaData)
        else {
            return nil
        }

        guard
            let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
            let actualSize = attrs[.size] as? Int64,
            actualSize == meta.expectedSize,
            actualSize > 100_000
        else {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: metaURL)
            return nil
        }

        return (fileURL, meta.mimeType)
    }
}
