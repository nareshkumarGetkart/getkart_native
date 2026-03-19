//
//  VideoPreviewView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 02/03/26.
//


import SwiftUI
import AVKit


import SwiftUI
import AVKit

struct VideoPreviewView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: PremiumVideoVM
    @State private var openSafari = false

    init(item: ItemModel?, strURl: String?) {
        _vm = StateObject(
            wrappedValue: PremiumVideoVM(
                url: URL(string: strURl?.getValidUrl() ?? "")!,
                item: item
            )
        )
    }

    var body: some View {

        ZStack {

            PlayerLayerView(player: vm.player)
                .ignoresSafeArea()
                .onTapGesture {
                    vm.toggleControls()
                }

            // Double tap seek
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

                    // Top bar
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

                    // Play pause
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

                    // Slider
                    VStack {

                        HStack {

                            Text(format(vm.sliderValue))
                                .foregroundColor(.white)
                                .font(.caption)

                            Slider(
                                value: $vm.sliderValue,
                                in: 0...vm.duration,
                                onEditingChanged: { editing in
                                    vm.sliderEditingChanged(editing)
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

                    // CTA Card
                    if vm.itemObj != nil {

                        VStack(spacing: 5) {

                            Text(vm.itemObj?.name ?? "")
                                .font(.headline)
                                .multilineTextAlignment(.center)

                            Button {

                                openSafari = true
                                vm.player.pause()
                                outboundClickApi(boardId: vm.itemObj?.id ?? 0)
                            } label: {

                                Text(vm.itemObj?.ctaLabel ?? "")
                                    .foregroundColor(.white)
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
                        .padding(.horizontal, 5)
                        .padding(.bottom, 10)

                    } else {

                        Button {

                            vm.player.pause()
                            dismiss()

                        } label: {

                            Text("Done")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 5)
                        .padding(.bottom, 10)
                    }
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
}



final class PremiumVideoVM: ObservableObject {

    @Published var isPlaying = true
    @Published var isMuted = false
    @Published var showControls = true

    @Published var sliderValue: Double = 0
    @Published var duration: Double = 1

    let player: AVPlayer

    private var timeObserver: Any?
    private var hideWorkItem: DispatchWorkItem?
    private var isDragging = false

    @Published var itemObj: ItemModel?

    init(url: URL, item: ItemModel?) {

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

        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in

            guard let self else { return }

            if !self.isDragging {
                let seconds = time.seconds
                self.sliderValue = seconds
            }
        }

        startAutoHideTimer()
    }

    @objc private func loopVideo() {

        player.seek(to: .zero)
        player.play()
    }

    // MARK: Controls

    func togglePlay() {

        isPlaying.toggle()

        isPlaying ? player.play() : player.pause()

        userDidInteract()
    }

    func toggleMute() {

        isMuted.toggle()
        player.isMuted = isMuted

        userDidInteract()
    }

    func toggleControls() {

        withAnimation {
            showControls.toggle()
        }

        if showControls {
            startAutoHideTimer()
        }
    }

    func seek(by seconds: Double) {

        let newTime = max(0, min(sliderValue + seconds, duration))

        player.seek(
            to: CMTime(seconds: newTime, preferredTimescale: 600),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )

        sliderValue = newTime

        userDidInteract()
    }

    // MARK: Slider

    func sliderEditingChanged(_ editing: Bool) {

        isDragging = editing

        if editing {

            cancelAutoHide()

        } else {

            let time = CMTime(seconds: sliderValue, preferredTimescale: 600)

            player.seek(
                to: time,
                toleranceBefore: .zero,
                toleranceAfter: .zero
            )

            startAutoHideTimer()
        }
    }

    // MARK: Interaction

    private func userDidInteract() {

        withAnimation {
            showControls = true
        }

        startAutoHideTimer()
    }

    // MARK: Auto Hide

    private func startAutoHideTimer() {

        cancelAutoHide()

        let task = DispatchWorkItem { [weak self] in

            withAnimation {
                self?.showControls = false
            }
        }

        hideWorkItem = task

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3,
            execute: task
        )
    }

    private func cancelAutoHide() {
        hideWorkItem?.cancel()
    }

    deinit {

        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }

        NotificationCenter.default.removeObserver(self)
    }
}
