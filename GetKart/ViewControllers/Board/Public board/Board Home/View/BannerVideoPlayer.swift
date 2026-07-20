//
//  BannerVideoPlayer.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/07/26.
//

import Foundation
import SwiftUI
import AVFoundation

final class BannerVideoPlayer: ObservableObject {

    let player = AVPlayer()

    private var observer: NSObjectProtocol?

    func load(url: URL) {

        // Already loaded
        if let asset = player.currentItem?.asset as? AVURLAsset,
           asset.url == url {
            return
        }

        cleanup()

        let item = AVPlayerItem(url: url)

        player.replaceCurrentItem(with: item)

        player.actionAtItemEnd = .none
        player.isMuted = true

        observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in

            self?.player.seek(to: .zero)

            self?.player.play()
        }
    }

    func play() {

        player.play()
    }

    func pause() {

        player.pause()
    }

    func mute(_ mute: Bool) {

        player.isMuted = mute
    }

    deinit {

        cleanup()
    }

    private func cleanup() {

        if let observer {

            NotificationCenter.default.removeObserver(observer)

            self.observer = nil
        }
    }
}
