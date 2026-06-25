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

