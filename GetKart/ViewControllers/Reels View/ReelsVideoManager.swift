


import Foundation
import AVFoundation
import SwiftUI

@MainActor
final class ReelsVideoManager: ObservableObject {

    static let shared = ReelsVideoManager()

    private init() {}

    // MARK: - Config

    private let maxPlayers = 4

    // MARK: - Storage

    private var players: [Int: AVQueuePlayer] = [:]
    private var loopers: [Int: AVPlayerLooper] = [:]
    private var playerOrder: [Int] = []

    @Published private(set) var currentPlayingId: Int?

    /// Global sound preference — persists across all reels once the user
    /// unmutes/mutes any single video. Defaults to muted (typical feed behavior).
    @Published private(set) var isSoundOn: Bool = false   // NEW

    // MARK: - Player

    func player(for id: Int, url: URL) -> AVQueuePlayer {

        if let player = players[id] {
            touch(id)
            return player
        }

        /*let item = ReelsVideoSource.playerItem(for: url)
        item.preferredForwardBufferDuration = 2*/
        let item = UnifiedVideoCache.shared.playerItem(for: url)
        item.preferredForwardBufferDuration = 2

        let player = AVQueuePlayer(playerItem: item)

        player.actionAtItemEnd = .none
        player.automaticallyWaitsToMinimizeStalling = false

        // NEW — respect the global preference instead of always starting muted
        player.isMuted = !isSoundOn
        player.volume = isSoundOn ? 1 : 0

        let looper = AVPlayerLooper(player: player, templateItem: item)

        players[id] = player
        loopers[id] = looper

        touch(id)

        return player
    }

    // MARK: - Playback

    func playOnly(id: Int) {

        currentPlayingId = id

        for (playerId, player) in players {

            if playerId == id {

                // NEW — re-apply the global sound preference every time a
                // reel becomes current, in case it was created before the
                // user changed the preference.
                player.isMuted = !isSoundOn
                player.volume = isSoundOn ? 1 : 0

                if player.currentItem?.status == .readyToPlay {
                    player.playImmediately(atRate: 1)
                } else {
                    player.play()
                }

            } else {
                player.pause()
            }
        }

        touch(id)
    }

    func pause(id: Int) {
        players[id]?.pause()
        if currentPlayingId == id {
            currentPlayingId = nil
        }
    }

    func pauseCurrent() {
        guard let id = currentPlayingId else { return }
        players[id]?.pause()
    }

    func resumeCurrent() {
        guard let id = currentPlayingId else { return }
        players[id]?.play()
    }

    func pauseAll() {
        players.values.forEach { $0.pause() }
        currentPlayingId = nil
    }

    // MARK: - Sound

    /// Toggles the GLOBAL sound preference and applies it to every
    /// currently-live player immediately, plus persists it for players
    /// created afterward.
    func toggleGlobalSound() {   // NEW — replaces old toggleSound(id:)

        isSoundOn.toggle()

        for (_, player) in players {
            player.isMuted = !isSoundOn
            player.volume = isSoundOn ? 1 : 0
        }
    }

    func muteAll() {

        isSoundOn = false

        for (_, player) in players {
            player.isMuted = true
            player.volume = 0
        }
    }

    // MARK: - Warmup / Preload

    func warmup(id: Int, url: URL) {
      /*  ReelsVideoSource.prefetch(url: url)
        _ = player(for: id, url: url)*/
  
        UnifiedVideoCache.shared.prefetch(url: url)
        _ = player(for: id, url: url)
    }

    // MARK: - Release

    func release(id: Int) {

        guard let player = players[id] else { return }

        player.pause()
        player.replaceCurrentItem(with: nil)

        players.removeValue(forKey: id)
        loopers.removeValue(forKey: id)

        playerOrder.removeAll { $0 == id }

        if currentPlayingId == id {
            currentPlayingId = nil
        }
    }

    func reset() {

        for (_, player) in players {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }

        players.removeAll()
        loopers.removeAll()
        playerOrder.removeAll()

        currentPlayingId = nil
    }
}

// MARK: - LRU

private extension ReelsVideoManager {

    func touch(_ id: Int) {
        playerOrder.removeAll { $0 == id }
        playerOrder.append(id)
        maintainCache()
    }

    func maintainCache() {

        while playerOrder.count > maxPlayers {

            let removeId = playerOrder.removeFirst()
            guard removeId != currentPlayingId else { continue }
            release(id: removeId)
        }
    }
}
/*
@MainActor
final class ReelsVideoManager: ObservableObject {

    static let shared = ReelsVideoManager()

    private init() {}

    // MARK: - Config

    private let maxPlayers = 4

    // MARK: - Storage

    private var players: [Int: AVQueuePlayer] = [:]
    private var loopers: [Int: AVPlayerLooper] = [:]

    /// LRU order
    private var playerOrder: [Int] = []

    @Published private(set) var currentPlayingId: Int?
    @Published private(set) var currentUnmutedId: Int?

    // MARK: - Player

    private var statusObservers: [Int: NSKeyValueObservation] = [:]
    
    func player(for id: Int, url: URL) -> AVQueuePlayer {

        if let player = players[id] {
            touch(id)
            return player
        }

        let item = ReelsVideoSource.playerItem(for: url)
       // let item = AVPlayerItem(url: url)   // TEMP: bypass ReelsVideoSource entirely

        item.preferredForwardBufferDuration = 2
        
        // TEMP DEBUG
        statusObservers[id] = item.observe(\.status, options: [.new]) { item, _ in
            switch item.status {
            case .readyToPlay:
                print("✅ Reel \(id) ready to play")
            case .failed:
                let nsError = item.error as NSError?
                print("❌ Reel \(id) FAILED")
                print("   domain:", nsError?.domain ?? "nil")
                print("   code:", nsError?.code ?? -1)
                print("   underlying:", nsError?.userInfo[NSUnderlyingErrorKey] ?? "none")
                print("   full:", nsError?.userInfo ?? [:])
                ReelsVideoSource.invalidateCache(for: url)
                
            case .unknown:
                print("⏳ Reel \(id) status unknown")
            @unknown default:
                break
            }
        }

    
        let player = AVQueuePlayer(playerItem: item)

        player.actionAtItemEnd = .none
        player.automaticallyWaitsToMinimizeStalling = false
        player.isMuted = true
        player.volume = 0

        let looper = AVPlayerLooper(
            player: player,
            templateItem: item
        )

        players[id] = player
        loopers[id] = looper

        touch(id)

        return player
    }

    // MARK: - Playback

    
    func playOnly(id: Int) {

        print("▶️ playOnly called for id:", id, "known players:", players.keys.sorted())

        currentPlayingId = id

        for (playerId, player) in players {

            if playerId == id {

                if player.currentItem?.status == .readyToPlay {
                    print("   ⚡️ playImmediately for", playerId)
                    player.playImmediately(atRate: 1)
                } else {
                    print("   ⏱ play() (not ready yet) for", playerId)
                    player.play()
                }

            } else {
                player.pause()
            }
        }

        touch(id)
    }

    func pause(id: Int) {

        players[id]?.pause()

        if currentPlayingId == id {
            currentPlayingId = nil
        }
    }

    func pauseCurrent() {
        guard let id = currentPlayingId else { return }
        players[id]?.pause()
    }

    func resumeCurrent() {
        guard let id = currentPlayingId else { return }
        players[id]?.play()
    }

    func pauseAll() {
        players.values.forEach { $0.pause() }
        currentPlayingId = nil
    }

    // MARK: - Sound

    func muteAll() {

        for (_, player) in players {
            player.isMuted = true
            player.volume = 0
        }

        currentUnmutedId = nil
    }

    func toggleSound(id: Int) {

        guard let player = players[id] else { return }

        if currentUnmutedId == id {

            let mute = !player.isMuted

            player.isMuted = mute
            player.volume = mute ? 0 : 1

            currentUnmutedId = mute ? nil : id

            return
        }

        muteAll()

        player.isMuted = false
        player.volume = 1

        currentUnmutedId = id
    }

    // MARK: - Warmup / Preload

    /// Creates a player + starts caching the video, without playing it.
    /// Call this for the next 1-2 items ahead of the current reel.
//    func warmup(id: Int, url: URL) {
//        _ = player(for: id, url: url)
//    }

    
    // MARK: - Warmup / Preload

    /// Creates a player for an upcoming reel AND explicitly starts caching
    /// it to disk, since it's not playing yet — safe to download in parallel.
    func warmup(id: Int, url: URL) {

        ReelsVideoSource.prefetch(url: url)

        _ = player(for: id, url: url)
    }
    // MARK: - Release

    func release(id: Int) {

        guard let player = players[id] else { return }

        player.pause()
        player.replaceCurrentItem(with: nil)

        players.removeValue(forKey: id)
        loopers.removeValue(forKey: id)

        playerOrder.removeAll { $0 == id }

        if currentPlayingId == id {
            currentPlayingId = nil
        }

        if currentUnmutedId == id {
            currentUnmutedId = nil
        }
    }

    func reset() {

        for (_, player) in players {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }

        players.removeAll()
        loopers.removeAll()
        playerOrder.removeAll()

        currentPlayingId = nil
        currentUnmutedId = nil
    }
}

// MARK: - LRU

private extension ReelsVideoManager {

    func touch(_ id: Int) {

        playerOrder.removeAll { $0 == id }
        playerOrder.append(id)

        maintainCache()
    }

    func maintainCache() {

        while playerOrder.count > maxPlayers {

            let removeId = playerOrder.removeFirst()

            guard removeId != currentPlayingId else { continue }

            release(id: removeId)
        }
    }
}
*/
