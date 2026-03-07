//
//  VideoPreviewView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 02/03/26.
//


import SwiftUI
import AVKit


struct VideoPreviewView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: PremiumVideoVM
     @State private var openSafari:Bool = false
    
    init(item:ItemModel) {
        _vm = StateObject(wrappedValue: PremiumVideoVM(url:URL(string: item.videoLink?.getValidUrl() ?? "")! , item: item))
    }
    
    var body: some View {
        ZStack {
            
            PlayerLayerView(player: vm.player)
                .ignoresSafeArea()
                .onTapGesture {
                    vm.toggleControls()
                }
            
            // Double Tap Seek
            HStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        vm.seek(by: -10)
                    }
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        vm.seek(by: 10)
                    }
            }
            .ignoresSafeArea()
            
            if vm.showControls {
                VStack {
                    
                    // Top Bar
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.system(size: 22, weight: .semibold))
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Button {
                            vm.toggleMute()
                        } label: {
                            Image(systemName: vm.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Play / Pause Center
                    Button {
                        vm.togglePlay()
                    } label: {
                        Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 40))
                            .padding(28)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Bottom Slider
                    VStack {
                        HStack {
                            Text(format(vm.currentTime))
                                .foregroundColor(.white)
                                .font(.caption)
                            
                            Slider(
                                value: $vm.currentTime,
                                in: 0...vm.duration,
                                onEditingChanged: { editing in
                                    if !editing {
                                        vm.seek(to: vm.currentTime)
                                    }
                                }
                            )
                            .tint(.white)
                            
                            Text(format(vm.duration))
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    // MARK: Bottom CTA Card
                 //   VStack {
                       // Spacer()
                        
                        VStack(spacing: 5) {
                            
                            Text(vm.itemObj?.name ?? "")
                                .font(.inter(.semiBold, size: 18))
                                .multilineTextAlignment(.center)
                            
                            Button {
                                print("Visit site tapped")
                                openSafari = true
                                vm.player.pause()

                            } label: {
                                Text(vm.itemObj?.ctaLabel ?? "")
                                    .foregroundColor(.white)
                                    .font(.inter(.medium, size: 16))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .cornerRadius(14)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                        )
                        .padding(.horizontal,5)
                        .padding(.bottom, 10)
                   // }

                    
                }
                .transition(.opacity)
            }
        }
        .onDisappear {
            vm.player.pause()
        }
        .sheet(isPresented: $openSafari) {
            if let url = URL(string: vm.itemObj?.outbondUrl?.getValidUrl() ?? "") {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func format(_ seconds: Double) -> String {
        let total = Int(seconds)
        let mins = total / 60
        let secs = total % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

/*struct VideoPreviewView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: VideoPlayerViewModel
  
    init(videoURL: URL) {
        _vm = StateObject(wrappedValue: VideoPlayerViewModel(url: videoURL))
    }
    
    var body: some View {
        ZStack {
            
            // MARK: Video Background
            VideoPlayer(player: vm.player)
                .ignoresSafeArea()
            
            VStack {
                
                // MARK: Top Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .semibold))
                            .padding(12)
                            .contentShape(Rectangle())
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // MARK: Play Pause Center Button
                Button {
                    vm.togglePlayPause()
                } label: {
                    Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                        .padding(26)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // MARK: Bottom Controls
                VStack(spacing: 8) {
                    
                    HStack {
                        Text(formatTime(vm.currentTime))
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Slider(
                            value: $vm.currentTime,
                            in: 0...vm.duration,
                            onEditingChanged: { editing in
                                if !editing {
                                    vm.seek(to: vm.currentTime)
                                }
                            }
                        )
                        .tint(.white)
                        
                        Text(formatTime(vm.duration))
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 110)
            }
            
            // MARK: Bottom CTA Card
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    
                    Text("Prada SS24 Single-breasted wool coat Prada SS24 Single-breasted wool coat Prada SS24 Single-breasted wool coat")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        print("Visit site tapped")
                    } label: {
                        Text("Visit site")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(14)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                )
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .onDisappear {
            vm.player.pause()
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let sec = Int(seconds)
        return String(format: "00.%02d", sec)
    }
}
*/
//#Preview {
//    VideoPreviewView(videoURL: URL(string:"https://d3se71s7pdncey.cloudfront.net/getkart/v1/item_images/2026/03/69a55a73ba7271.795803081772444275.mp4")!, item: ItemModel())
//}



final class PremiumVideoVM: ObservableObject {
    
    @Published var isPlaying = true
    @Published var isMuted = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var showControls = true
    
    let player: AVPlayer
    private var timeObserver: Any?
    private var hideWorkItem: DispatchWorkItem?
    @Published var itemObj:ItemModel?
    
    init(url: URL,item:ItemModel) {
        player = AVPlayer(url: url)
        itemObj = item
        setup()
    }
    
    private func setup() {
        player.play()
        player.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loopVideo),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        duration = player.currentItem?.asset.duration.seconds ?? 1
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
            [weak self] time in
            self?.currentTime = time.seconds
        }
        
        startAutoHideTimer()
    }
    
    @objc private func loopVideo() {
        player.seek(to: .zero)
        player.play()
    }
    
    func togglePlay() {
        isPlaying.toggle()
        isPlaying ? player.play() : player.pause()
        showTemporarily()
    }
    
    func toggleMute() {
        isMuted.toggle()
        player.isMuted = isMuted
        showTemporarily()
    }
    
    func seek(by seconds: Double) {
        let newTime = max(0, min(currentTime + seconds, duration))
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
        showTemporarily()
    }
    
    func seek(to value: Double) {
        player.seek(to: CMTime(seconds: value, preferredTimescale: 600))
    }
    
    func toggleControls() {
        withAnimation {
            showControls.toggle()
        }
        if showControls {
            startAutoHideTimer()
        }
    }
    
    private func showTemporarily() {
        withAnimation {
            showControls = true
        }
        startAutoHideTimer()
    }
    
    private func startAutoHideTimer() {
        hideWorkItem?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            withAnimation {
                self?.showControls = false
            }
        }
        
        hideWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: task)
    }
    
    deinit {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }
}
