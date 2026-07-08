//
//  BannerMediaView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 26/06/26.
//

import SwiftUI

import AVFoundation

struct BannerMediaView: View {

    
    let urlString: String
    let shouldPlay: Bool
    let action: (() -> Void)?
    let onVideoFinished: (() -> Void)?

    @State private var isMuted = true
    @State private var player: AVPlayer?
   // @State private var looper: AVPlayerLooper?
    @State private var endObserver: NSObjectProtocol?
    
    var isVideo: Bool {

        let lower = urlString.lowercased()

        return lower.contains(".mp4")
        || lower.contains(".mov")
        || lower.contains(".m4v")
        || lower.contains(".avi")
    }

    var body: some View {

        ZStack {

            if isVideo {

                if let player {

                    VideoBannerPlayer(player: player)

                } else {

                    Image("getkartplaceholder")
                        .resizable()
                        .scaledToFill()
                }

            } else {

                AsyncImage(
                    url: URL(string: urlString)
                ) { image in

                    image
                        .resizable()
                        .scaledToFill()

                } placeholder: {

                    Image("getkartplaceholder")
                        .resizable()
                        .scaledToFill()
                }
            }
        }.overlay(alignment: .topTrailing) {
            if isVideo{
                Button {
                    
                    isMuted.toggle()
                    player?.isMuted = isMuted
                    
                } label: {
                    
                    Image(systemName:
                            isMuted
                          ? "speaker.slash.fill"
                          : "speaker.wave.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(.black.opacity(0.6))
                    .clipShape(Circle())
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
            }
        }
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {

            player?.pause()
            action?()
        }
//        .onAppear {
//
//            createPlayerIfNeeded()
//
//            if shouldPlay {
//                player?.play()
//            }
//        }
        
        .onAppear {

            createPlayerIfNeeded()

            guard let player else { return }

            if shouldPlay {

                if player.timeControlStatus != .playing {

                    player.play()
                }
            }
        }
//        .onDisappear {
//
//            player?.pause()
//        }
        .onDisappear {

            player?.pause()

//            if let endObserver {
//                NotificationCenter.default.removeObserver(endObserver)
//            }
        }
        
        
        
        .onChange(of: shouldPlay) { play in

            guard let player else { return }

            if play {

                player.seek(to: .zero)
                player.play()

            } else {

                player.pause()
            }
        }.onReceive(NotificationCenter.default.publisher(for: .resumeBannerVideo)) { _ in
            guard shouldPlay else { return }

            player?.play()
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setActive(true)

                player?.play()
            } catch {
                print(error)
            }
        }
    }

    private func createPlayerIfNeeded() {

        guard isVideo else { return }

        guard player == nil else { return }

        guard let url = URL(string: urlString) else { return }

       /* let item = AVPlayerItem(url: url)

        let queuePlayer = AVQueuePlayer()

       // queuePlayer.isMuted = false
        queuePlayer.isMuted = isMuted
        let looper = AVPlayerLooper(
            player: queuePlayer,
            templateItem: item
        )

        self.player = queuePlayer
        self.looper = looper*/
        
        let item = AVPlayerItem(url: url)

        let player = AVPlayer(playerItem: item)
        player.isMuted = isMuted

       /* endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in

            onVideoFinished?()
        }*/
        
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in

            DispatchQueue.main.async {

                player.seek(to: .zero)

                onVideoFinished?()
            }
        }

        self.player = player
    }
}

//#Preview {
//    BannerMediaView()
//}
//


import AVFoundation

struct VideoBannerPlayer: UIViewRepresentable {

    let player: AVPlayer?

    func makeUIView(context: Context) -> UIView {

        let view = UIView()

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds

        view.layer.addSublayer(playerLayer)

        context.coordinator.playerLayer = playerLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {

        DispatchQueue.main.async {
            context.coordinator.playerLayer?.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}
