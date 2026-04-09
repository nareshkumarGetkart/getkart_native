//
//  GSPalyer.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 14/03/26.
//


import Foundation
import AVFoundation
import AVKit
import Combine
import SwiftUI


final class VideoCacheTracker {
    
    static let shared = VideoCacheTracker()
    
    private var cacheMap: [URL: Int64] = [:]
    private let queue = DispatchQueue(label: "cache.tracker")
    
    func update(url: URL, size: Int64) {
        queue.async {
            self.cacheMap[url] = size
        }
    }
    
    func size(for url: URL) -> Int64 {
        queue.sync {
            cacheMap[url] ?? 0
        }
    }
}

final class VideoPreloadManagerDefault {
    
    static let shared = VideoPreloadManagerDefault()
    
    private let queue = DispatchQueue(label: "video.preload.queue", qos: .utility)
    
    private var activeTasks: [URL: URLSessionDataTask] = [:]
    private let session: URLSession
    
    private let maxConcurrent = 3
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)
    }
    
    // MARK: - Public API (same usage as GSPlayer)
    
    func set(waiting urls: [URL]) {
        
        queue.async {
            self.startPrefetch(urls: urls)
        }
    }
}

private extension VideoPreloadManagerDefault {
    
    func startPrefetch(urls: [URL]) {
        
        // Limit concurrent downloads
        let availableSlots = maxConcurrent - activeTasks.count
        guard availableSlots > 0 else { return }
        
        let urlsToStart = urls.prefix(availableSlots)
        
        for url in urlsToStart {
            
            // Skip if already downloading
            if activeTasks[url] != nil { continue }
            
            // Skip if already cached
            if isFullyCached(url) { continue }
            
            startDownload(url: url)
        }
    }
    
    private func isFullyCached(_ url: URL) -> Bool {
        
        let fileURL = FileManager.default.cacheFileURL(for: url)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return false
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            
            if let fileSize = attributes[.size] as? Int64 {
                
                // ✅ Threshold (important)
                // If > 1MB → assume enough buffered for instant playback
                return fileSize > 1_000_000
            }
            
        } catch {
            return false
        }
        
        return false
    }
    
    func startDownload(url: URL) {
        
        var request = URLRequest(url: url)
        request.addValue("bytes=0-1500000", forHTTPHeaderField: "Range")
        
        let task = session.dataTask(with: request) { data, _, error in
            
            defer {
                self.queue.async {
                    self.activeTasks.removeValue(forKey: url)
                }
            }
            
            guard let data, error == nil else { return }
            
            // 🔥 Feed into cache system
            VideoCacheWriter.shared.append(data: data, for: url)
        }
        
        activeTasks[url] = task
        task.resume()
    }
}

final class VideoCacheWriter {
    
    static let shared = VideoCacheWriter()
    
    private let ioQueue = DispatchQueue(label: "video.cache.write", qos: .utility)
    
    func append(data: Data, for url: URL) {
        
        ioQueue.async {
            
            let fileURL = FileManager.default.cacheFileURL(for: url)
            
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            }
            
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                defer { try? handle.close() }
                
                try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
            }
        }
    }
}



final class CachedVideoPlayerItem: AVPlayerItem {
    
    private let customAsset: AVURLAsset
    
    init(url: URL) {
        
        let asset = AVURLAsset(url: url.toCacheURL())
        
        asset.resourceLoader.setDelegate(
            VideoCacheLoader.shared,
            queue: VideoCacheLoader.shared.queue
        )
        
        self.customAsset = asset
        
        super.init(asset: asset, automaticallyLoadedAssetKeys: ["playable"])
    }
    
    // 🔥 REQUIRED (fix crash)
    override init(asset: AVAsset, automaticallyLoadedAssetKeys keys: [String]?) {
        
        if let urlAsset = asset as? AVURLAsset {
            
            let newAsset = AVURLAsset(url: urlAsset.url)
            
            newAsset.resourceLoader.setDelegate(
                VideoCacheLoader.shared,
                queue: VideoCacheLoader.shared.queue
            )
            
            self.customAsset = newAsset
            
            super.init(asset: newAsset, automaticallyLoadedAssetKeys: keys)
            
        } else {
            self.customAsset = AVURLAsset(url: URL(string: "about:blank")!)
            super.init(asset: asset, automaticallyLoadedAssetKeys: keys)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

final class VideoCacheLoader: NSObject, AVAssetResourceLoaderDelegate {
    
    static let shared = VideoCacheLoader()
    
    let queue = DispatchQueue(label: "video.cache.loader")
    
    private var tasks: [URL: VideoDownloadTask] = [:]
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        guard let url = loadingRequest.request.url?.originalURL else {
            return false
        }
        
        print("🔥 ResourceLoader called")
        
        let task = tasks[url] ?? VideoDownloadTask(url: url)
        tasks[url] = task
        
        task.add(request: loadingRequest)
        
        return true
    }
}
extension URL {
    
    var originalScheme: URL? {
        var comp = URLComponents(url: self, resolvingAgainstBaseURL: false)
        comp?.scheme = "https"
        return comp?.url
    }

    func withScheme(_ scheme: String) -> URL {
        var comp = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        comp.scheme = scheme
        return comp.url!
    }
}

extension URL {
    
    func toCacheURL() -> URL {
        var comp = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        
        comp.scheme = "cache"
        
        let encoded = self.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        comp.queryItems = [URLQueryItem(name: "original", value: encoded)]
        
        return comp.url!
    }
    
    func originalURLFromCache() -> URL? {
        guard let comp = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let encoded = comp.queryItems?.first(where: { $0.name == "original" })?.value,
              let decoded = encoded.removingPercentEncoding,
              let url = URL(string: decoded) else {
            return nil
        }
        return url
    }
}

extension URL {
    
//    func toCacheURL() -> URL {
//        var comp = URLComponents(url: self, resolvingAgainstBaseURL: false)!
//        comp.scheme = "cache"
//        return comp.url!
//    }
    
    var originalURL: URL? {
        var comp = URLComponents(url: self, resolvingAgainstBaseURL: false)
        comp?.scheme = "https"
        return comp?.url
    }
}


final class VideoDownloadTask: NSObject, URLSessionDataDelegate {
    
    private let url: URL
    private var requests: [AVAssetResourceLoadingRequest] = []
    
    private var session: URLSession!
    private var task: URLSessionDataTask?
    
    private var receivedData = Data()
    private var expectedLength: Int64 = 0
    
    private let fileURL: URL
    private let fileHandle: FileHandle?
    
    init(url: URL) {
        self.url = url
        
        self.fileURL = FileManager.default.cacheFileURL(for: url)
        
        FileManager.default.createFileIfNeeded(at: fileURL)
        self.fileHandle = try? FileHandle(forWritingTo: fileURL)
        
        super.init()
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func add(request: AVAssetResourceLoadingRequest) {
        requests.append(request)
        startIfNeeded()
    }
    
    private func startIfNeeded() {
        guard task == nil else { return }
        
        print("⬇️ Start downloading:", url)
        
        var req = URLRequest(url: url)
        req.addValue("bytes=0-", forHTTPHeaderField: "Range")
        
        task = session.dataTask(with: req)
        task?.resume()
    }
    
    // MARK: RESPONSE
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        expectedLength = response.expectedContentLength
        
        if let http = response as? HTTPURLResponse {
            
            for request in requests {
                
                let content = request.contentInformationRequest
                content?.contentType = http.mimeType
                content?.contentLength = expectedLength
                content?.isByteRangeAccessSupported = true
            }
        }
        
        completionHandler(.allow)
    }
    
    // MARK: DATA
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data) {
        
        receivedData.append(data)
        fileHandle?.write(data)
        
        processRequests()
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        
        processRequests()
    }
    
    // MARK: SERVE
    
    private func processRequests() {
        
        var finished: [AVAssetResourceLoadingRequest] = []
        
        for request in requests {
            
            guard let dataRequest = request.dataRequest else { continue }
            
            let requestedOffset = Int(dataRequest.requestedOffset)
            let currentOffset = Int(dataRequest.currentOffset)
            let requestedLength = dataRequest.requestedLength
            
            let bytesAvailable = receivedData.count
            
            let startOffset = currentOffset
            
            guard bytesAvailable > startOffset else { continue }
            
            let bytesToSend = min(bytesAvailable - startOffset, requestedLength)
            
            let chunk = receivedData.subdata(in: startOffset..<(startOffset + bytesToSend))
            
            dataRequest.respond(with: chunk)
            
            let endOffset = startOffset + bytesToSend
            
            if endOffset >= requestedOffset + requestedLength {
                request.finishLoading()
                finished.append(request)
            }
        }
        
        requests.removeAll { finished.contains($0) }
        
        print("📦 Buffered:", receivedData.count)
    }
}

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

import CryptoKit

extension String {
    var md5: String {
        let digest = Insecure.MD5.hash(data: Data(self.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

struct SmartVideoPlayerView: View {

    let item: ItemModel

    @ObservedObject private var manager = FeedVideoManager.shared
    @State private var isReadyToPlay = false
    @State private var cancellables = Set<AnyCancellable>()

    private var videoId: Int? { item.id }

    private var player: AVQueuePlayer? {

        guard let id = item.id,
              let link = item.videoLink,
              let url = URL(string: link) else { return nil }

        return FeedVideoManager.shared.player(for: id, url: url)
    }

    private var isMuted: Bool {
        manager.currentUnmutedId != videoId
    }

    @State private var isExpand = false

    var onTapBottomButton: () -> Void

    var body: some View {

        VStack(spacing: 0) {

            GeometryReader { geo in

                ZStack(alignment: .top) {

                    // PLAYER
                    if let player {

                        PlayerLayerView(player: player)
                            .frame(height: 285)
                            .frame(width:geo.size.width)
                            .clipped()

                            .onAppear {

                                observeReadyState(player: player)

                                updateMuteState()

                                if let id = videoId {
                                    FeedVideoManager.shared.play(id: id)
                                }
                            }

                            .onDisappear {

                                if let id = videoId {
                                    FeedVideoManager.shared.pause(id: id)
                                }
                                isReadyToPlay = false
                                cancellables.removeAll()
                            }
                        
                        
                    }

                    // THUMBNAIL (always on top)
                        AsyncImage(url: URL(string: item.image ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }.frame(width:geo.size.width)
                        .frame(height: 285)
                        .clipped()
                        .opacity(isReadyToPlay ? 0 : 1)
                        .animation(.easeInOut(duration: 0.25), value: isReadyToPlay)

                    overlayUI
                }
            }
            .frame(height: 285)

            bottomCTA
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
        .onAppear{
          //  print("SmartVideoPlayerView appear")
            
            if let id = videoId {
                FeedVideoManager.shared.play(id: id)
            }
        }
        // GLOBAL AUDIO STATE CHANGE
        .onChange(of: manager.currentUnmutedId) { _ in
            updateMuteState()
        }

        .fullScreenCover(isPresented: $isExpand) {

            VideoPreviewView(
                item: item,
                strURl: item.videoLink ?? ""
            )
        }
    }
}
private extension SmartVideoPlayerView {

    var bottomCTA: some View {

        HStack {

            Text(item.ctaLabel ?? "")
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))

            Spacer()

            Image(systemName: "arrow.up.right")
                .foregroundColor(.white)
                .font(.system(size: 12))
        }
        .padding(.horizontal, 10)
        .frame(height: 35)
        .frame(maxWidth: .infinity)
        .background(Color.orange)
        .onTapGesture {
            onTapBottomButton()
            outboundClickApi(boardId: item.id ?? 0)
        }
    }
}
private extension SmartVideoPlayerView {

    var overlayUI: some View {

        VStack {

            HStack(alignment: .top) {

                if item.isFeature ?? false {
                    Text("Sponsored")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                }

                Spacer()

                VStack(spacing: 8) {

                    // MUTE BUTTON
                    Button {

                        if let id = videoId {
                            manager.toggleSound(for: id)
                        }

                    } label: {
                        
                        Image(systemName:
                                isMuted
                              ? "speaker.slash.fill"
                              : "speaker.wave.2.fill")
                        
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                    }

                    // EXPAND BUTTON
                    Button {

                        manager.muteAll()
                        manager.pauseAll()
                        isExpand = true

                    } label: {

                        Image("material-symbols_pan-zoom-rounded")
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
            }

            Spacer()
        }
        .padding(8)
    }
}
private extension SmartVideoPlayerView {
    
    private func observeReadyState(player: AVPlayer) {
        
        cancellables.removeAll()
        
        player.currentItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { status in
                
                switch status {
                    
                case .readyToPlay:
                  //  print("✅ Ready to play")
                    isReadyToPlay = true
                    
                case .failed:
                    print("❌ Failed")
                    isReadyToPlay = false
                    
                default:
                    isReadyToPlay = false
                }
            }
            .store(in: &cancellables)
    }
    
    
    func outboundClickApi(boardId:Int){
        
        let params = ["board_id":boardId]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.board_outbond_click, param: params,methodType: .post) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                _ = result["message"] as? String ?? ""
                
                if status == 200{
                    
                }else{
                }
            }
        }
    }
    
//    func observeReadyState(player: AVQueuePlayer) {
//
//        cancellables.removeAll()
//
//        player.publisher(for: \.timeControlStatus)
//            .receive(on: DispatchQueue.main)
//            .sink { status in
//
//               
//
//                if status == .playing ||
//                   player.currentItem?.isPlaybackLikelyToKeepUp == true {
//
//                    isReadyToPlay = true
//                }
//                if status == .waitingToPlayAtSpecifiedRate {
//
//                    let item = player.currentItem
//
//                    if item?.isPlaybackLikelyToKeepUp == true {
//                        player.play()
//                    }
//
//                    if item?.isPlaybackBufferFull == true {
//                        player.play()
//                    }
//                }
//            }
//            .store(in: &cancellables)
//    }
    

    func updateMuteState() {

        guard let player else { return }
        guard let id = videoId else { return }

        let shouldUnmute = manager.currentUnmutedId == id

        player.isMuted = !shouldUnmute
        player.volume = shouldUnmute ? 1 : 0
    }
}






final class FeedVideoManager: ObservableObject {
    
    static let shared = FeedVideoManager()
    
    private init() {}
    
    // MARK: - Player Pool (ONE player per video ID)
    
    private var loopers: [Int: AVPlayerLooper] = [:]
    
    var players: [Int: AVQueuePlayer] = [:]
    
    // Track order to limit memory
    private var playerOrder: [Int] = []
        
    // Currently unmuted video
    @Published private(set) var currentUnmutedId: Int?
    
    
    // MARK: - Get or Create Player
//    func player(for id: Int, url: URL) -> AVQueuePlayer {
//
//        if let existing = players[id] {
//
//            if existing.items().isEmpty {
//
//              //  let item = AVPlayerItem(url: url)
//                
//                let item = CachedVideoPlayerItem(url: url)
//                
//                item.preferredForwardBufferDuration = 2
//
//                let looper = AVPlayerLooper(player: existing, templateItem: item)
//                loopers[id] = looper
//            }
//
//            return existing
//        }
//
//     //   let item = AVPlayerItem(url: url)
//        let item = CachedVideoPlayerItem(url: url)
//        item.preferredForwardBufferDuration = 2
//
//        let queue = AVQueuePlayer(playerItem: item)
//        queue.automaticallyWaitsToMinimizeStalling = false
//        queue.actionAtItemEnd = .none
//        queue.isMuted = true
//        queue.volume = 0
//
//        let looper = AVPlayerLooper(player: queue, templateItem: item)
//
//        players[id] = queue
//        loopers[id] = looper
//
//        return queue
//    }
    
    func player(for id: Int, url: URL) -> AVQueuePlayer {

        if let existing = players[id] {

            if existing.items().isEmpty {

                let item = AVPlayerItem(url: url)
                item.preferredForwardBufferDuration = 2

                let looper = AVPlayerLooper(player: existing, templateItem: item)
                loopers[id] = looper
            }

            return existing
        }

       // print("🎬 Creating player:", id)

        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 2

        let queue = AVQueuePlayer(playerItem: item)
        queue.automaticallyWaitsToMinimizeStalling = false
        queue.actionAtItemEnd = .none
        queue.isMuted = true
        queue.volume = 0

        let looper = AVPlayerLooper(player: queue, templateItem: item)

        players[id] = queue
        loopers[id] = looper

        return queue
    }
    // MARK: - Warmup Player (for precaching)
    
    func warmupPlayer(id: Int, url: URL) {
        
        if players[id] != nil { return }
        
        _ = player(for: id, url: url)
    }
    
    
    // MARK: - Update Playback
    
    func updatePlayback(visibleIDs: Set<Int>) {

        for (id, player) in players {

            if visibleIDs.contains(id) {

                if player.timeControlStatus != .playing {
                    player.playImmediately(atRate: 1)
                }

            } else {

                if player.timeControlStatus == .playing {
                    player.pause()
                }
            }
        }
    }
    
    // MARK: - Play
    
//    func play(id: Int) {
//        players[id]?.play()
//    }
//    
    func play(id: Int) {
        
        guard let player = players[id] else { return }
        
        if player.currentItem?.status == .failed {
            print("⚠️ Recreating broken player:", id)
            players.removeValue(forKey: id)
            return
        }
        
        player.play()
    }
    
    
    // MARK: - Pause
    
    func pause(id: Int) {
        players[id]?.pause()
    }
    
    
    // MARK: - Pause All
    
    func pauseAll() {
        for (_, player) in players {
            player.pause()
        }
    }
    
    
    // MARK: - Mute All
    
    func muteAll() {
        
        for (_, player) in players {
            player.isMuted = true
            player.volume = 0
        }
        
        DispatchQueue.main.async {
            self.currentUnmutedId = nil
        }
    }
    
    
    // MARK: - Toggle Sound (ONLY ONE UNMUTED GLOBALLY)
    
    func toggleSound(for id: Int) {
        
        guard let player = players[id] else { return }
        
        // Tap same video
        if currentUnmutedId == id {
            
            let shouldMute = !player.isMuted
            
            player.isMuted = shouldMute
            player.volume = shouldMute ? 0 : 1
            
            DispatchQueue.main.async {
                self.currentUnmutedId = shouldMute ? nil : id
            }
            
            return
        }
        
        // Mute everything first
        muteAll()
        
        // Unmute selected
        player.isMuted = false
        player.volume = 1
        
        DispatchQueue.main.async {
            self.currentUnmutedId = id
        }
    }
    
    
    // MARK: - Reset
    
    func reset() {
        
        for (_, player) in players {
            player.pause()
            player.removeAllItems()
        }
        
        players.removeAll()
        loopers.removeAll()
        playerOrder.removeAll()
        
        currentUnmutedId = nil
    }
}


//===============

/*
import SwiftUI
import GSPlayer

struct GSVideoPlayerView: UIViewRepresentable {

    let url: URL
    let isPlaying: Bool
    let isMuted: Bool
    var onReady: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> VideoPlayerView {

        let player = VideoPlayerView()
        player.playerLayer.videoGravity = .resizeAspectFill
        player.clipsToBounds = true

        player.play(for: url)

        // Listen when video ready
      
        player.stateDidChanged = { state in

            if case .playing = state {

                DispatchQueue.main.async {
                    player.setNeedsLayout()
                    player.layoutIfNeeded()
                    context.coordinator.parent.onReady?()
                }
            }
        }

        return player
    }

    func updateUIView(_ uiView: VideoPlayerView, context: Context) {

        if isPlaying {
            uiView.resume()
        } else {
            uiView.pause()
        }

        uiView.player?.isMuted = isMuted
    }

    class Coordinator {

        var parent: GSVideoPlayerView

        init(_ parent: GSVideoPlayerView) {
            self.parent = parent
        }
    }
}

extension Notification.Name {
    static let pauseAllVideos = Notification.Name("pauseAllVideos")
}

import Foundation
import Combine

final class FeedVideoManager: ObservableObject {

    static let shared = FeedVideoManager()

    // Visible videos
    @Published var visibleVideoIDs: Set<Int> = []

    // Only one playing video
    @Published var playingVideoID: Int?

    // Only one video with sound
    @Published var currentUnmutedId: Int?

    private init() {}

    // MARK: - SOUND CONTROL

    func toggleSound(for id: Int) {

        if currentUnmutedId == id {
            currentUnmutedId = nil
        } else {
            currentUnmutedId = id
        }

        // Force UI refresh everywhere
        objectWillChange.send()
    }

    func muteAll() {
        currentUnmutedId = nil
        objectWillChange.send()
    }

    // MARK: - PLAYBACK CONTROL

    func updatePlayback(visibleIDs: Set<Int>) {

        visibleVideoIDs = visibleIDs

        if let firstVisible = visibleIDs.first {
            playingVideoID = firstVisible
        } else {
            playingVideoID = nil
        }

        // If sound owner leaves screen -> mute
        if let soundID = currentUnmutedId, !visibleIDs.contains(soundID) {
            currentUnmutedId = nil
        }
    }

    func pause(id: Int) {

        visibleVideoIDs.remove(id)

        if playingVideoID == id {
            playingVideoID = nil
        }

        if currentUnmutedId == id {
            currentUnmutedId = nil
        }
    }

    func pauseAll() {

        visibleVideoIDs.removeAll()
        playingVideoID = nil
        currentUnmutedId = nil
    }

    func reset() {

        visibleVideoIDs.removeAll()
        playingVideoID = nil
        currentUnmutedId = nil
    }
}

import SwiftUI
import GSPlayer

struct SmartVideoPlayerView: View {

    let item: ItemModel
    var onTapBottomButton: () -> Void

    @ObservedObject private var manager = FeedVideoManager.shared

    @State private var isPlaying = false
    @State private var isReadyToPlay = false
    @State private var isExpand = false

    private var videoId: Int { item.id ?? -1 }

    private var isMuted: Bool {
        manager.currentUnmutedId != videoId
    }

    var body: some View {

        VStack(spacing: 0) {

            ZStack {

                videoPlayer.background(Color(.black))
//                    .aspectRatio(contentMode: .fill)   // 👈 ADD THIS
//                                .frame(maxWidth: .infinity)
                                .frame(height: 280)

                thumbnailView

                if isReadyToPlay{
                    overlayUI
                }
            }
            .frame(height: 280)

            bottomCTA
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)

        // PLAY / PAUSE when visible IDs change
        .onChange(of: manager.playingVideoID) { id in
            isPlaying = id == videoId
        }

        // SAFETY pause
        .onDisappear {
            isPlaying = false
            FeedVideoManager.shared.pause(id: videoId)
        }
        // GLOBAL AUDIO STATE CHANGE
        .onChange(of: manager.currentUnmutedId) { _ in
            // Force refresh of mute state
            isPlaying = manager.visibleVideoIDs.contains(videoId)
        }
        .fullScreenCover(isPresented: $isExpand) {

            VideoPreviewView(
                item: item,
                strURl: item.videoLink ?? ""
            )
        }
    }
}

private extension SmartVideoPlayerView {

    var videoPlayer: some View {

        Group {

            if let link = item.videoLink,
               let url = URL(string: link) {

                GSVideoPlayerView(
                    url: url,
                    isPlaying: isPlaying,
                    isMuted: isMuted
                ) {
                    isReadyToPlay = true
                }
            }
        }
    }

    // Thumbnail until video ready
    var thumbnailView: some View {

        Group {

            if !isReadyToPlay {

                AsyncImage(url: URL(string: item.image ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                    
                } placeholder: {

                    Color.black.opacity(0.2)
                }
            }
        }
    }
}

import SwiftUI
import Combine


private extension SmartVideoPlayerView {

    var overlayUI: some View {

        VStack {

            HStack(alignment: .top) {

                if item.isFeature ?? false {

                    Text("Sponsored")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                }

                Spacer()

                VStack(spacing: 8) {

                    Button {

                        manager.toggleSound(for: videoId)

                    } label: {

                        Image(systemName:
                                isMuted
                                ? "speaker.slash.fill"
                                : "speaker.wave.2.fill")

                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                    }

                    Button {

                        manager.muteAll()
                        isExpand = true

                    } label: {

                        Image("material-symbols_pan-zoom-rounded")
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
            }

            Spacer()
        }
        .padding(8)
    }
}

private extension SmartVideoPlayerView {

    var bottomCTA: some View {

        HStack {

            Text(item.ctaLabel ?? "")
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))

            Spacer()

            Image(systemName: "arrow.up.right")
                .foregroundColor(.white)
                .font(.system(size: 12))
        }
        .padding(.horizontal, 10)
        .frame(height: 35)
        .frame(maxWidth: .infinity)
        .background(Color.orange)
        .onTapGesture {
            onTapBottomButton()
        }
    }
}
*/


/*struct GSVideoPlayerView: UIViewRepresentable {

    let url: URL
    var isPlaying: Bool
    var isMuted: Bool

    func makeUIView(context: Context) -> VideoPlayerView {

        let view = VideoPlayerView()
        view.playerLayer.videoGravity = .resizeAspectFill

        view.play(for: url)

        view.player?.isMuted = isMuted

        return view
    }

    func updateUIView(_ uiView: VideoPlayerView, context: Context) {

        uiView.player?.isMuted = isMuted

        if isPlaying {
            uiView.resume()
        } else {
            uiView.pause()
        }
    }
}
*/
