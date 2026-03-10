//
//  PInterestLikeView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 16/02/26.
//

import SwiftUI
import Foundation
import UIKit
import AVKit
import Combine

/*final class FeedVideoManager: ObservableObject {
    
    static let shared = FeedVideoManager()
    
  //  @Published var visibleVideoIDs: Set<Int> = []
    @Published var visibleVideoIDs: [Int] = []
    @Published var soundVideoID: Int?
      
      //  Track if sound was user-triggered
      var userSelectedSoundID: Int?
    
    private init() {}
    
    func setSound(id: Int?) {
        soundVideoID = id
    }
}*/

import AVKit
import Combine
import AVFoundation
import SwiftUI

final class FeedVideoManager: ObservableObject {
    
    static let shared = FeedVideoManager()
    
    private init() {}
    
    // MARK: - Player Pool (ONE player per video ID)
    
    private var loopers: [Int: AVPlayerLooper] = [:]
    
    var players: [Int: AVQueuePlayer] = [:]
    // Currently unmuted video
   // private(set) var currentUnmutedId: Int?
    
    @Published private(set) var currentUnmutedId: Int?
    // MARK: - Get or Create Player
    
    func player(for id: Int, url: URL) -> AVQueuePlayer {
        
        if let existing = players[id] {
            return existing
        }
        
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
    
    func updatePlayback(visibleIDs: Set<Int>) {
        
        for (id, player) in players {
            
            if visibleIDs.contains(id) {
                if player.timeControlStatus != .playing {
                    player.play()
                }
                //player.play()
            } else {
                if player.timeControlStatus == .playing {
                    player.pause()
                }
               // player.pause()
            }
        }
    }
    // MARK: - Play
    
    func play(id: Int) {
        players[id]?.play()
    }
    
    // MARK: - Pause
    
    func pause(id: Int) {
        players[id]?.pause()
    }
    
    // MARK: - Mute All
    
  /*  func muteAll() {
        for (_, player) in players {
            player.isMuted = true
            player.volume = 0
        }
        currentUnmutedId = nil
    }*/
    
    func muteAll() {
        for (_, player) in players {
            player.isMuted = true
            player.volume = 0
        }
        
        DispatchQueue.main.async {
            self.currentUnmutedId = nil
        }
    }
    
    func pauseAll() {
        for (_, player) in players {
            player.pause()
        }
    }
    // MARK: - Toggle Sound (ONLY ONE UNMUTED GLOBALLY)
    
 /*   func toggleSound(for id: Int) {
        
        guard let player = players[id] else { return }
        
        // If tapping same video -> toggle
        if currentUnmutedId == id {
            
            let shouldMute = !player.isMuted
            player.isMuted = shouldMute
            player.volume = shouldMute ? 0 : 1
            
            if shouldMute {
                currentUnmutedId = nil
            }
            
            return
        }
        
        // Mute everything first
        muteAll()
        
        // Unmute selected
        player.isMuted = false
        player.volume = 1
        currentUnmutedId = id
    }*/
    
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
    func reset() {
        
        // Pause everything first
        for (_, player) in players {
            player.pause()
            player.removeAllItems()
        }
        
        players.removeAll()
        loopers.removeAll()
        
        currentUnmutedId = nil
    }
}

final class PlayerUIView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

struct PlayerLayerView: UIViewRepresentable {
    
    var player: AVPlayer?
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.videoGravity = .resizeAspectFill
        view.playerLayer.player = player
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

import SwiftUI
import AVKit


/*struct SmartVideoPlayerView: View {
    
    let item: ItemModel
    
    @StateObject private var manager = FeedVideoManager.shared
    @State private var isVisible: Bool = false
    
    private var videoId: Int? {
        item.id
    }
    
    private var videoURL: URL? {
        guard let link = item.videoLink else { return nil }
        return URL(string: link)
    }
    
    private var player: AVQueuePlayer? {
        guard let id = videoId,
              let url = videoURL else { return nil }
        
        return manager.player(for: id, url: url)
    }
    
    var body: some View {
        
        ZStack {
            
            if let player = player {
                
                PlayerLayerView(player: player)
                    .frame(height: 300)
                    .background(Color.black)
                    .onAppear {
                        isVisible = true
                        manager.play(id: videoId ?? 0)
                    }
                    .onDisappear {
                        isVisible = false
                        manager.pause(id: videoId ?? 0)
                    }
                    .onTapGesture {
                        if let id = videoId {
                            manager.toggleSound(for: id)
                        }
                    }
            }
        }
    }
}*/

import SwiftUI
import AVFoundation
import Combine

struct SmartVideoPlayerView: View {
    
    let item: ItemModel
    
   // @ObservedObject private var manager = FeedVideoManager.shared
    private let manager = FeedVideoManager.shared
    @State private var isReadyToPlay = false
    @State private var isMuted = true
    
    @State private var cancellables = Set<AnyCancellable>()
    
    private var videoId: Int? { item.id }
    
   private var player: AVQueuePlayer? {
        guard let id = item.id,
              let link = item.videoLink,
              let url = URL(string: link) else { return nil }
        
        return manager.player(for: id, url: url)
    }
    
//    private var player: AVQueuePlayer? {
//        guard let id = item.id,
//              let link = item.videoLink,
//              let url = URL(string: link) else { return nil }
//
//        let playURL = VideoCacheManager.shared.cachedURL(for: url) ?? url
//        
//        return manager.player(for: id, url: playURL)
//    }
    
    @State  private var isExpand:Bool = false
    
    var onTapBottomButton:() ->Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            GeometryReader { geo in
                
                ZStack(alignment: .topTrailing) {
                    
                    // 🎥 Custom PlayerLayer
                    if let player = player {
                        PlayerLayerView(player: player)
                            .frame(height: 280)
                            .clipped()
                           /* .onAppear {
                                observeReadyState(player: player)
                                updateMuteState()
                            }*/
                        
                            .onAppear {
/*
                                if let link = item.videoLink,
                                   let url = URL(string: link) {

                                    VideoCacheManager.shared.precacheVideo(url: url)
                                }
*/
                                observeReadyState(player: player)
                                updateMuteState()
                            }
                        
                        
                            .onChange(of: manager.currentUnmutedId) { _ in
                                updateMuteState()
                            }
                            .onDisappear {
                                if let id = videoId {
                                    FeedVideoManager.shared.pause(id: id)
                                }
                                cancellables.removeAll()
                            }
                    }
                    
                    //  Thumbnail
                    if !isReadyToPlay {
                        AsyncImage(url: URL(string: item.image ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(height: 280)
                        .clipped()
                        .transition(.opacity)
                    }
                    VStack{
                        // 🔊 Mute Button
                        Button {
                            if let id = videoId {
                                manager.toggleSound(for: id)
                                
                                // instant UI update
                                isMuted = manager.currentUnmutedId != id
                            }
                        } label: {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        
                        Button {
                            manager.muteAll()
                            manager.pauseAll()
                            isExpand = true
                        } label: {
                            Image("material-symbols_pan-zoom-rounded")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                    }
                    .padding(8)
                }
            }
            .frame(height:280)
            
            // CTA
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
            .onTapGesture{
                onTapBottomButton()
            }
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
        .onChange(of: manager.currentUnmutedId) { _ in
            updateMuteState()
        }
        .fullScreenCover(isPresented: $isExpand) {
          
            if let url = URL(string:(item.videoLink ?? "").getValidUrl())  {
               
           
                VideoPreviewView(item: item,strURl: item.videoLink ?? "")
            }
        }
    }
    
    
}

private extension SmartVideoPlayerView {
    
   /* func observeReadyState(player: AVQueuePlayer) {
        
        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { status in
                if status == .playing {
                    isReadyToPlay = true
                }
            }
            .store(in: &cancellables)
    }
    */
    func observeReadyState(player: AVQueuePlayer) {
        
        // remove old observers
        cancellables.removeAll()
        
        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { status in
                if status == .playing {
                    isReadyToPlay = true
                }
            }
            .store(in: &cancellables)
    }
    
    func updateMuteState() {
        
        guard let id = videoId else { return }
        
        let shouldUnmute = manager.currentUnmutedId == id
        isMuted = !shouldUnmute
        
        guard let player = player else { return }
        
        player.isMuted = !shouldUnmute
        player.volume = shouldUnmute ? 1 : 0
    }
}


import Foundation
import CryptoKit

final class VideoCacheManager {

    static let shared = VideoCacheManager()

    private init() {}

    // MARK: Config

    private let precacheSize: Int = 5 * 1024 * 1024     // 5MB per video
    private let maxCacheSize: UInt64 = 500 * 1024 * 1024 // 500MB total

    private var runningTasks: [String: URLSessionDataTask] = [:]

    // MARK: Cache Folder

    private lazy var cacheFolder: URL = {

        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let folder = path.appendingPathComponent("FeedVideoCache")

        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }

        return folder
    }()

    // MARK: Cache Path

    private func cacheURL(for url: URL) -> URL {
        let name = url.absoluteString.md5
        return cacheFolder.appendingPathComponent(name)
    }

    func cachedURL(for url: URL) -> URL? {

        let file = cacheURL(for: url)

        guard FileManager.default.fileExists(atPath: file.path) else {
            return nil
        }

        // update last access date (for LRU)
        try? FileManager.default.setAttributes(
            [.modificationDate: Date()],
            ofItemAtPath: file.path
        )

        return file
    }

    // MARK: Precache

    func precacheVideo(url: URL) {

        let key = url.absoluteString

        if runningTasks[key] != nil { return }

        let cacheFile = cacheURL(for: url)

        var downloadedBytes = 0

        if FileManager.default.fileExists(atPath: cacheFile.path) {

            let attr = try? FileManager.default.attributesOfItem(atPath: cacheFile.path)
            downloadedBytes = attr?[.size] as? Int ?? 0
        }

        if downloadedBytes >= precacheSize { return }

        var request = URLRequest(url: url)

        let range = "bytes=\(downloadedBytes)-\(precacheSize)"
        request.setValue(range, forHTTPHeaderField: "Range")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            defer { self.runningTasks[key] = nil }

            guard let data = data else { return }

            if FileManager.default.fileExists(atPath: cacheFile.path) {

                if let handle = try? FileHandle(forWritingTo: cacheFile) {

                    handle.seekToEndOfFile()
                    handle.write(data)
                    try? handle.close()
                }

            } else {

                try? data.write(to: cacheFile)
            }

            // cleanup cache
            self.cleanupIfNeeded()
        }

        runningTasks[key] = task
        task.resume()
    }

    // MARK: Cache Cleanup (LRU)

    private func cleanupIfNeeded() {

        let files = try? FileManager.default.contentsOfDirectory(
            at: cacheFolder,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: []
        )

        guard var urls = files else { return }

        var totalSize: UInt64 = 0
        var fileInfos: [(url: URL, size: UInt64, date: Date)] = []

        for url in urls {

            let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])

            let size = UInt64(values?.fileSize ?? 0)
            let date = values?.contentModificationDate ?? Date()

            totalSize += size

            fileInfos.append((url, size, date))
        }

        if totalSize <= maxCacheSize { return }

        // sort oldest first
        fileInfos.sort { $0.date < $1.date }

        for file in fileInfos {

            try? FileManager.default.removeItem(at: file.url)

            totalSize -= file.size

            if totalSize <= maxCacheSize {
                break
            }
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

/*
final class FeedVideoManager: ObservableObject {
    
    static let shared = FeedVideoManager()
    
    @Published var soundVideoID: Int?
    
    private init() {}
    
    func setSound(id: Int?) {
        soundVideoID = id
    }
}


final class PlayerUIView: UIView {
    
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

struct PlayerLayerView: UIViewRepresentable {
    
    var player: AVPlayer?
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.videoGravity = .resizeAspectFill
        view.playerLayer.player = player
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}


struct SmartVideoPlayerView: View {
    
    let item: ItemModel
    
    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    @State private var isMuted = true
    @State private var isPlaying = false
    
    @ObservedObject private var manager = FeedVideoManager.shared
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack(alignment: .topTrailing) {
                
                PlayerLayerView(player: player)
                    .frame(height: 300)
                    .background(Color.black)
                
                if !isPlaying {
                    AsyncImage(url: URL(string: item.image ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(height: 300)
                    .clipped()
                }
                
                Button {
                    toggleSound()
                } label: {
                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(10)
            }
            
            HStack {
                Text(item.ctaLabel ?? "Learn More")
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .frame(height: 35)
            .background(Color.orange)
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(height: 335)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            pauseVideo()
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        checkVisibility(geo: geo)
                    }
                    .onChange(of: geo.frame(in: .global).minY) { _ in
                        checkVisibility(geo: geo)
                    }
            }
        )
        .onChange(of: manager.soundVideoID) { _ in
            handleSound()
        }
    }

    private func checkVisibility(geo: GeometryProxy) {
        
        let frame = geo.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height
        
        let visibleHeight = max(
            0,
            min(frame.maxY, screenHeight) - max(frame.minY, 0)
        )
        
        let percent = visibleHeight / frame.height
        
        // Play only if not already playing
        if percent >= 0.5 && !isPlaying {
            player?.play()
            isPlaying = true
        }
        
        // Pause only if currently playing
        if percent <= 0.3 && isPlaying {
            pauseVideo()
        }
    }
    
    private func pauseVideo() {
        player?.pause()
        isPlaying = false
    }
    
    private func setupPlayer() {
        
        // Prevent multiple creations
        if player != nil { return }
        
        guard let url = URL(string: item.videoLink ?? "") else { return }

        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 5

        let queue = AVQueuePlayer(playerItem: item)
        queue.automaticallyWaitsToMinimizeStalling = false
        queue.isMuted = true

        let looper = AVPlayerLooper(player: queue, templateItem: item)

        self.player = queue
        self.looper = looper
    }
    
    private func toggleSound() {
        if manager.soundVideoID == item.id {
            manager.setSound(id: nil)
        } else {
            manager.setSound(id: item.id)
        }
    }

    private func handleSound() {
        if manager.soundVideoID == item.id {
            isMuted = false
            player?.isMuted = false
        } else {
            isMuted = true
            player?.isMuted = true
        }
    }

   
}
*/

/*struct SmartVideoPlayerView: View {
    
    let item: ItemModel
    
    @State private var player: AVPlayer?
    @State private var isMuted = true
    @State private var isReadyToPlay = false
    @State private var cancellables = Set<AnyCancellable>()
    
    @ObservedObject private var manager = FeedVideoManager.shared
    
    var body: some View {
        
        GeometryReader { geo in
            
            let frame = geo.frame(in: .global)
            let screenHeight = UIScreen.main.bounds.height
            
            let visibleHeight = max(
                0,
                min(frame.maxY, screenHeight) - max(frame.minY, 0)
            )
            
            let visibilityPercent = visibleHeight / frame.height
            
            VStack(spacing: 0) {
                
                // MARK: - Video + Thumbnail
                
                ZStack(alignment: .topTrailing) {
                    
                    PlayerLayerView(player: player)
                        .aspectRatio(contentMode: .fill).frame(height:250)
                    
//                    if !isReadyToPlay {
//                        AsyncImage(url: URL(string: item.image ?? "")) { image in
//                            image
//                                .resizable()
//                                .scaledToFill().frame(height:250)
//                        } placeholder: {
//                            Color.gray.opacity(0.2).frame(height:250)
//                        }
//                        .transition(.opacity)
//                    }
                    
                    // MARK: - Mute Button
                    
                    Button {
                        toggleSound()
                    } label: {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }.frame(height:250)
                
                // MARK: - CTA
                
                HStack {
                    Text(item.ctaLabel ?? "Learn more")
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
            }
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
            .frame(height:285)
            // MARK: - Visibility Play Logic
            
            .onAppear {
                setupPlayer()
            }
            .onDisappear {
                player?.pause()
            }
            .onChange(of: visibilityPercent) { percent in
                
                // ▶️ Play if ≥ 40%
                if percent >= 0.4 {
                    player?.play()
                }
                
                // ⏸ Pause if ≤ 20%
                if percent <= 0.2 {
                    player?.pause()
                }
            }
            .onChange(of: manager.soundVideoID) { _ in
                handleSound()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isReadyToPlay)
    }
    
    private func setupPlayer() {
        guard let url = URL(string: item.videoLink ?? "") else { return }
        
        let playerItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.isMuted = true
        
        player = avPlayer
        
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { status in
                if status == .readyToPlay {
                    isReadyToPlay = true
                }
            }
            .store(in: &cancellables)
        
        addLoopObserver()
    }
    private func toggleSound() {
        guard let id = item.id else { return }
        
        if manager.soundVideoID == id {
            manager.setSound(id: nil)
        } else {
            manager.setSound(id: id)
        }
    }
    private func handleSound() {
        guard let id = item.id else { return }
        
        if manager.soundVideoID == id {
            isMuted = false
            player?.isMuted = false
        } else {
            isMuted = true
            player?.isMuted = true
        }
    }
    private func addLoopObserver() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
}
*/

/*
struct SmartVideoPlayerView: View {
    
    let item: ItemModel
    @State private var player: AVPlayer?
    @ObservedObject private var manager = FeedVideoManager.shared
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            VideoPlayer(player: player)
                .onAppear {
                    setupPlayer()
                    managerLogic()
                    player?.play()
                    addLoopObserver()
                }
                .onDisappear {
                    player?.pause()
                    player = nil
                }
                .onChange(of: manager.activeVideoID) { _ in
                    managerLogic()
                }
                .frame(height: UIScreen.main.bounds.width)
                .clipped()
               
            
            HStack {
                Text(item.ctaLabel ?? "")
                    .foregroundColor(.white)
                
                Spacer()
                
                Image("upRight")
                    .renderingMode(.template)
                    .foregroundColor(.white)
            }
            .padding(.horizontal,5)
            .frame(height: 35)
            .frame(maxWidth: .infinity)
            .background(Color.orange)
           
        } .cornerRadius(8)
    }
    
    private func setupPlayer() {
        guard let url = URL(string: item.videoLink ?? "") else { return }
        player = AVPlayer(url: url)
    }
    
    private func managerLogic() {
        if manager.activeVideoID == nil {
            manager.setActive(id: item.id ?? 0)
        }
        
        if manager.activeVideoID == item.id {
            player?.isMuted = false
        } else {
            player?.isMuted = true
        }
    }
    
    private func addLoopObserver() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
}

*/
