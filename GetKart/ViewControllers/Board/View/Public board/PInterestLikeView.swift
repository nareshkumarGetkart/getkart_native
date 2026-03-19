//
//  PInterestLikeView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 16/02/26.
//

import SwiftUI
import Foundation
import AVKit
import Combine
import AVFoundation
import SwiftUI

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



/*
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
                            .frame(height: 280)
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

                                cancellables.removeAll()
                            }
                    }

                   // THUMBNAIL
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
                    }
                    
                    
//                    // THUMBNAIL ABOVE PLAYER
//                    AsyncImage(url: URL(string: item.image ?? "")) { image in
//                        image
//                            .resizable()
//                            .scaledToFill()
//                    } placeholder: {
//                        Color.gray.opacity(0.2)
//                    }
//                    .frame(height: 280)
//                    .clipped()
//                    .opacity(isReadyToPlay ? 0 : 1)
//                    .animation(.easeInOut(duration: 0.25), value: isReadyToPlay)

                    overlayUI
                }
            }
            .frame(height: 280)

            bottomCTA
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)

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
    
    func observeReadyState(player: AVQueuePlayer) {

        cancellables.removeAll()

        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { status in

               

                if status == .playing ||
                   player.currentItem?.isPlaybackLikelyToKeepUp == true {

                    isReadyToPlay = true
                }
                if status == .waitingToPlayAtSpecifiedRate {

                    let item = player.currentItem

                    if item?.isPlaybackLikelyToKeepUp == true {
                        player.play()
                    }

                    if item?.isPlaybackBufferFull == true {
                        player.play()
                    }
                }
            }
            .store(in: &cancellables)
    }
    

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
    
    func play(id: Int) {
        players[id]?.play()
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

*/
